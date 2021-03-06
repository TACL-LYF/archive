ActiveAdmin.register Registration do
  menu priority: 2

  belongs_to :camp, optional: true

  includes :camper, :camp

  scope :all
  scope :active, default: true
  scope :cancelled
  scope :waitlist

  permit_params :camp_id, :grade, :shirt_size, :bus, :additional_notes,
    :preregistration, :jtasa_chapter, :status, :group, :camper_id,
    :additional_shirts, :camper_involvement, :registration_payment_id,
    :camp_preference, :covid_vaccinated, :internal_notes

  member_action :cancel, method: :put do
    resource.update_attributes!(status: :cancelled, admin_skip_validations: true)
    redirect_to resource_path, notice: "This registration has been cancelled."
  end

  action_item :cancel, only: :show, if: proc{ !registration.cancelled? } do
    link_to 'Cancel Registration',
      cancel_admin_registration_path(registration),
      method: :put
  end

  controller do
    def scoped_collection
      super.includes :camper, camper: :family
    end
  end

  index do
    selectable_column
    column "Registered", :created_at, sortable: :created_at
    # column(:group) { |r| best_in_place r, :group, as: :select, url: [:admin,r],
    #   collection: Registration.groups.keys.map{|group| [group,group] } }
    column :camper, sortable: 'campers.first_name'
    column "Parent", :family, sortable: :primary_parent
    column :grade
    column :gender
    column :shirt_size, :pretty_shirt_size
    column "Additional Shirts", :list_additional_shirts
    column :covid_vaccinated
    column "Medical", :medical_conditions_and_medication
    column "Diet/Allergies", :diet_and_food_allergies
    column "Notes", :additional_notes, sortable: false
    tag_column :status
    column :internal_notes
    actions dropdown: true
  end

  filter :camp
  filter :camper, as: :select, collection: Camper.all
  filter :created_at, label: "Registered"
  filter :status, as: :select, multiple: true, collection: Registration.statuses
  filter :preregistration
  filter :grade, as: :numeric_range_filter
  filter :shirt_size, as: :select, multiple: true, collection: Registration.shirt_sizes
  filter :bus

  show do
    columns do
      column do
        attributes_table do
          tag_row :status
          row :camper
          row :preregistration
          row :covid_vaccinated
          row :camp_preference
          row :grade
          row :shirt_size
          row('Additional Shirts') {|r| r.list_additional_shirts}
          row :bus
          row :jtasa_chapter
          row('Camper Involvement') {|r| r.list_camper_involvement}
          row :additional_notes
          row :registration_payment
        end
      end
      column do
        attributes_table do
          row :group
          row :camp_family
          row :cabin
          row :internal_notes
        end
      end
    end
    render 'admin/timestamps', context: self
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    columns do
      column do
        inputs do
          input :status
          input :camp
          input :camper
          input :preregistration
          input :covid_vaccinated
          input :camp_preference
          input :grade
          input :shirt_size
          input :additional_shirts, as: :text, input_html: { rows: 1 }
          input :bus
          input :jtasa_chapter
          input :camper_involvement, as: :text, input_html: { rows: 1 }
          input :additional_notes, input_html: { rows: 5 }
          input :registration_payment
        end
      end
      column do
        inputs do
          input :group
          input :camp_family
          input :cabin
          input :internal_notes
        end
      end
    end
    actions
  end

  xls(header_format: { weight: :bold}) do
    whitelist
    column('Registered') {|r| r.created_at.to_s}
    column :first_name
    column :last_name
    column :camper_email
    column('Parent') {|r| r.camper.family.primary_parent}
    column('Parent Email') {|r| r.camper.family.primary_parent_email}
    column('Parent Phone') {|r| r.camper.family.primary_parent_phone_number}
    column('Secondary Parent') {|r| r.camper.family.secondary_parent}
    column('Secondary Parent Email') {|r| r.camper.family.secondary_parent_email}
    column('Secondary Parent Phone') {|r| r.camper.family.secondary_parent_phone_number}
    column :gender
    column :grade
    column :group
    column :shirt_size
    column('Additional Shirts') {|r| r.list_additional_shirts}
    column :covid_vaccinated
    column :camp_preference
    column :medical_conditions_and_medication
    column :diet_and_food_allergies
    column :additional_notes
  end

  before_save do |reg|
    reg.admin_skip_validations = true
    reg.camper_involvement = eval(reg.camper_involvement)
    reg.additional_shirts = eval(reg.additional_shirts)
  end

end

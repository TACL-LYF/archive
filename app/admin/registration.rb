ActiveAdmin.register Registration do
  menu priority: 2

  belongs_to :camp, optional: true

  scope :all
  scope :active, default: true
  scope :cancelled
  scope :waitlist

  permit_params :camp_id, :grade, :shirt_size, :bus, :additional_notes,
    :preregistration, :jtasa_chapter, :status, :group, :camper_id,
    :additional_shirts

  member_action :cancel, method: :put do
    resource.update_attributes! status: :cancelled
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
    column(:group) { |r| best_in_place r, :group, as: :select, url: [:admin,r],
      collection: Registration.groups.keys.map{|group| [group,group] } }
    column :camper, sortable: 'campers.first_name'
    column "Parent", :family, sortable: :primary_parent
    column :grade
    column :gender
    column :shirt_size do |r|
      r.pretty_shirt_size
    end
    list_column :additional_shirts, sortable: false
    column :bus, sortable: false
    column :jtasa_chapter
    column "Medical", :medical_conditions_and_medication
    column "Diet/Allergies", :diet_and_food_allergies
    column "Notes", :additional_notes, sortable: false
    tag_column :status
    actions dropdown: true
  end

  filter :camp
  filter :camper, as: :select, collection: Camper.all
  filter :created_at, label: "Registered"
  filter :status, as: :select, multiple: true, collection: Registration.statuses
  filter :preregistration
  filter :grade, as: :range_select
  filter :shirt_size, as: :select, multiple: true, collection: Registration.shirt_sizes
  filter :bus

  show title: proc {|r| "#{r.camper.full_name} - #{r.camp.year} Registration"} do
    columns do
      column do
        attributes_table do
          tag_row :status
          row :camper
          row :preregistration
          row :grade
          row :shirt_size
          list_row :additional_shirts
          row :bus
          row :jtasa_chapter
          list_row :camper_involvement
          row :additional_notes
          row :registration_payment
        end
      end
      column do
        attributes_table do
          row :group
          row :cabin
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
          input :grade
          input :shirt_size
          input :additional_shirts, input_html: { rows: 1 }
          input :bus
          input :jtasa_chapter
          input :camper_involvement, input_html: { rows: 1 }
          input :additional_notes, input_html: { rows: 5 }
          input :waiver_signature
          input :waiver_date, as: :datepicker,
            datepicker_options: {
              min_date: 1.year.ago.to_date,
              max_date: 1.year.from_now.to_date
            }
        end
      end
      column do
        inputs do
          input :group
          input :camp_family
          input :cabin
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
    column('Parent') {|r| r.camper.family.primary_parent}
    column('Parent Email') {|r| r.camper.family.primary_parent_email}
    column('Parent Phone') {|r| r.camper.family.primary_parent_phone_number}
    column :gender
    column :grade
    column :group
    column :shirt_size
    column('Additional Shirts') {|r| r.list_additional_shirts}
    column :medical_conditions_and_medication
    column :diet_and_food_allergies
    column :additional_notes
    column :jtasa_chapter
    column(:camper_involvement) {|r| r.list_camper_involvement}
  end

end

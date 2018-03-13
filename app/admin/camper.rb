ActiveAdmin.register Camper do
  includes :registrations
  config.sort_order = 'first_name_asc'
  menu priority: 4

  belongs_to :family, optional: true

  scope :all
  scope :active, default: true
  scope :graduated

  permit_params :first_name, :last_name, :birthdate, :gender, :email,
    :medical_conditions_and_medication, :diet_and_food_allergies, :status,
    :returning, :family_id,
    registrations_attributes: [:id, :camp_id, :grade, :shirt_size, :bus,
    :additional_notes, :preregistration, :jtasa_chapter, :status,
    :waiver_signature, :waiver_date]

  member_action :preregister, method: :post do
    old_reg = resource.registrations.includes(:camp).order('camps.year desc').first
    new_camp = Camp.first
    new_registration = Registration.create(
      camper: resource,
      camp: new_camp,
      status: 'active',
      preregistration: true,
      grade: old_reg.grade+1,
      shirt_size: old_reg.shirt_size,
      additional_shirts: old_reg.additional_shirts,
      bus: old_reg.bus,
      jtasa_chapter: old_reg.jtasa_chapter,
      camper_involvement: old_reg.camper_involvement,
      additional_notes: old_reg.additional_notes)
    redirect_to edit_admin_registration_path(new_registration),
      notice: "#{resource.full_name} is now preregistered for #{new_camp.year}. Edit registration details below and save."
  end

  action_item :preregister, only: :show, if: proc{
      resource.registrations.where(camp: Camp.first).count == 0
    } do
    link_to 'Preregister', preregister_admin_camper_path(camper), method: :post
  end

  index do
    selectable_column
    column :first_name
    column :last_name
    column :birthdate
    column :gender
    column :email
    column :family
    column "Registrations" do |c|
      c.registrations.map{|r| link_to r.camp.year, admin_registration_path(r)}
        .join(", ").chomp(", ").html_safe
    end
    tag_column :status
    actions
  end

  filter :first_name_or_last_name_cont, as: :string, label: "Camper Name"
  filter :email_contains, label: "Camper Email"
  filter :birthdate
  filter :gender, as: :select, collection: Camper.genders
  filter :returning
  filter :medical_conditions_and_medication_contains
  filter :diet_and_food_allergies_contains

  show do
    columns do
      column do
        attributes_table do
          row :family
          row :first_name
          row :last_name
          row :birthdate
          row :gender
          row :email
          row :status
          row :returning
        end
      end
      column do
        attributes_table title: "Medical & Diet" do
          row :medical_conditions_and_medication
          row :diet_and_food_allergies
        end
      end
    end

    panel "Registrations" do
      table_for camper.registrations do
        column :camp
        column :grade
        column :shirt_size
        column :bus
        column :preregistration
        column "View" do |r|
          link_to "View Registration", admin_registration_path(r)
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
          input :family
          input :first_name
          input :last_name
          input :birthdate, as: :datepicker,
            datepicker_options: {
              min_date: 18.years.ago.to_date,
              max_date: 8.years.ago.to_date
            }
          input :gender
          input :email
          input :status
          input :returning
        end
      end
      column do
        inputs do
          input :medical_conditions_and_medication, input_html: { rows: 10 }
          input :diet_and_food_allergies, input_html: { rows: 10 }
        end
      end
    end
    f.has_many :registrations, heading: "Registrations",
               new_record: "Add Registration",
               allow_destroy: false do |r|
      r.input :camp
      r.input :status
      r.input :grade
      r.input :shirt_size
      r.input :bus
      r.input :additional_notes, input_html: { rows: 5 }
      r.input :preregistration
      r.input :jtasa_chapter
      r.input :waiver_signature
      r.input :waiver_date, as: :datepicker,
        datepicker_options: {
          min_date: 1.year.ago.to_date,
          max_date: 1.year.from_now.to_date
        }
    end
    actions
  end

end

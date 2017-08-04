ActiveAdmin.register Registration do
  menu priority: 2

  belongs_to :camp, optional: true

  scope :all, default: true
  scope :active
  scope :cancelled
  scope :waitlist

  permit_params :camp_id, :grade, :shirt_size, :bus, :additional_notes,
    :preregistration, :jtasa_chapter, :status

  controller do
    def scoped_collection
      super.includes :camper
    end
  end

  index do
    selectable_column
    column "Registered", :created_at, sortable: :created_at
    column :camper, sortable: 'campers.first_name'
    column "Parent", :family, sortable: :primary_parent
    column :grade
    column :gender
    column :bus, sortable: false
    column :shirt_size do |r|
      r.pretty_shirt_size
    end
    list_column :additional_shirts, sortable: false
    column "Medical", :medical_conditions_and_medication
    column "Diet/Allergies", :diet_and_food_allergies
    column "Notes", :additional_notes, sortable: false
    tag_column :status
    actions dropdown: true
  end

  filter :camp
  filter :created_at, label: "Registered"
  filter :status, as: :select, multiple: true, collection: Registration.statuses
  filter :preregistration
  filter :grade, as: :range_select
  filter :bus
  filter :shirt_size, as: :select, multiple: true, collection: Registration.shirt_sizes

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

end

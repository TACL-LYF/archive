ActiveAdmin.register Family do
  menu priority: 3
  includes :campers, :referrals
  config.sort_order = 'primary_parent_first_name_asc'

  permit_params :primary_parent_first_name, :primary_parent_last_name,
    :primary_parent_email, :primary_parent_phone_number,
    :secondary_parent_first_name, :secondary_parent_last_name,
    :secondary_parent_email, :secondary_parent_phone_number, :street, :suite,
    :city, :state, :zip,
    campers_attributes: [:id, :first_name, :last_name, :birthdate, :gender, :email,
    :medical_conditions_and_medication, :diet_and_food_allergies, :status,
    :returning, :_destroy],
    referrals_attributes: [:id, :referral_method_id, :details, :_destroy]

  index do
    selectable_column
    column "Parent First Name", sortable: :primary_parent_first_name do |f|
      link_to f.primary_parent_first_name, admin_family_path(f)
    end
    column "Last Name", sortable: :primary_parent_last_name do |f|
      link_to f.primary_parent_last_name, admin_family_path(f)
    end
    column "Email", :primary_parent_email, sortable: :primary_parent_email
    column "Phone", :primary_parent_phone_number
    column :city
    column "Campers" do |f|
      f.campers.map{ |c| link_to c.full_name, admin_camper_path(c) }.join(", ")
        .chomp(", ").html_safe
    end
    actions
  end

  filter :primary_parent_first_name_or_primary_parent_last_name_cont,
    as: :string, label: "Primary Parent Name"
  filter :primary_parent_email_contains, label: "Primary Parent Email"
  filter :street_contains, label: "Address"
  filter :city_contains, label: "City"

  show title: proc{|f| "#{f.primary_parent_first_name} #{f.primary_parent_last_name}"} do
    columns do
      column do
        attributes_table title: "Primary Parent Information" do
          row("First Name") {|f| f.primary_parent_first_name }
          row("Last Name") {|f| f.primary_parent_last_name }
          row("Email") {|f| f.primary_parent_email }
          row("Phone Number") {|f| f.primary_parent_phone_number }
        end
      end

      column do
        attributes_table title: "Secondary Parent Information" do
          row("First Name") {|f| f.secondary_parent_first_name }
          row("Last Name") {|f| f.secondary_parent_last_name }
          row("Email") {|f| f.secondary_parent_email }
          row("Phone Number") {|f| f.secondary_parent_phone_number }
        end
      end

      column do
        attributes_table title: "Address" do
          row :street
          row :suite
          row :city
          row :state
          row :zip
        end
      end
    end

    columns do
      column span: 2 do
        panel "Campers" do
          table_for family.campers do
            column("Name") {|c| link_to c.full_name, admin_camper_path(c) }
            column :birthdate
            column :gender
            column "Registrations" do |c|
              c.registrations.map{ |r|
                link_to r.camp.year, admin_registration_path(r), class: "reg_#{r.status}"
              }.join(", ").chomp(", ").html_safe
            end
            column :status
          end
        end
      end
      column do
        panel "Referrals" do
          table_for family.referrals do
            column :referral_method
            column :details
          end
        end
      end
    end

    render 'admin/timestamps', context: self
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    columns do
      column do
        f.inputs "Primary Parent Information" do
          f.input :primary_parent_first_name, label: "First Name"
          f.input :primary_parent_last_name, label: "Last Name"
          f.input :primary_parent_email, label: "Email"
          f.input :primary_parent_phone_number, label: "Phone Number"
        end
      end
      column do
        f.inputs "Secondary Parent Information" do
          f.input :secondary_parent_first_name, label: "First Name"
          f.input :secondary_parent_last_name, label: "Last Name"
          f.input :secondary_parent_email, label: "Email"
          f.input :secondary_parent_phone_number, label: "Phone Number"
        end
      end
      column do
        f.inputs "Address", :street, :suite, :city, :state, :zip
      end
    end
    f.has_many :referrals, heading: "Referrals",
               new_record: "Add Referral",
               allow_destroy: true do |r|
      r.input :referral_method
      r.input :details
    end
    f.has_many :campers, heading: "Campers",
               new_record: "Add A Camper",
               allow_destroy: true do |c|
      c.input :first_name
      c.input :last_name
      c.input :birthdate, as: :datepicker,
        datepicker_options: {
          min_date: 18.years.ago.to_date,
          max_date: 8.years.ago.to_date
        }
      c.input :gender
      c.input :email
      c.input :status
      c.input :returning
      c.input :medical_conditions_and_medication, input_html: { rows: 5 }
      c.input :diet_and_food_allergies, input_html: { rows: 5 }
    end
    actions
  end

end

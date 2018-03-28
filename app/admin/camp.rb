ActiveAdmin.register Camp do
  menu priority: 1

  config.sort_order = 'year_desc'

  permit_params :name, :year, :registration_fee, :shirt_price, :sibling_discount,
    :registration_late_fee, :registration_open_date, :registration_late_date,
    :registration_close_date, :camp_start_date, :camp_end_date, :campsite,
    :campsite_address

  index do
    selectable_column
    column :year
    column :name do |camp|
      link_to camp.name, admin_camp_path(camp)
    end
    column "Registrations" do |camp|
      link_to pluralize(camp.registrations.active.count, 'registration'), admin_camp_registrations_path(camp)
    end
    actions
  end

  filter :name_contains, label: "Name"
  filter :registration_fee, as: :range_select
  filter :registration_late_fee, as: :range_select
  filter :shirt_price, as: :range_select
  filter :sibling_discount, as: :range_select

  show do
    @summary = resource.get_summary
    columns do
      column do
        attributes_table title: "Registration Details" do
          row :registration_open_date
          row :registration_late_date
          row :registration_close_date
          number_row :registration_fee, as: :currency
          number_row :registration_late_fee, as: :currency
          number_row :shirt_price, as: :currency
          number_row :sibling_discount, as: :currency
        end
      end
      column do
        attributes_table title: "Registration Totals" do
          row("Active") { @summary[:active] }
          row("Waitlist") { @summary[:waitlist] }
          row("Cancelled") { @summary[:cancelled] }
          text_node link_to "View All Registrations", admin_camp_registrations_path(resource)
        end
        attributes_table title: "Gender Breakdown" do
          @summary[:gender_breakdown].each do |g, n|
            row(g) { n }
          end
        end
      end
      column do
        attributes_table title: "Grade Breakdown" do
          @summary[:grade_breakdown].each do |gr, n|
            row(gr.ordinalize) { n }
          end
        end
      end
      column do
        attributes_table title: "Shirt Totals" do
          @summary[:shirt_totals].each do |s, n|
            row(s) { n }
          end
        end
        panel "Bus Total" do
          @summary[:bus_total]
        end
      end
    end

    attributes_table title: "Camp Details" do
      row :camp_start_date
      row :camp_end_date
      row :campsite
      row :campsite_address
    end

    render 'admin/timestamps', context: self
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Details', :year, :name, :camp_start_date, :camp_end_date, :campsite,
      :campsite_address
    columns do
      column do
        inputs 'Registration Dates' do
          input :registration_open_date, as: :datepicker
          input :registration_late_date, as: :datepicker
          input :registration_close_date, as: :datepicker
        end
      end
      column do
        inputs 'Registration Fees', :registration_fee, :registration_late_fee,
          :shirt_price, :sibling_discount
      end
    end
    actions
  end

end

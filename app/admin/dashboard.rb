ActiveAdmin.register_page "Dashboard" do

  menu priority: 0, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    @camp = Camp.first
    @summary = @camp.get_summary
    columns do
      column do
        panel "LYF Camp #{@camp.year}: #{@camp.name}" do
          attributes_table_for @camp do
            row :registration_open_date
            row :registration_late_date
            row :registration_close_date
            number_row :registration_fee, as: :currency
            number_row :registration_late_fee, as: :currency
            number_row :shirt_price, as: :currency
            number_row :sibling_discount, as: :currency
          end
        end
      end
      column do
        panel "Registrations" do
          attributes_table_for @camp do
            row("Active") { @summary[:active] }
            row("Waitlist") { @summary[:waitlist] }
            row("Cancelled") { @summary[:cancelled] }
            text_node link_to "View All Registrations", admin_camp_registrations_path(@camp)
          end
        end
      end
      column do
        panel "Gender Breakdown" do
          attributes_table_for @camp do
            @summary[:gender_breakdown].each do |g, n|
              row(g) { n }
            end
          end
        end
      end
      column do
        panel "Grade Breakdown" do
          attributes_table_for @camp do
            @summary[:grade_breakdown].each do |gr, n|
              row(gr.ordinalize) { n }
            end
          end
        end
      end
    end
  end # content
end

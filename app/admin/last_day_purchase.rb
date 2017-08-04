ActiveAdmin.register LastDayPurchase do
  menu priority: 7

  # no creating or editing
  actions :index, :show

  index do
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone, sortable: false
    number_column :amount, as: :currency
    column :camper_names
    column :dollar_for_dollar, sortable: false
    column :company
    column "Stripe Charge", sortable: false do |ldp|
      link_to "Open in Stripe",
        CreditCardService.get_link(ldp.stripe_charge_id),
        target: '_blank'
    end
  end

  filter :first_name_or_last_name_cont, as: :string, label: "Name"
  filter :camper_names_contains, as: :string, label: "Camper Name(s)"
  filter :amount, as: :range_select
  filter :dollar_for_dollar, as: :select
  filter :company_contains, label: "Company Name"

  show title: proc {|ldp| "##{ldp.id} - #{ldp.email}"} do
    columns do
      column do
        attributes_table title: "Payer Details" do
          row :first_name
          row :last_name
          row :email
          row :phone
          row :address
          row :city
          row :state
          row :zip
          row :camper_names
        end
      end
      column do
        attributes_table title: "Payment Details" do
          number_row :amount, as: :currency
          row :dollar_for_dollar
          row :company
          row "Stripe Charge" do |d|
            link_to "Open in Stripe",
              CreditCardService.get_link(d.stripe_charge_id),
              target: '_blank'
          end
          row :stripe_brand
          row :stripe_last_four
        end
      end
    end
  end

end

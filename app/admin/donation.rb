ActiveAdmin.register Donation do
  menu priority: 6

  # no creating or editing
  actions :index, :show

  index do
    column "Timestamp", sortable: :created_at do |d|
      link_to d.created_at.to_s(:db), admin_donation_path(d)
    end
    column :first_name
    column :last_name
    column :email
    column :phone, sortable: false
    number_column :amount, as: :currency
    column :company_match, sortable: false
    column :company, sortable: false
    column "Stripe Charge", sortable: false do |d|
      link_to "Open in Stripe",
        CreditCardService.get_link(d.stripe_charge_id),
        target: '_blank'
    end
  end

  filter :first_name_or_last_name_cont, as: :string, label: "Donor Name"
  filter :amount, as: :numeric_range_filter
  filter :company_match, as: :select
  filter :company_contains, label: "Company Name"

  show title: proc {|d| "##{d.id} - #{d.email}"} do
    columns do
      column do
        attributes_table title: "Donor Details" do
          row :first_name
          row :last_name
          row :email
          row :phone
          row :address
          row :city
          row :state
          row :zip
        end
      end
      column do
        attributes_table title: "Donation Details" do
          number_row :amount, as: :currency
          row :company_match
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
    render 'admin/timestamps', context: self
  end

end

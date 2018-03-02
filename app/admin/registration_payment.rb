ActiveAdmin.register RegistrationPayment do
  menu parent: 'Registrations'

  # no creating or editing
  actions :index, :show

  # send confirmation email action
  member_action :resend_confirmation, method: :get do
    RegistrationPaymentMailer.registration_confirmation(resource).deliver_now
    redirect_to admin_registration_payment_path(resource),
      notice: "Confirmation email has been resent."
  end

  action_item :resend_confirmation, only: :show do
    link_to 'Resend Confirmation',
      resend_confirmation_admin_registration_payment_path(resource), method: :get
  end

  index do
    selectable_column
    column "Timestamp", :created_at, sortable: :created_at
    column "Registrations" do |rp|
      rp.registrations.map{ |r| link_to "#{r.camper.full_name} (#{r.camp.year})",
        admin_registration_path(r) }
      .join(", ").chomp(", ").html_safe
    end
    number_column :additional_donation, as: :currency
    column :discount_code
    number_column :total, as: :currency
    column "Stripe Charge" do |rp|
      link_to "Open in Stripe",
        CreditCardService.get_link(rp.stripe_charge_id),
        target: '_blank'
    end
    column :stripe_brand
    actions
  end

  filter :total, as: :range_select
  filter :additional_donation, as: :range_select
  filter :stripe_brand_contains

  show do
    columns do
      column span: 2 do
        panel "Registrations" do
          table_for registration_payment.registrations do |r|
            column("Year") { |reg| reg.camp.year }
            column :camper
            list_column :additional_shirts
          end
        end
      end
      column do
        attributes_table title: "Totals" do
          number_row :additional_donation, as: :currency
          number_row :discount_code, as: :currency
          number_row :total, as: :currency
        end
      end
      column do
        attributes_table title: "Payment Details" do
          row :stripe_brand
          row :stripe_last_four
          row :stripe_charge_id do |rp|
            link_to "Open in Stripe",
              CreditCardService.get_link(rp.stripe_charge_id),
              target: '_blank'
          end
        end
      end
    end
    render 'admin/timestamps', context: self
  end

end

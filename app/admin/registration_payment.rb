ActiveAdmin.register RegistrationPayment do
  menu parent: 'Registrations'

  includes :registrations

  permit_params :paid, :additional_donation, :payment_type, :check_number,
    registration_ids: []

  # send confirmation email action
  member_action :resend_confirmation, method: :get do
    RegistrationPaymentMailer.registration_confirmation(resource).deliver_now
    redirect_to admin_registration_payment_path(resource),
      notice: "Confirmation email has been resent."
  end

  member_action :send_prereg_confirmation, method: :get do
    RegistrationPaymentMailer.prereg_confirmation(resource).deliver_now
    redirect_to admin_registration_payment_path(resource),
      notice: "Prereg Confirmation email has been sent."
  end

  action_item :resend_confirmation, only: :show do
    link_to 'Resend Confirmation',
      resend_confirmation_admin_registration_payment_path(resource), method: :get
  end

  action_item :send_prereg_confirmation, only: :show do
    link_to 'Send Prereg Confirmation',
      send_prereg_confirmation_admin_registration_payment_path(resource),
      method: :get
  end

  index do
    selectable_column
    column "Timestamp", :created_at, sortable: :created_at
    column "Registrations" do |rp|
      rp.registrations.map{ |r| link_to r.display_name,
        admin_registration_path(r) }.join(", ").chomp(", ").html_safe
    end
    number_column :additional_donation, as: :currency
    column :discount_code
    number_column :total, as: :currency
    column :paid
    column :payment_type
    column :check_number
    column "Stripe Charge" do |rp|
      if rp.stripe_charge_id
        link_to "Open in Stripe",
          CreditCardService.get_link(rp.stripe_charge_id), target: '_blank'
      end
    end
    column :stripe_brand
    column :stripe_last_four
    actions
  end

  filter :total, as: :numeric_range_filter
  filter :additional_donation, as: :numeric_range_filter
  filter :stripe_brand_contains

  show do
    columns do
      column span: 2 do
        panel "Registrations" do
          table_for registration_payment.registrations do |r|
            column("Year") { |reg| reg.camp.year }
            column :camper
            column("Additional Shirts") {|reg| reg.list_additional_shirts}
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
          row :paid
          row :payment_type
          row :check_number
          row :stripe_charge_id do |rp|
            if rp.stripe_charge_id
              link_to "Open in Stripe",
                CreditCardService.get_link(rp.stripe_charge_id), target: '_blank'
            end
          end
          row :stripe_brand
          row :stripe_last_four
          row("Payment Token") do |rp|
            if rp.payment_token
              link_to rp.payment_token,
                registration_payment_path(rp.payment_token), target: '_blank'
            end
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
        inputs do
          input :registrations, as: :select, multiple: true,
            collection: Registration.includes(:camper, :camp)
          input :additional_donation
        end
      end
      column do
        inputs do
          input :paid
          input :payment_type
          input :check_number
        end
      end
    end
    actions
  end

  before_create do |rp|
    rp.set_total
    rp.registrations.each do |r|
      r.admin_skip_validations = true
    end
  end

end

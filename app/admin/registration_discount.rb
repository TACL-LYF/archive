ActiveAdmin.register RegistrationDiscount do
  menu parent: 'Registrations'

  belongs_to :camp, optional: true
  belongs_to :registration_payment, optional: true

  permit_params :camp_id, :code, :discount_type, :discount_amount, :description,
    :registration_payment_id

  index do
    selectable_column
    column :camp
    column :code
    column :description
    column :discount_type
    column :discount_amount
    column :redeemed
    column :registration_payment
    actions
  end

  filter :camp
  filter :discount_type
  filter :discount_amount, as: :numeric_range_filter
  filter :redeemed

  show title: :code do |f|
    attributes_table do
      row :camp
      row :code
      row :discount_type
      row :discount_amount
      row :description
      row :redeemed
      row :registration_payment
    end
    render 'admin/timestamps', context: self
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs :camp, :code, :discount_type, :discount_amount, :description,
      :registration_payment
    actions
  end

end

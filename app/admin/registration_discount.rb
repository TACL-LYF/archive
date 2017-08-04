ActiveAdmin.register RegistrationDiscount do
  menu parent: 'Registrations'

  belongs_to :camp, optional: true

  index do
    selectable_column
    column :camp
    column :code
    column :discount_percent
    column :redeemed
    column :registration_payment
    actions
  end

  filter :camp
  filter :discount_percent, as: :range_select
  filter :redeemed

  show title: :code do |f|
    attributes_table do
      row :camp
      row :code
      row :discount_percent
      row :redeemed
      row :registration_payment
    end
    render 'admin/timestamps', context: self
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs :camp, :code, :discount_percent
    actions
  end

end

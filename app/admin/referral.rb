ActiveAdmin.register Referral do
  menu parent: 'Referral Methods'

  permit_params :referral_method_id, :family_id, :details

  index do
    selectable_column
    column :family
    column :referral_method
    column :details
    actions
  end

  show do
    attributes_table do
      row :referral_method
      row :family
      row :details
    end
    render 'admin/timestamps', context: self
  end

end

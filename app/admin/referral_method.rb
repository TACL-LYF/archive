ActiveAdmin.register ReferralMethod do
  menu priority: 5
  includes :referrals

  config.sort_order = 'id_asc'

  permit_params :name, :allow_details, :details_field_label

  index do
    selectable_column
    column :name, sortable: :name do |rm|
      link_to rm.name, admin_referral_method_path(rm)
    end
    column("# of Referrals") { |rm| rm.referrals.count }
    actions
  end

  filter :allow_details, as: :check_boxes

  show do
    columns do
      column do
        attributes_table do
          row :name
          row :allow_details
          row :details_field_label
        end
      end
      column span: 2 do
        panel "Referrals" do
          table_for referral_method.referrals do
            column :family
            column :details
          end
        end
      end
    end

    render 'admin/timestamps', context: self
  end

end

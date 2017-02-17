class CreateRegSessionsAndDeleteSessionsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :sessions
    create_table :reg_sessions do |t|
      t.text :data

      t.timestamps
    end
  end
end

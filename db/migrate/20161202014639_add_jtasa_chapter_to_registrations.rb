class AddJtasaChapterToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :jtasa_chapter, :string
  end
end

class CreateBoards < ActiveRecord::Migration[8.1]
  def change
    create_table :boards do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.boolean :is_public, null: false, default: true

      t.timestamps
    end
    add_index :boards, :slug, unique: true
  end
end

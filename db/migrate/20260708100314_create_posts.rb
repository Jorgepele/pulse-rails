class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :board, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.string :status, null: false, default: "open"

      t.timestamps
    end
  end
end

class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :post, null: false, foreign_key: true
      t.string :voter_token, null: false

      t.timestamps
    end
    add_index :votes, [ :post_id, :voter_token ], unique: true
  end
end

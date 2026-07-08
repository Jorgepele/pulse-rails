class ReworkVotesForUsers < ActiveRecord::Migration[8.1]
  # A vote now belongs to a user instead of an anonymous voter_token,
  # matching the Django model (one vote per user per post).
  def up
    execute "DELETE FROM votes"  # old token-based votes have no user; demo data only
    remove_index :votes, column: [ :post_id, :voter_token ]
    remove_column :votes, :voter_token
    add_reference :votes, :user, null: false, foreign_key: true
    add_index :votes, [ :post_id, :user_id ], unique: true
  end

  def down
    remove_index :votes, column: [ :post_id, :user_id ]
    remove_reference :votes, :user
    add_column :votes, :voter_token, :string, null: false
    add_index :votes, [ :post_id, :voter_token ], unique: true
  end
end

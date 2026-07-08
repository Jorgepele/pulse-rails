class AddAuthorToPostsAndComments < ActiveRecord::Migration[8.1]
  def change
    # Nullable like Django's SET_NULL: content survives if the author is gone.
    add_reference :posts, :author, foreign_key: { to_table: :users }
    add_reference :comments, :author, foreign_key: { to_table: :users }
  end
end

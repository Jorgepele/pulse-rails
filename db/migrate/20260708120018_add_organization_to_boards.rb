class AddOrganizationToBoards < ActiveRecord::Migration[8.1]
  # A board now belongs to an organization (multi-tenant), and its slug is
  # unique per organization instead of globally — matching the Django model.
  def up
    # Existing boards have no org; clear demo data in FK-dependency order.
    execute "DELETE FROM comments"
    execute "DELETE FROM votes"
    execute "DELETE FROM posts"
    execute "DELETE FROM boards"
    add_reference :boards, :organization, null: false, foreign_key: true
    remove_index :boards, :slug
    add_index :boards, [ :organization_id, :slug ], unique: true
  end

  def down
    remove_index :boards, [ :organization_id, :slug ]
    remove_reference :boards, :organization
    add_index :boards, :slug, unique: true
  end
end

# frozen_string_literal: true

#
# Adds (or change) some foreign keys to delete in cascade, and fixes some
# invalid data.
#
class ForeignKeyCascading < ActiveRecord::Migration[5.0]
  def up
    remove_foreign_key :blockings, column: :blocked_id

    add_foreign_key :blockings, :users, column: :blocked_id, on_delete: :cascade

    %w[friend_id user_id].each { |col| remove_orphan_friendships(col) }

    add_foreign_key :friendships, :users, column: :friend_id,
                                          on_delete: :cascade
  end

  def down
    remove_foreign_key :friendships, column: :friend_id
    remove_foreign_key :blockings, column: :blocked_id

    add_foreign_key :blockings,
                    :users,
                    column: :blocked_id,
                    on_update: :restrict,
                    on_delete: :restrict
  end

  private

  def remove_orphan_friendships(column)
    execute <<-SQL.squish
      DELETE FROM friendships
      WHERE id IN (
        SELECT f.id
        FROM friendships f
        LEFT OUTER JOIN users u
        ON f.#{column} = u.id
        WHERE u.id IS NULL
      )
    SQL
  end
end

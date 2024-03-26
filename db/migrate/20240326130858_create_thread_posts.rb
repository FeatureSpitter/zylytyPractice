class CreateThreadPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :thread_posts do |t|
      t.string :text
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :category_thread, null: false, foreign_key: true

      t.timestamps
    end
  end
end

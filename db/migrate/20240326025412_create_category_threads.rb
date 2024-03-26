class CreateCategoryThreads < ActiveRecord::Migration[7.0]
  def change
    create_table :category_threads do |t|
      t.string :title, null: false
      t.references :category, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

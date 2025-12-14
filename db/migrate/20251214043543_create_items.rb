class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string  :name, null: false
      t.string  :game, null: false, default: "rs3"
      t.integer :external_id, null: false
      t.text    :description
      t.string  :icon_url
      t.string  :icon_large_url
      t.string  :item_type
      t.boolean :members, null: false, default: false

      t.timestamps
    end

    add_index :items, [:game, :external_id], unique: true
    add_index :items, :name
  end
end

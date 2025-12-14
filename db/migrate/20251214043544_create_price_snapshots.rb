class CreatePriceSnapshots < ActiveRecord::Migration[7.2]
  def change
    create_table :price_snapshots do |t|
      t.references :item, null: false, foreign_key: true
      t.string :series, null: false
      t.datetime :sampled_at, null: false
      t.integer :price, null: false
      t.string :source, null: false, default: "rs3_official"
      t.datetime :ingested_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    add_index :price_snapshots, [:item_id, :series, :sampled_at], unique: true
    add_index :price_snapshots, [:item_id, :sampled_at]
  end
end

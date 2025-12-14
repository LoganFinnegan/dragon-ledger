class PriceSnapshot < ApplicationRecord
  belongs_to :item

  validates :series, :sampled_at, :price, :source, :ingested_at, presence: true
  validates :sampled_at, uniqueness: { scope: %i[item_id series] }
end

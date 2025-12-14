class Item < ApplicationRecord
  validates :name, :game, :external_id, presence: true
  validates :external_id, uniqueness: { scope: :game }

  has_many :price_snapshots, dependent: :destroy
end

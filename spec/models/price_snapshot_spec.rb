require "rails_helper"

RSpec.describe PriceSnapshot, type: :model do
  it "enforces idempotency per item, series, and sampled_at" do
    item = Item.create!(name: "Steadfast boots", game: "rs3", external_id: 21787)

    sampled_at = Time.utc(2025, 6, 8)
    PriceSnapshot.create!(
      item: item,
      series: "daily",
      sampled_at: sampled_at,
      price: 5_203_175,
      source: "rs3_official",
      ingested_at: Time.current
    )

    duplicate = PriceSnapshot.new(
      item: item,
      series: "daily",
      sampled_at: sampled_at,
      price: 5_203_175,
      source: "rs3_official",
      ingested_at: Time.current
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors.full_messages.join).to match(/Sampled at/i)
  end
end

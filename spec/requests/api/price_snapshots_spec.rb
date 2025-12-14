# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::PriceSnapshots", type: :request do
  it "returns snapshots for an item and series" do
    ingested_at = Time.zone.now

    item = Item.create!(name: "Test item", game: "rs3", external_id: 999, members: false)

    PriceSnapshot.create!(item:, series: "daily", sampled_at: Time.zone.parse("2025-12-01"), price: 100, source: "rs3_official", ingested_at: ingested_at)
    PriceSnapshot.create!(item:, series: "daily", sampled_at: Time.zone.parse("2025-12-02"), price: 110, source: "rs3_official", ingested_at: ingested_at)
    PriceSnapshot.create!(item:, series: "average", sampled_at: Time.zone.parse("2025-12-02"), price: 105, source: "rs3_official", ingested_at: ingested_at)

    get "/api/items/#{item.id}/price_snapshots", params: { series: "daily" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)

    expect(body.length).to eq(2)
    expect(body.first["series"]).to eq("daily")
    expect(body.first).to have_key("sampled_at_epoch_ms")
  end

  it "filters by from/to" do
    ingested_at = Time.zone.now

    item = Item.create!(name: "Filter item", game: "rs3", external_id: 1000, members: false)

    PriceSnapshot.create!(item:, series: "daily", sampled_at: Time.zone.parse("2025-12-01"), price: 100, source: "rs3_official", ingested_at: ingested_at)
    PriceSnapshot.create!(item:, series: "daily", sampled_at: Time.zone.parse("2025-12-10"), price: 200, source: "rs3_official", ingested_at: ingested_at)

    get "/api/items/#{item.id}/price_snapshots", params: { series: "daily", from: "2025-12-05" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body.length).to eq(1)
    expect(body.first["price"]).to eq(200)
  end

  it "fills gaps only when price is identical on both sides (option A)" do
    ingested_at = Time.zone.now
    item = Item.create!(name: "Gap item", game: "rs3", external_id: 1234, members: false)

    PriceSnapshot.create!(
      item: item, series: "daily",
      sampled_at: Time.zone.parse("2025-12-03"),
      price: 500, source: "rs3_official", ingested_at: ingested_at
    )

    PriceSnapshot.create!(
      item: item, series: "daily",
      sampled_at: Time.zone.parse("2025-12-08"),
      price: 500, source: "rs3_official", ingested_at: ingested_at
    )

    get "/api/items/#{item.id}/price_snapshots", params: { series: "daily" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)

    dates = body.map { |h| h["sampled_at"][0, 10] }
    expect(dates).to include("2025-12-04", "2025-12-05", "2025-12-06", "2025-12-07")

    filled = body.select { |h| h["filled"] }
    expect(filled.length).to eq(4)
    expect(filled.all? { |h| h["source"] == "carry_forward" }).to eq(true)
    expect(filled.all? { |h| h["carried_from_sampled_at"].start_with?("2025-12-03") }).to eq(true)
  end

  it "does not fill gaps when prices differ" do
    ingested_at = Time.zone.now
    item = Item.create!(name: "No fill item", game: "rs3", external_id: 5678, members: false)

    PriceSnapshot.create!(
      item: item, series: "daily",
      sampled_at: Time.zone.parse("2025-12-03"),
      price: 500, source: "rs3_official", ingested_at: ingested_at
    )

    PriceSnapshot.create!(
      item: item, series: "daily",
      sampled_at: Time.zone.parse("2025-12-08"),
      price: 600, source: "rs3_official", ingested_at: ingested_at
    )

    get "/api/items/#{item.id}/price_snapshots", params: { series: "daily" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)

    filled = body.select { |h| h["filled"] }
    expect(filled).to eq([])
  end

  it "can fill missing days at the start of the window using a seed before from" do
    ingested_at = Time.zone.now
    item = Item.create!(name: "Seed item", game: "rs3", external_id: 9012, members: false)

    PriceSnapshot.create!(
      item: item, series: "daily",
      sampled_at: Time.zone.parse("2025-12-03"),
      price: 500, source: "rs3_official", ingested_at: ingested_at
    )

    PriceSnapshot.create!(
      item: item, series: "daily",
      sampled_at: Time.zone.parse("2025-12-08"),
      price: 500, source: "rs3_official", ingested_at: ingested_at
    )

    get "/api/items/#{item.id}/price_snapshots", params: { series: "daily", from: "2025-12-04", to: "2025-12-07" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)

    dates = body.map { |h| h["sampled_at"][0, 10] }
    expect(dates).to eq(%w[2025-12-04 2025-12-05 2025-12-06 2025-12-07])

    expect(body.all? { |h| h["filled"] == true }).to eq(true)
  end
end

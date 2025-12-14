# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Items", type: :request do
  it "lists items (with optional q filter)" do
    Item.create!(name: "Zamorak brew", game: "rs3", external_id: 111, members: true)
    Item.create!(name: "Saradomin brew", game: "rs3", external_id: 222, members: true)

    get "/api/items", params: { q: "Zam" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body.length).to eq(1)
    expect(body.first["name"]).to include("Zamorak")
  end

  it "shows an item" do
    item = Item.create!(name: "Abyssal whip", game: "rs3", external_id: 333, members: true)

    get "/api/items/#{item.id}"

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["id"]).to eq(item.id)
    expect(body["external_id"]).to eq(333)
  end
end

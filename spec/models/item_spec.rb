require "rails_helper"

RSpec.describe Item, type: :model do
  it "requires name, game, and external_id" do
    item = Item.new
    expect(item).not_to be_valid
    expect(item.errors.full_messages.join).to match(/Name|Game|External/i)
  end

  it "enforces uniqueness of external_id scoped to game" do
    Item.create!(name: "Steadfast boots", game: "rs3", external_id: 21787)

    dup = Item.new(name: "Steadfast boots", game: "rs3", external_id: 21787)
    expect(dup).not_to be_valid
  end
end

require "rails_helper"

RSpec.describe Rs3::ItemImporter do
  it "creates or updates an Item from detail payload" do
    payload = {
      "item" => {
        "id" => 21787,
        "name" => "Steadfast boots",
        "description" => "A pair of powerful-looking boots.",
        "icon" => "https://secure.runescape.com/icon.gif?id=21787",
        "icon_large" => "https://secure.runescape.com/icon_large.gif?id=21787",
        "type" => "Miscellaneous",
        "members" => "true"
      }
    }

    client = instance_double(Rs3::ItemdbClient)
    allow(client).to receive(:item_detail).with(21787).and_return(payload)

    importer = described_class.new(client: client)
    item = importer.import!(21787)

    expect(item).to be_persisted
    expect(item.game).to eq("rs3")
    expect(item.external_id).to eq(21787)
    expect(item.name).to eq("Steadfast boots")
    expect(item.description).to eq("A pair of powerful-looking boots.")
    expect(item.item_type).to eq("Miscellaneous")
    expect(item.members).to eq(true)
  end
end

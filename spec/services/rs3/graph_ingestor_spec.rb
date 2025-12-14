require "rails_helper"

RSpec.describe Rs3::GraphIngestor do
  it "stores daily and average series and is idempotent on re-run" do
    item = Item.create!(name: "Steadfast boots", game: "rs3", external_id: 21787)

    fake_payload = {
      "daily" => {
        "1749340800000" => 5203175
      },
      "average" => {
        "1749340800000" => 5190000
      }
    }

    client = instance_double(Rs3::ItemdbClient)
    allow(client).to receive(:graph).with(21787).and_return(fake_payload)

    ingestor = described_class.new(client: client)

    created_first = ingestor.ingest!(item)
    expect(created_first).to eq(2)
    expect(PriceSnapshot.count).to eq(2)

    created_second = ingestor.ingest!(item)
    expect(created_second).to eq(0)
    expect(PriceSnapshot.count).to eq(2)
  end
end

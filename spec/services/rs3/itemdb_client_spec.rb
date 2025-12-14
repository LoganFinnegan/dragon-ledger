require "rails_helper"

RSpec.describe Rs3::ItemdbClient do
  let(:base) { "https://secure.runescape.com" }

  it "fetches and parses graph JSON" do
    stub_request(:get, "#{base}/m=itemdb_rs/api/graph/21787.json")
      .to_return(
        status: 200,
        body: '{"daily":{"1749340800000":5203175},"average":{"1749340800000":5190000}}',
        headers: { "Content-Type" => "application/json" }
      )

    data = described_class.new.graph(21787)

    expect(data["daily"]["1749340800000"]).to eq(5_203_175)
    expect(data["average"]["1749340800000"]).to eq(5_190_000)
  end

  it "fetches and parses item detail JSON" do
    stub_request(:get, "#{base}/m=itemdb_rs/api/catalogue/detail.json")
      .with(query: { "item" => "21787" })
      .to_return(
        status: 200,
        body: '{"item":{"id":21787,"name":"Steadfast boots"}}',
        headers: { "Content-Type" => "application/json" }
      )

    data = described_class.new.item_detail(21787)

    expect(data["item"]["id"]).to eq(21787)
    expect(data["item"]["name"]).to eq("Steadfast boots")
  end

  it "raises on non-success responses" do
    stub_request(:get, "#{base}/m=itemdb_rs/api/graph/21787.json")
      .to_return(status: 500, body: "oops")

    expect { described_class.new.graph(21787) }.to raise_error(/RS3 ItemDB error: 500/)
  end
end

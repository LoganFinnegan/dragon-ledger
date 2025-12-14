# frozen_string_literal: true

module Rs3
  class ItemImporter
    def initialize(client: ItemdbClient.new)
      @client = client
    end

    # Fetches RS3 detail.json and creates/updates the Item row.
    # Returns the Item.
    def import!(external_id, game: "rs3")
      payload = client.item_detail(external_id)
      data = payload.fetch("item")

      item = Item.find_or_initialize_by(game: game, external_id: data.fetch("id"))
      item.name = data.fetch("name")
      item.description = data["description"]
      item.icon_url = data["icon"]
      item.icon_large_url = data["icon_large"]
      item.item_type = data["type"]
      item.members = (data["members"].to_s == "true")
      item.save!

      item
    end

    private

    attr_reader :client
  end
end

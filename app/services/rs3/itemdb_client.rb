# frozen_string_literal: true

module Rs3
  class ItemdbClient
    BASE_URL = "https://secure.runescape.com/m=itemdb_rs".freeze
    

    def initialize(http: default_http)
      @http = http
    end

    def item_detail(item_id)
      get_json("api/catalogue/detail.json", item: item_id)
    end

    def graph(item_id)
      get_json("api/graph/#{item_id}.json")
    end

    private

    attr_reader :http

    def default_http
      Faraday.new(url: BASE_URL) do |f|
        f.adapter Faraday.default_adapter
      end
    end

    def get_json(path, params = {})
      resp = http.get(path, params)
      raise "RS3 ItemDB error: #{resp.status}" unless resp.success?

      JSON.parse(resp.body)
    end
  end
end

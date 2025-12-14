# frozen_string_literal: true

module Rs3
  class GraphIngestor
    SERIES = %w[daily average].freeze

    def initialize(client: ItemdbClient.new, source: "rs3_official")
      @client = client
      @source = source
    end

    # Ingests graph data for an existing Item row.
    # Returns count of snapshots created.
    def ingest!(item)
      payload = client.graph(item.external_id)

      created = 0

      SERIES.each do |series|
        points = payload.fetch(series) { {} }
        points.each do |epoch_ms_str, price|
          sampled_at = Time.at(epoch_ms_str.to_i / 1000).utc

          snapshot = PriceSnapshot.create(
            item: item,
            series: series,
            sampled_at: sampled_at,
            price: price,
            source: source,
            ingested_at: Time.current
          )

          created += 1 if snapshot.persisted?
        end
      end

      created
    end

    private

    attr_reader :client, :source
  end
end

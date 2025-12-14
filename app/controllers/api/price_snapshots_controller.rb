# frozen_string_literal: true

module Api
  class PriceSnapshotsController < ApplicationController
    def index
      item = Item.find(params[:item_id])
      series = params[:series].presence || "daily"

      from_time = parse_time(params[:from])
      to_time   = parse_time(params[:to])
      return if performed?

      base = item.price_snapshots.where(series: series).order(:sampled_at)

      # Start with the requested window
      scope = base
      scope = scope.where("sampled_at >= ?", from_time) if from_time
      scope = scope.where("sampled_at <= ?", to_time) if to_time

      records = scope.to_a

      if fill_gaps?(series)
        # Seed before the window so we can carry-forward into the start
        if from_time
          seed_before = base.where("sampled_at < ?", from_time)
                            .order(sampled_at: :desc)
                            .first
          records = [ seed_before, *records ].compact
        end

        # Seed after the window so we can bridge gaps that span past `to`
        if to_time
          seed_after = base.where("sampled_at > ?", to_time)
                           .order(sampled_at: :asc)
                           .first
          records = [ *records, seed_after ].compact
        end
      end

      entries =
        if fill_gaps?(series)
          build_filled_entries(item_id: item.id, series: series, records: records)
        else
          build_real_entries(records)
        end

      # Drop anything outside the requested window (including seed points)
      entries = entries.select { |e| within_bounds?(e[:sampled_at], from_time, to_time) }

      render json: entries.map { |e| serialize_entry(e) }
    end

    private

    def fill_gaps?(series)
      return false unless series.in?(%w[daily average])

      raw = params[:fill_gaps]
      raw.nil? ? true : ActiveModel::Type::Boolean.new.cast(raw)
    end

    def build_real_entries(records)
      records.map do |ps|
        {
          item_id: ps.item_id,
          series: ps.series,
          sampled_at: ps.sampled_at.utc,
          price: ps.price,
          source: ps.source,
          filled: false
        }
      end
    end

    def build_filled_entries(item_id:, series:, records:)
      return [] if records.empty?
      return build_real_entries(records) if records.length == 1

      out = []
      out << {
        item_id: records.first.item_id,
        series: records.first.series,
        sampled_at: records.first.sampled_at.utc,
        price: records.first.price,
        source: records.first.source,
        filled: false
      }

      records.each_cons(2) do |prev, nxt|
        prev_date = prev.sampled_at.to_date
        nxt_date  = nxt.sampled_at.to_date
        gap_days  = (nxt_date - prev_date).to_i

        # OPTION A RULE: only fill if gap > 1 day AND prices match
        if gap_days > 1 && prev.price == nxt.price
          (1...gap_days).each do |i|
            d = prev_date + i
            t = Time.utc(d.year, d.month, d.day)

            out << {
              item_id: item_id,
              series: series,
              sampled_at: t,
              price: prev.price,
              source: "carry_forward",
              filled: true,
              carried_from_sampled_at: prev.sampled_at.utc
            }
          end
        end

        out << {
          item_id: nxt.item_id,
          series: nxt.series,
          sampled_at: nxt.sampled_at.utc,
          price: nxt.price,
          source: nxt.source,
          filled: false
        }
      end

      out
    end

    def serialize_entry(e)
      h = {
        item_id: e[:item_id],
        series: e[:series],
        sampled_at: e[:sampled_at].iso8601,
        sampled_at_epoch_ms: e[:sampled_at].to_i * 1000,
        price: e[:price],
        source: e[:source],
        filled: e[:filled]
      }

      if e[:carried_from_sampled_at]
        h[:carried_from_sampled_at] = e[:carried_from_sampled_at].iso8601
      end

      h
    end

    def within_bounds?(t, from_time, to_time)
      return false if t.nil?
      return false if from_time && t < from_time
      return false if to_time && t > to_time
      true
    end

    def parse_time(raw)
      return nil if raw.blank?
      Time.zone.parse(raw)
    rescue ArgumentError, TypeError
      render json: { error: "Invalid datetime for from/to: #{raw.inspect}" }, status: :bad_request
      nil
    end
  end
end

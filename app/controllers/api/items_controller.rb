# frozen_string_literal: true

module Api
  class ItemsController < ApplicationController
    def index
      q = params[:q].to_s.strip

      items =
        if q.empty?
          Item.order(:name).limit(50)
        else
          Item.where("name ILIKE ?", "%#{q}%").order(:name).limit(50)
        end

      render json: items.as_json(
        only: %i[id name game external_id description icon_url icon_large_url item_type members]
      )
    end

    def show
      item = Item.find(params[:id])

      render json: item.as_json(
        only: %i[id name game external_id description icon_url icon_large_url item_type members created_at updated_at]
      )
    end
  end
end

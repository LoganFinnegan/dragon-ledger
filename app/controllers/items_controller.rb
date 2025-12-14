class ItemsController < ApplicationController
  def index
    @items = Item.order(:name).limit(50)
  end

  def show
    @item = Item.find(params[:id])
    @latest_daily = @item.price_snapshots.where(series: "daily").order(sampled_at: :desc).first
  end
end

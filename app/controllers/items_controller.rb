class ItemsController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    scope = Item.order(:name)
    scope = scope.where("name ILIKE ?", "%#{@query}%") if @query.present?

    @items = scope.limit(100)
  end

  def show
    @item = Item.find(params[:id])
    @latest_daily = @item.price_snapshots.where(series: "daily").order(sampled_at: :desc).first
  end
end

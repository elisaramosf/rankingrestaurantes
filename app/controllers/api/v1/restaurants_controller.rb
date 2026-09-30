class Api::V1::RestaurantsController < Api::V1::BaseController
  def index
    restaurants = Restaurant.includes(:category).order(:name)
    render json: restaurants.map { |restaurant| restaurant_json(restaurant) }
  end

  def show
    restaurant = Restaurant.find(params[:id])
    render json: restaurant_json(restaurant)
  end

  private

    def restaurant_json(restaurant)
    {
      id: restaurant.id,
      name: restaurant.name,
      address: restaurant.address,
      category: restaurant.category&.name,
      photo_url: restaurant.photo.attached? ? rails_blob_url(restaurant.photo) : nil
    }
  end
end
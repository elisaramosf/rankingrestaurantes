
class Api::V1::FavoritesController < Api::V1::BaseController
  before_action :authenticate_user!

  def index
    favorites = current_user.favorites.includes(:restaurant)

    render json: favorites.map { |favorite| favorite_json(favorite) }
  end

  def create
    restaurant = Restaurant.find(params[:restaurant_id])

    favorite = current_user.favorites.find_or_initialize_by(
      restaurant: restaurant
    )

    if favorite.save
      render json: favorite_json(favorite), status: :created
    else
      render json: { errors: favorite.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    favorite = current_user.favorites.find_by!(
      restaurant_id: params[:restaurant_id]
    )

    favorite.destroy!
    head :no_content
  end

  private

  def favorite_json(favorite)
    {
      id: favorite.id,
      restaurant_id: favorite.restaurant_id,
      restaurant_name: favorite.restaurant.name,
      restaurant_address: favorite.restaurant.address
    }
  end
end

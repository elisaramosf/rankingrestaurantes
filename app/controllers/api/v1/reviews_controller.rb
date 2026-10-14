
class Api::V1::ReviewsController < Api::V1::BaseController
  before_action :authenticate_user!, except: :index

  def index
    restaurant = Restaurant.find(params[:restaurant_id])
    reviews = restaurant.reviews.includes(:user).order(created_at: :desc)

    render json: reviews.map { |review| review_json(review) }
  end

  def create
    restaurant = Restaurant.find(params[:restaurant_id])
    review = current_user.reviews.build(review_params)
    review.restaurant = restaurant

    if review.save
      render json: review_json(review), status: :created
    else
      render json: { errors: review.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    review = current_user.reviews.find(params[:id])

    if review.update(review_params)
      render json: review_json(review)
    else
      render json: { errors: review.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    review = current_user.reviews.find(params[:id])
    review.destroy!
    head :no_content
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def review_json(review)
    {
      id: review.id,
      restaurant_id: review.restaurant_id,
      user_id: review.user_id,
      user_name: review.user.name,
      rating: review.rating,
      comment: review.comment,
      created_at: review.created_at
    }
  end
end

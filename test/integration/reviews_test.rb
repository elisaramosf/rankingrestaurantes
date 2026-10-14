
require "test_helper"

class ReviewsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @restaurant = restaurants(:one)

    @token = @user.sessions.create!.token
    @headers = {
      "Authorization" => "Bearer #{@token}"
    }
  end

  test "listar reviews de un restaurante" do
    get "/api/v1/restaurants/#{@restaurant.id}/reviews"

    assert_response :success
    assert_kind_of Array, response.parsed_body
  end

  test "crear una review" do
    assert_difference("Review.count", 1) do
      post "/api/v1/restaurants/#{@restaurant.id}/reviews",
           params: {
             review: {
               rating: 5,
               comment: "Excelente restaurante"
             }
           },
           headers: @headers,
           as: :json
    end

    assert_response :created
    assert_equal 5, response.parsed_body["rating"]
  end

  test "no crear review sin autenticacion" do
    assert_no_difference("Review.count") do
      post "/api/v1/restaurants/#{@restaurant.id}/reviews",
           params: {
             review: {
               rating: 4,
               comment: "Muy bueno"
             }
           },
           as: :json
    end

    assert_response :unauthorized
  end

  test "editar una review propia" do
    review = Review.create!(
      user: @user,
      restaurant: @restaurant,
      rating: 5,
      comment: "Excelente restaurante"
    )

    patch "/api/v1/reviews/#{review.id}",
          params: {
            review: {
              rating: 4,
              comment: "Muy buena comida"
            }
          },
          headers: @headers,
          as: :json

    assert_response :success

    review.reload
    assert_equal 4, review.rating
    assert_equal "Muy buena comida", review.comment
  end

  test "eliminar una review propia" do
    review = Review.create!(
      user: @user,
      restaurant: @restaurant,
      rating: 5,
      comment: "Excelente restaurante"
    )

    assert_difference("Review.count", -1) do
      delete "/api/v1/reviews/#{review.id}",
             headers: @headers
    end

    assert_response :no_content
  end
end

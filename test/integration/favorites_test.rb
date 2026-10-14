
require "test_helper"

class FavoritesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @restaurant = restaurants(:one)

    @token = @user.sessions.create!.token
    @headers = {
      "Authorization" => "Bearer #{@token}"
    }
  end

  test "listar favoritos del usuario" do
    favorite = Favorite.find_or_create_by!(
      user: @user,
      restaurant: @restaurant
    )

    get "/api/v1/favorites", headers: @headers

    assert_response :success
    assert response.parsed_body.any? { |f| f["id"] == favorite.id }
  end

  test "agregar un restaurante a favoritos" do
    @user.favorites.where(restaurant: @restaurant).destroy_all

    assert_difference("Favorite.count", 1) do
      post "/api/v1/favorites",
           params: { restaurant_id: @restaurant.id },
           headers: @headers,
           as: :json
    end

    assert_response :created
  end

  test "no duplicar restaurantes favoritos" do
    Favorite.find_or_create_by!(
      user: @user,
      restaurant: @restaurant
    )

    assert_no_difference("Favorite.count") do
      post "/api/v1/favorites",
           params: { restaurant_id: @restaurant.id },
           headers: @headers,
           as: :json
    end

    assert_response :created
  end

  test "eliminar un restaurante de favoritos" do
    Favorite.find_or_create_by!(
      user: @user,
      restaurant: @restaurant
    )

    assert_difference("Favorite.count", -1) do
      delete "/api/v1/favorites/#{@restaurant.id}",
             headers: @headers
    end

    assert_response :no_content
  end

  test "no agregar favoritos sin autenticacion" do
    assert_no_difference("Favorite.count") do
      post "/api/v1/favorites",
           params: { restaurant_id: @restaurant.id },
           as: :json
    end

    assert_response :unauthorized
  end
end

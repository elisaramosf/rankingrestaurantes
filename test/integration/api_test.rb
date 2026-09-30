require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Ana", email: "ana@example.com", password: "clave12345")
    category = Category.create!(name: "Pizzería")
    @restaurant = Restaurant.create!(name: "Don Mario", address: "Calle 7", category: category)
  end

  test "login con datos correctos devuelve token" do
    post "/api/v1/login", params: { email: "ana@example.com", password: "clave12345" }, as: :json
    assert_response :created
    assert_not_nil response.parsed_body["token"]
  end

  test "login con contraseña incorrecta devuelve 401" do
    post "/api/v1/login", params: { email: "ana@example.com", password: "mal" }, as: :json
    assert_response :unauthorized
  end

  test "lista restaurantes sin token" do
    get "/api/v1/restaurants"
    assert_response :success
    assert_equal 1, response.parsed_body.size
  end

  test "restaurante inexistente devuelve 404" do
    get "/api/v1/restaurants/0"
    assert_response :not_found
  end

  test "profile sin token devuelve 401" do
    get "/api/v1/profile"
    assert_response :unauthorized
  end

  test "profile con token devuelve el usuario" do
    token = @user.sessions.create!.token
    get "/api/v1/profile", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    assert_equal "ana@example.com", response.parsed_body["email"]
  end

  test "el registro envía el mail de bienvenida" do
    assert_emails 1 do
      post "/api/v1/users", params: { name: "Nuevo", email: "nuevo@example.com", password: "clave12345" }, as: :json
    end
    assert_response :created
  end

  test "un usuario común no entra al admin" do
    post "/session", params: { email: "ana@example.com", password: "clave12345" }
    get "/admin"
    assert_redirected_to new_session_path
  end
end
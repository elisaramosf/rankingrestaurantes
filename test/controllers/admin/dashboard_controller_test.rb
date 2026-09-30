require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirige al login si no hay sesión" do
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "un admin puede ver el panel" do
    User.create!(name: "Admin", email: "admin@example.com", password: "clave12345", role: :admin)
    post session_url, params: { email: "admin@example.com", password: "clave12345" }

    get admin_root_url
    assert_response :success
  end
end
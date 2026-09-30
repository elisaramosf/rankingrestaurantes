require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "es válido con email y contraseña" do
    user = User.new(name: "Ana", email: "ana@example.com", password: "clave12345")
    assert user.valid?
  end

  test "no es válido sin email" do
    user = User.new(name: "Ana", password: "clave12345")
    assert_not user.valid?
  end

  test "no permite emails repetidos" do
    User.create!(name: "Ana", email: "ana@example.com", password: "clave12345")
    repetido = User.new(name: "Otra", email: "ana@example.com", password: "clave12345")
    assert_not repetido.valid?
  end

  test "por defecto el rol es user" do
    user = User.create!(name: "Ana", email: "ana@example.com", password: "clave12345")
    assert user.user?
  end
end
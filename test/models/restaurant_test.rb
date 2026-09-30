require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Pizzería")
  end

  test "es válido con nombre y categoría" do
    assert Restaurant.new(name: "Don Mario", category: @category).valid?
  end

  test "no es válido sin nombre" do
    assert_not Restaurant.new(category: @category).valid?
  end

  test "no es válido sin categoría" do
    assert_not Restaurant.new(name: "Don Mario").valid?
  end

  test "puede tener una foto adjunta" do
    restaurant = Restaurant.create!(name: "Don Mario", category: @category)
    restaurant.photo.attach(io: StringIO.new("contenido"), filename: "foto.png", content_type: "image/png")

    assert restaurant.photo.attached?
  end
end

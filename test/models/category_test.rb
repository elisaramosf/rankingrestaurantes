require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "es válida con nombre" do
    assert Category.new(name: "Pizzería").valid?
  end

  test "no es válida sin nombre" do
    assert_not Category.new.valid?
  end

  test "no permite nombres repetidos" do
    Category.create!(name: "Pizzería")
    assert_not Category.new(name: "Pizzería").valid?
  end

  test "no se puede borrar una categoría que tiene restaurantes" do
    category = Category.create!(name: "Pizzería")
    Restaurant.create!(name: "Don Mario", category: category)

    assert_not category.destroy
    assert_equal 1, Restaurant.count
  end
end

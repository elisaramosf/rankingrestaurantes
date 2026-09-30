admin = User.find_or_initialize_by(email: "admin@example.com")
admin.update!(name: "Admin", password: "admin1234", role: :admin)

user = User.find_or_initialize_by(email: "usuario@example.com")
user.update!(name: "Usuario", password: "usuario1234", role: :user)

pizzeria = Category.find_or_create_by!(name: "Pizzería")
parrilla = Category.find_or_create_by!(name: "Parrilla")

Restaurant.find_or_create_by!(name: "Don Mario") do |restaurant|
  restaurant.address = "Calle 7 nº 123"
  restaurant.category = pizzeria
end

Restaurant.find_or_create_by!(name: "La Estancia") do |restaurant|
  restaurant.address = "Calle 50 nº 456"
  restaurant.category = parrilla
end
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = User.create!(name: "Ana", email: "ana@example.com", password: "clave12345")
    mail = UserMailer.welcome(user)

    assert_equal "¡Bienvenido/a a Ranking Restaurantes!", mail.subject
    assert_equal [ "ana@example.com" ], mail.to
    assert_match "Ana", mail.body.encoded
  end
end

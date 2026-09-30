class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "¡Bienvenido/a a Ranking Restaurantes!")
  end
end

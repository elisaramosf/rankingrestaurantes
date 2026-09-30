class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    return if Current.user&.admin?

    redirect_to new_session_path, alert: "No tenés permiso para entrar al panel de administración."
  end
end

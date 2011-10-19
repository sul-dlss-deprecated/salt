class WebauthSessionsController < ApplicationController
#  skip_before_filter :store_bounce
  def new
    if session[:bounce] || params[:bounce]
      redirect_to session[:bounce]||params[:bounce] 
    else
      redirect_to "/"
    end
  end
end

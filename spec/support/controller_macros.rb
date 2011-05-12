module ControllerMacros
  
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Factory.create(:user)
      sign_in @user
    end
  end
  
  def logout_user
    before(:each) do
      sign_out @user
    end
  end
  
end

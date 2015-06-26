module ControllerMacros
  
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
  end
  
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end
  end
  
  
  def logout_user
    before(:each) do
      sign_out @user
    end
  end
  
end

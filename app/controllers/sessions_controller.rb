class SessionsController < ApplicationController

  # This url is called by gamebus when clicking on the connect button in the app
  # It has two get parameters: userid and token.
  # This token is the encryped token and must be decrypted
  def connect
    # First find the user and update it's encrypted key
    @user = User.find_or_initialize_by(gamebus_id: params[:userid])
    @user.gamebus_key = params[:token]
    @user.save!
    # Then save the user in the session so it can be found again later
    session[:user_id] = @user.id
    # Check the user's RVS key and act accordingly
    render :connected if @user.rvs_key_valid?
  end

  # Invalidate the rvs api-key and return true/false if succeeded
  def disconnect
    if @user = User.find_by_gamebus_id(params[:userid])
      render text: @user.rvs_disconnect
    else
      render text: false
    end
  end

  # Return true or false if the user is connected
  def status
    if @user = User.find_by_gamebus_id(params[:userid])
      render text: @user.rvs_key_valid?
    else
      render text: false
    end
  end

  # This is called when the user has entered his credentials
  def rvs_login
    # Set the user attributes
    current_user.attributes = user_params
    if current_user.rvs_get_key
      render :connected
    else
      flash.now[:danger] = 'Invalid credentials'
      render :connect
    end
  end

  private

  def user_params
    params.require(:user).permit :rvs_email, :rvs_password
  end

end

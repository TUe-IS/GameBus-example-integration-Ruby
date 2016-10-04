class User < ActiveRecord::Base

  attr_accessor :rvs_email, :rvs_password

  validates :gamebus_id, uniqueness: true, presence: true
  validates :gamebus_key, presence: true
  validates :rvs_id, uniqueness: true, allow_nil: true

  def rvs_key_valid?
    return false unless rvs_key.present?
    rvs_connection.get('/users/current').status == 200
  end

  def rvs_disconnect
    return false unless rvs_key.present?
    rvs_connection.delete('/api-keys/current').status == 200
  end

  def rvs_get_key
    return false unless rvs_email && rvs_password
    resp = rvs_connection.post('/api-keys', email: rvs_email, password: rvs_password)
    return false unless resp.status == 201
    update_column :rvs_key, JSON.parse(resp.body)['access_token']
    update_column :rvs_id,  JSON.parse(resp.body)['user']['id']
    return true
  end

  def gamebus_key
    # decrypt(self[:gamebus_key])
    "e484ef2f-e6b9-4bce-aa2d-7afefcb51d85"
  end

  private

  def rvs_connection
    connection = Faraday.new url: Rails.application.secrets.rvs_url do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    connection.headers['Authorization'] = "Token #{rvs_key}" if rvs_key
    return connection
  end

  def decrypt(token)
    (decipher.update(Base64.decode64(token)) + decipher.final).force_encoding('UTF-8')
  end

  def decipher
    decipher = OpenSSL::Cipher::AES.new(128, :CFB)
    # decipher.decrypt
    decipher.key = decipher.iv = Rails.application.secrets.gamebus_app_key
    decipher
  end

end

class AuthResponseSerializer
  def initialize(data)
    @data = data
  end

  def as_json
    {
      access_token: data[:access_token],
      refresh_token: data[:refresh_token],
      refresh_token_expires_at: data[:refresh_token_expires_at],
      user: UserSerializer.new(data[:user])
    }
  end

  private

  attr_reader :data
end

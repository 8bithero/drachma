class TokenResponseSerializer
  def initialize(data)
    @data = data
  end

  def as_json
    {
      access_token: data[:access_token],
      refresh_token: data[:refresh_token],
      refresh_token_expires_at: data[:refresh_token_expires_at]
    }
  end

  private

  attr_reader :data
end

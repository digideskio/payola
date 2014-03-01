module  Payola
  class Configuration
    attr_accessor :payment_gateway_api_key
  end

  def self.config
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield config
  end
end

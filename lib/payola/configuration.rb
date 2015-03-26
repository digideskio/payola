module  Payola
  class Configuration
    attr_accessor :payment_gateway_adapter,
                  :payment_gateway_api_key

    def payment_gateway_adapter=(other)
      Payola::Registry[:payment_gateway_adapter] = other
    end
  end

  def self.config
    @configuration ||= Configuration.new
  end

  def self.configure
    yield config
  end
end

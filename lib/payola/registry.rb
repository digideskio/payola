module  Payola
  class Registry
    @@registry = {
      payment_gateway_adapter: ::Payola::PaymentGateways::StripePaymentGateway
    }

    def self.method_missing(name, *args)
      return @@registry.public_send(name, *args) if @@registry.respond_to? name

      super
    end

    def self.respond_to_missing?(name)
      @@registry.respond_to? name || super
    end
  end

  def self.registry
    Registry
  end
end

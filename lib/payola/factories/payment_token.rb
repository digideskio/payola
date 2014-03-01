require 'payola/registry'
require 'payola/core_ext/string'
require 'payola/factories/stripe_payment_token'

module  Payola
module  Factories
class   PaymentToken
  def self.create(card: nil)
    payment_gateway_adapter_class_name = Payola.registry[:payment_gateway_adapter].name
    payment_gateway_adapter_type       = payment_gateway_adapter_class_name[/::(\w+)PaymentGateway\z/, 1]
    factory_class_name                 = "Payola::Factories::#{payment_gateway_adapter_type}PaymentToken"
    factory_class                      = factory_class_name.constantize

    factory_class.create(card: card)
  end
end
end
end

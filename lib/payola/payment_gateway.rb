module  Payola
class   PaymentGateway
  def self.sync(adapter: Payola.registry[:payment_gateway_adapter],
                subscription:)

    gateway_subscription = adapter.apply_subscription \
                            subscription.payment_gateway_parameters

    subscription = subscription.dup

    subscription.source_subscription_id   = gateway_subscription[:subscription_id]
    subscription.last_four_of_credit_card = gateway_subscription[:last_four_of_credit_card]
    subscription.status                   = gateway_subscription[:status]

    subscription
  end
end
end

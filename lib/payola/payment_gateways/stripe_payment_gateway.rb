require 'stripe'
require 'payola/errors/payment_gateway_request_error'

module  Payola
module  PaymentGateways
class   StripePaymentGateway
  attr_accessor :customer_id,
                :subscription_id,
                :plan_id,
                :amount,
                :interval,
                :interval_count,
                :plan_name,
                :payment_token,
                :api_key

  def initialize(**args)
    args.each do |name, value|
      public_send("#{name}=", value)
    end

    Stripe.api_key       = api_key || Payola.config.payment_gateway_api_key

    combined_id          = subscription_id || ''
    self.customer_id     = combined_id[/\A(cus_[A-Za-z0-9]{14})\:/, 1] || 'no_customer'
    self.subscription_id = combined_id[/\:(sub_[A-Za-z0-9]{14})\z/, 1] || 'no_subscription'
  end

  def apply_subscription
    update_subscription_plan
    update_subscription_payment_token

    {
      status:                   subscription.status,
      plan:                     subscription.plan[:id],
      subscription_id:          "#{subscription.customer}:#{subscription.id}",
      last_four_of_credit_card: last_four_of_credit_card,
    }
  end

  def self.apply_subscription(**args)
    new(**args).apply_subscription
  end

  private

  def update_subscription_plan
    if subscription.plan != plan.id
      subscription.plan = plan.id
      subscription.save
    end
  rescue Stripe::InvalidRequestError => e
    raise Payola::Errors::PaymentGatewayRequestError.wrap(e)
  end

  def update_subscription_payment_token
    subscription.save(card: payment_token)
  rescue Stripe::InvalidRequestError => e
    raise Payola::Errors::PaymentGatewayRequestError.wrap(e) unless e.message.match 'cannot use a Stripe token more than once'
  end

  def last_four_of_credit_card
    customer_default_card.last4 unless plan.amount.zero?
  end

  def customer_default_card
    customer.cards.retrieve(customer.default_card)
  end

  def subscription
    @subscription ||= customer.subscriptions.retrieve(subscription_id)
  rescue Stripe::InvalidRequestError => e
    raise Payola::Errors::PaymentGatewayRequestError.wrap(e) unless e.message.match 'does not have a subscription'

    @subscription ||= customer.subscriptions.create(plan: plan.id, card: payment_token)
  end

  def customer
    Stripe::Customer.retrieve customer_id
  rescue Stripe::InvalidRequestError => e
    raise Payola::Errors::PaymentGatewayRequestError.wrap(e) unless e.message.match 'No such customer'

    begin
      Stripe::Customer.create.tap do |customer|
        self.customer_id = customer.id
      end
    rescue StandardError => e
      raise Payola::Errors::PaymentGatewayRequestError.wrap(e)
    end
  end

  def plan
    Stripe::Plan.retrieve plan_id
  rescue Stripe::InvalidRequestError => e
    raise Payola::Errors::PaymentGatewayRequestError.wrap(e) unless e.message.match 'No such plan'

    begin
      Stripe::Plan.create id:             plan_id,
                          amount:         amount.cents,
                          currency:       amount.currency,
                          interval:       interval,
                          interval_count: interval_count,
                          name:           plan_name
    rescue StandardError => e
      raise Payola::Errors::PaymentGatewayRequestError.wrap(e)
    end
  end
end
end
end

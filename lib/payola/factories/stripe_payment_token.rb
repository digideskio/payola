module  Payola
module  Factories
class   StripePaymentToken
  def self.create(card: nil)
    Stripe.api_key = Payola.config.payment_gateway_api_key

    card ||= { number:     '4242424242424242',
               exp_month:  3,
               exp_year:   Time.now.strftime("%Y").to_i + 5,
               cvc:        '314' }

    Stripe::Token.create(card: card).id
  end
end
end
end

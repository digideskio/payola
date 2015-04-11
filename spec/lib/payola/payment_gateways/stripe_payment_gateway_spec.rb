require 'rspectacular'
require 'money'
require 'chamber'
require 'payola/payment_gateways/stripe_payment_gateway'
require 'payola/factories/stripe_payment_token'
require 'payola/configuration'

Chamber.load(basepath: Pathname.new(__dir__) + '../../../../')

module      Payola
module      PaymentGateways
describe    StripePaymentGateway, :stripe, :vcr do
  before(:each) do
    Payola.config.payment_gateway_api_key = Chamber.env.stripe.api_key
    Stripe.api_key                        = Chamber.env.stripe.api_key
  end

  let(:credit_card_token) do
    Payola::Factories::StripePaymentToken.create(card: {
                                                   number:    '4242424242424242',
                                                   exp_month: 3,
                                                   exp_year:  2020,
                                                   cvc:       '314' })
  end

  it 'can create a subscription using the API key from the configuration' do
    Stripe.api_key = nil

    subscription = StripePaymentGateway.apply_subscription \
                      subscription_id: nil,
                      plan_id:         'my test plan id',
                      amount:          Money.new(100, 'USD'),
                      interval:        'month',
                      interval_count:  1,
                      plan_name:       'my test plan name',
                      payment_token:   credit_card_token

    expect(subscription[:plan]).to eql 'my test plan id'
  end

  it 'can create a subscription when neither a customer nor plan exist' do
    subscription = StripePaymentGateway.apply_subscription \
                      subscription_id: nil,
                      plan_id:         'my test plan id',
                      amount:          Money.new(100, 'USD'),
                      interval:        'month',
                      interval_count:  1,
                      plan_name:       'my test plan name',
                      payment_token:   credit_card_token

    expect(subscription[:plan]).to                     eql   'my test plan id'
    expect(subscription[:subscription_id]).to          match(/\Acus_[A-Za-z0-9]{14}\:sub_[A-Za-z0-9]{14}\z/)
    expect(subscription[:status]).to                   eql   'active'
    expect(subscription[:last_four_of_credit_card]).to eql   '4242'
  end

  it 'can create a subscription when a customer exists but not a plan' do
    customer     = Stripe::Customer.create
    subscription = StripePaymentGateway.apply_subscription \
                      subscription_id: "#{customer.id}:",
                      plan_id:         'my test plan id',
                      amount:          Money.new(100, 'USD'),
                      interval:        'month',
                      interval_count:  1,
                      plan_name:       'my test plan name',
                      payment_token:   credit_card_token

    expect(subscription[:subscription_id]).to match(/#{customer.id}\:sub_[A-Za-z0-9]{14}/)
  end

  it 'can create a subscription when a plan already exists but not a customer' do
    Stripe::Plan.create id:       'my other existing test plan id',
                        amount:   200,
                        currency: 'EUR',
                        interval: 'week',
                        name:     'what you talkin bout'

    allow(Stripe::Plan).to receive(:create)

    subscription = StripePaymentGateway.apply_subscription \
                      subscription_id: nil,
                      plan_id:         'my other existing test plan id',
                      amount:          Money.new(100, 'USD'),
                      interval:        'month',
                      interval_count:  1,
                      plan_name:       'my test plan name',
                      payment_token:   credit_card_token

    expect(Stripe::Plan).not_to                        have_received(:create)
    expect(subscription[:plan]).to                     eql 'my other existing test plan id'
    expect(subscription[:subscription_id]).to          match(/\Acus_[A-Za-z0-9]{14}\:sub_[A-Za-z0-9]{14}\z/)
    expect(subscription[:status]).to                   eql   'active'
    expect(subscription[:last_four_of_credit_card]).to eql   '4242'
  end

  it 'can update a subscription with a new plan' do
    customer     = Stripe::Customer.create
    plan         = Stripe::Plan.create      id:       'my existing test plan id',
                                            amount:   200,
                                            currency: 'USD',
                                            interval: 'week',
                                            name:     'what you talkin bout'
    existing_subscription = customer.subscriptions.create(
                                            plan: plan.id,
                                            card: credit_card_token)

    updated_subscription  = StripePaymentGateway.apply_subscription \
                                            subscription_id: "#{customer.id}:#{existing_subscription.id}",
                                            plan_id:         'my test plan id',
                                            amount:          Money.new(100, 'USD'),
                                            interval:        'month',
                                            interval_count:  1,
                                            plan_name:       'my test plan name',
                                            payment_token:   nil

    expect(updated_subscription[:plan]).to                      eql 'my test plan id'
    expect(updated_subscription[:last_four_of_credit_card]).to  eql '4242'
  end

  it 'wraps all exceptions in Payola errors' do
    allow(Stripe::Customer).to receive(:create).
                               and_raise(RuntimeError.new 'error creating customer')

    expect do
      StripePaymentGateway.apply_subscription \
                      subscription_id: nil,
                      plan_id:         'my existing test plan id',
                      amount:          Money.new(100, 'USD'),
                      interval:        'month',
                      interval_count:  1,
                      plan_name:       'my test plan name',
                      payment_token:   credit_card_token
    end.to \
    raise_error(Payola::Errors::PaymentGatewayRequestError).
      with_message('RuntimeError: error creating customer')
  end

  it 'allows a free subscription to be created without a previous paid subscription' do
    subscription = StripePaymentGateway.apply_subscription \
                      subscription_id: nil,
                      plan_id:         'my test plan id',
                      amount:          Money.new(0, 'USD'),
                      interval:        'month',
                      interval_count:  1,
                      plan_name:       'my test plan name'

    expect(subscription[:plan]).to                     eql   'my test plan id'
    expect(subscription[:subscription_id]).to          match(/\Acus_[A-Za-z0-9]{14}\:sub_[A-Za-z0-9]{14}\z/)
    expect(subscription[:status]).to                   eql   'active'
    expect(subscription[:last_four_of_credit_card]).to eql   nil
  end

  it 'can update a subscription with a new payment token' do
    customer     = Stripe::Customer.create
    plan         = Stripe::Plan.create      id:       'my other existing test plan id',
                                            amount:   200,
                                            currency: 'USD',
                                            interval: 'week',
                                            name:     'what you talkin bout'
    existing_subscription = customer.subscriptions.create(
                                            plan: plan.id,
                                            card: credit_card_token)

    new_credit_card_token = Payola::Factories::StripePaymentToken.create(card: {
                                                                           number:    '4012888888881881',
                                                                           exp_month: 3,
                                                                           exp_year:  2020,
                                                                           cvc:       '314' })

    subscription = StripePaymentGateway.apply_subscription \
                          subscription_id: "#{customer.id}:#{existing_subscription.id}",
                          plan_id:         'my other existing plan id',
                          amount:          Money.new(200, 'USD'),
                          interval:        'week',
                          interval_count:  1,
                          plan_name:       'what you talking bout',
                          payment_token:   new_credit_card_token

    expect(subscription[:last_four_of_credit_card]).to eql   '1881'
  end
end
end
end

require 'payola/version'
require 'payola/payment_gateway'
require 'payola/payment_gateways'
require 'payola/registry'
require 'payola/configuration'

module Payola
  def self.sync(**args)
    PaymentGateway.sync(**args)
  end
end

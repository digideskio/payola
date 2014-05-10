Dir[File.join(File.expand_path('..', __FILE__), 'payment_gateways', '**', '*.rb')].each { |file| require file }

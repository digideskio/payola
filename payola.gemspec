# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'payola/version'

Gem::Specification.new do |gem|
  gem.name              = 'payola'
  gem.version           = Payola::VERSION
  gem.authors           = %w{jfelchner}
  gem.email             = 'accounts+git@thekompanee.com'
  gem.summary           = %q{Abstraction layer on top of Stripe/Braintree, etc so we can get Payola'ed}
  gem.description       = %q{}
  gem.homepage          = 'https://github.com/thekompanee/payola'
  gem.license           = 'MIT'

  gem.executables       = Dir['{bin}/**/*'].map    { |bin| File.basename(bin) }.
                                            reject { |bin| %w{rails rspec rake setup deploy}.include? bin }
  gem.files             = Dir['{app,config,db,lib,templates}/**/*'] + %w{Rakefile README.md LICENSE}
  gem.test_files        = Dir['{test,spec,features}/**/*']

  gem.add_dependency              'stripe',        '~> 1.10'
  gem.add_dependency              'human_error',   '~> 2.0'

  gem.add_development_dependency  'rspec',         '~> 3.0'
  gem.add_development_dependency  'rspectacular',  '~> 0.48'
  gem.add_development_dependency  'money',         '~> 6.0'
  gem.add_development_dependency  'vcr',           '~> 2.8.0'
  gem.add_development_dependency  'webmock',       '< 1.16'
end

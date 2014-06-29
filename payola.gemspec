# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'payola/version'

Gem::Specification.new do |gem|
  gem.rubygems_version  = '1.3.5'

  gem.name              = 'payola'
  gem.rubyforge_project = 'payola'

  gem.version           = Payola::VERSION
  gem.platform          = Gem::Platform::RUBY

  gem.authors           = %w{jfelchner}
  gem.email             = 'accounts+git@thekompanee.com'
  gem.date              = Time.now
  gem.homepage          = 'https://github.com/thekompanee/payola'

  gem.summary           = %q{Abstraction layer on top of Stripe/Braintree, etc so we can get Payola'ed}
  gem.description       = %q{}

  gem.rdoc_options      = ['--charset = UTF-8']
  gem.extra_rdoc_files  = %w{README.md}

  gem.executables       = Dir['{bin}/**/*'].map {|dir| dir.gsub!(/\Abin\//, '')}
  gem.files             = Dir['{app,config,db,lib}/**/*'] + %w{Rakefile README.md}
  gem.test_files        = Dir['{test,spec,features}/**/*']
  gem.require_paths     = ['lib']

  gem.add_dependency              'stripe',         '~> 1.10'
  gem.add_dependency              'human_error',    '~> 1.11'

  gem.add_development_dependency  'rspec',          '~> 3.0.0'
  gem.add_development_dependency  'rspectacular',   '~> 0.47.0'
  gem.add_development_dependency  'money',          '~> 6.0'
  gem.add_development_dependency  'vcr',            '~> 2.8.0'
  gem.add_development_dependency  'webmock',        '< 1.16'
end

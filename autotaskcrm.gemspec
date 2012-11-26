Gem::Specification.new do |s|
  s.name            = 'autotaskcrm'
  s.version         = '0.1.3'

  s.date            = '2012-11-26'
  s.summary         = "AutoTask functionality for Ruby."
  s.description     = "Commonly needed AutoTask functionality for Ruby projects."
  s.authors         = ["Mark Stanislav"]
  s.email           = 'mark.stanislav@gmail.com'
  s.files           = ["lib/autotaskcrm.rb", "README.md"]
  s.homepage        = 'http://rubygems.org/gems/autotaskcrm'
  s.license         = 'MIT'

  s.add_dependency('savon', '~> 1.1.0')
  s.add_dependency('gyoku', '~> 0.4.6')
  s.add_dependency('httpclient', '~> 2.2.5')
end

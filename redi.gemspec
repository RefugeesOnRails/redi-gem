Gem::Specification.new do |s|
  s.name        = 'redi'
  s.version     = '0.0.1'
  s.date        = '2016-01-31'
  s.summary     = 'ReDI Projects API client'
  s.description = 'Simple API client for interacting with ReDI projects sample application'
  s.authors     = ['Sebastian Probst Eide']
  s.email       = 'sebastian.probst.eide@gmail.com'
  s.files       = ['lib/redi.rb']
  s.homepage    = 'https://github.com/refugeesonrails/redi-gem'
  s.license     = 'MIT'
  s.add_runtime_dependency 'httparty', '~> 0.13'
end

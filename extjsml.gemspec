Gem::Specification.new do |s|
  s.name        = 'extjsml'
  s.version     = '0.0.1'
  s.date        = '2014-07-10'
  s.summary     = "ExtJS Markup Language for ExtJS4 extended from YAML"
  s.description = "ExtJS Markup Language for ExtJS4 extended from YAML ..."
  s.author      = "Sarunyoo Chobpanich"
  s.email       = 'wsaryoo@gmail.com'
  s.files       = Dir["lib/*.rb"] + Dir["lib/**/*.rb"]
  s.homepage    = 'http://rubygems.org/gems/extjsml'
  s.add_runtime_dependency 'json', '~> 1.8'
  # s.require_paths = ['lib']

  s.bindir      = 'bin'
  s.executables << 'extjsmlc'

  s.license     = 'MIT'
end

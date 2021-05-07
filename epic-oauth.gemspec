require_relative 'lib/epic/oauth/version'

Gem::Specification.new do |spec|
  spec.name          = 'epic-oauth'
  spec.version       = Epic::Oauth::VERSION
  spec.authors       = ['Vlad Radulescu']
  spec.email         = ['oss@games.directory']

  spec.summary       = "Authenticate via EpicGames' EOS REST service and retrieve account details."
  spec.description   = "A Ruby wrapper for user authentication and account details via EpicGames' EOS REST service using oauth2."
  spec.homepage      = 'https://github.com/games-directory/epic-oauth'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/games-directory/epic-oauth'
  spec.metadata['changelog_uri'] = 'https://github.com/games-directory/epic-oauth/CHANGELOG.md'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.16'

  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 12.3'
end

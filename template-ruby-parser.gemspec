require_relative "lib/template/version"

Gem::Specification.new do |s|
  s.name = "template-ruby-parser"
  s.version = ::Template::Parser::Version
  s.summary = "A parser for the Template programming language"
  s.description =
    'Like "Hello {name}" with {name: "Dorian"} gives "Hello Dorian"'
  s.authors = ["Dorian Marié"]
  s.email = "dorian@dorianmarie.fr"
  s.files = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/dorianmariefr/template-ruby-parser"
  s.license = "MIT"
end

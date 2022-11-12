require_relative "lib/code-ruby-parser"

Gem::Specification.new do |s|
  s.name = "code-ruby-parser"
  s.version = ::Template::Parser::Version
  s.summary = "A parser for the Code programming language"
  s.description =
    "A parser for the Code programming language, like 1 + 1 and user.first_name"
  s.authors = ["Dorian Marié"]
  s.email = "dorian@dorianmarie.fr"
  s.files = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/dorianmariefr/template-ruby-parser"
  s.license = "MIT"
end

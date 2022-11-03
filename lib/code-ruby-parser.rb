require "zeitwerk"
require "forwardable"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/template-ruby-parser.rb")
loader.ignore("#{__dir__}/code-ruby-parser.rb")
loader.setup

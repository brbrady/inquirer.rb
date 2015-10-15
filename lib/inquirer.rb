require 'inquirer/version'
require 'inquirer/utils/iohelper'
Dir["#{File.dirname(__FILE__)}/inquirer/prompts/**/*.rb"].each { |f| require f }

module Ask
  extend self
  # implement prompts
  [List, Checkbox, Input, Confirm].each do |klass|
    method = klass.name.downcase
    define_method(method) do |*args|
      klass.ask *args
    end
  end

end

require 'inquirer/version'
require 'inquirer/utils/iohelper'
require 'inquirer/utils/ctrl'

module Ask
  extend self
  module Prompts
    PROMPTS = []
  end
  # require prompts after defining Prompts module,
  # so prompts can append their names to Prompts::PROMPTS
  Dir["#{File.dirname(__FILE__)}/inquirer/prompts/*.rb"].each{|f| require f}
  # implement prompts
  Prompts::PROMPTS.each do |prompt|
    define_method(prompt) do |*args|
      Prompts.const_get(prompt.capitalize).ask(*args)
    end
  end
end

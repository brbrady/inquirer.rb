require 'inquirer/version'
require 'inquirer/utils/iohelper'
require 'inquirer/utils/ctrl'
require 'inquirer/prompts'

module Ask
  extend self
  include Inquirer

  # implement prompts
  Prompts::PROMPTS.each do |prompt|
    define_method(prompt) do |*args|
      Prompts.const_get(prompt.capitalize).ask(*args)
    end
  end
end

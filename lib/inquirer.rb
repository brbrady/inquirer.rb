require 'inquirer/version'
require 'inquirer/utils/iohelper'
require 'inquirer/prompts/list'
require 'inquirer/prompts/checkbox'
require 'inquirer/prompts/input'
require 'inquirer/prompts/confirm'
require 'inquirer/prompts/choice'

module Ask
  extend self
  # implement prompts
  def list *args
    List.ask *args
  end
  def checkbox *args
    Checkbox.ask *args
  end
  def input *args, **kwargs
    Input.ask *args, **kwargs
  end
  def confirm *args
    Confirm.ask *args
  end
  def choice *args
    Choice.ask *args
  end
end

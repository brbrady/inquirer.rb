require 'inquirer/version'
require 'inquirer/utils/iohelper'
require 'inquirer/prompts/list'
require 'inquirer/prompts/checkbox'
require 'inquirer/prompts/input'
require 'inquirer/prompts/confirm'

module Ask
  extend self
  # implement prompts
  def list *args, **kwargs
    List.ask *args, **kwargs
  end
  def checkbox *args, **kwargs
    Checkbox.ask *args, **kwargs
  end
  def input *args, **kwargs
    Input.ask *args, **kwargs
  end
  def confirm *args, **kwargs
    Confirm.ask *args, **kwargs
  end
end

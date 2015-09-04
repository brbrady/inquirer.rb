require 'inquirer/version'
require 'inquirer/utils/iohelper'
require 'inquirer/utils/ctrl'
require 'inquirer/prompts/list'
require 'inquirer/prompts/checkbox'
require 'inquirer/prompts/input'
require 'inquirer/prompts/confirm'
require 'inquirer/prompts/password'

module Ask
  extend self
  # implement prompts
  def list *args
    List.ask *args
  end
  def checkbox *args
    Checkbox.ask *args
  end
  def input *args
    Input.ask *args
  end
  def confirm *args
    Confirm.ask *args
  end
  def password *args
    Password.ask *args
  end
end

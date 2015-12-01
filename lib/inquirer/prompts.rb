module Inquirer::Prompts
  PROMPTS = []
end

# require prompts after defining Prompts module,
# so prompts can append their names to Prompts::PROMPTS
Dir["#{File.dirname(__FILE__)}/prompts/*.rb"].
  each{|f| require f}

require_relative '../lib/inquirer'

password = Ask.password "What's your password"
puts "password: #{password}"

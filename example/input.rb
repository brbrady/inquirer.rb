require_relative '../lib/inquirer'

name = Ask.input "What's your name", default: "Monkey"
phone = Ask.input("What's your phone number", validate: /^[0-9-]+$/)
puts "name: #{name}"
puts "phone: #{phone}"

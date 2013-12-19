# inquirer.rb

Interactive user prompts on CLI for ruby.

... under development ...

## Examples

```ruby
idx = Ask.list "Look behind you...", [
  "a three-headed monkey!",
  "a pink pony",
  "Godzilla"
]
# idx is the selected index
```

```ruby
idx = Ask.checkbox "Monkey see, monkey...", [
  "don't",
  "eats Banana",
  "do"
]
# idx is an array containing the selections
```

## Compatibility

|      Ruby      | Linux | OS X | Windows |
|----------------|:-----:|:----:|:-------:|
| MRI 1.9.3      | ✔     | ✔    | ✘       |
| MRI 2.0.0      | ✔     | ✔    | ✘       |
| Rubinius 2.2.1 | ✔     | ✔    | ✘       |
| JRuby 1.7.x    | ✘     | ✘    | ✘       |

## Credit

This is basically the wonderful [Inquirer.js](https://github.com/SBoudrias/Inquirer.js) ported to ruby. I was unable to find a good gem to handle user interaction in ruby as well as this module does in JS.

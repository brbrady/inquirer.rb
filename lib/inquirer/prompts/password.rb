require 'term/ansicolor'

# Base rendering for input
module PasswordRenderer
  def render heading = nil, value = nil, footer = nil
    # render the heading
    ( heading.nil? ? "" : @heading % heading ) +
    # render the list
    ( value.nil? ? "" : @value % value.gsub(/./, '*') ) +
    # render the footer (masking response with '*')
    ( footer.nil? ? "" : @footer % footer )
  end

  def renderResponse heading = nil, response = nil
    # render the heading
    ( heading.nil? ? "" : @heading % heading ) +
    # render the footer (masking response with '*')
    ( response.nil? ? "" : @response % response.gsub(/./, '*') )
  end
end

# Default formatting for list rendering
class PasswordDefault
  include PasswordRenderer
  C = Term::ANSIColor
  def initialize( style )
    @heading = "%s: "
    @value = "%s"
    @footer = "%s"
  end
end

# Default formatting for response
class PasswordResponseDefault
  include PasswordRenderer
  C = Term::ANSIColor
  def initialize( style = nil )
    @heading = "%s: "
    @response = C.cyan("%s") + "\n"
  end
end

class Password < Input
  def initialize question = nil, renderer = nil, responseRenderer = nil
    @question = question
    @value = ""
    @prompt = ""
    @pos = 0
    @renderer = renderer || PasswordDefault.new( Inquirer::Style::Default )
    @responseRenderer = responseRenderer = PasswordResponseDefault.new()
  end

  def self.ask question = nil, opts = {}
    l = Password.new question, opts[:renderer], opts[:rendererResponse]
    l.run opts.fetch(:clear, true), opts.fetch(:response, true)
  end
end

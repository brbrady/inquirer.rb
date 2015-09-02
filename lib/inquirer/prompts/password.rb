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

class Password
  def initialize question = nil, renderer = nil, responseRenderer = nil
    @question = question
    @value = ""
    @prompt = ""
    @pos = 0
    @renderer = renderer || PasswordDefault.new( Inquirer::Style::Default )
    @responseRenderer = responseRenderer = PasswordResponseDefault.new()
  end

  def update_prompt
    # call the renderer
    @prompt = @renderer.render(@question, @value)
  end

  def update_response
    @prompt = @responseRenderer.renderResponse(@question, @value)
  end

  def update_cursor
    print IOHelper.char_left * @pos
  end

  # Run the list selection, wait for the user to select an item and return
  # the selected index
  # Params:
  # +clear+:: +Bool+ whether to clear the selection prompt once this is done
  #   defaults to true; set it to false if you want the prompt to remain after
  #   the user is done with selecting
  # +response+:: +Bool+ whether show the rendered response when this is done
  #   defaults to true; set it to false if you want the prompt to remain after
  #   the user is done with selecting
  def run clear, response
    # render the
    IOHelper.render( update_prompt )
    # loop through user input
    # IOHelper.read_char
    IOHelper.read_key_while true do |key|
      raw  = IOHelper.char_to_raw(key)

      case raw
      when "backspace"
        @value = @value.chop
        IOHelper.rerender( update_prompt )
        update_cursor
      when "left"
        if @pos < @value.length
          @pos = @pos + 1
          print IOHelper.char_left
        end
      when "right"
        if @pos > 0
          @pos = @pos - 1
          print IOHelper.char_right
        end
      when "return"
      else
        unless ["up", "down"].include?(raw)
          @value = @value.insert(@value.length - @pos, key)
          IOHelper.rerender( update_prompt )
          update_cursor
        end
      end
      raw != "return"
    end
    # clear the final prompt and the line
    IOHelper.clear if clear

    # show the answer
    IOHelper.render( update_response ) if response

    # return the value
    @value
  end

  def self.ask question = nil, opts = {}
    l = Password.new question, opts[:renderer], opts[:rendererResponse]
    l.run opts.fetch(:clear, true), opts.fetch(:response, true)
  end

end

require 'term/ansicolor'

# Base rendering for confirm
module ChoiceRenderer
  def render heading = nil, options = [], default = nil, footer = nil
    options[options.index(default)].capitalize! if default

    # render the heading
    ( heading.nil? ? "" : @heading % heading ) +
    # render the list
    @options % options.join(', ') +
    # render the footer
    ( footer.nil? ? "" : @footer % footer )
  end

  def renderResponse heading = nil, response = nil
    # render the heading
    ( heading.nil? ? "" : @heading % heading ) +
    # render the footer
    ( response.nil? ? "" : @response % response )
  end

  def warning message
    # render the warning
    @warning % message
  end
end

# Default formatting for confirm rendering
class ChoiceDefault
  include ChoiceRenderer
  C = Term::ANSIColor
  def initialize( style )
    @heading = "%s: "
    @options = "(%s)"
    @footer = "%s"
  end
end

# Default formatting for response
class ChoiceResponseDefault
  include ChoiceRenderer
  C = Term::ANSIColor
  def initialize( style = nil )
    @heading = "%s: "
    @response = C.cyan("%s") + "\n"
    @warning = C.yellow("%s") + "\n"
  end
end

class Choice
  def initialize question = nil, options = nil, default = nil, renderer = nil, responseRenderer = nil
    @question = question
    @options = options
    @value = ""
    @default = default
    @prompt = ""
    @renderer = renderer || ChoiceDefault.new( Inquirer::Style::Default )
    @responseRenderer = responseRenderer = ChoiceResponseDefault.new()
  end

  def update_prompt
    # call the renderer
    @prompt = @renderer.render(@question, (@options.is_a?(Hash)? @options.keys : @options), @default)
  end

   def update_response
    @prompt = @responseRenderer.renderResponse(@question, (@options.is_a?(Hash)? @options[@value] : @value))
  end

  def print_warning message
    IOHelper.clear
    $stderr.print @responseRenderer.warning message
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
    # loop through user confirm
    # IOHelper.read_char
    IOHelper.without_cursor do
      IOHelper.read_key_while true do |key|
        raw  = IOHelper.char_to_raw(key)

        if (@options.is_a?(Hash)? @options.keys : @options).include?(raw)
          @value = raw
          false
        else
          case raw
          when "return"
            if @default
              @value = @default
              false
            else
              print_warning "No default value, please make a selection."
              IOHelper.rerender( update_prompt )
              true
            end
          else
            if raw.downcase =~ /^[a-z]$/
              print_warning "#{raw} is not in #{(@options.is_a?(Hash)? @options.keys : @options).join(', ')}"
              IOHelper.rerender( update_prompt )
            end
            true
          end
        end
      end
    end

    # clear the final prompt and the line
    IOHelper.clear if clear

    # show the answer
    IOHelper.render( update_response ) if response

    # return the value
    @value
  end

  def self.ask question = nil, options = nil, default = nil, opts = {}
    l = Choice.new question, options, default, opts[:renderer], opts[:rendererResponse]
    l.run opts.fetch(:clear, true), opts.fetch(:response, true)
  end

end

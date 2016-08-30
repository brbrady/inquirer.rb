require 'term/ansicolor'

module Inquirer::Prompts
  PROMPTS << :input

  # Base rendering for input
  module InputRenderer
    def render heading = nil, value = nil, default = nil, footer = nil
      # render the heading
      ( heading.nil? ? "" : @heading % heading ) +
        # render the defaults
        ( default.nil? ? "" : @default % default ) +
        # render the list
        ( value.nil? ? "" : @value % value ) +
        # render the footer
        ( footer.nil? ? "" : @footer % footer )
    end

    def renderResponse heading = nil, response = nil
      # render the heading
      ( heading.nil? ? "" : @heading % heading ) +
        # render the footer
        ( response.nil? ? "" : @response % response )
    end

    def error message
      # render the error
      @error % message
    end

    def warning message
      # render the warning
      @warning % message
    end
  end

  # Default formatting for list rendering
  class InputDefault
    include InputRenderer
    C = Term::ANSIColor
    def initialize( style )
      @heading = "%s: "
      @default = "(%s) "
      @value = "%s"
      @footer = "%s"
    end
  end

  # Default formatting for response
  class InputResponseDefault
    include InputRenderer
    C = Term::ANSIColor
    def initialize( style = nil )
      @heading = "%s: "
      @response = C.cyan("%s") + "\n"
      @error = C.red("%s") + "\n"
      @warning = C.yellow("%s") + "\n"
    end
  end

  class Input
    include Ctrl
    def initialize(question = nil,
                   default: nil,
                   renderer: nil,
                   responseRenderer: nil,
                   password: false,
                   **opts)
      @question = question
      @value = ""
      @default = default
      @prompt = ""
      @password = password
      @pos = 0
      @renderer = renderer || InputDefault.new( Inquirer::Style::Default )
      @responseRenderer = responseRenderer || InputResponseDefault.new()
      @validate = opts[:validate]
      @invalid_response = opts[:invalid_response]
    end

    def display_value
      return @value unless @password
      @value.tr("^\n", '*')
    end

    def update_prompt
      # call the renderer
      @prompt = @renderer.render(@question, display_value, @default)
    end

    def update_response
      @prompt = @responseRenderer.renderResponse(@question, @password ? '' : display_value)
    end

    def update_cursor
      print Inquirer::IOHelper.char_left * @pos
    end

    def print_error message
      Inquirer::IOHelper.clear
      $stderr.print @responseRenderer.error message
    end

    def print_warning message
      Inquirer::IOHelper.clear
      $stderr.print @responseRenderer.warning message
    end

    def valid_response?
      @validate.nil? or
        (@validate.is_a? Regexp and @validate =~ @value) or
        (@validate.is_a? Proc and @validate[@value])
    end

    def print_invalid_response
      if @invalid_response
        message = @invalid_response
      elsif @validate.is_a? Regexp
        message = "Invalid answer (must match #{@validate.inspect})" 
      else
        message = "Invalid answer."
      end
      print_warning message
      Inquirer::IOHelper.render( update_prompt )
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
      Inquirer::IOHelper.render( update_prompt )
      # loop through user input
      # Inquirer::IOHelper.read_char
      Inquirer::IOHelper.read_key_while true do |key|
        raw  = Inquirer::IOHelper.char_to_raw(key)

        case raw
        when "backspace"
          @value = @value.chop
          Inquirer::IOHelper.rerender( update_prompt )
          update_cursor
        when "left"
          if @pos < @value.length
            @pos = @pos + 1
            print Inquirer::IOHelper.char_left
          end
        when "right"
          if @pos > 0
            @pos = @pos - 1
            print Inquirer::IOHelper.char_right
          end
        when /^ctrl-([aekuw])$/
          ctrl $1.to_sym
          Inquirer::IOHelper.rerender( update_prompt )
          update_cursor
        when /^alt-([bdf])$/
          alt $1.to_sym
          Inquirer::IOHelper.rerender( update_prompt )
          update_cursor
        when "return"
          unless valid_response?
            print_invalid_response
            raw = ""
          end
          if not @default.nil? and @value == ""
            @value = @default
          end
        else
          unless ["up", "down"].include?(raw)
            @value = @value.insert(@value.length - @pos, key)
            Inquirer::IOHelper.rerender( update_prompt )
            update_cursor
          end
        end
        raw != "return"
      end
      # clear the final prompt and the line
      Inquirer::IOHelper.clear if clear

      # show the answer
      Inquirer::IOHelper.render( update_response ) if response

      # return the value
      @value
    end

    def self.ask question = nil, **opts
      l = Input.new question, **opts
      l.run opts.fetch(:clear, true), opts.fetch(:response, true)
    end

  end

end

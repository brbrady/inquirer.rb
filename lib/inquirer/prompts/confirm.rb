require 'term/ansicolor'

module Inquirer::Prompts
  PROMPTS << :confirm

  # Base rendering for confirm
  module ConfirmRenderer
    def render heading = nil, default = nil, footer = nil
      options = ['y','n']
      options[0].capitalize! if default == true
      options[1].capitalize! if default == false

      # render the heading
      ( heading.nil? ? "" : @heading % heading ) +
        # render the defaults
        (@default % options ) +
        # render the footer
        ( footer.nil? ? "" : @footer % footer )
    end

    def renderResponse heading = nil, response = nil
      # render the heading
      ( heading.nil? ? "" : @heading % heading ) +
        # render the footer
        ( response.nil? ? "" : @response % response )
    end

    def renderSloth heading = nil, response = nil, footer = nil
      options = ['y','n']
      if response == true
        options[0] = Term::ANSIColor.intense_cyan('Y')
      elsif response == false
        options[1] = Term::ANSIColor.intense_cyan('N')
      end

      # render the heading
      ( heading.nil? ? "" : @heading % heading ) +
        # render the defaults
        ( @default % options ) +
        # render the footer
        ( footer.nil? ? "" : @footer % footer )
    end
  end

  # Default formatting for confirm rendering
  class ConfirmDefault
    include ConfirmRenderer
    C = Term::ANSIColor
    def initialize( style )
      @heading = "%s: "
      @default = "(%s/%s)"
      @footer = "%s"
    end
  end

  # Default formatting for response
  class ConfirmResponseDefault
    include ConfirmRenderer
    C = Term::ANSIColor
    def initialize( style = nil )
      @heading = "%s: "
      @response = C.cyan("%s") + "\n"
    end
  end

  class Confirm
    def initialize(question = nil,
                   default = nil,
                   renderer: nil,
                   responseRenderer: nil,
                   **opts)
      @question = question
      @value = nil
      @default = default
      @prompt = ""
      @sloth_mode = opts[:sloth_mode]
      @renderer = renderer || ConfirmDefault.new( Inquirer::Style::Default )
      @responseRenderer = responseRenderer || ConfirmResponseDefault.new()
    end

    def update_prompt
      # call the renderer
      @prompt = @renderer.render(@question, @default)
    end

    def update_sloth
      @prompt = @renderer.renderSloth(@question, @value)
    end

    def update_response
      @prompt = @responseRenderer.renderResponse(@question, (@value)? 'Yes' : 'No')
    end

    def sloth_mode
      return false unless @sloth_mode
      Inquirer::IOHelper.rerender( update_sloth) unless @value.nil?
      true
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
      # loop through user confirm
      # Inquirer::IOHelper.read_char
      Inquirer::IOHelper.without_cursor do
        Inquirer::IOHelper.read_key_while true do |key|
          raw  = Inquirer::IOHelper.char_to_raw(key)

          case raw
          when "y","Y"
            @value = true
            sloth_mode
          when "n","N"
            @value = false
            sloth_mode
          when "return"
            @value = @default if @value.nil? and not @default.nil?
            @value.nil?
          else
            true
          end

        end
      end

      # clear the final prompt and the line
      Inquirer::IOHelper.clear if clear

      # show the answer
      Inquirer::IOHelper.render( update_response ) if response

      # return the value
      @value
    end

    def self.ask question = nil, **opts
      l = Confirm.new question, opts.fetch(:default, true), **opts
      l.run opts.fetch(:clear, true), opts.fetch(:response, true)
    end

  end

end

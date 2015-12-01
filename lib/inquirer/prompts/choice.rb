require 'term/ansicolor'

# Base rendering for confirm
module ChoiceRenderer
  def render heading = nil, choices = [], default = nil, footer = nil

    # render the heading
    ( heading.nil? ? "" : @heading % heading ) +
    # render the list

    @options % choices.map{|choice, key|
      render_item(choice, key, default)}.join(', ') +
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

  private
  def render_item choice, key, default
    (choice == default)?
      choice.clone.sub(key, "[#{key.upcase}]") :
      choice.clone.sub(key, "[#{key}]")
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
  def initialize(question = nil,
                 choices = nil,
                 default: nil,
                 renderer: nil,
                 responseRenderer: nil)
    @question = question
    @default = default
    @value = ""
    @prompt = ""
    @renderer = renderer || ChoiceDefault.new( Inquirer::Style::Default )
    @responseRenderer = responseRenderer = ChoiceResponseDefault.new()
    parse_choices(choices, default)
  end

  def update_prompt
    # call the renderer
    @prompt = @renderer.render(@question,
                               @choices.map{|k,v|[v[0], k]},
                               @default)
  end

  def update_response
    @prompt = @responseRenderer.renderResponse(@question, @final || @value)
  end

  def print_warning message
    IOHelper.clear
    $stderr.print @responseRenderer.warning message
  end

  def parse_choices(choices, default = nil)
    @choices = {}
    rx = /^\w*\[(\w)\]\w*$/
    excludes = choices.map{|k,| k =~ rx; [$1, k]}.compact.to_h
    #uniq! returns nil if array is already unique
    if @default.nil?
      overrides = choices.map{|k,|
        k.gsub(/\[(\w)\]/, '\1') if k =~ rx and $1 =~ /[A-Z]/
      }.compact
      @default = overrides[0].downcase if overrides.count == 1
    end
    choices.each do |choice, final|
      if choice =~ rx
        @choices[$1] = [choice.gsub(/\[(\w)\]/, '\1'), final]
      else
        choice.split('').each_with_index do |char, i|
          if @choices.include? char or (excludes.include?(char) and not excludes[char] == choice)
            next unless i == choice.length - 1
            raise ArgumentError.new('No unique selection character available!')
          else
            @choices[char] = [choice, final]
            break
          end # if @choices.include? char
        end # choice.split('').each_with_index do |char, i|
      end # if $2
    end # choices.each do |choice, final|
  end

  # Run the choice selection, wait for the user to select an item and return
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
        raw  = IOHelper.char_to_raw(key).downcase

        case raw
        when /^[a-z]$/
          if @choices.include? raw
            @value, @final = @choices[raw]

            false
          else
            print_warning "#{raw} is not in #{@choices.keys.join(', ')}"
            IOHelper.rerender( update_prompt )
            true
          end
        when "return"
          if @default
            @value = @default
            false
          else
            print_warning "No default value, please make a selection."
            IOHelper.rerender( update_prompt )
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

  def self.ask question = nil, choices = nil, **opts
    l = Choice.new question, choices, **opts
    l.run opts.fetch(:clear, true), opts.fetch(:response, true)
  end
end

require 'io/console'

module Inquirer::IOHelper
  extend self

  @rendered = ""

  KEYS = {
    " " => "space",
    "\t" => "tab",
    "\r" => "return",
    "\n" => "linefeed",
    "\e" => "escape",
    "\e[A" => "up",
    "\e[B" => "down",
    "\e[C" => "right",
    "\e[D" => "left",
    "\177" => "backspace",
    "\e[3~" => "delete",
    # ctrl + c    cancel
    "\003" => "ctrl-c",
    # ctrl + d    exit
    "\004" => "ctrl-d",
    # ctrl + w    delete word before cursor
    "\u0017" => "ctrl-w",
    # alt  + d    delete word after cursor
    "\ed" => "alt-d",
    # alt  + b    jump to beginning of word
    "\eb" => "alt-b",
    # alt  + f    jump to end of word
    "\ef" => "alt-f",
    # ctrl + a    jump to beginning of line
    "\u0001" => "ctrl-a",
    # ctrl + e    jump to end of line
    "\u0005" => "ctrl-e",
    # ctrl + u    delete to beginning of line
    "\u0015" => "ctrl-u",
    # ctrl + k    delete to end of line
    "\v" => "ctrl-k"
  }

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  # Read a keypress on console. Return the key name (e.g. "space", "a", "B")
  # Params:
  # +with_exit_codes+:: +Bool+ whether to throw Interrupts when the user presses
  #   ctrl-c and ctrl-d. (true by default)
  def read_key with_exit_codes = true, return_char = false
    char = read_char
    raise Interrupt if with_exit_codes and ( char == "\003" or char == "\004" )
    if return_char then char else char_to_raw char end
  end

  # Get each key the user presses and hand it one by one to the block. Do this
  # as long as the block returns truthy
  # Params:
  # +&block+:: +Proc+ a block that receives a user key and returns truthy or falsy
  def read_key_while return_char = false, &block
    STDIN.noecho do
      # as long as the block doen't return falsy,
      # read the user input key and sned it to the block
      while block.( Inquirer::IOHelper.read_key true, return_char )
      end
    end
  end

  # Get the console window size
  # Returns: [width, height]
  def winsize
    STDIN.winsize
  end

  # Render a text to the prompt
  def render prompt
    @rendered = prompt
    print prompt
  end

  # Clear the prompt and render the update
  def rerender prompt
    clear
    render prompt
  end

  def error message
    clear
    puts message
  end

  # clear the console based on the last text rendered
  def clear
    # get console window height and width
    h,w = Inquirer::IOHelper.winsize
    # determine how many lines to move up
    n = @rendered.scan(/\n/).length
    # jump back to the first position and clear the line
    print carriage_return + ( line_up + clear_line ) * n + clear_line
  end

  # hides the cursor and ensure the curso be visible at the end
  def without_cursor
    # tell the terminal to hide the cursor
    print `tput civis`
    begin
      # run the block
      yield
    ensure
      # tell the terminal to show the cursor
      print `tput cnorm`
    end
  end

  def char_to_raw char
    KEYS.fetch char, char
  end

  def carriage_return;  "\r"    end
  def line_up;          "\e[A"  end
  def clear_line;       "\e[0K" end
  def char_left;        "\e[D" end
  def char_right;       "\e[C" end

end

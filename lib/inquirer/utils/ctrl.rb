module Ctrl
  def ctrl(key)
    case key
    when :a
      @pos = @value.length
    when :e
      @pos = 0
    when :k
      # delete to end of line
      @value = @value[0...@value.length-@pos]
      @pos = 0
    when :u
      # delete to beginning of line
      @value = @value[@value.length - @pos...@value.length]
      @pos = @value.length
    when :w
      # delete word before cursor
      head = @value[0...@value.length-@pos].rstrip
      tail = @value[@value.length - @pos...@value.length]
      head[-1] = '' while head[-1] != ' ' and head[-1]
      @value = head + tail
    end # case key
  end # def ctrl(key)

  def alt(key)
    case key
    when :d
      # delete word after cursor
      head = @value[0...@value.length-@pos]
      tail = @value[@value.length - @pos...@value.length].lstrip
      tail[0] = '' while tail[0] != ' ' and tail[0]
      @pos = tail.length
      @value = head + tail
    when :f
      # jump to end of word
      @pos -= 1 while @pos != 0 and @value[@value.length-@pos] == ' '
      @pos -= 1 while @pos != 0 and @value[@value.length-@pos] != ' '
    when :b
      # jump to beginning of word
      while @pos < @value.length and [nil, ' '].include? @value[@value.length-(@pos+1)]
        @pos += 1
      end
      while @pos < @value.length and @value[@value.length-(@pos+1)] != ' '
        @pos += 1
      end
    end # case key
  end # def alt(key)
end

require 'taggie/string'

class String
  def to_taggie
    Taggie::String.new(self)
  end
end
# HTML/XML parsing with regex
module Taggie
  autoload :Array,  'taggie/array'
  autoload :String, 'taggie/string'

  def to_taggie
    String.new(self)
  end
end

String.send(:include, Taggie)
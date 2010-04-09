module Taggie
  class String < String

    AttributePrefix = '[^>]+?'
    AttributeValue = '("|\')(.*?)\2|(\S*)'
    OpenTag = '<(\w+)[^>]*'
    CloseTag = '[\/\?]>|>'
    SpecialTags = '<!--.*?-->|<\?.*?\?>|[^>]'
    TagMatcher = /(#{OpenTag}(?:#{CloseTag}((?:#{OpenTag}(?:#{CloseTag}.*<\/\4>)|#{SpecialTags})*)<\/\2>)|#{SpecialTags}*)/m

    undef :id if instance_methods.include?('id')

    attr_accessor :parent

    def [](attribute)
      [Integer, Range].include?(attribute.class) ? super(attribute) : to_h[attribute.to_s]
    end

    def []=(attribute, value)
      if [Integer, Range].include?(attribute.class)
        value = super(attribute, value)
      elsif !%w(comment string).include?(type)
        quote = value.to_s.include?('"') ? "'" : '"'
        if value.nil?
          sub!(/^(#{AttributePrefix})\s+#{attribute}=(?:#{AttributeValue})/m, '\1')
        elsif tag =~ /\s+#{attribute}=/m
          sub!(/^(#{AttributePrefix}#{attribute}=)(?:#{AttributeValue})/m,"\\1#{quote}#{value}#{quote}")
        else
          sub!(/^(#{AttributePrefix})\s*(\/|\?)?>/m, "\\1 #{attribute}=#{quote}#{value}#{quote}\\2>")
        end
        reload!(:attributes, :tag, :to_h)
        rebuild!
      end
      value
    end

    def attributes
      @attributes ||= %w(comment doctype string).include?(type) ? [] : tag.scan(/([\S]+)=(?:#{AttributeValue})/m).map! { |match| [match[0], match[2] || match[3]] }
    end

    def children
      @children ||= Collection.new(inner_html.siblings_and_self(false).map! { |child| child.parent = self; child }, self)
    end

    def class_name
      self['class']
    end

    def class_name=(value)
      self['class'] = value
    end

    def dup
      to_s.to_taggie
    end

    def inner_html
      regex, capture_index = inner_html_regex
      inner_html_match = match(regex)
      html = self.class.new(inner_html_match ? inner_html_match.captures[capture_index].to_s : '')
      html.parent = self
      html
    end

    def inner_html=(value)
      unless inner_html == value
        sub!(inner_html, value)
        reload!(:children)
        rebuild!
      end
      value
    end

    def inner_html_regex
      @inner_html_regex ||= begin
        @inner_html_regex_hash ||= { 'comment' => /^<!--(.*?)-->/m, 'doctype' => //, 'string' => /^([^<]+)/m, 'xml' => // }
        regex, capture_index = @inner_html_regex_hash[type], 0
        regex, capture_index = TagMatcher, 2 if regex.nil?
        [regex, capture_index]
      end
    end

    def method_missing(method, *args)
      if method.to_s =~ /=$/
        self[$`] = args[0]
      elsif args.empty?
        self[method.to_s]
      else
        super
      end
    end

    def rebuild!
      self.inner_html = children.join
      parent.rebuild! if parent
      self
    end

    def reload!(*variables)
      variables = variables.empty? ? instance_variables : variables.map! { |variable| "@#{variable}" }
      variables.each { |variable| instance_variable_set(variable, nil) }
    end

    def siblings_and_self(lookup_parent = true)
      lookup_parent && parent ? parent.children : Collection.new(scan(inner_html_regex[0]).map! { |match| match[0].parent = parent; match[0] }, parent)
    end

    def tag
      @tag ||= begin
        @tag_hash ||= { 'comment' => self, 'string' => inner_html }
        @tag_hash[type] || match(/^([^>]+>)/m).captures[0]
      end
    end

    def to_h
      @to_h ||= Hash[*attributes.flatten].merge!(:html => self)
    end

    def to_s
      ::String.new(self)
    end

    def type
      @type ||= begin
        @type_hash ||= { (/^<\??([^!\s]+)/m) => 1, (/^<!--/) => 'comment', (/^<!doctype/i) => 'doctype', (/^[^<]*/m) => 'string' }
        type = @type_hash.detect { |regex, value| self =~ regex }[1]
        type.is_a?(Integer) ? eval("$#{type}").downcase : type
      end
    end

  end
end
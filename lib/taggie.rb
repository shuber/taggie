class String; def to_taggie;Taggie.new self end end
class Taggie < String
  AttributeValue = '("|\')(.*?)\2|(\S*)'
  OpenTag = '<(\w+)[^>]*'
  CloseTag = '\/>|>'
  SpecialTags = '<!--.*?-->|<\?.*?\?>|[^>]'
  TagMatcher = /(#{OpenTag}(?:#{CloseTag}((?:#{OpenTag}(?:#{CloseTag}.*<\/\4>)|#{SpecialTags})*)<\/\2>)|#{SpecialTags}*)/m
  alias :__id__ :id;alias :__class__ :class;undef :id,:class
  attr_accessor :parent
  def [] a; [Integer,Range].include?(a.class)?super: to_h[a.to_s] end
  def []= a,v;@attributes=@tag=nil;[Integer,Range].include?(a.class)?super: !%w(comment string).include?(type)? v ? (q=v.include?('"')? "'":'"';sub!(/^([^>]+#{a}=)(?:#{AttributeValue})/m,"\\1#{q}#{v}#{q}");sub!(/^([^>]+?)\s*(\/|\?)?>/m, "\\1 #{a}=#{q}#{v}#{q}\\2>") if tag !~/\s+#{a}=/m):sub!(/^([^>]+)\s+#{a}=(?:#{AttributeValue})/,'\1'):nil;rebuild!;v end
  def attributes;@attributes||=%w(comment doctype string).include?(type)?[]:tag.scan(/([\S]+)=(?:#{AttributeValue})/m).map!{|m|[m[0],m[2]||m[3]]} end
  def children;@children||=inner_html.siblings_and_self.map!{|c|c.parent=self;c} end
  def inner_html;r,c=inner_html_regex;m=match(r);m ?m.captures[c]:'' end
  def inner_html= v;@children=nil;sub! inner_html,v;rebuild!;v end
  def inner_html_regex;r,c={'comment'=>/^<!--(.*?)-->/m,'doctype'=>//,'string'=>/^([^<]+)/m,'xml'=>/^<\?(.*?)\?>/m}[type],0;r,c=TagMatcher,2 if r.nil?;[r,c] end
  def method_missing m,*a;m.to_s=~/=$/?self[$`]=a[0]:a==[]?self[m.to_s]:super end
  def rebuild!;(parent.inner_html=parent.children.join;parent.parent.rebuild! if parent.parent) if parent end
  def siblings;siblings_and_self[1..-1] end
  def siblings_and_self;@siblings_and_self||=scan(inner_html_regex[0]).map!{|m|m[0]} end
  def tag;@tag||={'comment'=>self,'string'=>inner_html}[type]||match(/^([^>]+>)/m).captures[0] end
  def to_h; Hash[*attributes.flatten].merge! :html=>self end
  def to_s; String.new self end
  def type;@type||(m={(/^<([\w\-_:]+)[^>]*>/m)=>'1',(/^<!--/m)=>'comment',(/^<!doctype[^>]*>/mi)=>'doctype',(/^<\?/m)=>'xml'}.detect{|r,v|r=~self};@type=m ?eval('$'+m[1])||m[1]:'string') end
end
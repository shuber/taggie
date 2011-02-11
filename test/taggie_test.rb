require 'test_helper'

class TaggieTest < Test::Unit::TestCase
  def test_this_gem
    html = '<div class="cool" id="header"><img src="logo.png" /><h1>Your Company</h1></div><div id="body"><p class="content">some <span>content</span> here</p></div><div id="footer">footer</div>'.to_taggie
    puts html.inner_html
    html.children << '<div></div>'
    puts html.inner_html
    puts html.to_h.inspect
    flunk
  end
end
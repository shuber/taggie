require File.join(File.dirname(__FILE__), 'test_helper')

class TaggieTest < Test::Unit::TestCase

  should 'test this gem' do
    html = '<div id="header"><img src="logo.png" /><h1>Your Company</h1></div><div id="body"><p class="content">some <span>content</span> here</p></div>'.to_taggie
    flunk
  end

end
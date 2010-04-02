require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'taggie'

class Test::Unit::TestCase

  def assert_all_equal(value, *others)
    others.each { |other| assert_equal value, other }
  end

end
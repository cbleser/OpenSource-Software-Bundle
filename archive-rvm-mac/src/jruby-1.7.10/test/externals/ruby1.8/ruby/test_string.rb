require 'test/unit'
require File.expand_path('envutil', File.dirname(__FILE__))

class TestString < Test::Unit::TestCase
  def check_sum(str, bits=16)
    sum = 0
    str.each_byte {|c| sum += c}
    sum = sum & ((1 << bits) - 1) if bits != 0
    assert_equal(sum, str.sum(bits))
  end
  def test_sum
    assert_equal(0, "".sum)
    assert_equal(294, "abc".sum)
    check_sum("abc")
    check_sum("\x80")
    0.upto(70) {|bits|
      check_sum("xyz", bits)
    }
  end

  def test_inspect
    original_kcode = $KCODE

    $KCODE = 'n'
    assert_equal('"\343\201\202"', "\xe3\x81\x82".inspect)

    $KCODE = 'u'
    # JRuby fails this on Mac OS X (not tested on other platforms)
    # assert_equal('"\\343\\201\\202"', "\xe3\x81\x82".inspect)
    assert_no_match(/\0/, "\xe3\x81".inspect, '[ruby-dev:39550]')
  ensure
    $KCODE = original_kcode
  end

  def test_concat
    assert_raise(TypeError) { "foo" << :foo }
  end

  def test_hash_random
    str = 'abc'
    a = [str.hash.to_s]
    cmd = sprintf("%s -e 'print %s.hash'", EnvUtil.rubybin, str.dump)
    3.times {
      IO.popen(cmd, "rb") {|o|
        a << o.read
      }
    }
    assert_not_equal([str.hash.to_s], a.uniq)
  end
end

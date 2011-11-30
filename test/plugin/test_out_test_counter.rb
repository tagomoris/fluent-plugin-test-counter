require 'helper'

class TestCounterOutputTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
show_count false
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::TestCounterOutput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal false, d.instance.show_count

    d = create_driver %[
show_count true
]
    assert_equal true, d.instance.show_count
    
    d = create_driver %[
show_count false
]
    assert_equal false, d.instance.show_count
  end

  def test_format
    d = create_driver

    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d.emit({"a"=>1}, time)
    time = Time.parse("2011-01-02 13:14:16 UTC").to_i
    d.emit({"a"=>2}, time)

    d.expect_format %[20110102131415\n]
    d.expect_format %[20110102131416\n]

    d.run
  end

  def test_write
    d = create_driver
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d.emit({"a"=>1}, time)
    d.emit({"a"=>2}, time)
    result = d.run
    assert_equal [['20110102131415', 2]], result

    d = create_driver
    time = Time.parse("2011-01-02 13:14:16 UTC").to_i
    1001.times do 
      d.emit({"a"=>1}, time)
    end
    time = Time.parse("2011-01-02 13:14:17 UTC").to_i
    523.times do 
      d.emit({"a"=>1}, time)
    end
    time = Time.parse("2011-01-02 13:14:18 UTC").to_i
    12134.times do 
      d.emit({"a"=>1}, time)
    end
    result = d.run
    assert_equal [['20110102131416', 1001],['20110102131417', 523],['20110102131418', 12134]], result
  end
end

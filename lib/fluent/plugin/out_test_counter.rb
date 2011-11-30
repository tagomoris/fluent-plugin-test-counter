class Fluent::TestCounterOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('testcounter', self)

  attr_accessor :show_count

  include Fluent::SetTimeKeyMixin
  config_set_default :include_time_key, true

  def initialize
    super
    @counter = {}
  end

  def configure(conf)
    super
    @show_count = Fluent::Config.bool_value(conf['show_count'] || 'false')
    @timef = Fluent::TimeFormatter.new('%Y%m%d%H%M%S', false)
  end

  def start
    super
  end

  def shutdown
    super
  end

  def format(tag, time, record)
    @timef.format(time) + "\n"
  end

  def write(chunk)
    now_s = @timef.format(Fluent::Engine.now)
    chunk.read.split("\n").each {|record|
      next if record.length < 1
      @counter[record] ||= 0
      @counter[record] += 1
    }
    results = []
    @counter.keys.select{|k| k < now_s}.sort.each do |k|
      count = @counter.delete(k)
      p "#{k} #{count}" if @show_count
      results.push([k, count])
    end
    results
  end
end

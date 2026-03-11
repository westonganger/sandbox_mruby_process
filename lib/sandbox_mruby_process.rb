begin
  require_relative "sandbox_mruby/sandbox_mruby"
rescue LoadError
  raise LoadError.new("SandboxMruby native extension not found. Run `rake compile` first (from a git clone, run `rake setup`).")
end

class SandboxMrubyProcess
  @@global_config = {
    timeout: 60, # inseconds
    memory_limit: 10_000_000, # in bytes
  }

  def self.global_config
    @@global_config
  end

  def initialize(timeout: nil, memory_limit: nil)
    @timeout = timeout || self.class.global_config.fetch(timeout)
    @memory_limit = memory_limit || self.class.global_config.fetch(:memory_limit)

    @process_context = Object.new

    _sandbox_mruby_init(@timeout, @memory_limit)
  end

  def expose_object(obj)
    case obj
    when Method
      @process_context.define_singleton_method(obj.name) do |*args|
        obj.call(*args)
      end

      _sandbox_mruby_define_function(obj.name)
    when Module, Class
      @process_context.extend(obj)

      obj.instance_methods(false).each do |name|
        _sandbox_muby_define_function(name.to_s)
      end
    else
      #instances
      obj.public_methods(false).each do |name|
        target = obj # is this needed?

        @process_context.define_singleton_method(name) do |*args|
          target.public_send(name, *args)
        end

        _sandbox_mruby_define_function(name.to_s)
      end
    end

    return true
  end

  def close
    _sandbox_mruby_close
  end

  def closed?
    _sandbox_mruby_closed?
  end

  def reset!
    _sandbox_mruby_reset!
  end

  def eval(ruby_code)
    value, output, error = _sandbox_mruby_eval(code)

    return [value, output, error]
  end

  def run_code(code)
    eval(code)

    if result[:error]
      return "Error: #{result[:error]}"
    end

    run_output = ""

    if !result[:output].empty?
      run_output << "#{result[:output]}"
    end

    run_output << "#{result[:value]}"

    run_output
  end

  def repl
    require "readline"

    help_text = <<~HELP
      Try asking things like:
        - What's this customer's email?
        - Show me their orders
        - Do they have any open tickets?
        - Show me the details of ticket #1
        - Close ticket #1
        - Create a ticket about needing a refund
        - Update ticket #1's subject to "Resolved: order status"
        - Try to delete a ticket (you can't!)
    HELP

    puts "MRuby REPL"
    puts "Type 'exit' to quit\n\n"
    puts "Type 'help' for more info\n\n"

    prompt = "sandbox_mruby> "

    input = ""

    i = 0

    loop do
      input = input.strip

      if i == 0
        line = Readline.readline(prompt, true)
      else
        line = Readline.readline((input.empty? ? prompt : "     .. "), true)
      end

      case input.downcase
      when "exit"
        break
      when "help"
        puts help_text
        next
      end

      line << "\n"
      input << "\n"

      result = eval(input)

      if result[:error]&.match?(/SyntaxError.*unexpected.*\$end|unexpected end of file/i)
        next # incomplete input, keep reading input on new line
      end

      if !result[:output].empty?
        sandbox_mruby_print result[:output]
      end

      if result[:error]
        puts "Error: #{result[:error]}"
      else
        puts "#{result[:value]}"
      end

      input = ""

      i += 1
    end
  end
end

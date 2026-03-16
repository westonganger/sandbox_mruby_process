begin
  require_relative "sandbox_mruby_process_ext/sandbox_mruby_process.bundle"

  ### Methods defined by sandbox_mruby_process native extension:
  # SandboxMrubyProcess#_mruby_init
  # SandboxMrubyProcess#_mruby_eval
  # SandboxMrubyProcess#_mruby_define_function
  # SandboxMrubyProcess#_mruby_reset!
  # SandboxMrubyProcess#_mruby_close
  # SandboxMrubyProcess#_mruby_closed?
rescue LoadError
  raise LoadError.new("sandbox_mruby_process native extension not found. Run `rake compile` first (from a git clone, run `rake setup`).")
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
    @timeout = timeout || self.class.global_config.fetch(:timeout)
    @memory_limit = memory_limit || self.class.global_config.fetch(:memory_limit)

    @process_context = Object.new

    _mruby_init(@timeout, @memory_limit)
  end

  def expose_object(obj)
    case obj
    when Method
      @process_context.define_singleton_method(obj.name) do |*args|
        obj.call(*args)
      end

      _mruby_define_function(obj.name.to_s)
    when Module, Class
      @process_context.extend(obj)

      obj.instance_methods(false).each do |name|
        _mruby_define_function(name.to_s)
      end
    else
      #instances
      obj.public_methods(false).each do |name|
        target = obj # is this needed?

        @process_context.define_singleton_method(name) do |*args|
          target.public_send(name, *args)
        end

        _mruby_define_function(name.to_s)
      end
    end

    return true
  end

  def close
    _mruby_close
  end

  def closed?
    _mruby_closed?
  end

  def reset!
    _mruby_reset!
  end

  def eval_code(code)
    # code = code
    #   .gsub(" puts", " print")
    #   .gsub(/^puts/, "print")

    value, output, error = _mruby_eval(code)

    # if value == "nil"
    #   value = nil
    # end

    if output == ""
      output = nil
    end

    return {
      value: value,
      output: output,
      error: error,
    }
  end

  def repl
    begin
      require "readline"
    rescue LoadError
      raise LoadError.new("Failed to require 'readline'. If you would like to use the repl feature then please add the gem readline to your projects Gemfile.")
    end

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
    puts "Type 'exit' to quit"
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

      result = eval_code(input)

      if result[:error]&.match?(/SyntaxError.*unexpected.*\$end|unexpected end of file/i)
        next # incomplete input, keep reading input on new line
      end


      ### TODO puts not working with 'irb' because it overwrites Kernel#puts
      ### how does it work above though?

      if result[:output] && !result[:output].empty?
        puts result[:output]
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

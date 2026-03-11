# Sandbox MRuby Process

## Usage:

```ruby
sandbox_mruby_process = SandboxMrubyProcess.new(timeout: nil, memory_limit: nil)
sandbox_mruby_process.expose_object(some_class_or_instance_or_method)
sandbox_mruby_process.expose_object(some_other_class_or_instance_or_method)

begin
  sandbox_mruby_process.run_code(ruby_code_str) # recommended
  # or
  # sandbox_mruby_process.eval(ruby_code_str) # more low-level
  # or
  # sandbox_mruby_process.repl # (not much use for web-based projects as it requires a terminal)
ensure
  sandbox_mruby_process.close
end
```


## Install

```
git submodule update --init --recursive

bundle install

# install clang

bundle exec rake mruby:clean
bundle exec rake compile

```

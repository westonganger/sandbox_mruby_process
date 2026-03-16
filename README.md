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


## Usage

#### Evaluating Code

```
process = SandboxMrubyProcess.new

something = "foobar"

process.expose_object(something)

process.eval("something")
# => {value: "something", output: "", error: nil}

process.eval("something = 'baz'")
# => {value: "baz", output: "", error: nil}

process.eval("puts 'some_text'")
# => {value: nil, output: "some_text", error: nil}
```

#### Firing up a REPL (in a terminal or console)

TODO

#### Firing up a REPL (in any erb webpage)

TODO

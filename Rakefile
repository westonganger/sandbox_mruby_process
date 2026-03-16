require "bundler/gem_tasks"
require "rake/extensiontask"

Rake::ExtensionTask.new("sandbox_mruby_process") do |ext|
  ext.lib_dir = "lib/sandbox_mruby_process_ext"
end

task :init_submodules do
  mruby_dir = File.expand_path("ext/sandbox_mruby_process/mruby", __dir__)
  unless File.exist?(File.join(mruby_dir, "Rakefile"))
    puts "Initializing mruby submodule..."
    sh "git submodule update --init"
  end
end

task compile: [:init_submodules]

task default: [:compile]

task setup: [:init_submodules] do
  puts "Setting up development environment"
  sh "bundle install"
  Rake::Task[:compile].invoke
end

namespace :mruby do
  desc "Update mruby to latest and rebuild"
  task :update do
    sh "git -C ext/sandbox_mruby_process/mruby fetch origin"
    sh "git -C ext/sandbox_mruby_process/mruby checkout origin/master"
    Rake::Task["mruby:clean"].invoke
    puts "mruby updated. Run `rake compile` to rebuild."
  end

  desc "Clean mruby build artifacts"
  task :clean do
    rm_rf "ext/sandbox_mruby_process/mruby/build"
    rm_rf "tmp"
    rm_f "lib/sandbox_mruby_process_ext/sandbox_mruby_process.bundle"
    rm_f "lib/sandbox_mruby_process_ext/sandbox_mruby_process.so"
    puts "mruby build artifacts cleaned."
  end
end

task :console do
  require "irb" # must require irb before sandbox_mruby_process otherwise irb will overwrite the 'puts' method that sandbox_mruby_process already overrides
  require "sandbox_mruby_process"

  process = SandboxMrubyProcess.new

  module SomeModule
    def some_integer
      99
    end

    def some_float
      99.999
    end

    def some_string
      str = "foo"
      str << "bar"
      str
    end

    def some_array
      [:asd, :bar]
    end

    def some_hash
      {foo: "foo2", bar: "bar2"}
    end
  end

  process.expose_object(SomeModule)

  binding.irb
end

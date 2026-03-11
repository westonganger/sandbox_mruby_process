require "bundler/gem_tasks"
require "rake/extensiontask"

Rake::ExtensionTask.new("sandbox_mruby") do |ext|
  ext.lib_dir = "lib/sandbox_mruby"
end

task :init_submodules do
  mruby_dir = File.expand_path("ext/sandbox_mruby/mruby", __dir__)
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
    sh "git -C ext/sandbox_mruby/mruby fetch origin"
    sh "git -C ext/sandbox_mruby/mruby checkout origin/master"
    Rake::Task["mruby:clean"].invoke
    puts "mruby updated. Run `rake compile` to rebuild."
  end

  desc "Clean mruby build artifacts"
  task :clean do
    rm_rf "ext/sandbox_mruby/mruby/build"
    rm_rf "tmp"
    rm_f "lib/sandbox_mruby_process/sandbox_mruby.bundle"
    rm_f "lib/sandbox_mruby_process/sandbox_mruby.so"
    puts "mruby build artifacts cleaned."
  end
end

task :console do
  require "sandbox_mruby_process"

  require "irb"
  binding.irb
end

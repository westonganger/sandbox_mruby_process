MRuby::Build.new do |conf|
  conf.toolchain :clang

  ### Sandbox standard library
  conf.gembox "stdlib" # https://github.com/mruby/mruby/blob/master/mrbgems/stdlib.gembox
  conf.gembox "stdlib-ext" # https://github.com/mruby/mruby/blob/master/mrbgems/stdlib-ext.gembox
  conf.gembox "math" # https://github.com/mruby/mruby/blob/master/mrbgems/math.gembox
  conf.gembox "metaprog" # https://github.com/mruby/mruby/blob/master/mrbgems/metaprog.gembox

  ### Specifically NOT included for sandbox / safety
  # conf.gembox "stdlib-io" # https://github.com/mruby/mruby/blob/master/mrbgems/stdlib-io.gembox

  ### Non-core gems https://mruby.org/libraries/
  conf.gem github: "mattn/mruby-json" # https://github.com/mattn/mruby-json
  #conf.gem github: "citrus-lemon/mruby-pure-regexp" # https://github.com/citrus-lemon/mruby-pure-regexp
  #conf.gem github: "chasonr/mruby-bignum" # https://github.com/chasonr/mruby-bignum

  # Enable debug hook for code_fetch_hook (used for timeout)
  conf.cc.defines << "MRB_USE_DEBUG_HOOK"

  # Build as static library only — we link into the Ruby C extension
  conf.cc.flags << "-fPIC"
end

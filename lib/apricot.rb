require 'rational'
require 'set'

# TODO: Move gensym to a more appropriate file
module Apricot
  @gensym = 0

  def self.gensym(prefix = 'g')
    :"#{prefix}__#{@gensym += 1}"
  end
end

%w[parser compiler ast generator stages printers special_forms list identifier
constant ruby_ext namespace].each {|r| require "apricot/#{r}" }

# Start "booting" apricot. Set up core namespace and load the core library.
module Apricot
  Core = Namespace.new

  Core.set_var(:"*ns*", Core)

  Core.set_var(:"in-ns", lambda do |constant|
    Apricot.current_namespace = Namespace.find_or_create constant
  end)

  Core.set_var(:ns, lambda do |constant|
    List[Identifier.intern(:"in-ns"),
      List[Identifier.intern(:quote), constant]]
  end)
  Core.macros << :ns

  # TODO: load core.apr

#  ::User = Namespace.new
  Apricot.current_namespace = Core
  # TODO: make Apricot::Core public vars visible in User, default to User
end

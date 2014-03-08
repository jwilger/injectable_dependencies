require 'active_support/concern'

# Allows classes to define instance methods that will be evaluated at
# runtime.  (The implementation exploits Ruby's method lookup.)
#
# By default, dependencies declared at the class level will be made
# available to all instances of the class (note the call to
# .define_method in ClassMethods::Dependency).
#
# Individual instances of including classes, however, may define their
# own singleton methods based on values provided when the object is
# initialized.  NOTE:  For this behavior to work, including classes
# must invoke #initialize_dependencies before the dependency methods
# are called.  (A good place to do this is probably in your
# #initialize method, but if you want to do something weird, hey, you
# can.)
#
module InjectableDependencies
  UndeclaredDependencyError = Class.new(StandardError)
  MissingImplementationError = Class.new(StandardError)

  extend ActiveSupport::Concern

  module ClassMethods
    def dependency(name, &block)
      dependencies << name
      if block
        define_method(name, &block) # available to all instances
      else
        no_default_dependencies << name
      end
    end

    protected

    def dependencies
      @dependencies ||= []
    end

    def no_default_dependencies
      @no_default_dependencies ||= []
    end
  end

  def initialize_dependencies(overrides = {})
    return unless overrides
    self.class.send(:no_default_dependencies).each do |name|
      unless overrides.has_key?(name)
        raise MissingImplementationError.new("No implementation was provided for dependency ##{name}")
      end
    end
    overrides.each do |k,v|
      unless self.class.send(:dependencies).include?(k)
        raise UndeclaredDependencyError, "Cannot override undeclared dependency '#{k}'."
      end
      singleton_class.send(:define_method, k) { v } # available to this instance only
    end
  end
end

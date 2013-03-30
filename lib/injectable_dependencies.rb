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
  extend ActiveSupport::Concern

  module ClassMethods
    def dependency(name, &proc)
      dependencies << name
      define_method(name, &proc) # available to all instances
    end

    protected

    def dependencies
      @dependencies ||= []
    end
  end

  def initialize_dependencies(overrides = {})
    return unless overrides
    overrides.each do |k,v|
      unless self.class.send(:dependencies).include?(k)
        raise UndeclaredDependencyError, "Cannot override undeclared dependency '#{k}'."
      end
      singleton_class.send(:define_method, k) { v } # available to this instance only
    end
  end
end

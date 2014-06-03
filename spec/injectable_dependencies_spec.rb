require 'injectable_dependencies'

describe InjectableDependencies do
  FooDependency = :foo_dependency

  let(:dependent_class) {
    Class.new do
      include InjectableDependencies
      dependency(:foo) { FooDependency }
      dependency(:bar) { IfThisConstantIsEverDefinedSomeoneIsGettingFiredAndItWontBeMe }
      def initialize(options = {})
        initialize_dependencies options[:dependencies]
      end
    end
  }

  let(:dependent_class_with_default_initializer) {
    Class.new do
      include InjectableDependencies
      dependency(:foo) { FooDependency }
      dependency(:bar) { IfThisConstantIsEverDefinedSomeoneIsGettingFiredAndItWontBeMe }
    end
  }

  let(:dependent) {
    dependent_class.new
  }

  it 'allows the class to declare dependencies' do
    expect(dependent.foo).to eq FooDependency
  end

  it 'does not evaluate dependencies declared by the class until they are requested' do
    expect{ dependent.bar }.to raise_error(NameError)
  end

  it 'provides a convenience method for setting dependencies from the initializer' do
    dependent = dependent_class.new(:dependencies => {:bar => :bar_dependency})
    expect(dependent.bar).to eq :bar_dependency
  end

  it 'provides a default initializer that allows dependency overrides' do
    dependent = dependent_class_with_default_initializer.new(:dependencies => {:bar => :bar_dependency})
    expect(dependent.bar).to eq :bar_dependency
    expect(dependent.foo).to be FooDependency
  end

  it 'does not persist dependencies between instances' do
    s0 = dependent_class.new
    s1 = dependent_class.new(:dependencies => { :foo => :s1_dep })
    s2 = dependent_class.new(:dependencies => { :foo => :s2_dep })

    expect(s0.foo).to eq FooDependency
    expect(s1.foo).to eq :s1_dep
    expect(s2.foo).to eq :s2_dep
  end

  it 'does not allow undeclared dependencies to be specified in initializer' do
    expect{ dependent_class.new(:dependencies => {:undeclared_thing => :oops}) } \
      .to raise_error(InjectableDependencies::UndeclaredDependencyError,
                      "Cannot override undeclared dependency 'undeclared_thing'.")
  end

  context 'when a dependency is defined without a default implementation' do
    context 'when the dependent class has its own initializer' do
      let(:dependent_class) {
        Class.new do
          include InjectableDependencies
          dependency(:baz)
          def initialize(dependencies = {})
            initialize_dependencies(dependencies)
          end
        end
      }

      it 'raises an error if an implementation is not provided during dependency initialization' do
        expect{ dependent_class.new }.to \
          raise_error(InjectableDependencies::MissingImplementationError,
                      'No implementation was provided for dependency #baz')
      end
    end

    context 'when the dependent class uses the default initializer' do
      let(:dependent_class) {
        Class.new do
          include InjectableDependencies
          dependency(:baz)
        end
      }

      it 'raises an error if an implementation is not provided during dependency initialization' do
        expect{ dependent_class.new }.to \
          raise_error(InjectableDependencies::MissingImplementationError,
                      'No implementation was provided for dependency #baz')
      end
    end
  end
end

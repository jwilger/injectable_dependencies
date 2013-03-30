require 'injectable_dependencies'

describe InjectableDependencies do
  FooDependency = :foo_dependency

  let(:dependant_class) {
    Class.new do
      include InjectableDependencies
      dependency(:foo) { FooDependency }
      dependency(:bar) { IfThisConstantIsEverDefinedSomeoneIsGettingFiredAndItWontBeMe }
      def initialize(options = {})
        initialize_dependencies options[:dependencies]
      end
    end
  }

  let(:dependant) {
    dependant_class.new
  }

  it 'allows the class to declare dependencies' do
    expect(dependant.foo).to eq FooDependency
  end

  it 'does not evaluate dependencies declared by the class until they are requested' do
    expect{ dependant.bar }.to raise_error(NameError)
  end

  it 'provides a convenience method for setting dependencies from the initializer' do
    dependant = dependant_class.new(:dependencies => {:bar => :bar_dependency})
    expect(dependant.bar).to eq :bar_dependency
  end

  it 'does not persist dependencies between instances' do
    s0 = dependant_class.new
    s1 = dependant_class.new(:dependencies => { :foo => :s1_dep })
    s2 = dependant_class.new(:dependencies => { :foo => :s2_dep })

    expect(s0.foo).to eq FooDependency
    expect(s1.foo).to eq :s1_dep
    expect(s2.foo).to eq :s2_dep
  end

  it 'does not allow undeclared dependencies to be specified in initializer' do
    expect{ dependant_class.new(:dependencies => {:undeclared_thing => :oops}) } \
      .to raise_error(InjectableDependencies::UndeclaredDependencyError,
                      "Cannot override undeclared dependency 'undeclared_thing'.")
  end
end
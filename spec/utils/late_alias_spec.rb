require 'spec_helper'

RSpec.describe Prototok::Utils::LateAlias do
  let(:extended_class) { Class.new { extend Prototok::Utils::LateAlias } }
  subject { extended_class.new }

  describe '.late_alias' do
    let(:aliased_class) { extended_class.late_alias :b, :a; extended_class }
    let(:subclass1_inst) do
      Class.new(aliased_class) do
        def a
          'subclass1'
        end
      end.new
    end
    let(:subclass2_inst) do
      Class.new(aliased_class) do
        def a
          'subclass2'
        end
      end.new
    end

    it 'doesnt raise an exception calling .late_alias' do
      expect { extended_class.late_alias :b, :a }.to_not raise_exception
    end

    it 'doesnt raise an exception on calling aliased method if it exists' do
      extended_class.late_alias :a, :b
      extended_class.class_eval { def b; end }
      expect { subject.a }.to_not raise_error
    end

    it 'raises NoMethodError on calling aliased method if no aliased method exists' do
      extended_class.late_alias :a, :b
      expect { subject.a }.to raise_error(NoMethodError)
    end

    it 'aliases different methods on different subclasses' do
      expect(subclass1_inst.b).to_not be_eql(subclass2_inst.b)
    end

    it 'works only on class level' do
      subclass1_inst.define_singleton_method(:a) { 'inst' }
      expect(subclass1_inst.b).to be_eql('subclass1')
    end

    it 'works only before first call (not redefining after origin overload)' do
      subclass1_inst.b
      subclass1_inst.class.class_eval do
        def a
          'overloaded'
        end
      end
      expect(subclass1_inst.b).to be_eql('subclass1')
    end

    it 'works before first call after origin overload' do
      subclass1_inst.class.class_eval do
        def a
          'overloaded'
        end
      end
      expect(subclass1_inst.b).to be_eql('overloaded')
    end
  end
end

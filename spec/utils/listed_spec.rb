require 'spec_helper'

RSpec.describe Prototok::Utils::Listed do
  let(:extended_class) { Class.new { extend Prototok::Utils::Listed } }
  let(:seeking_const) { extended_class::SomeConst = 'value'.freeze; extended_class::SomeConst }
  let(:namespace_module) { extended_class::Namespace = Module.new }
  let(:namespaced_const) { namespace_module::SomeConst = 'namespaced_value'.freeze }

  context 'no arguments' do
    it 'doesnt raise error' do
      expect { extended_class.find }.to_not raise_error
    end

    it 'returns nil' do
      expect(extended_class.find).to be_eql nil
    end
  end

  context '1 argument' do
    it 'tries to get camelized const from class' do
      expect(extended_class).to receive(:const_get).with('NonExistantConst', false).and_call_original
      extended_class.find 'non_existant_const'
    end

    it 'returns const if it exists' do
      expect(seeking_const).to be_eql(extended_class.find('some_const'))
    end

    it 'returns nil if it doesnt exist' do
      expect(nil).to be_eql(extended_class.find('some_other_const'))
    end
  end

  context '2+ arguments' do
    it 'tries to get camelized const from class' do
      expect(extended_class).to receive(:const_get).with('Namespace::SomeConst', false).and_call_original
      extended_class.find 'namespace', 'some_const'
    end

    it 'returns const if it exists' do
      expect(namespaced_const).to be_eql(extended_class.find('namespace', 'some_const'))
    end

    it 'returns nil if it doesnt exist' do
      expect(nil).to be_eql(extended_class.find('other_namespace', 'some_other_const'))
    end
  end
end

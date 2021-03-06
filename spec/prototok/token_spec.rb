require 'spec_helper'

RSpec.describe Prototok::Token do
  [:exp, :nbf, :iat].each do |attrib|
    describe "#{attrib}=" do
      it 'raises TypeMismatch error if not ::Time given' do
        expect{subject.send("#{attrib}=", 1)}.to raise_error(Prototok::Errors::TypeMismatch)
      end
    end
  end
end

require "spec_helper"

module MinitestToRspec
  RSpec.describe Processor do
    let(:processor) { described_class.new }

    describe "#process_call" do
      let(:delegate) { Subprocessors::Call }

      it "delegates" do
        input = s(:call)
        allow(delegate).to receive(:process).and_call_original
        processor.process(input)
        expect(delegate).to have_received(:process).with(input)
      end
    end

    describe "#process_class" do
      let(:delegate) { Subprocessors::Class }

      it "delegates" do
        input = s(:class)
        allow(delegate).to receive(:process).and_call_original
        processor.process(input)
        expect(delegate).to have_received(:process).with(input)
      end
    end
  end
end

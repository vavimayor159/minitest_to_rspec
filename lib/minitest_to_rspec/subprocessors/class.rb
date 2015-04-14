require_relative "../errors"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Class < Base
      class << self
        def process(exp)
          raise ArgumentError unless exp.shift == :class
          name = exp.shift
          parent = exp.shift
          assert_valid_name(name)
          block = shift_into_block(exp)
          build(name, parent, block)
        end

        private

        def build(name, parent, block)
          result = build_root(name, parent)
          result.push(block) if block.length > 1
          result
        end

        def active_support_test_case?(parent)
          parent.length == 3 &&
            parent[1] == s(:const, :ActiveSupport) &&
            parent[2] == :TestCase
        end

        def assert_valid_name(name)
          if name.is_a?(Symbol)
            # noop. all is well
          elsif name.respond_to?(:sexp_type) && name.sexp_type == :colon2
            raise ModuleShorthandError
          else
            raise ProcessingError, "Unexpected class expression: #{name}"
          end
        end

        # Given a `test_class_name` like `BananaTest`, returns the
        # described clas, like `Banana`.
        def described_class(test_class_name)
          test_class_name.to_s.gsub(/Test\Z/, "").to_sym
        end

        def inheritance?(exp)
          exp.sexp_type == :colon2
        end

        # Returns the root of the result: either an :iter representing
        # an `RSpec.describe` or, if it's not a test case, a :class.
        def build_root(name, parent)
          if parent && test_case?(parent)
            rspec_describe_block(name)
          else
            s(:class, name, parent)
          end
        end

        def rspec_describe(arg)
          s(:call, s(:const, :RSpec), :describe, arg)
        end

        # Returns a S-expression representing a call to RSpec.describe
        def rspec_describe_block(name)
          arg = s(:const, described_class(name))
          s(:iter, rspec_describe(arg), s(:args))
        end

        def shift_into_block(exp)
          block = s(:block)
          until exp.empty?
            block << full_process(exp.shift)
          end
          block
        end

        # TODO: Obviously, there are test case parent classes
        # other than ActiveSupport::TestCase
        def test_case?(parent)
          raise ArgumentError unless inheritance?(parent)
          active_support_test_case?(parent)
        end
      end
    end
  end
end

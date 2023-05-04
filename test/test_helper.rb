# frozen_string_literal: true

require 'minitest/autorun'
require 'rubocop'
require 'byebug'

module TestHelper
  FLOAT_LITERALS = %w[10.0 1e1 1.0E1].freeze
  INTEGER_LITERALS = %w[10 1_0].freeze

  def assert_offense(cop_name: nil, violation_message: nil)
    matching_offenses = matching_offenses_for_cop_name(cop_name)
    detected_message = detected_message_for_cop_name(cop_name)

    refute_empty(matching_offenses, detected_message)
    assert_equal(matching_offenses.first.message, violation_message) if matching_offenses.any?
  end

  def assert_no_offenses(cop_name = nil)
    matching_offenses = cop_name.nil? ? cop.offenses : cop.offenses.select { _1.cop_name == cop_name }

    assert_empty(matching_offenses, 'Expected no offense to be detected but there was one')
  end
  alias refute_offense assert_no_offenses

  private

  def parse_source(source, file = nil)
    if file.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end

    processed_source = RuboCop::ProcessedSource.new(source, ruby_version, file)
    processed_source.config = configuration
    processed_source.registry = registry
    processed_source
  end

  def configuration
    @configuration ||= if defined?(config)
                         config
                       else
                         RuboCop::Config.new({}, "#{Dir.pwd}/.rubocop.yml")
                       end
  end

  def registry
    @registry ||= begin
      keys = configuration.keys
      cops =
        keys.map { |directive| RuboCop::Cop::Registry.global.find_cops_by_directive(directive) }
            .flatten
      cops << cop_class if defined?(cop_class) && !cops.include?(cop_class)
      cops.compact!
      RuboCop::Cop::Registry.new(cops)
    end
  end

  def inspect_source(source, file = nil)
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    processed_source = parse_source(source, file)
    unless processed_source.valid_syntax?
      raise 'Error parsing example code: ' \
            "#{processed_source.diagnostics.map(&:render).join("\n")}"
    end

    _investigate(cop, processed_source)
  end

  def _investigate(cop, processed_source)
    team = RuboCop::Cop::Team.new([cop], configuration, raise_error: true)
    report = team.investigate(processed_source)
    @last_corrector = report.correctors.first || RuboCop::Cop::Corrector.new(processed_source)
    report.offenses.reject(&:disabled?)
  end

  def ruby_version
    RuboCop::TargetRuby::DEFAULT_VERSION
  end

  def cop
    raise NotImplementedError, "Please define `cop' in your test"
  end

  def config
    @config ||= RuboCop::Config.new(hash)
  end

  def matching_offenses_for_cop_name(cop_name)
    cop.offenses.select { _1.cop_name == cop_name }
  end

  def detected_message_for_cop_name(cop_name)
    ['Expected an offense',
     string_for_cop_name(cop_name),
     'to be detected but there was none'].compact.join(' ')
  end

  def string_for_cop_name(cop_name = nil)
    return nil unless cop_name

    "named #{cop_name}"
  end
end

Minitest::Test.include(TestHelper)

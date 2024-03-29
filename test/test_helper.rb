# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/color'
require 'rubocop'
require 'byebug'
require 'rubocop/magic_numbers'

module TestHelper
  FLOAT_LITERALS = %w[10.0 1e1 1.0E1].freeze
  INTEGER_LITERALS = %w[10 1_0].freeze
  ALL_LITERALS = (FLOAT_LITERALS | INTEGER_LITERALS).freeze

  def assert_offense(cop_name: nil, violation_message: nil)
    matching_offenses = matching_offenses_for_cop_name(cop_name)
    detected_message = detected_message_for_cop_name(cop_name)

    refute_empty(matching_offenses, detected_message)
    assert_equal(matching_offenses.first.message, violation_message) if matching_offenses.any?
  end

  def assert_no_offenses(cop_name: nil)
    raise NotImplementedError, "Please call `inspect_source' before making assertions" unless @offenses

    matching_offenses = cop_name.nil? ? @offenses : @offenses.select { _1.cop_name == cop_name }

    assert_empty(matching_offenses, 'Expected no offense to be detected but there was one')
  end
  alias refute_offense assert_no_offenses

  private

  def matched_numerics(type = :all)
    unless %i[all float integer].include?(type.to_sym)
      raise ArgumentError, "type must be one of all, float, or integer but was #{type}"
    end

    TestHelper.const_get("#{type.to_s.upcase}_LITERALS")
  end

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

  def inspect_source(source, file: nil, cops: [cop])
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    processed_source = parse_source(source, file)
    unless processed_source.valid_syntax?
      raise 'Error parsing example code: ' \
            "#{processed_source.diagnostics.map(&:render).join("\n")}"
    end

    _investigate(cops, processed_source)
  end

  def _investigate(cops, processed_source)
    team = RuboCop::Cop::Team.new(cops, configuration, raise_error: true)
    report = team.investigate(processed_source)
    @last_corrector = report.correctors.first || RuboCop::Cop::Corrector.new(processed_source)
    @offenses = report.offenses.reject(&:disabled?)
  end

  def ruby_version
    RuboCop::TargetRuby::DEFAULT_VERSION
  end

  def cop
    raise NotImplementedError, "Please define `cop' in your test"
  end

  def update_config(updated_config = {})
    remove_instance_variable(:@config) if defined?(@config)

    set_config(updated_config)
  end

  def config
    @config ||= set_config
  end

  def set_config(hash = {})
    RuboCop::Config.new(hash)
  end

  def matching_offenses_for_cop_name(cop_name)
    raise NotImplementedError, "Please call `inspect_source' before making assertions" unless @offenses

    @offenses.select { _1.cop_name == cop_name }
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

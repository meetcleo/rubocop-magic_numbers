# frozen_string_literal: true

require 'minitest'
require 'byebug'
require 'rubocop'

module TestHelper
  def assert_offense(violation_message)
    refute_empty(cop.offenses, "Expected a #{cop.cop_name} offense to be detected but there was none")
    assert_equal(cop.offenses.first.message, violation_message) if cop.offenses.any?
  end

  def refute_offense
    assert_empty(cop.offenses)
  end

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
    @config ||= RuboCop::Config.new
  end
end

Minitest::Test.include(TestHelper)

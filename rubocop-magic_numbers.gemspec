# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'rubocop/magic_numbers/version'

Gem::Specification.new do |s|
  s.name = 'rubocop-magic_numbers'
  s.version = RuboCop::MagicNumbers::VERSION
  s.summary = 'rubocop/magic_numbers implements a rubocop cop for detecting the use ' \
              'of bare numbers when linting'
  s.description = 'rubocop/magic_numbers implements a rubocop cop for detecting the use ' \
                  'of bare numbers when linting'

  s.files =
    Dir.glob('lib/**/*') +
    %w[README.md]

  s.require_path = 'lib'
  s.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  s.authors = ['Gavin Morrice', 'Fell Sunderland']
  s.email = ['gavin@gavinmorrice.com', 'fell@meetcleo.com']

  s.homepage = 'https://github.com/Bodacious/rubocop-magic_numbers'

  s.add_dependency('parser')
  s.add_dependency('rubocop')

  s.license = 'MIT'
  s.metadata['rubygems_mfa_required'] = 'true'
end

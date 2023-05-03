$LOAD_PATH << File.expand_path('lib', __dir__)
require 'custom/no_magic_numbers/version'

Gem::Specification.new do |s|
  s.name = 'no-magic-numbers-cop'
  s.version = Custom::NoMagicNumbers::VERSION
  s.summary = 'no_magic_numbers implements a rubocop cop for detecting the use ' \
    'of bare numbers when linting'
  s.description = 'no_magic_numbers implements a rubocop cop for detecting the use ' \
    'of bare numbers when linting'

  s.files =
    Dir.glob('lib/**/*') +
    %w[README.md]

  s.require_path = 'lib'
  s.required_ruby_version = Gem::Requirement.new('>= 3.2.0')

  s.authors = ['Gavin Morrice', 'Fell Sunderland']
  s.email = ['gavin@meetcleo.com', 'fell@meetcleo.com']

  s.homepage = 'https://github.com/Bodacious/no-magic-numbers-cop'

  s.add_dependency('parser')
  s.add_dependency('rubocop')
  s.add_dependency('rubocop-rails')

  s.license = 'MIT'
  s.metadata['rubygems_mfa_required'] = 'true'
end

# rubocop-magic_numbers

![Ruby tests](https://github.com/bodacious/rubocop-magic_numbers/actions/workflows/ruby.yml/badge.svg)
![RuboCop Lint](https://github.com/bodacious/rubocop-magic_numbers/actions/workflows/rubocop.yml/badge.svg)


`rubocop-magic_numbers` is a gem that detects the use of magic numbers within Ruby code and raises them as offenses.

Magic numbers are typically integers or floats that are used within code with no descriptive context to help other developers understand what they represent. To write cleaner and more maintainable code, it is recommended to assign the numbers to constants with helpful names.

``` ruby
# BAD
def calculate_annual_earnings
  pay_per_shift = 50.0
  pay_per_shift * 5 * 52
end

# GOOD
PAY_PER_SHIFT = 50.0
SHIFTS_PER_WEEK = 5
WEEKS_PER_YEAR = 52
def calculate_annual_earnings
  PAY_PER_SHIFT * SHIFTS_PER_WEEK * WEEKS_PER_YEAR
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-magic_numbers', require: false, group: :development
```

And then execute:

```bash
$ bundle install
```

## Usage

After installing the gem, `rubocop` should automatically detect and raise offenses for magic numbers within your code. You can customize the behavior of the gem by adding configurations to a `.rubocop.yml` file in your project's root directory.

Here are some examples of configurations you can use:

```yaml
require:
  - rubocop-magic_numbers

# TODO
# define configs here
```

For more information on configuring `rubocop`, please refer to the [official documentation](https://docs.rubocop.org/rubocop/configuration.html).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bodacious/rubocop-magic_numbers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
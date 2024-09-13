# rubocop-magic_numbers

![Ruby tests](https://github.com/meetcleo/rubocop-magic_numbers/actions/workflows/ruby.yml/badge.svg)
![RuboCop Lint](https://github.com/meetcleo/rubocop-magic_numbers/actions/workflows/rubocop.yml/badge.svg)


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

After installing the gem, `rubocop` should automatically detect and raise offenses for magic numbers within your code.

The gem will detect offenses of the following sorts:

### MagicNumbers/NoArgument

Detects when magic numbers are used as method arguments.

``` ruby
# BAD
@user.too_many_widgets?(20) # what does 20 mean?!

# GOOD
@user.too_many_widgets?(FREE_SUBSCRIPTION_WIDGET_MAX)

# BAD
monthly_average = total / 28 # why 28?

# GOOD
monthly_average = total / FOUR_WEEK_MONTH_IN_DAYS
```

### MagicNumbers/NoAssignment

``` ruby
# BAD
total_widget_limit = 20 # why 20?

# GOOD
total_widget_limit = FREE_SUBSCRIPTION_WIDGET_MAX
```

### MagicNumbers/NoDefault


``` ruby
# BAD
def over_widget_limit?(limit = 20)
  # ...
end

# GOOD
def over_widget_limit?(limit = FREE_SUBSCRIPTION_WIDGET_MAX)
  # ...
end
```

### MagicNumbers/NoReturn


``` ruby
# BAD
def widget_limit_for_user(user)
  return 20 if user.subscription_free?

  return 40
end

# GOOD
def widget_limit_for_user(user)
  return FREE_SUBSCRIPTION_WIDGET_MAX if user.subscription_free?

  PAID_SUBSCRIPTION_WIDGET_MAX
end
```

You can customize the behavior of the gem by adding configurations to a `.rubocop.yml` file in your project's root directory.

Here are some examples of configurations you can use:

```yaml
require:
  - rubocop-magic_numbers

MagicNumbers/NoArgument:
  ForbiddenNumerics: All/Float/Integer # default All
  IgnoredMethods:
    - '[]' # defaults to just the #[] method
  PermittedValues: # defaults to []
    - -1
    - 1
MagicNumbers/NoAssignment:
  ForbiddenNumerics: All/Float/Integer # default All

MagicNumbers/NoDefault:
  ForbiddenNumerics: All/Float/Integer # default All

MagicNumbers/NoReturn:
  AllowedReturns: Implicit/Explicit/None # default None
  ForbiddenNumerics: All/Float/Integer # default All
```

For more information on configuring `rubocop`, please refer to the [official documentation](https://docs.rubocop.org/rubocop/configuration.html).

## Rails usage

If using as part of a Ruby on Rails project, you may want to add the following to your RuboCop configuration:

``` YAML
MagicNumbers/NoArgument:
  Exclude:
    - config/application.rb
    - db/migrate/*.rb
```

This will prevent RuboCop from complainig about Rails version numbers in your migration files and application config.

``` ruby
module Cleo
  class Application < Rails::Application
    config.load_defaults 7.1 # <= here
  end
end

# If you remove `[]` from ignored methods, you might want to add this
class AddBankCardIdToUsers < ActiveRecord::Migration[7.1]
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/meetcleo/rubocop-magic_numbers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

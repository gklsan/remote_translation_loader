# Remote Translation Loader [![Gem Version](https://badge.fury.io/rb/remote_translation_loader.svg)](https://badge.fury.io/rb/remote_translation_loader)

`remote_translation_loader` is a Ruby gem for fetching YAML translation files from remote sources and dynamically loading them into your Ruby on Rails application’s I18n translations. This gem is useful for applications that need to integrate external translations without writing them to local files.

## Features

- Fetch translation files from remote URLs
- Merge remote translations with local translations
- Directly load translations into Rails I18n without writing to files
- Handles YAML parsing errors and HTTP request failures

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'remote_translation_loader'
```

Then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install remote_translation_loader
```

## Usage

### Basic Setup

1. **Initialize the Loader**

   Create an instance of the `RemoteTranslationLoader::Loader` class with a list of remote YAML URLs:

   ```ruby
   loader = RemoteTranslationLoader::Loader.new([
     'https://example.com/translations/en.yml',
     'https://example.com/translations/fr.yml'
   ])
   ```

2. **Fetch and Load Translations**

   Call the `fetch_and_load` method to fetch and load the translations:

   ```ruby
   loader.fetch_and_load
   ```

   This will:
    - Fetch the YAML files from the specified URLs
    - Parse the YAML content
    - Merge the remote translations with your existing local translations
    - Load the merged translations into Rails I18n

### Example

```ruby
require 'remote_translation_loader'

# Initialize the loader with remote YAML URLs
loader = RemoteTranslationLoader::Loader.new([
  'https://example.com/translations/en.yml',
  'https://example.com/translations/fr.yml'
])

# Fetch and load translations
loader.fetch_and_load

# Now you can use the loaded translations in your application
puts I18n.t('greetings.hello') # Output will depend on the remote translation files
```

### Handling Errors

The gem will raise errors in case of:
- **Invalid YAML Content**: If the remote YAML file is invalid, a `RuntimeError` will be raised with a message indicating a YAML parsing error.
- **HTTP Request Failures**: If fetching the remote YAML file fails, a `RuntimeError` will be raised with a message indicating the failure.

### Customizing Error Handling

You can customize the error handling by rescuing from `RuntimeError` or any other specific exceptions as needed:

```ruby
begin
  loader.fetch_and_load
rescue RuntimeError => e
  puts "An error occurred: #{e.message}"
end
```

## Development

To contribute to the development of `remote_translation_loader`, follow these steps:

1. **Clone the Repository**

   ```bash
   git clone https://github.com/gklsan/remote_translation_loader.git
   cd remote_translation_loader
   ```

2. **Install Dependencies**

   ```bash
   bundle install
   ```

3. **Run Tests**

   Run the test suite to ensure everything is working correctly:

   ```bash
   bundle exec rspec
   ```

4. **Make Your Changes**

   Implement your changes or features and ensure they are covered by tests.

5. **Submit a Pull Request**

   Push your changes to your forked repository and submit a pull request with a clear description of the changes.

## License

`remote_translation_loader` is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

For questions or support, please open an issue on [GitHub](https://github.com/gklsan/remote_translation_loader/issues).

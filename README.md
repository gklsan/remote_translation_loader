# RemoteTranslationLoader

[![Gem Version](https://badge.fury.io/rb/remote_translation_loader.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/remote_translation_loader)
[![Downloads](https://img.shields.io/gem/dt/remote_translation_loader.svg)](https://badge.fury.io/rb/remote_translation_loader)
[![Github forks](https://img.shields.io/github/forks/gklsan/remote_translation_loader.svg)](https://github.com/gklsan/remote_translation_loader/network)
[![Github stars](https://img.shields.io/github/stars/gklsan/remote_translation_loader.svg)](https://github.com/gklsan/remote_translation_loader/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


**RemoteTranslationLoader** is a Ruby gem designed to dynamically fetch and load translation files (YAML format) into your Ruby or Ruby on Rails application. It supports multiple sources such as HTTP URLs, local files, and AWS S3, allowing you to seamlessly integrate external translations.

---

## **Features**

- Fetch translations from multiple sources:
   - **HTTP URLs**
   - **Local files**
   - **AWS S3 buckets**
- Supports deep merging of translations with existing `I18n` backend.
- Namespace support for isolating translations.
- Dry-run mode to simulate translation loading.
- Rake tasks for easy integration with Rails applications.
- CLI tool for manual loading.

---

## **Installation**

Add this line to your application's Gemfile:

```ruby
gem 'remote_translation_loader'
```

And then execute:

```bash
bundle install
```

Or install it directly:

```bash
gem install remote_translation_loader
```

---

## **Usage**

### **Basic Usage**

#### **1. HTTP Fetching**
```ruby
require 'remote_translation_loader'

urls = ['https://example.com/en.yml', 'https://example.com/fr.yml']
loader = RemoteTranslationLoader::Loader.new(urls)
loader.fetch_and_load
```

#### **2. Local File Fetching**
```ruby
require 'remote_translation_loader'

files = ['/path/to/local/en.yml', '/path/to/local/fr.yml']
loader = RemoteTranslationLoader::Loader.new(files, fetcher: RemoteTranslationLoader::Fetchers::FileFetcher.new)
loader.fetch_and_load
```

#### **3. AWS S3 Fetching**
```ruby
require 'remote_translation_loader'

bucket = 'your-s3-bucket'
s3_fetcher = RemoteTranslationLoader::Fetchers::S3Fetcher.new(bucket, region: 'us-east-1')
keys = ['translations/en.yml', 'translations/fr.yml']

loader = RemoteTranslationLoader::Loader.new(keys, fetcher: s3_fetcher)
loader.fetch_and_load
```

---

### **Advanced Options**

#### **Namespace Support**
Add a namespace to group translations under a specific key:
```ruby
loader.fetch_and_load(namespace: 'remote')
# Translations will be grouped under the `remote` key, e.g., `remote.en.some_key`
```

#### **Dry-Run Mode**
Simulate the loading process without modifying the `I18n` backend:
```ruby
loader.fetch_and_load(dry_run: true)
# Outputs fetched translations to the console without loading them
```

---

## **CLI Usage**

Install the gem globally and use the CLI tool:

```bash
remote_translation_loader https://example.com/en.yml /path/to/local/fr.yml
```

- The CLI fetches and loads the specified translations.
- Add the executable to your `$PATH` for easier access.

---

## **Rails Integration**

### **1. Rake Task**
Use the provided Rake task to fetch translations in a Rails application:

#### Add this to your `Rakefile`:
```ruby
require 'remote_translation_loader'
load 'remote_translation_loader/tasks/remote_translation_loader.rake'
```

#### Run the task:
```bash
rake translations:load[https://example.com/en.yml,/path/to/local/fr.yml]
```

### **2. Automatic Loading**

Add an initializer to load translations on application startup:

#### `config/initializers/remote_translation_loader.rb`
```ruby
require 'remote_translation_loader'

urls = ['https://example.com/en.yml', '/path/to/local/fr.yml']
loader = RemoteTranslationLoader::Loader.new(urls)
loader.fetch_and_load(namespace: 'remote')
```

---

## **Contributing**

We welcome contributions! Follow these steps:

1. Fork the repository.
2. Create your feature branch:
   ```bash
   git checkout -b feature/my-new-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m 'Add some feature'
   ```
4. Push the branch:
   ```bash
   git push origin feature/my-new-feature
   ```
5. Create a pull request.

---

## **Development**

To work on the gem locally:

1. Clone the repository:
   ```bash
   git clone https://github.com/gklsan/remote_translation_loader.git
   cd remote_translation_loader
   ```
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Run tests:
   ```bash
   rspec
   ```

---

## **License**

This gem is released under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## **Acknowledgments**

A big thanks to the open-source community for the inspiration and support. Special mention to contributors who helped shape this gem!

---

For questions, bug reports, or feature requests, feel free to [open an issue](https://github.com/gklsan/remote_translation_loader/issues). 🚀
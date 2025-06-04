# gem-clone

A RubyGems plugin that allows you to clone gem repositories by fetching source code URLs from gem metadata and using `ghq` or `git clone`.

## Usage

### Basic Usage

```bash
# Clone a gem repository
gem clone sinatra

# Clone with verbose output
gem clone rails --verbose

# Show repository URL without cloning
gem clone rails --show-url
```

### Options

- `-v, --verbose`: Show verbose output during execution
- `-u, --show-url`: Display the repository URL without executing the clone operation

### Examples

```bash
# With ghq available
$ gem clone sinatra
Executing: ghq get https://github.com/sinatra/sinatra
Successfully cloned repository: https://github.com/sinatra/sinatra

# With verbose output
$ gem clone rails --verbose
Fetching gem metadata for 'rails'...
Found repository URL: https://github.com/rails/rails
Executing: ghq get https://github.com/rails/rails
Successfully cloned repository: https://github.com/rails/rails

# Fallback to git clone when ghq is not available
$ gem clone rails --verbose
Fetching gem metadata for 'rails'...
Found repository URL: https://github.com/rails/rails
ghq not found, falling back to git clone
Executing: git clone https://github.com/rails/rails
Successfully cloned repository: https://github.com/rails/rails

# Show URL only
$ gem clone rails --show-url
https://github.com/rails/rails
```

## Installation

### From RubyGems

```bash
gem install gem-clone
```

### From Source

```bash
git clone https://github.com/hsbt/gem-clone.git
cd gem-clone
gem build gem-clone.gemspec
gem install gem-clone-*.gem
```

### Prerequisites

This plugin works best with `ghq` but will automatically fall back to `git clone` if `ghq` is not available.

#### Recommended: Install ghq

```bash
# Install ghq (example for macOS)
brew install ghq

# Or install via Go
go install github.com/x-motemen/ghq@latest

# Or download binary from GitHub releases
# https://github.com/x-motemen/ghq/releases
```

#### Fallback: Git only

If `ghq` is not installed, the plugin will automatically use `git clone` instead. Make sure `git` is available in your PATH.

## Technical Details

### How it works

The plugin performs the following steps:

1. **Fetch gem metadata** from RubyGems.org API (`/api/v1/gems/{gem_name}.json`)
2. **Extract repository URL** from gem metadata in this priority order:
   - `source_code_uri` metadata field
   - `homepage_uri` (if it looks like a repository URL)
3. **Normalize URL** by removing version-specific paths (e.g., `/tree/v1.0.0`, `/blob/main/README.md`)
4. **Clone repository** using:
   - `ghq get <url>` (preferred method if available)
   - `git clone <url>` (fallback if ghq is not available)
   - Display URL only if `--show-url` option is specified

### URL Normalization

The plugin automatically normalizes repository URLs by removing common Git hosting service paths:

- `/tree/*` → removed (GitHub, GitLab branches/tags)
- `/blob/*` → removed (GitHub, GitLab file views)
- `/commits/*` → removed (commit history pages)
- `/releases/*` → removed (release pages)
- `/issues/*` → removed (issue pages)
- `/pull/*` → removed (pull request pages)
- `/tags/*` → removed (tag pages)
- `/branches/*` → removed (branch pages)

**Example:**
- `https://github.com/rails/rails/tree/v8.0.2` → `https://github.com/rails/rails`

### Cross-platform Support

The plugin includes cross-platform command detection:

- **Unix/Linux/macOS**: Uses `which` command
- **Windows**: Uses `where` command
- **Error handling**: Gracefully handles missing commands

### Supported Repository Hosts

The plugin recognizes repository URLs from:

- GitHub (github.com)
- GitLab (gitlab.com)
- Bitbucket (bitbucket.org)
- Codeberg (codeberg.org)
- SourceHut (sourcehut.org)

### Requirements

- Ruby >= 2.7.0
- RubyGems
- `ghq` (recommended) or `git` (fallback)

## Development

### Setting up the development environment

```bash
# Clone the repository
git clone https://github.com/hsbt/gem-clone.git
cd gem-clone

# Install dependencies
bundle install

# Run tests
bundle exec rake test

# Build the gem
gem build gem-clone.gemspec
```

### Running Tests

```bash
# Run all tests
bundle exec rake test

# Run specific test file
ruby -Ilib:test test/clone_command_test.rb

# Run with verbose output
ruby -Ilib:test test/clone_command_test.rb --verbose
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and add tests
4. Run the test suite (`bundle exec rake test`)
5. Commit your changes (`git commit -am 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

```
MIT License

Copyright (c) 2024 Hiroshi SHIBATA

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

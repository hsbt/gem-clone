# RubyGems Clone Plugin

A RubyGems plugin that allows you to clone gem repositories using `ghq` based on gem metadata.

## Installation

```bash
gem install gem-clone
```

Or build and install locally:

```bash
gem build gem-clone.gemspec
gem install gem-clone-0.1.0.gem
```

## Prerequisites

This plugin works best with `ghq` but will automatically fall back to `git clone` if `ghq` is not available.

### Recommended: Install ghq

```bash
# Install ghq (example for macOS)
brew install ghq

# Or install via Go
go install github.com/x-motemen/ghq@latest
```

### Fallback: Git only

If `ghq` is not installed, the plugin will automatically use `git clone` instead. Make sure `git` is available in your PATH.

## Usage

```bash
# Clone a gem repository
gem clone sinatra

# Clone with verbose output
gem clone rails --verbose

# Show repository URL without cloning
gem clone rails --show-url
```

The command will:

1. Fetch gem metadata from RubyGems.org API
2. Extract repository URL from:
   - `source_code_uri` metadata
   - `homepage_uri` (if it looks like a repository URL)
   - `project_uri` (if it looks like a repository URL)
3. Clone the repository using:
   - `ghq get` (preferred method if available)
   - `git clone` (fallback if ghq is not available)
   - Skip cloning if `--show-url` is specified

## Options

- `-v, --verbose`: Show verbose output during execution
- `-u, --show-url`: Display the repository URL without executing the clone operation

## Examples

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

## Development

After checking out the repo, run tests and build the gem:

```bash
gem build gem-clone.gemspec
gem install gem-clone-0.1.0.gem
```

## License

The gem is available as open source under the terms of the MIT License.

require 'rubygems/command'
require 'json'
require 'net/http'
require 'uri'
require 'open3'

class Gem::Commands::CloneCommand < Gem::Command
  # git goget answers with these for a repository it deliberately left alone.
  GOGET_UNREACHABLE = 3
  GOGET_LOCAL_WORK = 4

  def initialize
    super 'clone', 'Clone a gem repository using git goget, ghq, or git'

    add_option('-v', '--verbose', 'Show verbose output') do |value, options|
      options[:verbose] = true
    end

    add_option('-u', '--show-url', 'Show repository URL without cloning') do |value, options|
      options[:show_url] = true
    end
  end

  def arguments # :nodoc:
    "GEM_NAME        name of gem to clone"
  end

  def description # :nodoc:
    <<-EOF
The clone command fetches gem metadata from RubyGems.org and clones
the gem's source repository using git goget (preferred), ghq, or git
based on the homepage or source_code_uri from the gem's metadata.

Examples:
  gem clone sinatra
  gem clone rails --verbose
  gem clone rails --show-url
    EOF
  end

  def execute
    gem_name = get_one_gem_name

    say "Fetching gem metadata for '#{gem_name}'..." if options[:verbose]

    gem_info = fetch_gem_info(gem_name)

    if gem_info.nil?
      alert_error "Could not find gem '#{gem_name}'"
      terminate_interaction 1
    end

    repository_url = extract_repository_url(gem_info)

    if repository_url.nil?
      alert_error "Could not find repository URL for gem '#{gem_name}'"
      terminate_interaction 1
    end

    say "Found repository URL: #{repository_url}" if options[:verbose]

    if options[:show_url]
      say repository_url
    else
      clone_repository(repository_url)
    end
  end

  private

  def fetch_gem_info(gem_name)
    uri = URI("https://rubygems.org/api/v1/gems/#{gem_name}.json")

    begin
      response = Net::HTTP.get_response(uri)

      if response.code == '200'
        JSON.parse(response.body)
      else
        nil
      end
    rescue => e
      say "Error fetching gem info: #{e.message}" if options[:verbose]
      nil
    end
  end

  def extract_repository_url(gem_info)
    if gem_info['source_code_uri'] && !gem_info['source_code_uri'].empty?
      return normalize_repository_url(gem_info['source_code_uri'])
    end

    if gem_info['homepage_uri'] && is_repository_url?(gem_info['homepage_uri'])
      return normalize_repository_url(gem_info['homepage_uri'])
    end

    nil
  end

  def is_repository_url?(url)
    return false if url.nil? || url.empty?

    url.match?(/github\.com|gitlab\.com|bitbucket\.org|codeberg\.org|sourcehut\.org/)
  end

  def normalize_repository_url(url)
    return url if url.nil? || url.empty?

    normalized_url = url.sub(/[#?].*/m, '')
    normalized_url = normalized_url.sub(%r{\Ahttp://}, 'https://').sub(%r{\Ahttps://www\.}, 'https://')
    normalized_url = normalized_url.gsub(%r{/(tree|blob|commits|releases|issues|pull|tags|branches)/.*$}, '')

    normalized_url.chomp('/').sub(/\.git\z/, '')
  end

  def clone_repository(url)
    if command_available?('git-goget')
      clone_with_git_goget(url)
    elsif command_available?('ghq')
      clone_with_ghq(url)
    elsif command_available?('git')
      clone_with_git(url)
    else
      alert_error "None of 'git goget', 'ghq', or 'git' is available in your PATH. Please install one of them."
      terminate_interaction 1
    end
  end

  private

  def command_available?(command)
    begin
      check_command = RUBY_PLATFORM =~ /mswin|mingw|cygwin/ ? 'where' : 'which'
      _, _, status = Open3.capture3("#{check_command} #{command}")
      status.success?
    rescue
      false
    end
  end

  def clone_with_git_goget(url)
    say "Executing: git goget #{url}" if options[:verbose]

    system("git", "goget", url)

    case $?.exitstatus
    when 0
      say "Successfully cloned repository: #{url}"
    when GOGET_UNREACHABLE
      alert_error "Repository is unreachable: #{url}"
      terminate_interaction 1
    when GOGET_LOCAL_WORK
      alert_warning "Left the existing checkout alone: #{url}"
    else
      alert_error "Failed to clone repository with git goget."
      terminate_interaction 1
    end
  end

  def clone_with_ghq(url)
    say "git goget not found, falling back to ghq" if options[:verbose]
    say "Executing: ghq get #{url}" if options[:verbose]

    system("ghq", "get", url)

    if $?.success?
      say "Successfully cloned repository: #{url}"
    else
      alert_error "Failed to clone repository with ghq."
      terminate_interaction 1
    end
  end

  def clone_with_git(url)
    say "ghq not found, falling back to git clone" if options[:verbose]
    say "Executing: git clone #{url}" if options[:verbose]

    system("git", "clone", url)

    if $?.success?
      say "Successfully cloned repository: #{url}"
    else
      alert_error "Failed to clone repository with git."
      terminate_interaction 1
    end
  end
end

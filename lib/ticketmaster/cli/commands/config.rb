def config(options)
  ARGV << '--help' if ARGV.length == 0
  begin
    OptionParser.new do |opts|
      opts.banner = 'Usage: ticketmaster -p PROVIDER [options] config [config_options]'
      opts.separator ''
      opts.separator 'Options:'
      
      opts.on('-a', '--add', 'Add a new entry to the configuration file based on ticketmaster options.') do
        options[:subcommand] = 'add'
      end
      
      opts.on('-e', '--edit', 'Edit an existing entry to the configuration file based on ticketmaster options') do
        options[:subcommand] = 'edit'
      end
      
      opts.on('-p', '--set-default-provider', 'Set the current provider as the default.', 'Requires provider to be specified, otherwise unsets the default') do
        options[:subcommand] = 'set_default_provider'
      end
      
      opts.separator ''
      opts.separator 'Other options:'
      
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end.parse(ARGV)
  rescue OptionParser::MissingArgument => exception
    puts "ticketmaster #{options[:original_argv].join(' ')}\n\n"
    puts "Error: An option was called that requires an argument, but was not given one"
    puts exception.message
  end
  send(options[:subcommand], options)
end

def add(options)
  require_provider unless options[:provider]
  provider = options[:provider]
  config = YAML.load_file(config_file = File.expand_path(options[:config]))
  if config[provider]
    puts "#{provider} has already been specfied in #{options[:config]}. Refusing to add. Use --edit instead."
    exit 1
  end
  config[provider] = {}
  config[provider]['authentication'] = options[:authentication] || {}
  config[provider]['project'] = options[:project] if options[:project]
  File.open(config_file, 'w') do |out|
    YAML.dump(config, out)
  end
  puts "Wrote #{provider} to #{config_file}"
  exit
end

def edit(options)
  require_provider unless options[:provider]
  provider = options[:provider]
  config = YAML.load_file(config_file = File.expand_path(options[:config]))
  config[provider] ||= {}
  config[provider]['authentication'] = options[:authentication] || {}
  config[provider]['project'] = options[:project] if options[:project]
  File.open(config_file, 'w') do |out|
    YAML.dump(config, out)
  end
  puts "Wrote #{provider} to #{config_file}"
  exit
end

def set_default_provider(options)
  provider = options[:provider]
  config = YAML.load_file(config_file = File.expand_path(options[:config]))
  puts "Warning! #{provider} is not defined in #{config_file}" unless provider.nil? or config[provider]
  config['default'] = provider
  File.open(config_file, 'w') do |out|
    YAML.dump(config, out)
  end
  puts "Default provider has been set to '#{provider}'"
  exit
end

def require_provider
  puts "Provider must be specified!"
  exit 1
end

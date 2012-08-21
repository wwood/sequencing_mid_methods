#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'


SCRIPT_NAME = File.basename(__FILE__); LOG_NAME = SCRIPT_NAME.gsub('.rb','')

# Parse command line options into the options hash
options = {
  :logger => 'stderr',
}
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} MID_FILE
    
    Given a list of MIDs, cluster them. Print out one cluster per line\n\n"
    
  opts.on("-e", "--eg ARG", "description [default: #{options[:eg]}]") do |arg|
    options[:example] = arg
  end

  # logger options
  opts.separator "\n\tVerbosity:\n\n"
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") {Bio::Log::CLI.trace('error')}
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") { |name| options[:logger] = name}
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG"){|s| Bio::Log::CLI.trace(s)}
end; o.parse!
if ARGV.length != 0
  $stderr.puts o
  exit 1
end
# Setup logging. bio-logger defaults to STDERR not STDOUT, I disagree
Bio::Log::CLI.logger(options[:logger]); log = Bio::Log::LoggerPlus.new(LOG_NAME); Bio::Log::CLI.configure(LOG_NAME)


mids = ARGF.readlines.compact.collect{|s|s.strip}.reject{|s|s==''}.uniq
log.info "Read #{mids.length} mids"

clusters = 

mids.each do |mid|
  num_bad_connections = mids.reject{|m| m==mid}.collect{|m| Levenshtein.distance(m, mid)}.select{|dist| dist < 2}.length
  puts [
    mid,
    num_bad_connections,
  ].join("\t")
end
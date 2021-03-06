#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'
require 'reachable'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'sequencing_mid_methods'

SCRIPT_NAME = File.basename(__FILE__); LOG_NAME = SCRIPT_NAME.gsub('.rb','')

# Parse command line options into the options hash
options = {
  :logger => 'stderr',
}
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} <mids_file>

    Take a list of MIDs (multiplex identifiers) and determine the hamming distances between them.\n\n"

  # logger options
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") {Bio::Log::CLI.trace('error')}
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") { |name| options[:logger] = name}
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG"){|s| Bio::Log::CLI.trace(s)}
end
o.parse!
if ARGV.length != 1 and ARGV.length != 0
  $stderr.puts o
  exit 1
end
# Setup logging. bio-logger defaults to STDERR not STDOUT, I disagree
Bio::Log::CLI.logger(options[:logger]); log = Bio::Log::LoggerPlus.new(LOG_NAME); Bio::Log::CLI.configure(LOG_NAME)

mids = ARGF.readlines.reach.strip.reject{|s| s.nil? or s==''}
log.info "Read #{mids.length} MIDs from the input"
mids.each_lower_triangular_matrix do |mid1, mid2|
  raise if mid1.gsub(/[ATGC]+/,'').length > 0
  raise if mid2.gsub(/[ATGC]+/,'').length > 0
  sliding_distance = MID.minimum_hamming_distance(mid1, mid2)
  
  min_length = [mid1,mid2].min{|a,b| a.length<=>b.length}.length
  distance = MID.hamming(mid1[0...min_length], mid2[0...min_length])
  
  lev1 = "#{mid1}"
  lev2 = "#{mid2}"
  lev = MID.levenshtein_distance(lev1, lev2)
  puts [
    sliding_distance,
    distance,
    lev,
    mid1,
    mid2,
  ].join("\t")
end
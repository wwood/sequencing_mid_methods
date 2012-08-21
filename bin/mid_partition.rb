#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'
require 'progressbar'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'sequencing_mid_methods'

SCRIPT_NAME = File.basename(__FILE__); LOG_NAME = SCRIPT_NAME.gsub('.rb','')

# Parse command line options into the options hash
options = {
  :logger => 'stdout',
}
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} -m MIDS_FILE
    
    Takes a list of MIDs, and determines the best 2 sets, that use the minimal levenshtein distance.\n\n"
    
  opts.on("-m", "--mids MIDS_FILE", "File of MIDs, one per line [default: #{options[:mids_file]}]") do |arg|
    options[:mids_file] = arg
  end

  # logger options
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") {Bio::Log::CLI.trace('error')}
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") { |name| options[:logger] = name}
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG"){|s| Bio::Log::CLI.trace(s)}
end; o.parse!
if ARGV.length != 0 or options[:mids_file].nil?
  $stderr.puts o
  exit 1
end
# Setup logging. bio-logger defaults to STDERR not STDOUT, I disagree
Bio::Log::CLI.logger(options[:logger]); log = Bio::Log::LoggerPlus.new(LOG_NAME); Bio::Log::CLI.configure(LOG_NAME)

# Read mids in from the file
mids = File.open(options[:mids_file]).readlines.reject{|s| s.nil?}.collect{|s| s.strip}.reject{|s| s==''}.sort
log.info "Read #{mids.length} MIDs"

# work out the distances between each of the mids
distances = {}
mids.each_lower_triangular_matrix do |mid1, mid2|
  distances[[mid1,mid2]] = MID.levenshtein_distance(mid1, mid2)
end
log.info "Calculated #{distances.length} distances between these MIDs, e.g. #{distances.keys[0].join(',')} => #{distances.values[0]}"

# Iterate through all possible arrays

number_in_gasket1 = mids.length/2
log.info "Number being assigned to the first partition is #{number_in_gasket1}, leaving #{mids.length-number_in_gasket1} for the second partition"
  
# mids.length choose number_in_gasket1. Simple combinatorics
# Ruby doesn't have factorial in the stdlib..
class Integer
  def factorial
    downto(1).inject(:*)
  end
end
n = mids.length
k = number_in_gasket1
number_combinations = n.factorial/(k.factorial*((n-k).factorial))
log.info "By brute force, this requires #{number_combinations} combinations"

# Setup progress bar
progress = ProgressBar.new('mid_partitioning', number_combinations)
current_record = 0
current_record_mids = []


# fitness function for a gasket (set of mids)
evaluate_gasket = lambda do |gasket_mids|
  min_distance = 10
  gasket_mids.sort.combination(2) do |mid1, mid2|
    dist = distances[[mid1, mid2]]
    #log.debug "Found distance #{dist} between #{mid1} and #{mid2}"
    # if dist==0
      # log.error "Found distance 0 between these two: #{mid1} and #{mid2}"
      # exit
    # end
    if dist < min_distance
      min_distance = dist
      break if min_distance <= current_record
    end
  end
  
  min_distance 
end

# Iterate through all possible combinations
mids.combination(number_in_gasket1) do |gasket1_mids|
  progress.inc
  # evalutate this partition - min distance in the first one, min distance in the second. If the maximum of these distances is less than the current record, replace. Otherwise do nothing
  gasket1_min_distance = evaluate_gasket.call(gasket1_mids)
  #log.debug "Found min distance #{gasket1_min_distance} for this gasket1"
  next if gasket1_min_distance <= current_record #no point evaluating the second gasket if the first already fails
  gasket2_mids = mids-gasket1_mids
  gasket2_min_distance = evaluate_gasket.call(gasket2_mids)
  log.debug "Found min distance #{gasket2_min_distance} for this gasket2"
  unless gasket2_min_distance <= current_record
    log.info "Found a current champion combination with distances #{gasket1_min_distance} and #{gasket2_min_distance}"
    current_record = [gasket1_min_distance, gasket2_min_distance].max
    current_record_mids = [gasket1_mids, gasket2_mids]
  end
end
progress.finish

log.info "Found a mid combination set with #{current_record} minimum distance: #{current_record_mids.inspect}"

puts [
  current_record,
  current_record_mids[0].join(','),
  current_record_mids[1].join(','),
].join("\n")

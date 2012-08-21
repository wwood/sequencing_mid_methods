#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'
require 'graphviz'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'sequencing_mid_methods'

SCRIPT_NAME = File.basename(__FILE__); LOG_NAME = SCRIPT_NAME.gsub('.rb','')

# Parse command line options into the options hash
options = {
  :logger => 'stderr',
  :output_dot => 'mid_graph.dot'
}
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} MID_FILE_1 MID_FILE_2

    Takes a set of mids, and outputs a graphviz file, so that they can be manually partitioned (the auto-way will take until the sun explodes to finish)\n\n"

  # opts.on("-e", "--eg ARG", "description [default: #{options[:eg]}]") do |arg|
  # options[:example] = arg
  # end

  # logger options
  opts.separator "\n\tVerbosity:\n\n"
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") {Bio::Log::CLI.trace('error')}
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") { |name| options[:logger] = name}
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG"){|s| Bio::Log::CLI.trace(s)}
end; o.parse!
if ARGV.length != 2
  $stderr.puts o
  exit 1
end
# Setup logging. bio-logger defaults to STDERR not STDOUT, I disagree
Bio::Log::CLI.logger(options[:logger]); log = Bio::Log::LoggerPlus.new(LOG_NAME); Bio::Log::CLI.configure(LOG_NAME)

# Read mids files
mids1 = File.open(ARGV[0]).readlines.compact.reject{|s| s==''}.collect{|s| s.strip}.uniq
log.info "Read #{mids1.length} mids from #{ARGV[0]}"
mids2 = File.open(ARGV[1]).readlines.compact.reject{|s| s==''}.collect{|s| s.strip}.uniq
log.info "Read #{mids2.length} mids from #{ARGV[1]}"

graph = GraphViz.new :MID_connections
#graph.node_attrs[:shape] = :point

nodes = []
# Add nodes for the first gasket in blue
mids1.each do |mid|
  graph.add_nodes(mid, :color => 'red', :label => mid)
  nodes.push mid
end
# Add nodes for the second gasket in green
mids2.each do |mid|
  graph.add_nodes(mid, :color => 'blue', :label => mid)
  nodes.push mid
end
log.info "Total nodes: #{nodes.length}, e.g. #{nodes[0].inspect}"

# For each pair of nodes, add an edge between them if their distance is less than 2
log.info "Calculating bad connections.."
nodes.combination(2).each do |array|
  mid1 = array[0]
  mid2 = array[1]
  dist = Levenshtein.distance(mid1, mid2)
  if dist < 2
    log.debug "Adding link between #{mid1} and #{mid2}"
    node1 = mid1
    node2 = mid2
    if mid1.length < mid2.length
      node1 = mid2
      node2 = mid1
    end
    graph.add_edges(node1, node2, :label => "#{dist}")
  end
end

log.info "Outputting graph to: #{options[:output_dot]}"
graph.output :dot => options[:output_dot]

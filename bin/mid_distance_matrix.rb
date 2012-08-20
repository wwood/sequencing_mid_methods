#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'
require 'reachable'

class MID
  
  def self.minimum_hamming_distance(mid1, mid2)
    #it's ok if shorter.length == longer.length
    longer = nil
    shorter = nil
    if mid1.length > mid2.length
      longer = mid1
      shorter = mid2
    else
      longer = mid2
      shorter = mid1
    end
    
    offset = 0
    min_distance = nil
    while shorter.length+offset <= longer.length
      string1 = shorter
      string2 = longer[offset...offset+shorter.length]
      distance = hamming string1, string2
      if min_distance.nil? or distance < min_distance
        min_distance = distance
      end
      offset += 1
      
    end
    
    return min_distance
  end
  
  def self.hamming(string1, string2)
    
    raise unless string1.length == string2.length
    distance = 0
    (0...string1.length).each do |i|
      char1 = string1[i]
      char2 = string2[i]
      distance += 1 if char1 != char2
    end
    return distance
  end
  
  # Stolen from http://rosettacode.org/wiki/Levenshtein_distance#Ruby
  def self.levenshtein_distance(s, t)
    m = s.length
    n = t.length
    return m if n == 0
    return n if m == 0
    d = Array.new(m+1) {Array.new(n+1)}
   
    (0..m).each {|i| d[i][0] = i}
    (0..n).each {|j| d[0][j] = j}
    (1..n).each do |j|
      (1..m).each do |i|
        d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                    d[i-1][j-1]       # no operation required
                  else
                    [ d[i-1][j]+1,    # deletion
                      d[i][j-1]+1,    # insertion
                      d[i-1][j-1]+1,  # substitution
                    ].min
                  end
      end
    end
    d[m][n]
  end
end

class Array
  # Similar to pairs(another_array) iterator, in that you iterate over 2
  # pairs of elements. However, here only the one array (the 'this' Enumerable)
  # and the names of these are from the names
  def each_lower_triangular_matrix
    each_with_index do |e1, i|
      if i < length-1
        self[i+1..length-1].each do |e2|
          yield e1, e2
        end
      end
    end
  end
end
  
if __FILE__ == $0 #needs to be removed if this script is distributed as part of a rubygem
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
    distance = MID.minimum_hamming_distance(mid1, mid2)
    lev1 = "123456789#{mid1}123456789"
    lev2 = "123456789#{mid2}123456789"
    lev = MID.levenshtein_distance(lev1, lev2)
    puts [
      distance,
      lev,
      mid1,
      mid2,
    ].join("\t")
  end
end #end if running as a script
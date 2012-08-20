require 'rspec'
require 'pp'
require 'open3'

# To run this test:
# $ rspec /path/to/test_script_being_tested.rb

# Assumes that the name of the file being tested is ../something.rb, and the name of this script is test_something.rb
$:.unshift File.join(File.dirname(__FILE__),'..')
script_under_test = File.basename(__FILE__).gsub(/^test_/,'')
require script_under_test
def assert_equal(e,o); o.should eq(e); end
path_to_script = File.join('..',script_under_test)



describe script_under_test do
  it 'hamming' do
    MID.hamming('AT','GC').should eq(2)
    MID.hamming('AT','AC').should eq(1)
    MID.hamming('ATGG','ATGG').should eq(0)
  end
  
  it 'min hamming' do
    MID.minimum_hamming_distance('AT','AT').should eq(0)
    MID.minimum_hamming_distance('AT','ATG').should eq(0)
    MID.minimum_hamming_distance('ACT','ATG').should eq(2)
    MID.minimum_hamming_distance('ACGT','ATG').should eq(1)
    MID.minimum_hamming_distance('ACGT','CAT').should eq(1)
    MID.minimum_hamming_distance('CAT','ACGT').should eq(1)
  end
  
  it 'should open3 test' do
    seqs = %w(AT ATG AGAGA)
    
    Open3.popen3("#{script_under_test} -q") do |stdin, stdout, stderr|
      stdin.puts seqs.join("\n")
      stdin.close
      
      err = stderr.readlines
      puts err
      raise err unless err == []
      answer = [
      %w(0 1 AT ATG).join("\t"),
      %w(1 4 AT AGAGA).join("\t"),
      %w(2 3 ATG AGAGA).join("\t"),
      ].join("\n")+"\n"
      stdout.read.should eq(answer)
    end
  end
end
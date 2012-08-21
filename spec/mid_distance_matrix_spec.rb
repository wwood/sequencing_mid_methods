require 'open3'
require 'spec_helper'

path_to_script = File.join(File.dirname(__FILE__),'..','bin','mid_distance_matrix.rb')



describe path_to_script do

  it 'should open3 test' do
    seqs = %w(AT ATG AGAGA)
    
    Open3.popen3("#{path_to_script} -q") do |stdin, stdout, stderr|
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
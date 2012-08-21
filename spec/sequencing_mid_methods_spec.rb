require 'spec_helper'

describe 'sequencing_mid_methods' do
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
end
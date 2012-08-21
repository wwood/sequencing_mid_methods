require 'text'

class Levenshtein
  include Text::Levenshtein
  
  def self.distance(str1, str2)
    Levenshtein.new.distance(str1, str2)
  end
end

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
  
  
  def self.levenshtein_distance(s, t)
    Levenshtein.distance(s, t)
    
    # m = s.length
    # n = t.length
    # return m if n == 0
    # return n if m == 0
    # d = Array.new(m+1) {Array.new(n+1)}
#    
    # (0..m).each {|i| d[i][0] = i}
    # (0..n).each {|j| d[0][j] = j}
    # (1..n).each do |j|
      # (1..m).each do |i|
        # d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                    # d[i-1][j-1]       # no operation required
                  # else
                    # [ d[i-1][j]+1,    # deletion
                      # d[i][j-1]+1,    # insertion
                      # d[i-1][j-1]+1,  # substitution
                    # ].min
                  # end
      # end
    # end
    # d[m][n]
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



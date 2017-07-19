class FreqStats
  attr_accessor :total_grams, :freq_n_chars, :max_ngrams, :max_ngram_freqs

  def initialize(max_ngrams,max_ngram_freqs)
    return nil unless (max_ngrams.is_a?(Integer) && max_ngrams>0 && max_ngram_freqs.is_a?(Integer) && max_ngram_freqs>0)
    @total_grams = Hash.new(0)
    @freq_n_chars = {} # hash of hashes that have n-gram -> freq mapping ; reverse sorted
    @max_ngrams = max_ngrams
    @max_ngram_freqs = max_ngram_freqs
  end

  def stats_cost_from(other_freq)  # max n is max size of ngrams - using 5 here
    # return the total cost  from self; only look at keys in the hashes that
    cost = {}
    total_cost = 0
    (1..@max_ngrams).each {|i| total_cost += distance(@freq_n_chars[i],other_freq.freq_n_chars[i])    }
    total_cost ## Just a dumb total_cost function right now as a trial
  end

  def translate_using(key)
    # returns how ngram frequencies will look once key is used to 'decrypt' the
    # document that represents the current FreqStats object
    return nil unless key.is_a?(Hash)
    # translate the state var hashes by decrypting/translating using the key
    # return a new object of Frequencies type
    trans = Marshal.load(Marshal.dump(self))
    translated_keys = {}
    (1..@max_ngrams).each do |i|
      translated_keys[i] = trans.freq_n_chars[i].keys.map { |el|
                            el.chars.map{|c| key[c]}.join
                          }
      trans.freq_n_chars[i] = translated_keys[i].zip(trans.freq_n_chars[i].values).to_h
    end
    trans
  end

  def key_from_character_frequencies(plain_freqs)
    # A simple starting key by simply mapping the character frequencies in order
    # in the plain text document and the encrypted text document
    key = {}
    encr = @freq_n_chars[1].sort_by{|_,v| v}.to_h.keys
    plain = plain_freqs.freq_n_chars[1].sort_by{|_,v| v}.to_h.keys
    plain.each_with_index do |v,i|
      key[v] =  encr[i];
    end
    key.invert.sort_by {|k,v| k}.to_h
  end


  # ngrams with frequencies close to each other - higher the n, smaller the vicinity in which we search EXPONENTIALLY
  # This is just one algorithm - may not be optimal
  def ngram_sets_w_freq_within_percent(n,pc)
    return nil unless (n.is_a?(Integer) && n>=1)
    arr = []
    (1..n).each {|i|
      @freq_n_chars[i].keys.each { |c|
        curr_freq = @freq_n_chars[i][c]
        @freq_n_chars[i].select {|k,v| k > c && ((v-curr_freq).abs < (pc ** i))}.keys.each { |el|
          if c.length==1
            arr << [c,el]
          else
            arr1 = c.chars
            arr2 = el.chars
            (0..(arr1.length-1)).each {|j|
              sorted_swp_chars = [arr1[j],arr2[j]].sort
              arr << sorted_swp_chars unless (arr.include?(sorted_swp_chars) || (arr1[j] == arr2[j]))
            }
          end
        }
      }
    }
    arr
    # result is an array of 2-element-arrays; each element of the
    # 2-element-array is an ngram similar to the other element ngram of same n
  end

  private

  def distance(hash1, hash2) # distance from first hash
    sum = 0
    hash1.each {|k,v| v2 = hash2[k] || 0; sum += (v-v2)**2 }
    Math.sqrt(sum)
  end

  def top_freq(n,frq_hash)
    return nil unless (n.is_a?(Integer) && n>0 && frq_hash.is_a?(Hash))
    frq_hash.sort_by {|_,v| v}.reverse[0..(n-1)].to_h
  end
end

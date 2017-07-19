class Traverser
  attr_accessor :curr_best_key, :curr_min_cost, :keys_traversed

  def initialize(encr_freqs,base_freqs,key)
    return nil unless (encr_freqs.is_a?(FreqStats) && base_freqs.is_a?(FreqStats) && key.is_a?(Hash))

    @encr_freqs = encr_freqs
    @base_freqs = base_freqs
    @curr_best_key = key # string form
    @curr_min_cost = cost_with_key(key)
    @keys_traversed = {flatted(@curr_best_key) => @curr_min_cost}
  end

  def traverse_by_flipping_adjacent_chars_in_freq(adj_n=1,adj_pc=1.0)
    # only swap adj_n away in index and only if the percent difference in frequency is less than adj_pc
    char_freqs = @encr_freqs.freq_n_chars[1].to_a
    (0..(char_freqs.length-1-adj_n)).each {|i|
      adj = i+adj_n
      if (char_freqs[i][1] - char_freqs[adj][1]).abs < adj_pc
        new_key = KeySet.update_key(@curr_best_key,[char_freqs[i][0],char_freqs[adj][0]])
        traverse_keys([new_key])
      end
    }
  end

  def traverse_over_keys_highest_ngram_freq_wise(n,max_ngrams)
    # TOP n for 2-grams, n/2 for 3-grams, n/4 for 4 grams etc.
    (2..max_ngrams).each { |i|
      (0..(2*n/i)).each { |j|
        e_chars = @encr_freqs.freq_n_chars[i].keys[j].chars
        p_chars = @base_freqs.freq_n_chars[i].keys[j].chars
        curr_key = Marshal.load(Marshal.dump(@curr_best_key))
        (0..(e_chars.length-1)).each {|indx|
          tmp = curr_key[e_chars[indx]]
          to_swp = curr_key.key(p_chars[indx])
          curr_key[e_chars[indx]] = p_chars[indx]
          curr_key[to_swp] = tmp
        }
        if !key_traversed?(curr_key)
          this_cost = cost_with_key(curr_key)
          insert_traversed_key(curr_key,this_cost)
          if this_cost < @curr_min_cost
            @curr_min_cost = this_cost
            @curr_best_key = curr_key
          end
        end
      }
    }
  end

  def traverse_keys(key_set)
    return nil unless (key_set.is_a? Array)
    key_set.each { |key|
      if !key_traversed?(key)
        this_cost = cost_with_key(key)
        insert_traversed_key(key,this_cost)
        if this_cost < @curr_min_cost
          @curr_min_cost = this_cost
          @curr_best_key = key
        end
      end
    }
  end

  def cost_with_key(key)
    freq_stats = @encr_freqs.translate_using(key)
    freq_stats.stats_cost_from(@base_freqs)
  end

  def flatted(key)
    return nil unless (key.is_a?(Hash) && key.keys.length==26)
    # key is flattened to a string - so sorting works
    key.sort_by{|k,_| k}.to_h.values.join
  end

  private
  def key_traversed? (key)
    # if fkey is in the @keys_sorted array
    @keys_traversed.keys.include? flatted(key)
  end

  def insert_traversed_key(key,cost)
    @keys_traversed[flatted(key)] = cost
  end


end

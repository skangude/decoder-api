class Doc
  attr_reader :text, :frq, :sanitized_text, :words, :word_freq, :all_gram_freq, :key_from_char_freqs

  def initialize(str,freqs)    # empty FreqStats object passed to fill in
    @text = str if str.is_a? String
    @frq = freqs if freqs.is_a? FreqStats
    if @text && @frq
      @sanitized_text = sanitized
      @words = words_arr
      # @word_freq = word_histogram
      @all_gram_freq = all_grams_from_words

      (1..@frq.max_ngrams).each { |i|
        @frq.freq_n_chars[i]=n_gram_hash(i,@frq.max_ngram_freqs)
      }
    end
  end

  def n_gram_hash(n,limit)
    hash = @all_gram_freq.select {|k,_| k.length==n} if (n.is_a?(Integer) && n>0)
    h = hash.sort_by {|_,v| v}.reverse[0..(limit-1)].to_h   # reverse sorted hash on freq values
    h.each {|k,v| h[k] = v.to_f * 100.0 / @frq.total_grams[n].to_f}  # percent normalized
  end

  private

  def sanitized
    # p "TEXT follows"
    # p @text
    # replace with space all non alpha chars except apostrophe; remove apostrophe
    @text.downcase.gsub(/[^a-z\']/i,' ').gsub(/[\']/i,'')
  end

  def words_arr
    # p "sanitized_text follows"
    # p @sanitized_text
    @sanitized_text.split
  end

  # def word_histogram
  #   @words.inject(Hash.new(0)) {|hash,word| hash[word] += 1; hash}
  # end

  def all_grams_from_words
    # p @words
    @words.inject(Hash.new(0)) {|hash,word|
      sub_strs = sub_strings(word)
      # p "sub strings:"
      # p sub_strs
      sub_strs.each { |ss|
        # p ss
        # p hash
        hash[ss] += 1
        @frq.total_grams[ss.length] += 1  # storing total for each substring size
      }
      hash
    }
  end

  def sub_strings(word)
    (0..word.length).inject([]) {|ai,i|
      (1..word.length - i).inject(ai) {|aj,j|
        aj << word[i,j]
      }
    }
  end

end

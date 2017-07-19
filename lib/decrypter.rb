class Decrypter

  MAX_NGRAMS = 6
  MAX_NGRAM_FREQS = 30

  PERCENT_SWP_RANGE = 2.0
  ADJ_CHARS_RANGE = 5
  TWO_GRAM_KEY_MAP_RANGE = 6

  def initialize(plain,encr,decr)
    @plain_fname = plain
    @encr_fname = encr
    @decr_fname = decr
  end

  def decrypt
    plain_doc = Doc.new(File.read(@plain_fname),FreqStats.new(MAX_NGRAMS,MAX_NGRAM_FREQS))
    encr_doc = Doc.new(File.read(@encr_fname),FreqStats.new(MAX_NGRAMS,MAX_NGRAM_FREQS))

    plain_freqs = plain_doc.frq
    encr_freqs = encr_doc.frq

    initial_key = encr_freqs.key_from_character_frequencies(plain_freqs)

    traverser = Traverser.new(encr_doc.frq,plain_doc.frq,initial_key)
    traverser.traverse_over_keys_highest_ngram_freq_wise(TWO_GRAM_KEY_MAP_RANGE,MAX_NGRAMS)
    (1..ADJ_CHARS_RANGE).each { |i| traverser.traverse_by_flipping_adjacent_chars_in_freq(i,PERCENT_SWP_RANGE) }

    output_decrypted_file(traverser)
  end

  def output_decrypted_file(traverser)
    decr_key = traverser.curr_best_key
    encrypted_text = File.read(@encr_fname).downcase
    decrypted_text = encrypted_text.chars.map { |c|  if (c<='z' && c>='a') then decr_key[c] else c end}.join
    #json_str = decrypted_text.to_json

    File.open(@decr_fname, 'w') { |file| file.write(decrypted_text) }
    json_data = {encryptedFile: encrypted_text ,decryptedFile: decrypted_text, decrKey: traverser.flatted(decr_key)}
  end

end

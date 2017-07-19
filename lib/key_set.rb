class KeySet

  def self.update_key(key,swp)
    # a swp is an array of 2 elements that are to be swapped
    # each element is a string whose characters need to be replaced with other's characters
    nkey = Marshal.load(Marshal.dump(key))
    arr1=swp[0].chars
    arr2=swp[1].chars
    len = arr1.length
    return nil if len != arr2.length
    (0..(len-1)).each {|i|
        tmp = nkey[arr1[i]]
        nkey[arr1[i]] = nkey[arr2[i]]
        nkey[arr2[i]] = tmp
    }
    nkey
  end

end

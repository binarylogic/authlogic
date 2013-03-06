require 'digest/sha2'

module Authlogic
  module CryptoProviders
    class Drupal
      class << self

        ITOA64 = './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
				DRUPAL_MIN_HASH_COUNT = 7
				DRUPAL_MAX_HASH_COUNT = 30
				DRUPAL_HASH_LENGTH = 55

				
				def matches?(crypted, *tokens)
					# The first 12 characters of an existing hash are its setting string.   
					crypted_password = crypted     
					crypted = crypted[0..11]
				
					if(crypted[0] != '$' || crypted[2] != '$')
						return false
					end

					count_log2 = ITOA64.index(crypted[3].to_s)
					# Hashes may be imported from elsewhere, so we allow != DRUPAL_HASH_COUNT
					if(count_log2 < DRUPAL_MIN_HASH_COUNT || count_log2 > DRUPAL_MAX_HASH_COUNT)
						return 1
					end
					
					salt = crypted[4..11]
					if salt.length != 8
						return 2
					end

					# Convert the base 2 logarithm into an integer. (check if it not have -1 somewhere)
					count = 1 << count_log2
					# Plain = introduced password
					plain, not_used_salt = *tokens
					digest = salt + plain
					hash = Digest::SHA512.digest(digest)
					
					while count > 0 do
						digest = hash.to_s + plain
						hash = Digest::SHA512.digest(digest)
						count -= 1
					end

					len = hash.length
					output = crypted + encode_64(hash,len)
					expected = 12+ ((8*len).to_f/6).ceil 
					# return (output.length == expected) ? output[0,DRUPAL_HASH_LENGTH] : false
					return (output[0,DRUPAL_HASH_LENGTH] == crypted_password ) if output.length == expected
				end
        def encode_64(input, length)
          output = "" 
          i = 0
          while i < length
            #value = input[i].to_i 
						value = input[i].ord
            i+=1
            break if value.nil?
            output += ITOA64[value & 0x3f, 1]
            value |= input[i].ord << 8 if i < length
            output += ITOA64[(value >> 6) & 0x3f, 1]

            i+=1
            break if i >= length
            value |= input[i].ord << 16 if i < length
            output += ITOA64[(value >> 12) & 0x3f,1]

            i+=1
            break if i >= length
            output += ITOA64[(value >> 18) & 0x3f,1]
          end
          output
        end
      end
    end
  end
end

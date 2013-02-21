begin
  require "bcrypt"
rescue LoadError
  "sudo gem install bcrypt-ruby"
end

module Authlogic
  module CryptoProviders
    # For most apps Sha512 is plenty secure, but if you are building an app that stores nuclear launch codes you might want to consier BCrypt. This is an extremely
    # secure hashing algorithm, mainly because it is slow. A brute force attack on a BCrypt encrypted password would take much longer than a brute force attack on a
    # password encrypted with a Sha algorithm. Keep in mind you are sacrificing performance by using this, generating a password takes exponentially longer than any
    # of the Sha algorithms. I did some benchmarking to save you some time with your decision:
    #
    #   require "bcrypt"
    #   require "digest"
    #   require "benchmark"
    #
    #   Benchmark.bm(18) do |x|
    #     x.report("BCrypt (cost = 10:") { 100.times { BCrypt::Password.create("mypass", :cost => 10) } }
    #     x.report("BCrypt (cost = 4:") { 100.times { BCrypt::Password.create("mypass", :cost => 4) } }
    #     x.report("Sha512:") { 100.times { Digest::SHA512.hexdigest("mypass") } }
    #     x.report("Sha1:") { 100.times { Digest::SHA1.hexdigest("mypass") } }
    #   end
    #
    #                            user     system      total        real
    #   BCrypt (cost = 10):  37.360000   0.020000  37.380000 ( 37.558943)
    #   BCrypt (cost = 4):    0.680000   0.000000   0.680000 (  0.677460)
    #   Sha512:               0.000000   0.000000   0.000000 (  0.000672)
    #   Sha1:                 0.000000   0.000000   0.000000 (  0.000454)
    #
    # You can play around with the cost to get that perfect balance between performance and security.
    #
    # Decided BCrypt is for you? Just install the bcrypt gem:
    #
    #   gem install bcrypt-ruby
    #
    # Tell acts_as_authentic to use it:
    #
    #   acts_as_authentic do |c|
    #     c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    #   end
    #
    # You are good to go!
    class BCrypt
      class << self
        # This is the :cost option for the BCrpyt library. The higher the cost the more secure it is and the longer is take the generate a hash. By default this is 10.
        # Set this to any value >= the engine's minimum (currently 4), play around with it to get that perfect balance between security and performance.
        def cost
          @cost ||= 10
        end
        def cost=(val)
          if val < ::BCrypt::Engine::MIN_COST
            raise ArgumentError.new("Authlogic's bcrypt cost cannot be set below the engine's min cost (#{::BCrypt::Engine::MIN_COST})")
          end
          @cost = val
        end
        
        # Creates a BCrypt hash for the password passed.
        def encrypt(*tokens)
          ::BCrypt::Password.create(join_tokens(tokens), :cost => cost)
        end
        
        # Does the hash match the tokens? Uses the same tokens that were used to encrypt.
        def matches?(hash, *tokens)
          hash = new_from_hash(hash)
          return false if hash.blank?
          hash == join_tokens(tokens)
        end
        
        # This method is used as a flag to tell Authlogic to "resave" the password upon a successful login, using the new cost
        def cost_matches?(hash)
          hash = new_from_hash(hash)
          if hash.blank?
            false
          else
            hash.cost == cost
          end
        end
        
        private
          def join_tokens(tokens)
            tokens.flatten.join
          end
          
          def new_from_hash(hash)
            begin
              ::BCrypt::Password.new(hash)
            rescue ::BCrypt::Errors::InvalidHash
              return nil
            end
          end
      end
    end
  end
end

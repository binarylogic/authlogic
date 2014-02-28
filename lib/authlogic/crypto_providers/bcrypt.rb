begin
  require "bcrypt"
rescue LoadError
  "sudo gem install bcrypt-ruby"
end

module Authlogic
  module CryptoProviders
    # The family of adaptive hash functions (BCrypt, SCrypt, PBKDF2)
    # is the best choice for password storage today. They have the
    # three properties of password hashing that are desirable. They
    # are one-way, unique, and slow. While a salted SHA or MD5 hash is
    # one-way and unique, preventing rainbow table attacks, they are
    # still lightning fast and attacks on the stored passwords are
    # much more effective. This benchmark demonstrates the effective
    # slowdown that BCrypt provides:
    #
    #   require "bcrypt"
    #   require "digest"
    #   require "benchmark"
    #
    #   Benchmark.bm(18) do |x|
    #     x.report("BCrypt (cost = 10:") { 100.times { BCrypt::Password.create("mypass", :cost => 10) } }
    #     x.report("BCrypt (cost = 2:") { 100.times { BCrypt::Password.create("mypass", :cost => 2) } }
    #     x.report("Sha512:") { 100.times { Digest::SHA512.hexdigest("mypass") } }
    #     x.report("Sha1:") { 100.times { Digest::SHA1.hexdigest("mypass") } }
    #   end
    #
    #                           user     system      total        real
    #   BCrypt (cost = 10): 10.780000   0.060000  10.840000 ( 11.100289)
    #   BCrypt (cost = 2):  0.180000   0.000000   0.180000 (  0.181914)
    #   Sha512:             0.000000   0.000000   0.000000 (  0.000829)
    #   Sha1:               0.000000   0.000000   0.000000 (  0.000395)
    #
    # You can play around with the cost to get that perfect balance
    # between performance and security. A default cost of 10 is the
    # best place to start.
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
        # Set this to whatever you want, play around with it to get that perfect balance between security and performance.
        def cost
          @cost ||= 10
        end
        attr_writer :cost
        
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

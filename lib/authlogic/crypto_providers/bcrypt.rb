begin
  require "bcrypt"
rescue LoadError
end

module Authlogic
  module CryptoProviders
    # = Bcrypt
    #
    # For most apps Sha512 is plenty secure, but if you are building an app that stores the nuclear launch codes you might want to consier BCrypt. This is an extremely
    # secure hashing algorithm, mainly because it is slow. A brute force attack on a BCrypt encrypted password would take much longer than a brute force attack on a
    # password encrypted with a Sha algorithm. Keep in mind you are sacrificing performance by using this, generating a password takes exponentially longer than any
    # of the Sha algorithms. I did some benchmarking to save you some time with your decision:
    #
    #   require "bcrypt"
    #   require "digest"
    #   require "benchmark"
    #
    #   Benchmark.bm do |x|
    #     x.report("BCrypt:") { BCrypt::Password.create("mypass") }
    #     x.report("Sha512:") { Digest::SHA512.hexdigest("mypass") }
    #   end
    #
    #             user     system      total        real
    #   BCrypt:  0.110000   0.000000   0.110000 (  0.113493)
    #   Sha512:  0.010000   0.000000   0.010000 (  0.000554)
    #
    # Decided BCrypt is for you? Just insall the bcrypt gem:
    #
    #   gem install bcrypt-ruby
    class Bcrypt
      class << self
        def cost
          @cost ||= 10
        end
        attr_writer :cost
        
        def encrypt(pass)
          BCrypt::Password.create(pass, :cost => cost)
        end
        
        # This does not actually decrypt the password, BCrypt is *not* reversible. The way the bcrypt library is set up requires us to do it this way.
        def decrypt(crypted_pass)
          BCrypt::Password.create(crypted_pass)
        end
      end
    end
  end
end
require 'test_helper'

class RandomTest < ActiveSupport::TestCase
  def test_that_hex_tokens_are_unique
    tokens = Array.new(100) { Authlogic::Random.hex_token }
    assert_equal tokens.size, tokens.uniq.size
  end

  def test_that_friendly_tokens_are_unique
    tokens = Array.new(100) { Authlogic::Random.friendly_token }
    assert_equal tokens.size, tokens.uniq.size
  end
end

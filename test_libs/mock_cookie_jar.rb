class MockCookieJar < Hash
  def [](key)
    hash = super
    hash && hash[:value]
  end
end
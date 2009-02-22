module Authlogic # :nodoc:
  # = Version
  #
  # A class for describing the current version of a library. The version
  # consists of three parts: the +major+ number, the +minor+ number, and the
  # +tiny+ (or +patch+) number.
  class Version
    
    include Comparable
  
    # A convenience method for instantiating a new Version instance with the
    # given +major+, +minor+, and +tiny+ components.
    def self.[](major, minor, tiny)
      new(major, minor, tiny)
    end

    attr_reader :major, :minor, :tiny

    # Create a new Version object with the given components.
    def initialize(major, minor, tiny)
      @major, @minor, @tiny = major, minor, tiny
    end

    # Compare this version to the given +version+ object.
    def <=>(version)
      to_i <=> version.to_i
    end

    # Converts this version object to a string, where each of the three
    # version components are joined by the '.' character. E.g., 2.0.0.
    def to_s
      @to_s ||= [@major, @minor, @tiny].join(".")
    end

    # Converts this version to a canonical integer that may be compared
    # against other version objects.
    def to_i
      @to_i ||= @major * 1_000_000 + @minor * 1_000 + @tiny
    end
    
    def to_a
      [@major, @minor, @tiny]
    end

    MAJOR = 1
    MINOR = 4
    TINY  = 3

    # The current version as a Version instance
    CURRENT = new(MAJOR, MINOR, TINY)
    # The current version as a String
    STRING = CURRENT.to_s
    
  end
  
end
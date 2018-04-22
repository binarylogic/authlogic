module Authlogic
  # This is a module the contains regular expressions used throughout Authlogic.
  # The point of extracting them out into their own module is to make them
  # easily available to you for other uses. Ex:
  #
  #   validates_format_of :my_email_field, :with => Authlogic::Regex.email
  module Regex
    # A general email regular expression. It allows top level domains (TLD) to
    # be from 2 - 24 in length. The decisions behind this regular expression
    # were made by analyzing the list of top-level domains maintained by IANA
    # and by reading this website:
    # http://www.regular-expressions.info/email.html, which is an excellent
    # resource for regular expressions.
    EMAIL = /
      \A
      [A-Z0-9_.&%+\-']+   # mailbox
      @
      (?:[A-Z0-9\-]+\.)+  # subdomains
      (?:[A-Z]{2,25})     # TLD
      \z
    /ix

    # A draft regular expression for internationalized email addresses. Given
    # that the standard may be in flux, this simply emulates @email_regex but
    # rather than allowing specific characters for each part, it instead
    # disallows the complement set of characters:
    #
    # - email_name_regex disallows: @[]^ !"#$()*,/:;<=>?`{|}~\ and control characters
    # - domain_head_regex disallows: _%+ and all characters in email_name_regex
    # - domain_tld_regex disallows: 0123456789- and all characters in domain_head_regex
    #
    # http://en.wikipedia.org/wiki/Email_address#Internationalization
    # http://tools.ietf.org/html/rfc6530
    # http://www.unicode.org/faq/idn.html
    # http://ruby-doc.org/core-2.1.5/Regexp.html#class-Regexp-label-Character+Classes
    # http://en.wikipedia.org/wiki/Unicode_character_property#General_Category
    EMAIL_NONASCII = /
      \A
      [^[:cntrl:][@\[\]\^ \!"\#$\(\)*,\/:;<=>?`{|}~\\]]+                        # mailbox
      @
      (?:[^[:cntrl:][@\[\]\^ \!\"\#$&\(\)*,\/:;<=>\?`{|}~\\_.%+']]+\.)+         # subdomains
      (?:[^[:cntrl:][@\[\]\^ \!\"\#$&\(\)*,\/:;<=>\?`{|}~\\_.%+\-'0-9]]{2,25})  # TLD
      \z
    /x

    # A simple regular expression that only allows for letters, numbers, spaces, and
    # .-_@+. Just a standard login / username regular expression.
    LOGIN = /\A[a-zA-Z0-9_][a-zA-Z0-9\.+\-_@ ]+\z/

    # Accessing the above constants using the following methods is deprecated.

    # @deprecated
    def self.email
      ::ActiveSupport::Deprecation.warn(
        "Authlogic::Regex.email is deprecated, use Authlogic::Regex::EMAIL",
        caller(1)
      )
      EMAIL
    end

    # @deprecated
    def self.email_nonascii
      ::ActiveSupport::Deprecation.warn(
        "Authlogic::Regex.email_nonascii is deprecated, use Authlogic::Regex::EMAIL_NONASCII",
        caller(1)
      )
      EMAIL_NONASCII
    end

    # @deprecated
    def self.login
      ::ActiveSupport::Deprecation.warn(
        "Authlogic::Regex.login is deprecated, use Authlogic::Regex::LOGIN",
        caller(1)
      )
      LOGIN
    end
  end
end

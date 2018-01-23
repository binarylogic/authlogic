module Authlogic
  # This is a module the contains regular expressions used throughout Authlogic. The point
  # of extracting them out into their own module is to make them easily available to you
  # for other uses. Ex:
  #
  #   validates_format_of :my_email_field, :with => Authlogic::Regex.email
  module Regex
    # A general email regular expression. It allows top level domains (TLD) to be from 2 -
    # 24 in length. The decisions behind this regular expression were made by analyzing
    # the list of top-level domains maintained by IANA and by reading this website:
    # http://www.regular-expressions.info/email.html, which is an excellent resource for
    # regular expressions.
    def self.email
      @email_regex ||= begin
        email_name_regex  = '[A-Z0-9_\.&%\+\-\']+'
        domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
        domain_tld_regex  = '(?:[A-Z]{2,25})'
        /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
      end
    end

    # A draft regular expression for internationalized email addresses. Given that the
    # standard may be in flux, this simply emulates @email_regex but rather than allowing
    # specific characters for each part, it instead disallows the complement set of
    # characters:
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
    def self.email_nonascii
      @email_nonascii_regex ||= begin
        email_name_regex  = '[^[:cntrl:][@\[\]\^ \!\"#$\(\)*,/:;<=>\?`{|}~\\\]]+'
        domain_head_regex = '(?:[^[:cntrl:][@\[\]\^ \!\"#$&\(\)*,/:;<=>\?`{|}~\\\_\.%\+\']]+\.)+'
        domain_tld_regex  = '(?:[^[:cntrl:][@\[\]\^ \!\"#$&\(\)*,/:;<=>\?`{|}~\\\_\.%\+\-\'0-9]]{2,25})'
        /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/
      end
    end

    # A simple regular expression that only allows for letters, numbers, spaces, and
    # .-_@+. Just a standard login / username regular expression.
    def self.login
      /\A[a-zA-Z0-9_][a-zA-Z0-9\.+\-_@ ]+\z/
    end
  end
end

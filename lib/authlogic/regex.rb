#encoding: utf-8
module Authlogic
  # This is a module the contains regular expressions used throughout Authlogic. The point of extracting
  # them out into their own module is to make them easily available to you for other uses. Ex:
  #
  #   validates_format_of :my_email_field, :with => Authlogic::Regex.email
  module Regex
    # A general email regular expression. It allows top level domains (TLD) to be from 2 - 13 in length.
    # The decisions behind this regular expression were made by analyzing the list of top-level domains
    # maintained by IANA and by reading this website: http://www.regular-expressions.info/email.html,
    # which is an excellent resource for regular expressions.
    def self.email
      @email_regex ||= begin
        email_name_regex  = '[A-Z0-9_\.%\+\-\']+'
        domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
        domain_tld_regex  = '(?:[A-Z]{2,13})'
        /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
      end
    end

    # A simple regular expression that only allows for letters, numbers, spaces, and .-_@. Just a standard login / username
    # regular expression.
    def self.login
      /\A\w[\w\.+\-_@ ]+\z/
    end
  end
end

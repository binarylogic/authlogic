# Upgrading Authlogic

Supplemental instructions to complement CHANGELOG.md.

## 3.4.0

In version 3.4.0, the default crypto_provider was changed from *Sha512* to *SCrypt*.

If you never set a crypto_provider and are upgrading, your passwords will break unless you set the original:

``` ruby
c.crypto_provider = Authlogic::CryptoProviders::Sha512
```

And if you want to automatically upgrade from *Sha512* to *SCrypt* as users login:

```ruby
c.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
c.crypto_provider = Authlogic::CryptoProviders::SCrypt
```

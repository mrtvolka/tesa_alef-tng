# ALEF: The Next Generation

ALEF: TNG is a learning system.

## Requirements

* Ruby 2.2
* Bundler
* PostgreSQL 9.3

## Installation

Clone and install gems.

```
git clone git@github.com:PewePro/alef-tng.git
cd alef-tng
bundle install
```

Edit configuration file(s).

```
cp config/database.yml.example config/database.yml
vim config/database.yml
```

Create the database.

```
RAILS_ENV=development rake db:create && rake db:migrate
```

Optionally, seed the database with development data.

```
RAILS_ENV=development rake db:seed
```

## Testing

!TODO!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin new-feature`)
5. Create new Pull Request

## License

!TODO!

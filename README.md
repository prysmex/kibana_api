# Kibana

This repository contains Ruby integrations for [Kibana API](https://www.elastic.co/guide/en/kibana/7.x/using-api.html).

## Getting started

Add this line to your application's Gemfile:

```ruby
gem 'kibana'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kibana

Create `config/initializers/kibana.rb` and set your Kibana API credentials.

```ruby
Kibana.configure do |config|
  config.api_host = ENV['KIBANA_API_HOST']
  config.api_key = ENV['KIBANA_API_KEY']
end
```

Remember to base64-encode the id and api_key provided by Kibana like this: `id:api_key`

## Usage

### Importing the client

Kibana::API provides a list of clients that will help you make requests to the REST API. You need to instanciate the client that you require and it will give you access to the methods specified by Kibana.

```ruby
saved_object_client = Kibana::API::SavedObjectClient.new
saved_object_client.create(params, "index-pattern",  "my_new_index_pattern")
```

- [Kibana::API::SpaceClient](https://www.elastic.co/guide/en/kibana/master/spaces-api.html)
  - `create(params)` 
  - `update(id, params)`
  - `get_by_id(id)`
  - `get_all`
  - `delete(id)`
  - `copy_saved_objects_to_space TODO`
  - `resolve_copy_to_space_conflicts TODO`

- [Kibana::API::SavedObjectClient](https://www.elastic.co/guide/en/kibana/master/saved-objects-api.html)
  - `create(params, type, id, space_id, options)` 
  - `bulk_create(params, space_id, options)`
  - `update(params, type, id, space_id, options)`
  - `get_by_id(id, type, space_id)`
  - `delete(id, type, space_id)`
  - `bulk_get(params, space_id)`
  - `find(params, space_id)`
  - `exists?(id, type, space_id)`
  - `import(params, space_id)`
  - `export(params, space_id, options)`
  - `resolve_import_errors(params, space_id, options)`

- [Kibana::API::RoleClient](https://www.elastic.co/guide/en/kibana/master/role-management-api.html)
  - `create(id, params)` 
  - `update(id, params)`
  - `get_by_id(id)`
  - `get_all`
  - `delete(id)`

### Notes

There are still missing some clients and methods, but it has the essentials to get started with the integration.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/prysmex/kibana_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kibana project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/prysmex/kibana_api/blob/master/CODE_OF_CONDUCT.md).

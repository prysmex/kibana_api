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
Kibana::API.client = Kibana::Transport::Client.new({
  api_host: ENV['KIBANA_API_HOST'],
  api_key: ENV['KIBANA_API_KEY']
})
```

Remember to base64-encode the id and api_key provided by Kibana like this: `id:api_key`

## Usage

### Transport client

Kibana::Transport::Client class is used to connect to your kibana instance. To instantiate a new client, simply pass
your api_host and api_key.

```ruby
transport_client = Kibana::Transport::Client.new(api_host: ENV['some_host'], api_key: ENV['some_host'])
```

In order to keep referencing to your same kibana client instance, save it in the Kibana::API module
```ruby
Kibana::API.client = transport_client

# now you can always access it
Kibana::API.client
```

### Accessing the API clients

Kibana::API provides a list of clients that will help you make requests to the REST API. You need to instanciate the client that you require and it will give you access to the methods specified by Kibana.

Faraday is used as the HTTP library.

Let's do an example with the SavedObjectClient.

```ruby
saved_object_client = Kibana::API::SavedObjectClient.new(transport_client)
saved_object_client.create(...) #create a new saved object!
```

In order to make it easier to create an manage references to created API clients, there is a shorhand for this.
```ruby
# this also creates a new saved object and stores the SavedObjectClient instance reference for future use!
transport_client.saved_object.create(...)
transport_client.saved_object.update(...)

#of course, you also can use your previously stored client
Kibana::API.client.saved_object.get(...)
```

### API clients

These is the list of the supported API clients:

- Kibana::API::CanvasClient
- Kibana::API::DashboardClient
- Kibana::API::FeaturesClient
- Kibana::API::RoleClient
- Kibana::API::SavedObjectClient
- Kibana::API::SpaceClient

If you want to prevent parsing the response, you can use {raw: true} as a parameter in API method

```ruby
Kibana::API.client.saved_object.find({..., raw: true})
```

Similarly, if you want to prevent the request's body stringification (required by Faraday on json requests), you can pass {raw_body: true}
```ruby
Kibana::API.client.saved_object.import({..., raw_body: true})
```

Since Kibana is organized into spaces, DashboardClient and SavedObjectClient support setting the space context via block syntax

```ruby
# to default space
Kibana::API.client.saved_object.find(...)

# with a specified space
Kibana::API.client.saved_object.with_space('your_awesome_space') do |saved_object_client|
  # all methods are scoped to your_awesome_space
  saved_object_client.find(...)
  saved_object_client.create(...)

  #you can nest the context!
  Kibana::API.client.saved_object.with_space('your_awesome_space') do |other_client|
    other_client.find(...)
  end

  #still on your_awesome_space context
  saved_object_client.create(...)
end
```


### Detailed method list

- [Kibana::API::CanvasClient](https://www.elastic.co/guide/en/kibana/master/saved-objects-api.html)
  - `find`

- [Kibana::API::DashboardClient](https://www.elastic.co/guide/en/kibana/master/dashboard-api.html)
  - `export`
  - `import`

- [Kibana::API::FeaturesClient](https://www.elastic.co/guide/en/kibana/master/features-api-get.html)
  - `features`

- [Kibana::API::RoleClient](https://www.elastic.co/guide/en/kibana/master/role-management-api.html)
  - `create`
  - `update`
  - `get_by_id`
  - `get_all`
  - `delete`

- [Kibana::API::SavedObjectClient](https://www.elastic.co/guide/en/kibana/master/saved-objects-api.html)
  - `get`
  - `bulk_get`
  - `find`
  - `find_each_page` ToDo: Use scroll API
  - `create`
  - `bulk_create`
  - `update`
  - `delete`
  - `export`
  - `import`
  - `resolve_import_errors TODO`
  - `exists?`
  - `related_objects`
  - `counts`
  - `find_orphans`
  - `fields_for_index_pattern`

- [Kibana::API::SpaceClient](https://www.elastic.co/guide/en/kibana/master/spaces-api.html)
  - `create` 
  - `update`
  - `get_by_id`
  - `get_all`
  - `delete`
  - `exists?`
  - `copy_saved_objects_to_space TODO`
  - `resolve_copy_to_space_conflicts TODO`
  - `get_current_config`
  - `copy_saved_objects_to_spaces`

### Notes

There are still some missing methods, but it has the essentials to get started with the integration.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/prysmex/kibana_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kibana project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/prysmex/kibana_api/blob/master/CODE_OF_CONDUCT.md).

# Contributing

## Testing

First, prepare a database for the test.

```sh
bundle install
RAILS_ENV=test bundle exec rake db:create db:migrate
```

We use [Appraisal](https://github.com/thoughtbot/appraisal) to test with different versions of Rails.

```
appraisal install

# Run with specific version of Rails
appraisal rails-4.1 rspec

# Run with all versions of Rails
appraisal rspec
```

## Run local server

When run local server, use multithreaded server and specify some environment variables.
If you have not created OAuth application in development environment, create it with
`rails console` command.

```
bundle exec rake db:create db:migrate
cd spec/dummy/
GARAGE_REMOTE_SERVER=http://localhost:3000/ \
  GARAGE_CONSOLE_APP_UID=$ANY_CONSOLE_APP_UID \
  bundle exec puma -t '2:10' -p3000
```

You can get an information of resources in `http://localhost:3000/docs`.

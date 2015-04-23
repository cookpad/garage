# Contributing
## Development tips
We use [Appraisal](https://github.com/thoughtbot/appraisal) to test with different versions of Rails.

```
bundle install
appraisal install

# Run with specific version of Rails
appraisal rails-4.1 rspec

# Run with all versions of Rails
appraisal rspec
```

When run local server, use multithreaded server and specify some environment variables.
If you have not created oauth application in development environment, create it with
`rails console` command.

```
# In spec/dummy
GARAGE_REMOTE_SERVER=http://localhost:3000/ \
  GARAGE_CONSOLE_APP_UID=$ANY_CONSOLE_APP_UID \
  bundle exec puma -t '2:10' -p3000
```

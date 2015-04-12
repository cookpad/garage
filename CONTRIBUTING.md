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

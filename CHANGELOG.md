# CHANGELOG

## 2.8.2 - 2022-11-01

* Delete sassc-rails from dependencies [#116](https://github.com/cookpad/garage/pull/116)
* Avoid unexpected error at `Garage::Utils#fuzzy_parse` [#118](https://github.com/cookpad/garage/pull/118)
* Modify typo of `Garage::Tracer::NullTracer`'s docs [#119](https://github.com/cookpad/garage/pull/119)

## 2.8.1 - 2022-04-05

* Removed dependency to coffee-rails [#115](https://github.com/cookpad/garage/pull/115)

## 2.8.0 - 2022-01-11

* Don't return location from #create if URL pattern for #show is not found [#108](https://github.com/cookpad/garage/pull/108)
* Migrate from sass-rails to sassc-rails [#109](https://github.com/cookpad/garage/pull/109)

## 2.7.0 - 2021-10-15

* Fix double running rspec [#103](https://github.com/cookpad/garage/pull/103)
* Replace render :text with :plain for Rails 5.1+ [#104](https://github.com/cookpad/garage/pull/104)
* Setup docker for development use [#105](https://github.com/cookpad/garage/pull/105)
* Use GitHub Actions [#106](https://github.com/cookpad/garage/pull/106)
* **BREAKING CHANGE:** Drop support for Rails 4.0 and 4.1 [#107](https://github.com/cookpad/garage/pull/107)

## 2.6.1 - 2021-03-14

* Support Rails 6.1 [#102](https://github.com/cookpad/garage/pull/102)

## 2.6.0 - 2020-10-21

* Pass the X-Request-Id header to an auth server [#96](https://github.com/cookpad/garage/pull/96)
* Support Kaminari 1.x [#97](https://github.com/cookpad/garage/pull/97)
* Use the Authorization header instead of the access_token query parameter to send an access token in the console [#99](https://github.com/cookpad/garage/pull/99)

## 2.5.0 - 2020-06-25

* Allow options to be passed to `to_resource` when casting resources
* Supports Ruby 2.7 and Rails 6 [#91](https://github.com/cookpad/garage/pull/91)
* Dropped support for EOL Ruby 2.3, 2.4 [#91](https://github.com/cookpad/garage/pull/91)

## 2.4.4 - 2019-06-13

* Include selector string to cache key. [#88](https://github.com/cookpad/garage/pull/88)

## 2.4.3 - 2017-09-22

* Configurable signout path. [#84](https://github.com/cookpad/garage/pull/84)

## 2.4.2 - 2017-06-20

* Switch to use net/http hook to implement distributed tracing support. [#83](https://github.com/cookpad/garage/pull/83)

## 2.4.1 - 2017-06-09

* Use disable_trace to disable net/http hook. [#81](https://github.com/cookpad/garage/pull/81)

## 2.4.0 - 2017-06-07

* Support distributed tracing. [#80](https://github.com/cookpad/garage/pull/80)

## 2.3.3 - 2017-02-01

* Compatible with ruby 2.4 (Integer unification). #73
* Compatible with oj v2.18.0 (use_as_json option). #75

## 2.3.2 - 2016-11-11

* Correctly implement setting current path feature #72

## 2.3.1 - 2016-11-11

* Set current path with query parameters to `return_to` #71

## 2.3.0 - 2016-09-02

* Add label for scope checkbox [#67](https://github.com/cookpad/garage/pull/67)
* Update documentation [#68](https://github.com/cookpad/garage/pull/68)
* Add checkbox to check all scopes [#69](https://github.com/cookpad/garage/pull/69)

## 2.2.0 - 2016-08-18

* Migrate to RSpec3 #63
* Support rails version 5 #64 #66

## 2.1.0 - 2016-05-16

* Hold raw response of auth server in AccessToken #62
* Fully support the "presentation layer design" #60
* Users can access configuration object without initialization #61
* Fix typo in code document #58
* Follow WebMock 2.0 changes #59

## 2.0.3 - 2016-04-14

* Check the value is a Representer #57

## 2.0.2 - 2016-02-18

* Require responders automatically #56

## 2.0.1 - 2016-02-18

* `Bundler.require` can require by `the_garage` name.

## 2.0.0 - 2016-02-18

* Apply new gem name: the_garage #55

## 1.5.5 - 2016-02-09

* Fix broken toc feature #54
  * Add links of permalink to header of document.

## 1.5.4 - 2016-02-02

* Treat as valid access token with null token value #53

## 1.5.3 - 2016-02-02

* Add an option to respond with body for PATCH #35
* Fix issue with STI models #38
* Treat Symbol as a primitive type #39
* Remove unnecessary `preserve` helper #40
* Simplify primitive? check #42
* use `xxx_action` instead of deprecated `xxx_filter` #46
* Better checking to detect resource(s) is a collection #48
* Identify resource by `#resource_identifier` in addition to `#id` #50
* Improve AuthServer strategy #51
* Remove forgotten doorkeeper things #52

## 1.5.2 - 2015-08-13

* `unauthorized_render_options` accepts `error` keyword argument.

## 1.5.1 - 2015-07-09

* Bump version of http_accept_language to 2.0.0.

## 1.5.0 - 2015-05-20

* Support Time type as primitive types.
* Doorkeeper depndency was seprated to other gem as extension.
  * Use https://github.com/cookpad/garage-doorkeeper to keep Doorkeeper integration.
  * Remove no_authentiction feature. Use `Garage::Strategy::NoAuthentication` instread.
  * Document feature requires both console-app uid and console-app secret. Previously,
    this only required console-app uid.
  * Default auth strategy is `NoAuthentication`. Use Doorkeeper or AuthServer strategy
    to authentication/authorize request. See 'Advanced Configurations' section in README.

## 1.4.1 - 2015-04-23

* Support namespace in API document feature.

## 1.4.0 - 2015-04-17

* Support doorkeeper gem v2.0.0 or later.
* Drop support of doorkeeper v1.4.2 or earlier.

## 1.3.1 - 2015-04-09

* Fix Definition#name to convert @options[:as] to string.
* Accept doorkeeper > 1.4.1 for security issue.
* Add rescue_error check to NoAuthentication as ControllerHelper.
* Support date type as a representable object.
* Loosen redcarpet version restriction to accept >= 3.2.x.

## 1.3.0 - 2014-12-24

* Support Rails 4.2.
* Drop support of Rails 3.x.

## 1.2.5 - 2014-09-25

* Divide unauthorized error into missing scope error and permission error
  so that application can identify and handle missing scope error and permission error.

## 1.2.4 - 2014-08-05

* Remove garage_docs prefix.
* Limit upper version of doorkeeper gem.

## 1.2.3 - 2014-07-15

* Add `read_timeout` option for connecting slow auth center (like staging).

## 1.2.2 - 2014-07-02

* Support Rails 4 style path methods

## 1.2.1 - 2014-06-12

* Replace inheritable property implementation to speed things up

## 1.2.0 - 2014-06-04

* Add `Garage.configuration.rescue_error` (default: true)

## 1.1.9 - 2014-05-19

* Change scope symbols to strings.
* Add no authentication and no AuthCenter option.

## 1.1.8 - 2014-05-12

* Revert adding disable AuthCenter option. It has bugs.

## 1.1.7 - 2014-05-12

* Use Authorization Code Grant Flow at console

## 1.1.6 - 2014-05-09

* Add disable AuthCenter option. But authentication with doorkeeperDB is still alive.

## 1.1.5 - 2014-05-02

* Inheritable property

## 1.1.4 - 2014-05-01

* Fix redcarpet version

## 1.1.3 - 2014-05-01

* Improve console

## 1.1.2 - 2014-04-09

* Update redcarpet gem version. redcarpet 3.1.1 has fixed SEGV bug.

## 1.1.1 - 2014-04-07

* Fix `<` & `>` handling on JSON encoding
* Remove refresh_token attribute from access token object

## 1.1.0 - 2014-02-04

* Added auth-center integration

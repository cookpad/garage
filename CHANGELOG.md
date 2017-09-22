# CHANGELOG
## 2.4.3
* Configurable signout path. [#84](https://github.com/cookpad/garage/pull/84)

## 2.4.2
* Switch to use net/http hook to implement distributed tracing support. [#83](https://github.com/cookpad/garage/pull/83)

## 2.4.1
* Use disable_trace to disable net/http hook. [#81](https://github.com/cookpad/garage/pull/81)

## 2.4.0
* Support distributed tracing. [#80](https://github.com/cookpad/garage/pull/80)

## 2.3.3
* Compatible with ruby 2.4 (Integer unification). #73
* Compatible with oj v2.18.0 (use_as_json option). #75

## 2.3.2
* Correctly implement setting current path feature #72

## 2.3.1
* Set current path with query parameters to `return_to` #71

## 2.3.0
* Add label for scope checkbox [#67](https://github.com/cookpad/garage/pull/67)
* Update documentation [#68](https://github.com/cookpad/garage/pull/68)
* Add checkbox to check all scopes [#69](https://github.com/cookpad/garage/pull/69)

## 2.2.0
* Migrate to RSpec3 #63
* Support rails version 5 #64 #66

## 2.1.0
* Hold raw response of auth server in AccessToken #62
* Fully support the "presentation layer design" #60
* Users can access configuration object without initialization #61
* Fix typo in code document #58
* Follow WebMock 2.0 changes #59

## 2.0.3
* Check the value is a Representer #57

## 2.0.2
* Require responders automatically #56

## 2.0.1
* `Bundler.require` can require by `the_garage` name.

## 2.0.0
* Apply new gem name: the_garage #55

## 1.5.5
* Fix broken toc feature #54
  * Add links of permalink to header of document.

## 1.5.4
* Treat as valid access token with null token value #53

## 1.5.3
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

## 1.5.2
* `unauthorized_render_options` accepts `error` keyword argument.

## 1.5.1
* Bump version of http_accept_language to 2.0.0.

## 1.5.0
* Support Time type as primitive types.
* Doorkeeper depndency was seprated to other gem as extension.
  * Use https://github.com/cookpad/garage-doorkeeper to keep Doorkeeper integration.
  * Remove no_authentiction feature. Use `Garage::Strategy::NoAuthentication` instread.
  * Document feature requires both console-app uid and console-app secret. Previously,
    this only required console-app uid.
  * Default auth strategy is `NoAuthentication`. Use Doorkeeper or AuthServer strategy
    to authentication/authorize request. See 'Advanced Configurations' section in README.

## 1.4.1
* Support namespace in API document feature.

## 1.4.0
* Support doorkeeper gem v2.0.0 or later.
* Drop support of doorkeeper v1.4.2 or earlier.

## 1.3.1
* Fix Definition#name to convert @options[:as] to string.
* Accept doorkeeper > 1.4.1 for security issue.
* Add rescue_error check to NoAuthentication as ControllerHelper.
* Support date type as a representable object.
* Loosen redcarpet version restriction to accept >= 3.2.x.

## 1.3.0
* Support Rails 4.2.
* Drop support of Rails 3.x.

## 1.2.5
* Divide unauthorized error into missing scope error and permission error
  so that application can identify and handle missing scope error and permission error.

## 1.2.4
* Remove garage_docs prefix.
* Limit upper version of doorkeeper gem.

## 1.2.3
* Add `read_timeout` option for connecting slow auth center (like staging).

## 1.2.2
* Support Rails 4 style path methods

## 1.2.1
* Replace inheritable property implementation to speed things up

## 1.2.0
* Add `Garage.configuration.rescue_error` (default: true)

## 1.1.9
* Change scope symbols to strings.
* Add no authentication and no AuthCenter option.

## 1.1.8
* Revert adding disable AuthCenter option. It has bugs.

## 1.1.7
* Use Authorization Code Grant Flow at console

## 1.1.6
* Add disable AuthCenter option. But authentication with doorkeeperDB is still alive.

## 1.1.5
* Inheritable property

## 1.1.4
* Fix redcarpet version

## 1.1.3
* Improve console

## 1.1.2
* Update redcarpet gem version. redcarpet 3.1.1 has fixed SEGV bug.

## 1.1.1
* Fix `<` & `>` handling on JSON encoding
* Remove refresh_token attribute from access token object

## 1.1.0
* Added auth-center integration

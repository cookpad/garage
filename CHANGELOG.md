# CHANGELOG
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

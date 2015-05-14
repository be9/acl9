## 2.0.0 - 14 May 2015

Thanks to @pjungwir:

 * Raise ArgumentError now if bad options passed to allow/deny

## 1.3.0 - 13 May 2015

Quick new feature dump:

 * Prepositions in has(_no)_role[!?] methods

## 1.2.1 - 13 Mar 2015

Bugfix for API love:

 * Rails::API was erroring

## 1.2.0 - 12 Jan 2015

The generator release (and some other cool new features):

 * New: ZOMG - we have a generator now
 * Role names are now normalized with `.underscore.singularize` - especially
   handy in case sensitive DBs
 * New: `Acl9.configure` lets you specify config options nicely
 * New: `object.users :managers` to get a list of users who have manager role on
   `object`
 * Testing against Ruby 2.2

## 1.1.0 - 15 Dec 2014

Bugfix release with a minor version bump because one security fix might not be
expected, also doc improvements

 * `has_role!` was not returning true properly when more roles remained (this is
   the change that might be unexpected)
 * License added to gemspec
 * Testing against Rails 4.2
 * When subject was destroyed, roles were not removed from the DB.

## 1.0.0 - 22 Nov 2014

The resurrection, Rails4, doc cleanup, Ruby2, SemVer, xunit, lots of stuff:

 * Getting involved is easier, ie. you should be able to just `bundle && rake`
 * The tests are all in xunit now because rspec is ugly, slow and cumbersome (and the whole test suite now runs in 3 seconds (on my machine ;))
 * The deprecation warnings are GOOOOONE
 * That annoying "Stack level too deep" bug is fixed
 * There's now an actual license for the project
 * The gemspec specifies the license (and doesn't have the date hardcoded anymore)
 * The wiki is New and Improved™ - with a lot of work still left to do there
 * WIP: The README is being reduced to something more consumable (because all the nitty gritty details are now in the wiki)
 * The README is now in markdown, so it's easier to transfer things out into the wiki
 * We've adopted SemVer officially
 * The issues are groomed and in milestones
 * CI is now happening on Travis
 * Code quality is now happening on CodeClimate
 * We're testing against Rails 4.0 and 4.1 in both Ruby 2.0 and 2.1 now
 * We're officially not supporting Rails < 4 or Ruby < 2 in the 1.x releases (we'll bow to peer pressure if there is any)
 * WIP: `protect_global_roles` is true by default for 1.0.0
 * We're now on IRC as #acl9 (on freenode)

## 0.12.0 - 04 Jan 2010

An anniversary release of fixes and hacks, introduced by venerable users of the plugin.

 * Allow for inheritance of subject (Jeff Jaco)
 * Renamed "Object" module in extensions, since it caused some breakage inside activesupport
   (invisiblelama).
 * `show_to` helper for usage in views (Antono Vasiljev)
 * `:association_name` config option, now you can change Subject#role_objects to whatever
   you want (Jeff Tucker).
 * Fix bug when Subject#id is a string, e.g. UUID (Julien Bachmann)
 * Bug with action blocks when using anonymous and another role (Franck)


## 0.11.0 - 16 Sep 2009

 * :protect_global_roles
 * Subject#roles renamed to Subject#role_objects
 * Fix namespaced models in roles backend (thanks goes to Tomas Jogin)
 * Action name override in boolean methods.
 * `:query_method` option for `access_control`.

## 0.10.0 - 03 May 2009

 * Use context+matchy combo for testing
 * Bugfix: unwanted double quote in generated SQL statement

## 0.9.4 - 27 Feb 2009

 * Introduce :if and :unless rule options.

## 0.9.3 - 04 Feb 2009

 * Fix bug in delete_role - didn't work with custom class names
 * Add `:helper` option for `access_control`.
 * Ability to generate helper methods directly (place `include Acl9Helpers` in your helper module).

## 0.9.2 - 11 Jan 2009

 * `access_control :method do end` as shorter form for `access_control :as_method => :method do end`.
 * Boolean method can now receive an objects hash which will be looked into first before taking
   an instance variable.

## 0.9.1 - 03 Jan 2009

Initial release.

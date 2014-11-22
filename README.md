# acl9 [![](https://travis-ci.org/be9/acl9.svg?branch=master)](https://travis-ci.org/be9/acl9)

Acl9 is yet another solution for role-based authorization in Rails. It consists of two
 subsystems which can be used separately.

**Role control subsystem** allows you to set and query user roles for various objects.

**Access control subsystem** allows you to specify different role-based access rules
 inside controllers.

A bunch of access rules is translated into a complex
boolean expression. Then it's turned into a lambda or a method and can
be used with `before_filter`. Thus you can block unprivileged access to certain
actions of your controller.

An example:

    class VerySecretController < ApplicationController
      access_control do
        allow :superadmin
        allow :owner, :of => :secret

        action :index do
          allow anonymous, logged_in
        end

        allow logged_in, :to => :show
        allow :manager, :of => :secret, :except => [:delete, :destroy]
        deny :thiefs
      end

      def index
        # ...
      end

      # ...
    end

## Contacts

Acl9 is hosted [on GitHub](http://github.com/be9/acl9).

You may find tutorials and additional docs on the [wiki page](http://wiki.github.com/be9/acl9).

Rdocs are available [here](http://rdoc.info/projects/be9/acl9).

If you have questions, please post to the
 [acl9-discuss group](http://groups.google.com/group/acl9-discuss)

## Installation

Acl9 can be installed as a gem from [gemcutter](http://gemcutter.org).

### in Rails 2.3

Add the following line to your `config/environment.rb`:

    config.gem "acl9", :source => "http://gemcutter.org", :lib => "acl9"

Then run rake gems:install (with possible rake gems:unpack thereafter) and you're done!

Alternatively you can install Acl9 as a plugin:

    script/plugin install git://github.com/be9/acl9.git

### in Rails 3.0

Add the following line to your Gemfile:

    gem "acl9"

Then run bundle install and you're done!

Alternatively you can install Acl9 as a plugin:

    rails plugin install git://github.com/be9/acl9.git

## Basics

### Authorization is not authentication!

Both words start with "auth" but have different meaning!

**Authentication** is basically a mapping of credentials (username, password) or
OpenID to specific user account in the system.

**Authorization** is an authenticated user's permission to perform some
specific action somewhere in the system.

Acl9 is a authorization solution, so you will need to implement authentication
by other means. I recommend Authlogic
for that purpose, as it's simple, clean and at the same time very configurable.

### Roles

Role is an abstraction. You could directly assign permissions to user accounts in
your system, but you'd not want to! Way more manageable solution is to assign permissions
to roles and roles further to users.

For example, you can have role called admin which has all available permissions. Now
you may assign this role to several trusted accounts on your system.

Acl9 also supports the notion of object roles, that is, roles with limited scope.

Imagine we are building a magazine site and want to develop a permission system. So, what roles
and permissions are there?

Journalists should be able to create articles in their section and edit their own articles.

Section editors should be able to edit and delete all articles in their sections and
change the published flag.

Editor-in-chief should be able to change everything.

We clearly see that journalists and section editors are tied to a specific section, whereas
editor-in-chief is a role with global scope.

### Role interface

All permission checks in Acl9 are boiled down to calls of a single method:

    subject.has_role?(role, object)

That should be read as "Does subject have role on object?".

Subject is an instance of a User, or Account, or whatever model you use for
authentication.  Object is an instance of any class (including subject class!)
or nil (in which case it's a global role).

Acl9 builtin role control subsystem provides has_role? method for you, but you can
also implemented it by hand (see Coming up with your own role implementation below).

## Acl9 role control subsystem

Role control subsystem has been lifted from
Rails authorization plugin,
but undergone some modifications.

It's based on two tables in the database. First, role table, which stores pairs [role_name, object]
where object is a polymorphic model instance or a class. Second, join table, which joins users and roles.

To use this subsystem, you should define a Role model.

### Role model

    class Role < ActiveRecord::Base
      acts_as_authorization_role
    end

The structure of `roles` table is as follows:

    create_table "roles", :force => true do |t|
      t.string   :name,              :limit => 40
      t.string   :authorizable_type, :limit => 40
      t.integer  :authorizable_id
      t.timestamps
    end

    add_index :roles, [:authorizable_type, :authorizable_id]

Note that you will almost never use the `Role` class directly.

### Subject model

    class User < ActiveRecord::Base
      acts_as_authorization_subject  :association_name => :roles
    end

You won't need any specific columns in the `users` table, but
there should be a join table:

    create_table "roles_users", :id => false, :force => true do |t|
      t.references  :user
      t.references  :role
      t.timestamps
    end

    add_index :roles_users, :user_id
    add_index :roles_users, :role_id

### Object model

Place `acts_as_authorization_object` call inside any model you want to act
as such.

    class Foo < ActiveRecord::Base
      acts_as_authorization_object
    end

    class Bar < ActiveRecord::Base
      acts_as_authorization_object
    end

### Interface

#### Subject model

A call of `acts_as_authorization_subject` defines following methods on the model:

`subject.has_role?(role, object = nil)`. Returns `true` of `false` (has or has not).

`subject.has_role!(role, object = nil)`. Assigns a `role` for the `object` to the `subject`.
 Does nothing is subject already has such a role.

`subject.has_no_role!(role, object = nil)`. Unassigns a role from the `subject`.

`subject.has_roles_for?(object)`. Does the `subject` has any roles for `object`? (`true` of `false`)

`subject.has_role_for?(object)`. Same as `has_roles_for?`.

`subject.roles_for(object)`. Returns an array of `Role` instances, corresponding to `subject`'s roles on
 `object`. E.g. `subject.roles_for(object).map(&:name).sort` will give you role names in alphabetical order.

`subject.has_no_roles_for!(object)`. Unassign any `subject`'s roles for a given `object`.

`subject.has_no_roles!`. Unassign all roles from `subject`.

#### Object model

A call of `acts_as_authorization_object` defines following methods on the model:

`object.accepts_role?(role_name, subject)`. An alias for `subject.has_role?(role_name, object)`.

`object.accepts_role!(role_name, subject)`. An alias for `subject.has_role!(role_name, object)`.

`object.accepts_no_role!(role_name, subject)`. An alias for `subject.has_no_role!(role_name, object)`.

`object.accepts_roles_by?(subject)`. An alias for `subject.has_roles_for?(object)`.

`object.accepts_role_by?(subject)`. Same as `accepts_roles_by?`.

`object.accepts_roles_by(subject)`. An alias for `subject.roles_for(object)`.

TODO - add the `accepted_roles` stuff in here.

### Custom class names

You may want to deviate from default `User` and `Role` class names. That can easily be done with
arguments to `acts_as_...`.

Say, you have `Account` and `AccountRole`:

    class Account < ActiveRecord::Base
      acts_as_authorization_subject :role_class_name => 'AccountRole'
    end

    class AccountRole < ActiveRecord::Base
      acts_as_authorization_role :subject_class_name => 'Account'
    end

    class FooBar < ActiveRecord::Base
      acts_as_authorization_object :role_class_name => 'AccountRole', :subject_class_name => 'Account'
    end

Or... since Acl9 defaults can be changed in a special hash, you can put the following snippet:

    Acl9::config.merge!({
      :default_role_class_name => 'AccountRole',
      :default_subject_class_name => 'Account',
    })

... into `config/initializers/acl9.rb` and get rid of that clunky arguments:

    class Account < ActiveRecord::Base
      acts_as_authorization_subject
    end

    class AccountRole < ActiveRecord::Base
      acts_as_authorization_role
    end

    class FooBar < ActiveRecord::Base
      acts_as_authorization_object
    end

Note that you'll need to change your database structure appropriately:

    create_table "account_roles", :force => true do |t|
      t.string   :name,              :limit => 40
      t.string   :authorizable_type, :limit => 40
      t.integer  :authorizable_id
      t.timestamps
    end

    create_table "account_roles_accounts", :id => false, :force => true do |t|
      t.references  :account
      t.references  :account_role
      t.timestamps
    end

### Examples

    user = User.create!
    user.has_role? 'admin'              # => false

    user.has_role! :admin

    user.has_role? :admin               # => true

`user` now has global role *admin*. Note that you can specify role name either
 as a string or as a symbol.

    foo = Foo.create!

    user.has_role? 'admin', foo         # => false

    user.has_role! :manager, foo

    user.has_role? :manager, foo        # => true
    foo.accepts_role? :manager, user    # => true

    user.has_roles_for? foo             # => true

You can see here that global and object roles are distinguished from each other. User
with global role *admin* isn't automatically admin of `foo`.

However,

    user.has_role? :manager             # => true

That is, if you have an object role, it means that you have a global role with the same name too!
 In other words, you are *manager* if you manage at least one `foo` (or a `bar`...).

    bar = Bar.create!

    user.has_role! :manager, bar
    user.has_no_role! :manager, foo

    user.has_role? :manager, foo        # => false
    user.has_role? :manager             # => true

Our `user` is no more manager of `foo`, but has become a manager of `bar`.

    user.has_no_roles!

    user.has_role? :manager             # => false
    user.has_role? :admin               # => false
    user.roles                          # => []

At this time `user` has no roles in the system.

### Coming up with your own role implementation

The described role system with its 2 tables (not counting the `users` table!)
might be an overkill for many cases. If all you want is global roles without
any scope, you'd better off implementing it by hand.

The access control subsystem of Acl9 uses only `subject.has_role?` method, so
there's no need to implement anything else except for own convenience.

For example, if each your user can have only one global role, just add `role`
column to your `User` class:

    class User < ActiveRecord::Base
      def has_role?(role_name, obj=nil)
        self.role == role_name
      end

      def has_role!(role_name, obj=nil)
        self.role = role_name
        save!
      end
    end

If you need to assign multiple roles to your users, you can use `serialize`
with role array or a special solution like
[preference_fu](http://github.com/brennandunn/preference_fu).

## Access control subsystem

By means of access control subsystem you can protect actions of your controller
from unauthorized access. Acl9 provides a nice DSL for writing access rules.

### Allow and deny

Access control is mostly about allowing and denying. So there are two
basic methods: `allow` and `deny`. They have the same syntax:

    allow ROLE_LIST, OPTIONS
    deny  ROLE_LIST, OPTIONS

#### Specifying roles

ROLE_LIST is a list of roles (at least 1 role should be there). So,

    allow :manager, :admin
    deny  :banned


will match holders of global role *manager* **and** holders of global role *admin* as allowed.
On the contrary, holders of *banned* role will match as denied.

Basically this snippet is equivalent to

    allow :manager
    allow :admin
    deny  :banned


which means that roles in argument list are OR'ed for a match, and not AND'ed.

Also note that:

 * You may use both strings and :symbols to specify roles (the latter get converted into strings).
 * Role names are singularized before check.

Thus the snippet above can also be written as

    allow :managers, :admins
    deny  'banned'


or even

    allow *%w(managers admins)
    deny  'banned'

#### Object and class roles

Examples in the previous section were all about global roles. Let's see how we can
use object and class roles in the ACL block.

    allow :responsible, :for => Widget
    allow :possessor, :of => :foo
    deny  :angry, :at => :me
    allow :interested, :in => Future
    deny  :short, :on => :time
    deny  :hated, :by => :us

To specify an object you use one of the 6 preposition options:

 * :of
 * :at
 * :on
 * :by
 * :for
 * :in

They all have the same meaning, use one that makes better English out of your rule.

Now, each of these prepositions may point to a Class or a :symbol. In the former case we get
class role. E.g. `allow :responsible, :for => Widget` becomes `subject.has_role?('responsible', Widget)`.

Symbol is trickier, it means that the appropriate instance variable of the controller is taken
as an object.

`allow :possessor, :of => :foo` is translated into
`subject.has_role?('possessor', controller.instance_variable_get('@foo'))`.

Checking against an instance variable has sense when you have another *before filter* which is executed
**before** the one generated by `access_control`, like this:

    class MoorblesController < ApplicationController
      before_filter :load_moorble, :only => [:edit, :update, :destroy]

      access_control do
        allow :creator, :of => :moorble

        # ...
      end

      # ...

      private

      def load_moorble
        @moorble = Moorble.find(params[:id])
      end
    end

Note that the object option is applied to all of the roles you specify in the argument list.
As such,

    allow :devil, :son, :of => God


is equivalent to

    allow :devil, :of => God
    allow :son,   :of => God

but **NOT**

    allow :devil
    allow :son, :of => God

#### Pseudo-roles

There are three pseudo-roles in the ACL: `all`, `anonymous` and `logged_in`.

`allow all` will always match (as well as `deny all`).

`allow anonymous` and `deny anonymous` will match when user is anonymous, i.e. subject is `nil`.
 You may also use a shorter notation: `allow nil` (`deny nil`).

`logged_in` is direct opposite of `anonymous`, so `allow logged_in` will match if the user is logged in
 (subject is not `nil`).

No role checks are done in either case.

#### Limiting action scope

By default rules apply to all actions of the controller. There are two options that
 narrow the scope of the `deny` or `allow` rule: `:to` and `:except`.

    allow :owner, :of => :site, :to => [:delete, :destroy]
    deny anonymous, :except => [:index, :show]

For the first rule to match not only the current user should be an *owner* of the *site*, but also
current action should be *delete* or *destroy*.

In the second rule anonymous user access is denied for all actions, except *index* and *show*.

You may not specify both `:to` and `:except`.

Note that you can use actions block instead of `:to` (see *Actions block*
below). You can also use `:only` and `:except` options in the
`access_control` call which will serve as options of the `before_filter` and thus
limit the scope of the whole ACL.

#### Rule conditions

You may create conditional rules using `:if` and `:unless` options.

    allow :owner, :of => :site, :to => [:delete, :destroy], :if => :chance_to_delete

Controller's `:chance_to_delete` method will be called here. The rule will match if the action
is 'delete' or 'destroy' AND if the method returned `true`.

`:unless` has the opposite meaning and should return `false` for a rule to match.

Both options can be specified in the same rule.

    allow :visitor, :to => [:index, :show], :if => :right_phase_of_the_moon?, :unless => :suspicious?

`right_phase_of_the_moon?` should return `true` AND `suspicious?` should return `false` for a poor visitor to see a page.

Currently only controller methods are supported (specify them as :symbols). Lambdas are **not** supported.

### Rule matching order

Rule matching system is similar to that of Apache web server. There are two modes: *default allow*
(corresponding to `Order Deny,Allow` in Apache) and *default deny* (`Order Allow,Deny` in Apache).

#### Setting modes

Mode is set with a `default` call.

`default :allow` will set *default allow* mode.

`default :deny` will set *default deny* mode. Note that this is the default mode, i.e. it will be on
if you don't do a `default` call at all.

#### Matching algorithm

First of all, regardless of the mode, all `allow` matches are OR'ed together and all `deny` matches
are OR'ed as well.

We'll express this in the following manner:

    ALLOWED = (allow rule 1 matches?) OR ((allow rule 2 matches?) OR ...
    NOT_DENIED = NOT ((deny rule 1 matches?) OR (deny rule 2 matches?) OR ...)

So, ALLOWED is `true` when either of the `allow` rules matches, and NOT_DENIED is `true` when none
of the `deny` rules matches.

Let's denote the final result of algorithm as ALLOWANCE. If it's `true`, access is allowed, if `false`, denied.

In the case of *default allow*:

    ALLOWANCE = ALLOWED OR NOT_DENIED

In the case of *default deny*:

    ALLOWANCE = ALLOWED AND NOT_DENIED

Same result as a table:

|_. Rule matches |_. Default allow mode |_. Default deny mode |
| None of the `allow` and `deny` rules matched. | Access is allowed. | Access is denied. |
| Some of the `allow` rules matched, none of the `deny` rules matched. | Access is allowed. | Access is allowed. |
| None of the `allow` rules matched, some of the `deny` rules matched. | Access is denied. | Access is denied. |
| Some of the `allow` rules matched, some of the `deny` rules matched. | Access is allowed. | Access is denied. |

Apparently *default deny* mode is more strict, and that's because it's on by default.

### Actions block

You may group rules with the help of the `actions` block.

An example from the imaginary `PostsController`:

    allow :admin

    actions :index, :show do
      allow all
    end

    actions :new, :create do
      allow :managers, :of => Post
    end

    actions :edit, :update do
      allow :owner, :of => :post
    end

    action :destroy do
      allow :owner, :of => :post
    end

This is equivalent to:

    allow :admin

    allow all, :to => [:index, :show]
    allow :managers, :of => Post, :to => [:new, :create]
    allow :owner, :of => :post, :to => [:edit, :update]
    allow :owner, :of => :post, :to => :destroy

Note that only `allow` and `deny` calls are available inside `actions` block, and these may not have
`:to`/`:except` options.

`action` is just a synonym for `actions`.

### access_control method

By calling `access_control` in your controller you can get your ACL block translated into...

1.  a lambda, installed with `before_filter` and raising `Acl9::AccessDenied` exception on occasion.
2.  a method, installed with `before_filter` and raising `Acl9::AccessDenied` exception on occasion.
3.  a method, returning `true` or `false`, whether access is allowed or denied.

First case is by default. You can catch the exception with `rescue_from` call and do something
you like: make a redirect, or render "Access denied" template, or whatever.

Second case is obtained with specifying method name as an argument to
`access_control` (or using `:as_method` option, see below) and may be helpful
if you want to use `skip_before_filter` somewhere in the derived controller.

Third case will take place if you supply `:filter => false` along with method
name. You'll get an ordinary method which you can call anywhere you want.

#### :subject_method

Acl9 obtains the subject instance by calling specific method of the controller. By default it's
`:current_user`, but you may change it.

    class MyController < ApplicationController
      access_control :subject_method => :current_account do
        allow :nifty
        # ...
      end

      # ...
    end

Subject method can also be changed globally. Place the following into `config/initializers/acl9.rb`:

    Acl9::config[:default_subject_method] = :current_account

TODO - add docs for protect_global_roles

#### :debug

`:debug => true` will output the filtering expression into the debug log. If
Acl9 does something strange, you may look at it as the last resort.

#### :as_method

In the case

    class NiftyController < ApplicationController
      access_control :as_method => :acl do
        allow :nifty
        # ...
      end

      # ...
    end

access control checks will be added as `acl` method onto MyController, with `before_filter :acl` call thereafter.

Instead of using `:as_method` you may specify the name of the method as a positional argument
to `access_control`:

    class MyController < ApplicationController
      access_control :acl do
        # ...
      end

      # ...
    end

#### :filter

If you set `:filter` to `false` (it's `true` by default) and also use
`:as_method` (or method name as 1st argument to `access_control`, you'll get a
method which won't raise `Acl9::AccessDenied` exception, but rather return
`true` or `false` (access allowed/denied).

    class SecretController < ApplicationController
      access_control :secret_access?, :filter => false do
        allow :james_bond
        # ...
      end

      def index
        if secret_access?
          _secret_index
        else
          _ordinary_index
        end
      end

      # ...

      private

      def _secret_index
        # ...
      end

      def _ordinary_index
        # ...
      end
    end

The generated method can receive an objects hash as an argument. In this example,

    class LolController < ApplicationController
      access_control :lolcats?, :filter => false do
        allow :cats, :by => :lol
        # ...
      end
    end

you may not only call `lolcats?` with no arguments, which will basically return

    current_user.has_role?('cats', @lol)

but also as `lolcats?(:lol => Lol.find(params[:lol]))`. The hash will be looked into first,
even if you have an instance variable `lol`.

TODO - document `_action` override.

#### :helper

Sometimes you want to have a boolean method (like `:filter => false`) accessible
in your views. Acl9 can call `helper_method` for you:

    class LolController < ApplicationController
      access_control :helper => :lolcats? do
        allow :cats, :by => :lol
        # ...
      end
    end

That's equivalent to

    class LolController < ApplicationController
      access_control :lolcats?, :filter => false do
        allow :cats, :by => :lol
        # ...
      end

      helper_method :lolcats?
    end

#### Other options

Other options will be passed to `before_filter`. As such, you may use `:only` and `:except` to narrow
the action scope of the whole ACL block.

    class OmgController < ApplicationController
      access_control :only => [:index, :show] do
        allow all
        deny :banned
      end

      # ...
    end

is basically equivalent to

    class OmgController < ApplicationController
      access_control do
        actions :index, :show do
          allow all
          deny :banned
        end

        allow all, :except => [:index, :show]
      end

      # ...
    end

### access_control in your helpers

Apart from using `:helper` option for `access_control` call inside controller, there's a
way to generate helper methods directly, like this:

    module SettingsHelper
      include Acl9Helpers

      access_control :show_settings? do
        allow :admin
        allow :settings_manager
      end
    end

Here we mix in `Acl9Helpers` module which brings in `access_control` method and call it,
obtaining `show_settings?` method.

An imaginary view:

    <% if show_settings? %>
      <%= link_to 'Settings', settings_path %>
    <% end %>

### show_to in your views

`show_to` is predefined helper for your views:

    <% show_to :admin, :supervisor do %>
      <%= link_to 'destroy', destroy_path %>
    <% end %>

or even

    <% show_to :prince, :of => :persia do %>
      <%= link_to 'Princess', princess_path %>
    <% end %>

---
Copyright © 2009, 2010 Oleg Dashevskii, released under the MIT license.
                    

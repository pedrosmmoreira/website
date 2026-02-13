---
title: "Extending Pundit with dedicated policies per user role"
date: "2016-11-09"
slug: extending-pundit-with-dedicated-policies-per-user-role
description: "Refactoring complex authorization logic in Rails by creating role-specific Pundit policies."
---

I am a big fan of using Pundit for authorization. It is simple, easy to implement and extensible. On a recent project, we had to deal with multiple user roles and as such we were starting to get a quite complex policy object. In particular we had to start checking the type of user we had, leading to complex logic branches:

```ruby
class FooPolicy < ApplicationPolicy
  #...
  class Scope
    #...
    def resolve
      if user.roles.include?("admin")
        scope.not_cancelled
      elsif user.roles.include?("official")
        scope.not_draft
      elsif user.roles.include?("provider")
        scope.provided_by(user)
      else
        scope.none
      end
    end
  end

  def show?
    (provider && !record.cancelled?) ||
    (official || user_is_assigned_provider?(user))
  end
end
```

This is solely for resolving a Scope of records accessible by an user. You can imagine how complex the logic for permitting an individual action can get at this point.

As more actions needed additional conditional logic, we started to encounter small bugs and our tests became less and less clear as source of truth for *who could do what*.

Our first step was to actually write the code we wish we had and let our integration tests guide the refactoring, starting from the top of the conditional branch in the resolve block:

```ruby
class AdminFooPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, context)
      @user = user
      @scope = context.record
    end

    def resolve
      scope.not_cancelled?
    end
  end

  def initialize(user, context)
    @user = user
    @record = context.record
  end

  def show?
    !record.cancelled?
  end
end
```

Since Pundit policies are based on a user and a record being passed in, or in the case of a Scope, a class name, we knew we had to provide some additional context in order for this to work. Passing additional arguments to the policy would not help our case, since we needed a dynamic way of instantiating the correct policy object for each of our users. Our next port of call was to investigate how Pundit itself retrieves policy objects. We quickly found the answer in the `PolicyFinder` class.

Pundit checks if the passed in object responds to a instance or class policy_class method. Failing that it assigns the klass local variable to the objects model name or class and appends the value of SUFFIX, which is "Policy". Armed with this knowledge it becomes simple to implement our requirement: we need to wrap the object we pass to Pundit with something that responds to policy_class, returning the correct name of the policy to instantiate.

For there on, it was easy to arrive at our solution:

```ruby
class PolicyContext
  attr_reader :record

  def initialize(record, user)
    @record = record
    @user = user
  end

  def policy_class
    "#{@user.role}FooPolicy".classify
  end
end
```

Given an User with a role of admin, our policy class method will respond with "AdminFooPolicy", which Pundit will then constantize and initiate. We expose a reader for the record so that we can then unwrap the record to authorize in our policy object.

This will work both with instantiating a record policy, a scope policy and a specific controller action. The calls in our controller now look like this:

```ruby
class FoosController < ApplicationController
  include Pundit
  #...

  # record policy
  def set_record_policy
    policy(PolicyContext.new(record, current_user)
  end

  # scope policy
  def set_policy_scope
    policy_scope(PolicyContext.new(RecordClassName, current_user))
  end

  # authorizing controller action
  def authorize_action
    authorize PolicyContext.new(record, user), "#{action_name}?"
  end
end
```

Our tests per individual policy are now much cleaner and we've managed to get rid of a lot of conditional logic and subsequent potential for hidden bugs.

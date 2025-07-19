# ActiveState

[![CircleCI](https://circleci.com/gh/buhrmi/activestate.svg?style=shield)](https://circleci.com/gh/buhrmi/activestate)
[![Gem Version](https://badge.fury.io/rb/activestate.svg)](https://rubygems.org/gems/activestate)
[![npm version](https://badge.fury.io/js/activestate.svg)](https://www.npmjs.com/package/activestate)

ActiveState allows you to update your Svelte application state easily and in real-time from your Rails backend. It's a combination of an npm package and a Ruby gem that gives you an application-wide Svelte 5 `$state` object and methods to manipulate this state object using dot-notation.

## Quick example

**In your Svelte component:**
```html
<script>
import { State } from 'activestate'
</script>

<!-- This updates automatically when the backend changes it -->
<h1>Welcome, {State.user?.name}!</h1>
<p>You have {State.notifications?.length || 0} new messages</p>
```

**In your Rails backend:**
```ruby
# Instantly update the UI for a specific user
UserChannel[current_user].state('user.name').set('John Doe')
UserChannel[current_user].state('notifications').push({
  id: 123, 
  message: 'Welcome to ActiveState!'
})
```

That's it! No message handlers, no state management boilerplate.

## Detailed example

Let's say you have a web app and want to display real-time messages to a specific user. This can be easily done with ActiveState by pushing new messages to a centralized state object as they arrive. Let's take a look:

### Setup

First, we need a channel to subscribe to:

```rb
# user_channel.rb
class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Then, inside your component, set up a subscription and iterate over `State.messages`:

```svelte
<script>
import { subscribe, State } from 'activestate'
import { onDestroy } from 'svelte'

// Set up a subscription to the UserChannel
const unsubscribe = subscribe('UserChannel', {user_id: something})

// Don't forget to unsubscribe when the component is destroyed
onDestroy(unsubscribe)

// Initialize it with an empty array
State.messages ||= []
const messages = $derived(State.messages)
</script>

{#each messages as message}
  <p>{message.text}</p>
{/each}
```

Now you can push directly into `State.messages` from your server through the UserChannel:

```rb
# Somewhere in your Ruby code:
UserChannel[some_user].state('messages').push({id: 4, text: "Hello from Ruby"})
```

And you can update the message:

```rb
UserChannel[some_user].state('messages').upsert({id: 4, text: "Changed text"})
```


## Modifying state

All state modifications operate on a path. This path can be specified using dot-notation (e.g., `projects.421.name`) or as an array (e.g., `["projects", project.id, "name"]`).

ActiveState comes with 5 built-in modifiers: `set`, `assign`, `push`, `upsert`, and `delete`:

#### `set(data)`

```rb
UserChannel[some_user].state('current_user.name').set("John")
```

Replaces the value of `current_user.name` with `John`.

#### `assign(data)`

```rb
UserChannel[some_user].state('current_user').assign({name: 'new name'})
```

Uses `Object.assign` to merge the passed object onto `current_user`.

#### `push(data)`

Pushes data onto the array. If the specified path doesn't exist, it will be initialized as a new array.

#### `upsert(data, key = "id")`

```rb
UserChannel[some_user].state('current_user.notices').upsert([{id: 4, name: "new name"}])
```

This iterates over the array in `current_user.notices` and performs an upsert using the specified key.

#### `delete({key: val})`

If called on an array, it iterates over the array and deletes all entries whose keys match the provided object.

#### `delete(key)`

If called on an object, it deletes the provided key from the object.

### Native modifiers

You can also call functions that natively exist on objects in the state. For example, if you have an array in `current_user.notices`, you can call its native `push` function:

```ruby
UserChannel[some_user].state('current_user.notices').push "next chunk"
```

### Custom modifiers

You can also define custom methods to modify your state:

```js
import { registerMutator, State } from 'activestate'

registerMutator('append', function(currentValue, data) {
  return currentValue.concat(data)
})

<p>
Here is a very long string: {State.long_string}
</p>
```

```ruby
UserChannel[some_user].state('long_string').append "next chunk"
```

### Sending to a specific connection

The `state` method is also available on a Channel instance. This means you can update Svelte stores through a specific connection instead of broadcasting to all subscribers:

```rb
# user_channel.rb
class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    state('current_user').set(current_user.as_json)
  end
end
```

### SSR

When using ActiveState in a Server-Side Rendering (SSR) context, the server-side JavaScript process is usually shared between requests. Therefore, it's important to call `reset()` before or after rendering to clear the state and avoid data leakage between requests:

```js
import { reset } from 'activestate'

reset()

// ... rest of code comes here
```

## FAQ

### Is it a good idea to place all state into a global state object?

I wasn't sure at first, but now I think it's awesome. Svelte 5 introduced [fine-grained reactivity](https://frontendmasters.com/blog/fine-grained-reactivity-in-svelte-5/) for objects declared with `$state`. This means that even if your object becomes huge with deeply nested data, it should not impact performance. So yes, I think it's clever and smart! 🤓

## Installation

### Ruby gem

Add this line to your application's Gemfile:

```ruby
gem 'activestate'
```

And then execute:

    $ bundle install

### NPM package

Install the package:

    $ npm i -D activestate


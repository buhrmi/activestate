import { createConsumer } from "@rails/actioncable";
import {get,set} from '@eivifj/dot';

export let consumer

const State = $state({})
export default State
export { State }

const handlers = {
  set(path, data) {
    set(State, path, data);
  },
  assign(path, data) {
    const currentValue = get(State, path);
    if (currentValue) Object.assign(currentValue, data);
    else set(State, path, data);
  },
  upsert(path, data) {
    const updates = Array.isArray(data.value) ? data.value : [data.value];
    const target = get(State, path);
    if (!target) set(State, path, updates);
    else updates.forEach(entry => {
      const item = target.find(item => item[data.key] === entry[data.key]);
      if (item) Object.assign(item, entry);
      else target.push(entry);
    })
  },
  push(path, data) {
    const target = get(State, path);
    if (!target) set(State, path, [data]);
    else target.push(data);
  },
  delete(path, selector) {
    const target = get(State, path);
    if (Array.isArray(target)) {
      const [key, value] = Object.entries(selector)[0];
      const index = target.findIndex(item => item[key] === value);
      if (index !== -1) target.splice(index, 1);
    }
    else {
      delete target[selector];
    }
  }
}

export function registerHandler(name, handler) {
  handlers[name] = function(path, data) {
    const currentValue = get(State, path);
    const newValue = handler(currentValue, data);
    set(State, path, newValue);
  }
}


function received(data) {
  const handler = handlers[data.action]
  if (handler) {
    handler(data.path, data.data);
  } 
  else {
    const target = get(State, data.path);
    if (target && typeof target[data.action] === 'function') {
      target[data.action](data.data);
    }
    else {
      console.error(`No handler or method found for action "${data.action}" on path "${data.path}"`);
    }
  }
}

export function subscribe(channel, params = {}) {
  if (typeof document == "undefined") return () => {};

  if (!consumer) consumer = createConsumer();

  const subscription = consumer.subscriptions.create(
    { channel, ...params },
    {
      received,
    },
  );

  return function unsubscribe() {
    consumer.subscriptions.remove(subscription);
  };
}

export function reset() {
  Object.keys(State).forEach(key => {
    delete State[key];
  });
}

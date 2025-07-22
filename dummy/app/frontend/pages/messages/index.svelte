<script>
  import State, { subscribe, registerHandler } from "activestate"

  State.records = [{id: 1, name: "old1"}, {id: 3, name: "old3"}]
  State.deeply = {nested: {value: 'foundme'}}
  State.messages = [
    { id: 1, message: 'Hello World' },
    { id: 2, message: 'Goodbye World' }
  ]
  State.longString ||= "123456"
  State.val = {deleteme: "deleteme"}
  State.delete = {array: [{id: 1, name: 'deleteMe'}, {id: 2, name: 'keepMe'}]}

  const user = $derived(State.user || {})
  const records = $derived(State.records)
  const messages = $derived(State.messages)
  const longString = $derived(State.longString)

  subscribe('UserChannel')

  import axios from 'axios'

  // const user = getStore('user', {})
  // const messages = getStore('messages', [])
  // const records = getStore('records', [{id:1, name: "old"}])
  // const largeNumber = getStore('large_number', 5)
  // const word = getStore('word', 'hello')
  // const obj = getStore('object', {value: 'old'})
  // const anArray = getStore('anArray', [{id: 1, name: 'deleteMe'}, {id: 2, name: 'keepMe'}])

  function makeMessage() {
    axios.post('/messages', { message: 'Hello World' })
  }

registerHandler('append', function(old, val) {
  return old.concat(val)
})
  
// registerHandler('keepLarger', function(store, data) {
//   store.update(_data => _data >= data.value ? _data : data.value)
// })
</script>

<h1>{user.name}</h1>

Deeply nested value: {State.deeply.nested.value}

<h2>records</h2>

{#each records as record}
  {record.name}
{/each}
 
<h2>Messages</h2>

{#each messages as message}
  {message}
{/each}

<h2>Long String</h2>
<p>{longString}</p>

<p>
  Delete Me: {State.val.deleteme}
</p>

<p>
  {JSON.stringify(State.delete.array)}
</p>

<p>
  {State.numberkeys?.[23].person.name}
</p>

<p>
  {State.numberkeys?.[24].person.name}
</p>
<!--

<h2>
Large Number: {$largeNumber}
</h2>

<h2>
  Long word: {$word}
</h2>

<h2>
Object value: {$obj.value}
</h2>

<h2>
  An Array: {$anArray[0].name} and {$anArray[1]?.name}
</h2> -->


<button on:click={makeMessage}>Make Message</button>

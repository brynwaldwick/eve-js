# eve-js

Simple ethereum in the browser. A collection of useful helpers to build more literate webapps with ethereum.

Intended for use alongside browser plugins like (the amazing) [Metamask](https://metamask.io/) that load `web3` onto the window.

## Methods

### `parseProtocolUrl(url)`

Build a raw ethereum transaction by parsing an ethereum "protocol url" and query, according to [this discussion here](https://github.com/ethereum/EIPs/issues/67).

The transaction is encoded like `ethereum:[to_address]?[params,...]`

Put `value`, and `gas` into the query to pass these options into the transaction, along with one of the following to encode a function call

* `data`: an encoded bytecode input
* `function`: a string of the raw function signature like `functionImCalling(arg_1_value, arg_2_value)`
* `fn`: the name of the function you'd like to call (as specified in the Contract's ABI), and a query-encoded abi like `fn=functionImCalling&input.arg_1.type=string&input.arg_1=arg_1_value&input.arg_2.type=address&input.arg_2=arg_2_value`.

exports.send = (tx, cb) ->
    {to, value, from, gas} = tx

### `buildAPIWithABI(abi)`

Build an associative array (object) of javascript functions to call a Contract's functions from your application code. Call the function by name with the normal arguments from the Contract, a parameter `options` to optionally configure `from`, `value`, and `gas`, and a callback for the web3 provider.


```coffee
eve = require 'eve-js'

# A hypothetical ethereum call that pays an
# invoice keyed off a unique string.

my_abi = [{
    constant: false,
    inputs: [{
        name: "purchaser",
        type: "string"}
    ],
    name: "payInvoice",
    outputs: [],
    payable: true,
    type: "function"
}]

# Build a function to use in your code
{payInvoice} = eve.buildAPIWithABI my_abi

# now call the function like...
purchaser_key = window.user.my_unique_key
options = {}
payInvoice purchaser_key, options, (err, txid) ->
    # handle response here...
```

The functions will be called by passing them to `window.web3`, like Metamask provides.

### `execWithABI(abi, address, fn, args..., options, cb)`

Call a function by name from a raw ABI and a Contract address. Optionall configure `from`, `value`, and `to` in options.

### `send({to, from, gas, value}, cb)`

Convenience function to send ether from raw transaction json. `from` and `gas` are optional.

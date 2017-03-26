# eve-js

Build apps with ethereum in the browser. A collection of helpers to build more readable webapps with ethereum.

Intended for use alongside browser plugins like (the amazing) [Metamask](https://metamask.io/) that load `web3` onto the window.

## Methods

### `parseProtocolUrl(url)`

Build a raw ethereum transaction by parsing an ethereum "protocol url" and query, according to [this discussion here](https://github.com/ethereum/EIPs/issues/67).

The transaction is encoded like `ethereum:[to_address]?[params,...]`

Put `value`, and `gas` in params to pass these options into the transaction, along with (optionally) one of the following to encode a function call

* `function`: a string of the raw function signature like `functionImCalling(arg_1_value, arg_2_value)`
* `fn`: the name of the function you'd like to call (as specified in the Contract's ABI), and a query-encoded abi like

    ```coffee
    fn=functionImCalling&
    input.arg_1.type=string&
    input.arg_1=arg_1_value&
    input.arg_2.type=address&
    input.arg_2=arg_2_value
    ```

* `data`: encoded bytecode of the transaction inputs as described [here](https://github.com/ethereum/wiki/wiki/JavaScript-API#web3ethsendtransaction)

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
invoice_address = 'my_invoice_address'
purchaser_key = window.user.my_unique_key
options = {}
payInvoice invoice_address, purchaser_key, options, (err, txid) ->
    # handle response here...
```

The functions will be called by passing them to `window.web3`, like Metamask provides.

### `execWithABI(abi, address, fn, args..., options, cb)`

Call a function by name from a raw ABI and a Contract address. Optionally configure `from`, `value`, and `to` in options. Using the same example from above...

```coffee
eve.execWithABI my_abi, invoice_address, 'PayInvoice', purchaser_key, {}, (err, txid) ->
    # handle response here...
```

### `send({to, from, gas, value}, cb)`

Convenience function to send ether from raw transaction json. `from` and `gas` are optional.

```coffee
eve = require 'eve-js'

bill_payer = '0x0'

my_accounts = {
    utilities: '0x0'
    dinner: '0x0'
    girlfriend: '0x0'
}

sendTransaction = (reason) ->
    eve.send {to: bill_payer, from: my_accounts[reason], value: 1000000000000000}
```

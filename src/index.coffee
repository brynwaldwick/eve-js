qs = require 'querystring'

if window?.web3?
    if (typeof window.web3 == 'undefined')
        # Use Mist/MetaMask's provider
        web3 = new Web3 window.web3.currentProvider
        window.web3 = web3

else
    console.log 'Warning: no web3 exists in the window... :('

# TODO: make these configurable

exports.parseFunctionSignature = (fn_string) ->
    name = fn_string.split('(')[0]
    args = fn_string.split('(')[1].slice(0, -1)
    # ... TODO build a regexp
    inputs = args.split(', ').map (a) ->
        [type, value] = a.split ' '
        {type, value}

    return {name, inputs}

# Per this enticing discussion here
# https://github.com/ethereum/EIPs/issues/67

exports.parseProtocolUrl = (url) ->
    [path, query] = split('?')
    [protocol, to] = path.split(':')
    q = qs.decode query
    if q.fn?
        input_types = {}

        # parsing an array of typed inputs
        Object.keys(query).map (q_k) =>
            if q_k.indexOf('input.') > -1
                slugs = q_k.split('.')
                if slugs[2] == 'type'
                    return
                else if input_name = slugs[1]
                    input_types[input_name] = query["input.#{input_name}.type"]

        tx = {
            to: address
            value: q.value
            gas: q.gas
            inputs: Object.keys(input_types).map (name) ->
                {
                    name,
                    type: input_types[name]
                }
        }

    else if q.function?
        parseFunctionSignature q.function

        tx = {
            to: address
            value: q.value
            gas: q.gas
            inputs: parseFunctionSignature q.function
        }

    else if q.data
        tx = {
            to: address
            value: q.value
            gas: q.gas

        }

    return tx

exports.send = (tx, cb) ->
    {to, value, from, gas} = tx
    value = Number value
    window.web3.eth.sendTransaction {from: (from || window.web3.eth.accounts[0]), to, value, gas}, cb

# Export an associative array of functions with arguments to be
# called in a line of javascript, built from a full or partial Contract ABI
# https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI#json
# fnNameFromABI(contract_address, args..., options, cb)

exports.buildAPIWithABI = (abi) ->
    _exports = {}

    abi.map (fn) ->
        _exports[fn.name] = (address, args..., _options, cb) ->
            console.log 'address', args..., _options, fn.name
            window.web3.eth.contract(abi).at address, (err, Contract) ->

                options = Object.assign {}, {
                    to: address
                    from: web3.eth.accounts[0]
                    value: 0
                    gas: 10000
                }, _options
           
                console.log 'Submitting transaction w local web3 provider', options

                Contract[fn.name] args..., options, cb

    return _exports

# Execute a function from a portion or full Contract ABI deployed at [address]

exports.execWithABI = (abi, address, fn, args..., options_, cb) ->

    window.web3.eth.contract(abi).at address, (err, Contract) ->

        options = Object.assign {}, {
            to: address
            from: window.web3.eth.accounts[0]
            value: 0
            gas: 100000
        }, options_

        Contract[fn] args..., options, cb

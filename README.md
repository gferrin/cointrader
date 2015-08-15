# cointrader
This is a node.js wrapper for the CoinTrader [API](http://docs.cointrader.apiary.io/).

### Install

`npm install cointrader`

```js
var CoinTrader = require('cointrader');

// secret only needs to be passed if you used one to create your keys
var cointrader = new CoinTrader(public_key, private_key, secret);

cointrader.limit_order("buy", "XBTCAD", 1, 300, function(err, order_id){
	console.log(order_id); // 2194028
});
```

### Sandbox

If you would like to run the API in sandbox mode then run your code with the environment variable `COINTRADER=sandbox`

Here is the [link](https://sandbox.cointrader.net/user/registration) to register for a sandbox account.

## Functions

`symbols(cb)`

`daily_stats(currency_pair, cb)`

`weekly_stats(currency_pair, cb)`

`open_orders(currency_pair, type, limit, cb)`

`inside(type, currency_pair, cb)`

`weighted_average(type, amount, currency_pair, cb)`

`trades(currency_pair, limit, offset, cb)`

`market_data(currency_pair, limit, offset, cb)`

##### AUTHENTICATED REQUESTS 

`balance(cb)`

`fees(cb)`

`list_bank_account(cb)`

`deposit_address(cb)`

`withdraw('btc' || 'fiat', transfer_method, id_or_address, amount, cb)`

`account_history(symbol, cb)`

`limit_order(type, currency_pair, total_quantity, price, cb)`

`orders(currency_pair, cb)`

`cancel_order(currency_pair, order_id, cb)`

`cancel_all_orders(currency_pair, cb)`

`market_order(type, currency_pair, total_amount, cb)`

`trade_history(currency_pair, options, cb)`



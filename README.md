# cointrader
This is a node.js wrapper for the CoinTrader [API](http://docs.cointrader.apiary.io/).

### Install

`npm install cointrader`

```js
var CoinTrader = require('cointrader');

var cointrader = new CoinTrader(public_key, private_key, secret);

cointrader.limit_order("buy", "XBTCAD", 1, 300, function(err, order_id){
	console.log(order_id); // 2194028
});
```

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

`withdraw(type, transfer_method, id_or_address, amount, cb)`

`account_history(symbol, cb)`

`limit_order(type, currency_pair, total_quantity, price, cb)`

`orders(currency_pair, cb)`

`cancel_order(currency_pair, order_id, cb)`

`cancel_all_orders(currency_pair, cb)`

`market_order(type, currency_pair, total_amount, cb)`

`trade_history(currency_pair, options, cb)`



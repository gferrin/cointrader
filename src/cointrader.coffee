request = require 'request'
moment = require 'moment'
crypto = require 'crypto'
	
# secret is an optional param that should only be used if one was used 
# to create the api keys
module.exports = class CoinTrader

	constructor: (public_key, private_key, secret) ->

		# @url = 'https://www.cointrader.net/api4/'
		@url =  'https://sandbox.cointrader.net/api4/'
		@secret = secret
		@public_key = public_key
		@private_key = private_key
		@nonce = moment().valueOf()

	_nonce: ->

		if @nonce < moment().subtract(1, 'minutes').valueOf()
			@nonce = moment().valueOf()
			return @_nonce()

		else 
			return moment.utc(++@nonce).format("YYYY-MM-DD HH:mm:ss [UTC]")


	public_request: (sub_path, cb) ->

		options = 
			url: @url + sub_path
			method: 'GET'
			timeout: 15000
			json: true

		request options, (err, response, body) ->	
			try 
				if err || (response.statusCode != 200 && response.statusCode != 400)
					return cb new Error(err ? response.statusCode)
				
				if body['success']
					return cb(null, body['data'])
				else 
					cb(new Error(body['message']))

			catch err
				return cb(err)
	
	private_request: (sub_path, params, cb) ->

		if !@public_key or !@private_key
			return cb(new Error("missing public key or private key"))

		payload = 
			t: @_nonce()

		if @secret?
			payload['secret'] = @secret

		try 
			for key, value of params
				# convert all values to strings
				if typeof value isnt 'string'
					value = value.toString()

				payload[key] = value

			payload_string = new Buffer(JSON.stringify(payload))
			auth_hash = crypto.createHmac("sha256", @private_key).update(payload_string).digest('hex')
		catch err
			return cb(err)

		headers = 
			'Accept': 'application/json'
			'X-Auth': @public_key 
			'X-Auth-Hash': auth_hash

		options = 
			url: @url + sub_path
			method: "POST"
			headers: headers
			body: payload
			timeout: 15000
			json: true

		request options, (err, response, body) ->
			try 
				if err || (response.statusCode != 200 && response.statusCode != 400)
					return cb new Error(err ? response.statusCode)
				
				if body['success']
					return cb(null, body['data'])
				else 
					cb(new Error(body['message']))

			catch err
				return cb(err)

	#####################################
	########## PUBLIC REQUESTS ##########
	#####################################  
	symbols: (cb) ->

		@public_request('stats/symbol', cb)

	daily_stats: (currency_pair, cb) ->

		path = 'stats/daily/'

		if typeof currency_pair is 'function'
			cb = currency_pair
		else 
			try 
				path += currency_pair.toUpperCase()
			catch err
				return cb(err)

		@public_request(path, cb)

	weekly_stats: (currency_pair, cb) ->

		path = 'stats/weekly/'

		if typeof currency_pair is 'function'
			cb = currency_pair
		else 
			try 
				path += currency_pair.toUpperCase()
			catch err
				return cb(err)

		@public_request(path, cb)

	open_orders: (currency_pair, type, limit, cb) ->

		try 
			if typeof limit is 'function'
				cb = limit
				path = 'stats/orders/' + currency_pair + '/' + type
			else 
				path = 'stats/orders/' + currency_pair + '/' + type + '/' + limit
			
			@public_request(path, cb)
		catch err
			return cb(err)

	inside: (type, currency_pair, cb) ->

		map = 
			buy: 'high'
			sell: 'low'

		if not map[type]?
			return cb(new Error('bad type'))

		path = 'stats/' + map[type] + '/'	

		if typeof currency_pair is 'function'
			cb = currency_pair
		else 
			try 
				path += currency_pair.toUpperCase()
			catch err
				return cb(err)

		@public_request(path, cb)


	weighted_average: (type, amount, currency_pair, cb) ->

		map = 
			buy: 'buyprice'
			sell: 'sellprice'

		if not map[type]?
			return cb(new Error('bad type'))

		try 
			path = 'stats/' + map[type] + '/' + currency_pair.toUpperCase() + '/' + amount
		catch err
			return cb(err)

		@public_request(path, cb)

	trades: (currency_pair, limit, offset, cb) ->

		try 
			path = 'stats/trades/' + currency_pair.toUpperCase() + '/' + limit + '/' + offset

			@public_request(path, cb)
		catch err
			return cb(err)

	market_data: (currency_pair, limit, offset, cb) ->

		try 
			path = 'stats/market/' + currency_pair.toUpperCase() + '/' + limit + '/' + offset

			@public_request(path, cb)
		catch err
			return cb(err)


	# #####################################
	# ###### AUTHENTICATED REQUESTS #######
	# #####################################   

	balance: (cb) ->

		path = 'account/balance'

		@private_request(path, {}, cb)

	fees: (cb) ->

		path = 'account/fees'

		@private_request(path, {}, cb)

	list_bank_account: (cb) ->

		path = 'account/listbank'

		@private_request(path, {}, cb)

	deposit_address: (cb) ->

		path = 'account/btcaddress'

		@private_request(path, {}, cb)

	withdraw: (type, transfer_method, id_or_address, amount, cb) ->

		try 
			path = 'account/withdraw'	
			map = 
				btc: 'btc_address'
				fiat: 'bank_account_id'	

			params = 
				transfer_method: 'transfer_method'
				amount: amount

			if map[type]?
				return cb(new Error('bad type'))

			params[map[type]] = id_or_address

			@private_request(path, params, cb)
		catch err
			return cb(err)

	account_history: (symbol, cb) ->

		path = 'account/history'
		params =
			symbol: symbol

		@private_request(path, params, cb)

	limit_order: (type, currency_pair, total_quantity, price, cb) ->

		if type isnt 'buy' and type isnt 'sell'
			return cb(new Error('bad type - options are buy and sell'))

		try 
			path = 'order/' + currency_pair.toUpperCase() + '/' + type
			params = 
				total_quantity: total_quantity
				price: price

			@private_request(path, params, cb)
		catch err
			return cb(err)

	orders: (currency_pair, cb) ->

		try 
			path = 'order/' + currency_pair.toUpperCase() + '/list'

			@private_request(path, {}, cb)
		catch err
			return cb(err)

	cancel_order: (currency_pair, order_id, cb) ->

		try 
			path = 'order/' + currency_pair.toUpperCase() + '/cancel'

			params = 
				order_id: order_id

			@private_request(path, params, cb)
		catch err
			return cb(err)

	cancel_all_orders: (currency_pair, cb) ->

		try 
			path = 'order/' + currency_pair.toUpperCase() + '/cancelall'

			@private_request(path, {}, cb)
		catch err
			return cb(err)

	market_order: (type, currency_pair, total_amount, cb) ->

		map = 
			buy: 'marketbuy'
			sell: 'marketsell'

		if not map[type]?
			return cb(new Error('bad type - options are buy and sell'))

		try 
			path = 'order/' + currency_pair.toUpperCase() + '/' + map[type]
			params = 
				total_amount: total_amount

			@private_request(path, params, cb)
		catch err
			return cb(err)

	trade_history: (currency_pair, options, cb) ->

		if typeof options is 'function'
			cb = options
			options = {}

		try
			path = 'account/tradehistory/' + currency_pair.toUpperCase()

			@private_request(path, options, cb)
		catch err
			return cb(err)
		




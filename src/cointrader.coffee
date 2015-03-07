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

		for key, value of params
			payload[key] = value

		payload_string = new Buffer(JSON.stringify(payload))
		auth_hash = crypto.createHmac("sha256", @private_key).update(payload_string).digest('hex')

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

		@public_request ''

	# #####################################
	# ###### AUTHENTICATED REQUESTS #######
	# #####################################   







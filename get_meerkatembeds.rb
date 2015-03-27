require 'rubygems'
require 'oauth'
require 'json'

embed_codes = []
mrkt_tweets = Object.new

embeds_file = "mrkt_embeds.txt"

File.open("brand_meerkatters.txt") do |line|
  ids_file = line.read
  mrkt_tweets = JSON.parse(ids_file)
end

mrkt_tweets.each do |mrkt_tweet|
  tweet_id = mrkt_tweet["id"]
  puts "Tweet ID: #{tweet_id}"

  baseurl = "https://api.twitter.com"
  path    = "/1.1/statuses/oembed.json"
  query   = URI.encode_www_form(
    "id" => tweet_id
  )

  address = URI("#{baseurl}#{path}?#{query}")
  request = Net::HTTP::Get.new(address.request_uri)

  http             = Net::HTTP.new(address.host, address.port)
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  consumer_key = OAuth::Consumer.new(
  #consumer key goes here,
  #consumer secret key goes here)
  access_token = OAuth::Token.new(
  #access token goes here,
  #access token secret goes here)

  request.oauth!(http, consumer_key, access_token)
  http.start
  response = http.request(request)

  tweet_embeds = nil
  if response.code == "200"
    tweet_embeds = JSON.parse(response.body)
    puts "Tweet embeds: #{tweet_embeds}"

    if tweet_embeds["html"]
      embed_codes << tweet_embeds["html"]
    else
      puts "No embed code"
    end
  end
end

File.open(embeds_file, 'w') do |f|
  f.puts embed_codes
end

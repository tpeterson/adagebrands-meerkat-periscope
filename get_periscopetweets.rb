require 'rubygems'
require 'oauth'
require 'json'

brand_names = []
scope_links = []

periscopes_file = "brand_periscopes.txt"

File.open("AdAge_BiggestBrands.txt").each do |line|
  brand_names << line
end

brand_names.each do |brand|
  baseurl = "https://api.twitter.com"
  path    = "/1.1/statuses/user_timeline.json"
  query   = URI.encode_www_form(
      "screen_name" => brand,
      "count" => 200
  )
  address = URI("#{baseurl}#{path}?#{query}")
  request = Net::HTTP::Get.new address.request_uri

  http             = Net::HTTP.new address.host, address.port
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  consumer_key = OAuth::Consumer.new(
  #consumer key goes here,
  #consumer secret key goes here)
  access_token = OAuth::Token.new(
  #access token goes here,
  #access token secret goes here)

  request.oauth! http, consumer_key, access_token
  http.start
  response = http.request request

  tweets = nil

  if response.code == "200" then
    tweets = JSON.parse(response.body)
  end

  tweets.each do |tweet|
    if tweet["entities"]["urls"].empty? == false
      link = tweet["entities"]["urls"][0]["display_url"]
      name = tweet["user"]["name"]
      id = tweet["id_str"]

      if /^periscope.tv/.match(link)
        puts "Periscope link: #{link}"
        scope_links.push(
          name: name,
          link: link,
          id: id
        )
      else
        puts "Non-Periscope link: #{link}"
      end
    else
      puts "No link"
    end
  end
end

File.open(periscopes_file, 'w') do |f|
  f.puts JSON.pretty_generate(scope_links)
end

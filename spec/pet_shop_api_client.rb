# frozen_string_literal: true

require "faraday"
require "json"
require 'net/http'

class PetShopApiClient
  def post_pet(kind)
    conection = Faraday.new("https://pet-aggregator.matic.com") do |f|
      f.request :json
      f.response :json
    end
    conection.post('/pet_requests') do |req|
      req.body = {kind: kind}
    end
  end

  def get_pets(id)
    Faraday.new.get(URI("https://pet-aggregator.matic.com/pet_requests/#{id}/offers"))
  end

  def sort_offers(id, range)
    conection = Faraday.new("https://pet-aggregator.matic.com") do |f|
      f.response :json
    end
    conection.get("/pet_requests/#{id}/offers") do |req|
      req.params['price_lt'] = range
    end
  end

  def sort_in_order(id, range, order)
    conection = Faraday.new("https://pet-aggregator.matic.com") do |f|
      f.response :json
    end
    conection.get("/pet_requests/#{id}/offers") do |req|
      req.params['direction'] = order
      req.params['sort_by'] = range
    end
  end
end

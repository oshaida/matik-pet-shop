# frozen_string_literal: true

require 'spec_helper'
require_relative 'pet_shop_api_client'

describe PetShopApiClient do
  let(:pet_shop_api_client) { PetShopApiClient.new }

  context "post_pet_dog" do
    let(:kind) { "dog" }

    it "returns status 201 Created" do
      response = VCR.use_cassette('post_pet_dog') do
      pet_shop_api_client.post_pet(kind)
      end

      expect(response.status).to eq 201
      expect(response.body).to include("kind" => "dog")
    end
  end

  context "post_pet_cat" do
    let(:kind) { "cat" }

    it "returns status 201 Created" do
      response = VCR.use_cassette('post_pet_cat') do
        pet_shop_api_client.post_pet(kind)
      end
      expect(response.status).to eq 201
      expect(response.body).to include("kind" => "cat")
    end
  end

  context "post_no_pet" do
    let(:kind) { nil }.to_json

    it "returns status 201 Created" do
      response = VCR.use_cassette('post_no_pet') do
        pet_shop_api_client.post_pet(kind)
      end
      expect(response.status).to eq 201
      expect(response.body).to include("kind" => nil)
    end
  end

  context "check returned list" do
    let(:dog_id) do
      dog_response = pet_shop_api_client.post_pet("dog")
      dog_response.body.fetch("id")
    end

    it "returns list of dogs" do
      response = pet_shop_api_client.get_pets(dog_id)
      expect(response.status).to eq 200
      expect(response.body).to include("breed", "price", "id")
    end
  end

  context "get specified pet" do
    let(:dog_id) do
      dog_response = pet_shop_api_client.post_pet("dog")
      dog_response.body.fetch("id")
    end

    it "returns list of dogs" do
      response = VCR.use_cassette('list_of_dogs') do
        pet_shop_api_client.get_pets(dog_id)
      end
      expect(response.status).to eq 200
      expect(response.body.to_json).to include(
                                         "Bernese Mountain Dogs",
                                         "Portuguese Water Dogs",
                                         "Chihuahuas",
                                         "Boxers"
                                       )
    end
  end

  context "filter offers" do
    let(:dog_id) do
      dog_response = pet_shop_api_client.post_pet("dog")
      dog_response.body.fetch("id")
    end
    let(:sort_by_less) { "400" }
    let(:sort_by) { "price" }
    let(:sort_order) { "asc" }

    it "return offers that are less than 400$" do
      response = pet_shop_api_client.sort_offers(dog_id, sort_by_less)
      price = response.body.each.with_object("price").map(&:[])

      expect(response.status).to eq 200
      price.map(&:to_i).each { |p| expect(p) .to be < 400 }
    end

    it "sort offers by price from lowest to highest price" do
      response = pet_shop_api_client.sort_in_order(dog_id, sort_by, sort_order)

      expect(response.status).to eq 200
      price = response.body.each.with_object("price").map(&:[])
      expect(price.map(&:to_i)).to eq(price.map(&:to_i).sort)
    end
  end
end

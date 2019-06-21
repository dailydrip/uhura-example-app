# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index

  end

  def status
    ## This is the way how we can get the status of a  message
    client = UhuraClient::MessageClient.new(
      api_key: "b1dcc4b8287a82fe8889", team_id: "1", public_token: "42c50c442ee3ca01378e")

    client.status_of(UhuraClient::Message.new(id: "1"))
  end

  def send_message
    message = UhuraClient::Message.new(
      public_token: "42c50c442ee3ca01378e",
      receiver_sso_id: "88543898",
      email: UhuraClient::Email.new(
        subject: "Yo!",
        message: "Yo!",
        options: {}
      ),
      template_id: "d-0ce0d614007d4a72b8242838451e9a65",
      sms_message: "Yo!"
      )

    # create a client by passing the api key, team id and public token
    client = UhuraClient::MessageClient.new(
      api_key: "b1dcc4b8287a82fe8889", team_id: "1", )
    client.send_message(message)
  end
end

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
      receiver_sso_id: "55357450",
      email_subject: "Picnic Saturday",
      email_message: {
            "header": "Dragon Rage",
            "section1": "imagine you are writing an email. you are in front of the computer...",
            "button": "Count me in!"
      },
      template_id: "d-05d33214e6994b01b577602036bfa9f5",
      sms_message: "Yo!"
      )

    client = UhuraClient::MessageClient.new(
      api_key: "b1dcc4b8287a82fe8889",
      team_id: "1"
    )
    begin
      client.send_message(message)
    rescue StandardError => error
      flash[:error] =  JSON.parse(error.to_s)['error']['message']
    end
    flash[:success] =  'Success!'
    redirect_to :root
  end
end

class PhoneNumber < ActiveRecord::Base
  attr_accessible :number

  STEPS =
    ["YOU ARE DEAD",
      "YOU ARE ALIVE",
      "YOU ARE GREAT!"]

  def finished?
    step >= STEPS.size
  end

  def perform
    if !finished?
      # send the message
      account_sid = 'AC8f2ccfbac949b145e8c80dda4b11241a'
      auth_token = '37b978b1cc067b42f030f736b612e8d8'

      # set up a client to talk to the Twilio REST API
      client = Twilio::REST::Client.new(account_sid, auth_token)

      body = STEPS[self.step]
      account = client.account
      message = account.sms.messages.create({:from => '+16179817476', :to => self.number, :body => body})

      # progress
      self.step += 1
      save
    end
  end
end

class PhoneNumbersController < ApplicationController
  def create
    PhoneNumber.create(number: params[:number])

    render nothing: true
  end
end

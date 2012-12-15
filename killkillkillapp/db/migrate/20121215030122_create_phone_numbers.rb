class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.text "number"
      t.integer 'step', default: 0

      t.timestamps
    end
  end
end

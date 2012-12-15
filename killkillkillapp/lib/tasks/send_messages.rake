task :send_all => :environment do
  PhoneNumber.all.each do |x|
    if x.created_at < 5.minutes.ago
      x.perform()
    end
  end
end

every :day, :at => "1:05am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 4)"
end

every :day, :at => "1:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 5)"
end

every :day, :at => "2:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 6)"
end

every :day, :at => "3:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 7)"
end

every :day, :at => "4:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 8)"
end

every :day, :at => "5:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 9)"
end

every :day, :at => "6:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 10)"
end

every :day, :at => "7:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 4)"
end

every :day, :at => "8:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 5)"
end

every :day, :at => "9:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 6)"
end

every :day, :at => "10:00am", :roles => [:app] do
  runner "require 'data_downloader'; DataDownloader.new.download_all_for_month(2009, 7)"
end





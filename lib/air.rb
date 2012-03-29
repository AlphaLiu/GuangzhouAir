#encoding:utf-8
module Air
	require 'nokogiri'
	require 'open-uri'

	class AirQuality 

		def self.get_gz_air
			#get the Guangzhou monitor points' values
			begin
				date_css = "form table:first tr td b"
				data_css = "form table:eq(2) tr:gt(2)"
				gz_url = 'http://www.gzepb.gov.cn/comm/pm25.asp'

				monitor_points = []

				body = Nokogiri::HTML(open(gz_url))

				#the first table is updated_time
				updated_time = body.css(date_css).text.strip

				#parse the second form table
				body.css(data_css).each do |tr|
					#get each monitor point's values
					monitor_point = {}

					#the values
					monitor_point[:updated_at] = updated_time
					monitor_point[:mp_name],
						monitor_point[:pm25_avg_1hour], 
						monitor_point[:pm25_avg_24hours],
						monitor_point[:o3_avg_1hour], 
						monitor_point[:o3_avg_24hours], 
						monitor_point[:co_avg_1hour], 
						monitor_point[:co_avg_24hours] = tr.css('td').map { |td| td.text.strip }
					monitor_point[:aqi] = aqi_pm25(monitor_point[:pm25_avg_1hour].to_i).to_s
					aqi_category(monitor_point[:aqi].to_i, monitor_point)

					monitor_points << monitor_point

				end
				monitor_points		#return array

			rescue Exception => ex
				puts "Exception #{ex}"
				nil
			end
		end

	private
		def self.linear(aqi_high,aqi_low,conc_high,conc_low,conc)
			a=((conc-conc_low)/(conc_high-conc_low))*(aqi_high-aqi_low)+aqi_low
			a.round
		end

		def self.aqi_pm25(pm25)
			case pm25
			when 0...15.5 then linear(50,0,15.4,0,pm25)
			when 15.5...35.5 then linear(100,51,35.4,15.5,pm25)
			when 35.5...65.5 then linear(150,101,65.4,35.5,pm25)
			when 65.5...150.5 then linear(200,151,150.4,65.5,pm25)
			when 150.5...250.5 then linear(300,201,250.4,150.5,pm25)
			when 250.5...350.5 then linear(400,301,350.4,250.5,pm25)
			when 350.5...500.5 then linear(500,401,500.4,350.5,pm25)
			else 600
			end
		end

		def self.aqi_category(aqi, monitor_point)
			descriptions_cn = ["优良","中等", "敏感群体有害", "不健康", "非常不健康", "有毒害一级", "有毒害二级", "尼玛！PM2.5爆表啦！"]
			descriptions_en = ["Good","Moderate", "Unhealthy for Sensitive Groups", "Unhealthy", "Very Unhealthy", "Hazardous", "Hazardous", "Damn! PM2.5 is out of range!"]
			#descriptions = ['1', '2', '3', '4', '5', '6']
			level = case aqi
							when 0..50 then 0	
							when 51..100 then 1
							when 101..150 then 2
							when 151..200 then 3
							when 201..300 then 4
							when 301..400 then 5
							when 401..500 then 6
							else 1
							end 
			monitor_point[:aqi_level] = level
			monitor_point[:aqi_desc_cn] = descriptions_cn[level]
			monitor_point[:aqi_desc_en] = descriptions_en[level]
		end
	end
end

#mps = Air::AirQuality.get_gz_air
#if mps
	#mps.each do |mp|
		#puts mp[:mp_name]
		#puts mp[:updated_at]
		#puts mp[:pm25_avg_1hour]
		#puts mp[:pm25_avg_24hours]
		#puts mp[:o3_avg_1hour]
		#puts mp[:o3_avg_24hours]
		#puts mp[:co_avg_1hour]
		#puts mp[:co_avg_24hours]
		#puts mp[:aqi]
		#puts mp[:aqi_level]
		#puts mp[:aqi_desc_cn]
		#puts mp[:aqi_desc_en]
		#puts '='*20
	#end
#end

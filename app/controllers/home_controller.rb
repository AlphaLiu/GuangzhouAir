#encoding:utf-8
class HomeController < ApplicationController
  def index
    @title = "广州市空气质量国控点 PM2.5 监测结果"
    @monitor_points = Air::AirQuality.get_gz_air
    @updated_at = @monitor_points[0][:updated_at] if @monitor_points
  end
end

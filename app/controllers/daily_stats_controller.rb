class DailyStatsController < ApplicationController
  before_filter :lookups

  def harvest
    begin
      count_of_days, count_of_tickets, sum_of_points = DailyStat.process_next_harvest
      flash[:notice] = "Harvest result: #{count_of_days} days collected, #{count_of_tickets.to_int} tickets closed and #{sum_of_points} points burned"
    rescue Lighthouse::ConnectivityError => e
      flash[:error] = "We're unable to reach lighthouse app... please check your network"
      logger.error "Connection error: #{e.inspect} #{e.message}"
    rescue Lighthouse::ResourceError => e
      flash[:error] = "Lighthouse isn't happy!... please check your project configuration"
      logger.error "Resource error: #{e.inspect} #{e.message}"
    rescue Exception => e 
      logger.error "Unexpected error: #{e.inspect} #{e.message}"
      flash[:error] = "WTF? we got no idea what happend... best check log"
    end
    redirect_to "/daily-stats/index"
  end

  def index
    @daily_stats = DailyStat.paginate(:all, :page => params[:page], :order => '"when" DESC', :per_page => (params[:per_page]||31))
  end

  def reports
    flash[:notice] = "Nothing analytical written yet :^(" 
    redirect_to "/daily-stats/index"
  end

  protected
  def lookups
    @stat_count =  DailyStat.count
    @latest_stat_message = @stat_count > 0 ?  "Tickets last collected #{Date.today - DailyStat.most_recent_collection_date} days ago" : "No stats recorded"
    @collection_period_message = DailyStat.collected_period_as_sentence
  end
end

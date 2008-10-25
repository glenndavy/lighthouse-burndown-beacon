require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyStatsController do

  it "should do index" do
    @stats = [] << @stat = mock('daily_stat')
    DailyStat.stub!(:find).and_return(@stats)
    DailyStat.should_receive(:paginate).and_return(@stats)
    get :index
    response.should be_success
    assigns(:stat_count).should be_number
    assigns(:latest_stat_message).should be_string
    assigns(:collection_period_message).should be_string 
  end

  it "should harvest" do
    DailyStat.stub!(:process_next_harvest).and_return([])
    DailyStat.should_receive(:process_next_harvest).and_return([])
    get :harvest
    response.should redirect_to("/daily-stats/index") 
    flash[:notice].should_not be_nil
  end


  it "should do reports" do
    get "reports"
    response.should be_success
  end
end


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyStatsController do

  before(:each) do
    DailyStat.stub!(:count).and_return(5)
    DailyStat.stub!(:most_recent_collection_date).and_return(Date.new)
    DailyStat.stub!(:collected_period_as_sentence).and_return("abcde")
  end
 

  it "should do index" do
    @stats = [] << @stat = mock('daily_stat')
    DailyStat.stub!(:find).and_return(@stats)
    DailyStat.should_receive(:paginate).and_return(@stats)
    get :index
    response.should be_success
    assigns(:stat_count).class.name.should == "Fixnum"
    assigns(:latest_stat_message).class.name.should == "String"
    assigns(:collection_period_message).class.name.should == "String"
  end

  it "should harvest" do
    DailyStat.stub!(:process_next_harvest).and_return([])
    DailyStat.should_receive(:process_next_harvest).and_return([])
    get :harvest
    response.should redirect_to("/daily-stats/index") 
    flash[:notice].should_not be_nil
    assigns(:stat_count).class.name.should == "Fixnum"
    assigns(:latest_stat_message).class.name.should == "String"
    assigns(:collection_period_message).class.name.should == "String"
  end


  it "should do reports" do
    get "reports"
    response.should be_redirect #for now
    assigns(:stat_count).class.name.should == "Fixnum"
    assigns(:latest_stat_message).class.name.should == "String"
    assigns(:collection_period_message).class.name.should == "String"
  end
end


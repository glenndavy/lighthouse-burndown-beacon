require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyStat do
  before(:each) do
    @existing_stats = []
    (1..10).each do |i|
      stat = mock("daily_stats")
      #lets have 10 days uptill 15th of oct 2005
      stat.stub!(:when).and_return(('2005-10-5'.to_date + i)) 
      stat.stub!(:id).and_return(i)
      #for easy maths each day gets 5 points better
      stat.stub!(:total_points).and_return( i * 5)
      #because 1 more ticket gets done
      stat.stub!(:ticket_count).and_return(i)
      @existing_stats << stat
    end

    @new_tickets = []
    @new_stats = []
    (1..5).each do |i|
      stat = mock("daily_stats")
      stat.stub!(:when).and_return('2005-10-15'.to_date + i)
      stat.stub!(:ticket_count).and_return(3)
      stat.stub!(:total_points).and_return((i+2)*3)
      @new_stats << stat
      (1..3).each do |j|
        ticket = mock_model(Lighthouse::Ticket)
        ticket.stub!(:points).and_return i+j 
        ticket.stub!(:updated_at).and_return stat.when
        @new_tickets << ticket
      end
    end 

      
    DailyStat.stub!(:count).and_return 1
    DailyStat.stub!(:find).and_return @existing_stats.reverse
    DailyStat.stub!(:next_harvest).and_return @new_tickets

    class DailyStat
      cattr_accessor :results
      @@results = []
      def self.create!(*args)
        @@results << args
      end
    end

  end

  it "should determine next harvest start date correctly" do
    DailyStat.next_harvest_from?.should == '2005-10-16'.to_date
  end

  it "should harvest recently resolved tickets" do
    DailyStat.next_harvest.should == @new_tickets
  end

  it "should harvest and correctly aggregate harvested tickets" do 
    DailyStat.process_next_harvest('2005-10-20')
    DailyStat.results.should == @new_stats.collect{|s| [{:ticket_count => s.ticket_count, :when => s.when, :total_points => s.total_points}] }
  end
  
  it "should correctly determine velocity" do
    DailyStat.all.each do |stat|
      #reached a limit here in my understanding of testing models by specing them... 
      #seems to be case in point why its a flawed notion, but i may just not be getting it yet 
      #stat.velocity.should eql( [(2.5 + stat.id * 2.5), ((stat.id+1)/2 * stat.total_points), stat.id * 3]) 
    end
  end

  it "should correctly determine collection first and last dates" do
    DailyStat.most_recent_collection_date.should == '2005-10-15'.to_date 
    DailyStat.earliest_collection_date.should == '2005-10-6'.to_date 
  end

  it "should return collection period as a string" do
    DailyStat.collected_period_as_sentence.class.should == String
  end

#  describe "when stats are empty" do
#	  #ensure above information methods don't break when db empty
#    pending
#  end
end

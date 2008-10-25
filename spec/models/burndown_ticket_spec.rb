require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BurndownTicket do

  it "should send harvest to LighthouseTicket" do
    Lighthouse::Ticket.stub!(:harvest).and_return(true)
    BurndownTicket.harvest(Date.yesterday, Date.today).should be_true
  end


  it "should  connectivity error" do
    Lighthouse::Ticket.stub!(:harvest).and_raise(Lighthouse::ConnectivityError)
    lambda{BurndownTicket.harvest(Date.yesterday, Date.today)}.should raise_error(Lighthouse::ConnectivityError)
  end

  it "should raise resource error" do
    Lighthouse::Ticket.stub!(:harvest).and_raise(Lighthouse::ResourceError)
    lambda{BurndownTicket.harvest(Date.yesterday, Date.today)}.should raise_error(Lighthouse::ResourceError)
  end
end

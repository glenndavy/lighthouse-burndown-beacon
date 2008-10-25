Lighthouse.token = '37ce8fb6a6ea0610741d35037c1a5f4a14e50130'
Lighthouse.account = 'burndown'
module Lighthouse
  class ConnectivityError < Exception#nodoc
  end
  class ResourceError < Exception#nodoc
  end
  class Ticket  
    @@project_id = 18671
    def self.harvest_from(date_from=(Date.yesterday))
      self.harvest(date_from, Date.today)
    end

    def self.harvest(date_from=(Date.yesterday), date_to=Date.today) 
      date_diff = "last #{date_to - date_from } days"
      begin
        self.find(:all, :params => {:project_id => @@project_id, :q => "state:closed update:\"date_diff\""}).select do|t| 
          #A brief comment about this apparently superflues step and that is
          #the lighthouse API is a little free form in its date selection capacity.
          #So... we use the API to get a small set as simply  possible, then actually select out what we want
          # The +1 on date to is because comparing dates vs date times... we need midnight that night"
          t.updated_at <= date_to + 1 && t.updated_at >= date_from
        end
      rescue SocketError, Errno::ENETUNREACH  => e
        raise ConnectivityError.new
      rescue ActiveResource::ResourceNotFound #404
        raise ResourceError.new 
      end
    end

    def points
      #TODO - this assumes a pretty ideal scenario
      #and recovers deceptively if tag left out
      #this should be revisted and errors raised and handeled
      #when 
      # * there are no tags, 
      # * tags include more than points, 
      # * points are not numeric 
    
      tag.split(":")[-1].to_d
    rescue
      0
    end
  end
end

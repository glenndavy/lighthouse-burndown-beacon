class DailyStat < ActiveRecord::Base
  validates_presence_of :when 

  def self.next_harvest_from?
    self.count > 0 ? self.most_recent_collection_date.next : '2000-01-01'.to_date 
  end
 
  def self.next_harvest(date_to = Date.yesterday)
    BurndownTicket.harvest(self.next_harvest_from?, date_to)
  end  

  def self.process_next_harvest(date_to = Date.yesterday)
    old_count = DailyStat.count
    running_count_of_tickets = running_sum_of_points = 0.0
    DailyStat.transaction do 
      self.next_harvest(date_to).group_by{|t| t.updated_at.to_date}.each do |(date, days_tickets)|
        DailyStat.create!(:when => date, :ticket_count => (days_tickets.length), :total_points => days_tickets.sum(&:points))
        running_count_of_tickets += days_tickets.length
        running_sum_of_points +=  (days_tickets.sum(&:points)||0.0)
      end
    end
    return  (DailyStat.count - old_count), running_count_of_tickets, running_sum_of_points 
  rescue Exception => e
    logger.error "*** Daily stats model recorded this error during harvest: #{e.message} ***"
    raise e 
  end

  def velocity
    #I should probably google and find out what this really means... but till then...
    #seems to me the analogy of d/t from physics usefull enough where d=points instead of distance, and time here is days.
    #and seems whats more usefull is a running average of velocity rather than velocity at that point.
    #perhaps in future it would be more helpful to determine velocity over a specific period than across whole data set.
    sum_of_points = DailyStat.find(:all, :conditions => ['"when" <= ?',self.when], :order => '"when" desc').sum(&:total_points)
    count_of_stats = DailyStat.find(:all, :conditions => ['"when" <= ?',self.when], :order => '"when" desc').count
    return (sum_of_points / count_of_stats), sum_of_points, count_of_stats
  end
  
  def self.earliest_collection_date
    self.count > 0 ? self.find(:all, :order => '"when" desc').last.when : nil
  end
  
  def self.most_recent_collection_date
    self.count > 0 ? self.find(:all, :order => '"when" desc').first.when : nil
  end

  def self.collected_period_as_sentence
    if self.count > 0
      "Stats are based on tickets collected between #{self.earliest_collection_date.to_s} and #{self.most_recent_collection_date.to_s}"
    else
      "Nothing harvested from lighthouse at this stage"
    end
  end
end

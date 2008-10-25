require 'burndown_lighthouse'
class BurndownTicket
  def self.harvest(date_from, date_to)
    Lighthouse::Ticket.harvest(date_from, date_to)
  end
end  

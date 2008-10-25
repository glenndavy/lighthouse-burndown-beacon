ActionController::Routing::Routes.draw do |map|
 
  map.connect "/daily-stats/index", :controller => "daily_stats", :action => "index"
  map.connect "/daily-stats/harvest", :controller => "daily_stats", :action => "harvest"
  map.connect "/daily-stats/reports", :controller => "daily_stats", :action => "reports"

  map.root :controller => "daily_stats", :action => "index"

 # map.connect ':controller/:action/:id'
 # map.connect ':controller/:action/:id.:format'
end

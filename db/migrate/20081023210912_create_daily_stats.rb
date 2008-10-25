class CreateDailyStats < ActiveRecord::Migration
  def self.up
    create_table :daily_stats do |t|
      t.date :when
      t.decimal :total_points
      t.integer :ticket_count

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_stats
  end
end

class ReplaceStatusByVerifiedAtAndCanceledAtOnReports < ActiveRecord::Migration
  def up
    add_column :reports, :verified_at, :datetime
    add_column :reports, :canceled_at, :datetime

    Report.find_each do |report|
      time = report.updated_at || report.created_at || Time.zone.now
      case report.status.to_sym
      when :canceled then report.update_columns verified_at: time, canceled_at: time
      when :approved then report.update_columns verified_at: time
      end
    end
    
    remove_column :reports, :status
  end

  def down
    add_column :reports, :status, :integer, default: 0, null: false

    Report.find_each do |report|
      if report.canceled_at.present?
        report.update_columns status: 2
      elsif report.verified_at.present?
        report.update_columns status: 1
      else
        report.update_columns status: 0
      end
    end
    
    remove_column :reports, :verified_at, :datetime
    remove_column :reports, :canceled_at, :datetime
  end
end

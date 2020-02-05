require 'thread/pool'

namespace :hyacinth do
  namespace :data_migration do

    task :update_original_file_path_storage => :environment do

      if ENV['START_AT'].present?
        start_at = ENV['START_AT'].to_i
        puts 'Starting at: ' + start_at.to_s
      else
        start_at = 0
      end


      total = DigitalObjectRecord.count
      i = start_at

      DigitalObjectRecord.find_each(batch_size: 500, start: start_at) do |digital_object_record|

        begin

          puts "Processing #{digital_object_record.pid} (#{digital_object_record.id}) ..."

          obj = DigitalObject::Base.find(digital_object_record.pid)

          if obj.state != 'D' && obj.is_a?(DigitalObject::Asset)

            current_file_path = obj.get_original_file_path
            current_file_path = current_file_path.first if current_file_path.is_a?(Array)
            current_file_path = current_file_path.gsub(/^\["/, '').gsub(/"\]$/, '') if current_file_path.start_with?("[\"") && current_file_path.end_with?("\"]") # Correction for recent issue

            obj.set_original_file_path(current_file_path)
            obj.save
            puts "Updated Asset - #{i} of #{total}"
          else
            puts "Skipping non-Asset (or deleted) object - #{i} of #{total}"
          end
        rescue RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error 'Error: Skipping ' + digital_object_record.pid + "\nException: #{e.class}, Message: #{e.message}"
        end

        i += 1
      end

    end
    task :migrate_captions_content_to_synchronized => :environment do
      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      elsif ENV['PIDLIST'].present?
        pids = open(ENV['PIDLIST'],'r').map(&:strip)
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs) or PIDLIST (filepath)'
        next
      end
      pids.each do |pid|
        digital_object = DigitalObject::Base.find(pid)
        if digital_object.captions.present?
          digital_object.synchronized_transcript = digital_object.captions
          digital_object.publish_after_save = (ENV['PUBLISH'] == 'true')
          digital_object.save
        end
      end
    end
  end
end

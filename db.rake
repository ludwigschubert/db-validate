namespace :db do

  task validate: :environment do |task, args|
    puts "Searching for invalid records..."

    Rails.application.eager_load!
    record_count = Database.record_count
    bar = ProgressBar.create(title: "Records", starting_at: 0, total: record_count)
    invalid_records = Database.invalid_records {bar.increment}
    bar.finish

    invalid_records.each do |invalid_record|
      puts "#{invalid_record.class.to_s}: #{invalid_record.id} is invalid. (#{invalid_record.errors.full_messages.join(', ')}) (#{invalid_record.inspect})"
    end

    if invalid_records.count > 0
      puts "Do you want to destroy all #{invalid_records.count} invalid record(s) now? (Y/n)"

      if STDIN.gets.strip == 'Y'
        invalid_records.each do |invalid_record|
          puts "Destroying #{invalid_record.class.to_s}: #{invalid_record.id} is invalid. (#{invalid_record.errors.full_messages.join(', ')})"
          begin
            invalid_record.destroy
          rescue Exception => exception
            puts "Couldn't destroy #{invalid_record.class.to_s}: #{invalid_record.id}, deleting instead."
            invalid_record.delete
          end
        end
      else
        puts "No invalid records were destroyed."
      end
    else
      puts "Checked #{record_count} records, all are valid. Good job! Bye."
    end
  end # task


  class Database

    def self.model_classes
      ActiveRecord::Base.descendants.select do |active_record_class|
        active_record_class.column_names.include? 'id'
      end
    end

    def self.record_count
      Database.model_classes.map(&:count).inject(:+)
    end

    def self.invalid_records &block
      Database.model_classes.reduce([]) do |records, model_class|
        records + Database.invalid_records_for_class(model_class, &block)
      end
    end

    def self.invalid_records_for_class model_class
      model_class.all.reject do |model|
        yield if block_given? # usually used for counters, etc.
        begin
          model.valid?
        rescue Exception => exception
          false # if valid? crashed, then the object is surely not valid.
        end
      end
    end

  end # class Database

end # namespace
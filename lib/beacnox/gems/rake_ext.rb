module Beacnox
  module Gems
    class RakeExt
      def self.init
        ::Rake::Task.class_eval do
          next if method_defined?(:invoke_with_beacnox)

          def invoke_with_beacnox(*args)
            now = Beacnox::Utils.time
            status = "success"
            invoke_without_new_beacnox(*args)
          rescue Exception => ex # rubocop:disable Lint/RescueException
            status = "error"
            raise(ex)
          ensure
            if !Beacnox.skipable_rake_tasks.include?(name)
              task_info = Beacnox::Gems::RakeExt.find_task_name(*args)
              task_info = [name] if task_info.empty?
              Beacnox::Models::RakeRecord.new(
                task: task_info,
                datetime: now.strftime(Beacnox::FORMAT),
                datetimei: now.to_i,
                duration: (Beacnox::Utils.time - now) * 1000,
                status: status
              ).save
            end
          end

          alias_method :invoke_without_new_beacnox, :invoke
          alias_method :invoke, :invoke_with_beacnox

          def invoke(*args) # rubocop:disable Lint/DuplicateMethods
            invoke_with_beacnox(*args)
          end
        end
      end

      def self.find_task_name(*args)
        (ARGV + args).compact
      end
    end
  end
end

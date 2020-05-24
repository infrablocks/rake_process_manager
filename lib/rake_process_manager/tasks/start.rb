require 'rake_factory'

module RakeProcessManager
  module Tasks
    class Start < RakeFactory::Task
      default_name :start
      default_description RakeFactory::DynamicValue.new { |t|
        "Start #{t.process_description}."
      }

      parameter :process_name, required: true
      parameter :process_description, required: true
      parameter :log_file_path,
          default: RakeFactory::DynamicValue.new { |t|
            "run/logs/#{t.process_name}.log"
          }
      parameter :pid_file_path,
          default: RakeFactory::DynamicValue.new { |t|
            "run/pids/#{t.process_name}.pid"
          }

      action do |t|
        mkdir_p File.dirname(t.log_file_path)
        mkdir_p File.dirname(t.pid_file_path)
      end
    end
  end
end

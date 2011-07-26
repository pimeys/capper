require File.dirname(__FILE__) + '/../capper' unless defined?(Capper)

Capper.load do
  on :load do
    if stages.include?(ARGV.first)
      # Execute the specified stage so that recipes required in stage can contribute to task list
      find_and_execute_task(ARGV.first) if ARGV.any?{ |option| option =~ /-T|--tasks|-e|--explain/ }
    else
      # Execute the default stage so that recipes required in stage can contribute tasks
      find_and_execute_task(default_stage) if exists?(:default_stage)
    end
  end

  namespace :multistage do
    task :ensure do
      if !exists?(:stage)
        if exists?(:default_stage)
          logger.important "Defaulting to `#{default_stage}'"
          find_and_execute_task(default_stage)
        else
          abort "No stage specified. Please specify one of: #{stages.join(', ')} (e.g. `cap #{stages.first} #{ARGV.last}')"
        end
      end
    end
  end

  on :start, "multistage:ensure", :except => stages
end

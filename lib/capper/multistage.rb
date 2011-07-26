require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  # execute the specified stage so that recipes required in stage can contribute to task list
  on :load do
    if stages.include?(ARGV.first)
      find_and_execute_task(ARGV.first) if ARGV.any?{ |option| option =~ /-T|--tasks|-e|--explain/ }
    end
  end

  namespace :multistage do
    task :ensure do
      unless exists?(:current_stage)
        abort "No stage specified. Please specify one of: #{stages.join(', ')} (e.g. `cap #{stages.first} #{ARGV.last}')"
      end
    end
  end

  on :start, "multistage:ensure", :except => stages
end

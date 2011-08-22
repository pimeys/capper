require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  set(:monitrc) { "#{deploy_to}/.monitrc.local" }

  namespace :monit do
    task :setup do
      str = fetch(:monit_configs, {}).join("\n\n")
      upload_template_string(str, monitrc, :mode => "0644")
    end

    task :reload do
      run "monit reload"
    end
  end

  after "deploy:update_code", "monit:setup"
  before "deploy:restart", "monit:reload"
end

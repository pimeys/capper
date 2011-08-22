require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  set(:monitrc) { "#{deploy_to}/.monitrc.local" }

  namespace :monit do
    task :setup do
      configs = []

      fetch(:monit_configs, {}).each do |name, body|
        configs << "# #{name}\n#{body}"
      end

      upload_template_string(configs.join("\n\n"),
                             monitrc,
                             :mode => "0644")
    end

    task :reload do
      run "monit reload &>/dev/null"
    end
  end

  after "deploy:update_code", "monit:setup"
  before "deploy:restart", "monit:reload"
end

require 'newrelic_api'
begin
  newrelic_config = YAML.load_file("config/newrelic.yml")
  applications = newrelic_config['applications']

  # Emitted metrics:
  # - rpm_apdex
  # - rpm_error_rate
  # - rpm_throughput
  # - rpm_errors
  # - rpm_response_time
  # - rpm_db
  # - rpm_cpu
  # - rpm_memory

  SCHEDULER.every '5s', :first_in => 0 do |job|
    applications.each do |application|
      NewRelicApi.api_key = application["api_key"]
      app = NewRelicApi::Account.find(application["account_id"].to_i).applications(application["application_id"].to_i)

      app.threshold_values.each do |v|
        value_name = v.name.downcase.gsub(/ /, '_')
        value = v.metric_value
        status = 'ok'
        status = case value_name
        when 'apdex'
          case
          when value < 0.5 then 'danger'
          when value < 0.7 then 'warning'
          end
        when 'response_time'
          case
          when value > 1000 then 'danger'
          when value > 500 then 'warning'
          end
        end
        send_event(application["name"].downcase+"_rpm_" + value_name, { value: value, status: status })
      end
    end
  end
rescue Errno::ENOENT
  puts "No config file found for new relic - not starting the New Relic job"
end

# config/initializers/delayed_job_config.rb
Delayed::Worker.backend = :active_record
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 300.minutes
#Delayed::Worker.delay_jobs = !Rails.env.test?

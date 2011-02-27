# config/initializers/delayed_job_config.rb
Delayed::Worker.backend = :active_record
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 10
Delayed::Worker.max_run_time = 1.minutes
#Delayed::Worker.delay_jobs = !Rails.env.test?

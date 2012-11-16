AutoTask CRM Ruby Gem
=====================

Create config/initializers/auto_task.rb:
----------------------------------------
```ruby
AUTOTASK_CONFIG = YAML.load_file("#{Rails.root}/config/auto_task.yml")[Rails.env]
```

Create config/auto_task.yml:
----------------------------
```
development:
  username: xxxxx@yyyyy.zzz
  password: xxxxxxxxxxx

test:
  username: xxxxx@yyyyy.zzz
  password: xxxxxxxxxxx

production:
  username: xxxxx@yyyyy.zzz
  password: xxxxxxxxxxx
```

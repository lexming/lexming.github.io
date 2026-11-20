---
title: PHP Sessions on Redis Socket
created: 2026-11-19
modified: 2026-11-19
tags:
  - php
  - redis
---
The recent vulnerability for PHP called [phpAfterShell](https://depthfirst.com/phpaftershell) (CVE-2026-126714) can lead to unauthenticated RCE by exploiting a bug on PHP's default file-based sessions.

I want to avoid this issue altogether by switching from files to [Redis](https://github.com/redis/redis) as session handler in my PHP servers. I already have Redis running as [cache layer of Nextcloud](https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/caching_configuration.html) and it should bring some gain in performance _for free_ as well (probably negligible as load is usually low, but who can refuse more speed?). I won't try to use a database as I want to avoid any unnecessary load on the MariaDB used by my Nextcloud.

## Redis and php-redis

I'm not going to explain how to run Redis here. That's already covered extensively elsewhere on the Internet. The following just serves to check that the service and module for PHP are available.

1. Check redis service

   ```console
   systemctl status redis
   ```

2. Check php-redis module is available

   ```console
   php -m | grep redis
   ```

## Enable Redis session handler

> [!note]
> I run Redis bound to a local socket only serving localhost. In the following replace the socket path `/var/run/redis/redis.sock` with the path to your socket or a TCP port if necessary.

We just need to define a target database in Redis and some prefix to enable Redis as session handler in PHP:

1. Check the databases available in Redis

   ```console
   $ redis-cli -s /var/run/redis/redis.sock CONFIG GET databases
     1) "databases"
     2) "16"
   ```

2. Select a suitable database index
   In my case, Nextcloud already uses database 0 in Redis, so I'll set PHP session handler to 1.
   
3. Define some arbotrary prefix for the session keys. For instance, _PHP_SESSION:_.
   
4. Set Redis as session handler with the following configuration parameters in `php.ini`

   ```php
   [Session]
   session.save_handler = redis
   session.save_path = "unix:///var/run/redis/redis.sock?database=1&prefix=PHP_SESSION:"
   session.use_strict_mode = 1
   ```

5. I recommend enabling locking in php-redis to avoid collisions. Append the following parameters at the end of `php.ini`

   ```php
   [redis]
   redis.session.locking_enabled = 1
   redis.session.lock_retries = 10
   redis.session.lock_wait_time = 15000
   ```

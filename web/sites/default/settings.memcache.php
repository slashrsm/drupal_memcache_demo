<?php

$settings['memcache']['servers'] = ['memcached:11211' => 'default'];
$settings['memcache']['bins'] = ['default' => 'default'];
$settings['memcache']['key_prefix'] = '';

$settings['cache']['default'] = 'cache.backend.memcache';

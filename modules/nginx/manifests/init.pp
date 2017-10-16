class nginx (
  $message   = "Message default from nginx class",    
){

  File {
    owner => 'root',
    group => 'root',
    mode  => '0775’,
  }

  case $::osfamily {
    'RedHat','Debian': {
      $package  = 'nginx'
      $owner    = 'root'
      $group    = 'root'
      $docroot  = '/var/www'
      $confdir  = '/etc/nginx'
      $blockdir = '/etc/nginx/conf.d'
      $logdir   = '/var/log/nginx'
      $service  = 'nginx'
    }
    default : {
      fail("This module is not supported on ${::osfamily}")
    }
  }

  $user = $::osfamily ? {
    'RedHat' => 'nginx',
    'Debian' => 'www-data',
    default  => 'fail',
  }

  if $user == 'fail' {
    fail("This module is not suppported on ${::osfamily}")
  }


  notify { "$message": }

  package { $package:
    ensure => present,
    before => [File["${blockdir}/default.conf"],File["${confdir}/nginx.conf"]],
  }

  file { $docroot:
    ensure => directory,
  }

  file { "${docroot}/index.html":
    ensure  => file,
    #source => 'puppet:///modules/nginx/index.html',
    content => epp('nginx/index.html.epp'),
  }

  service { $service:
    ensure    => running,
    enable    => true,
    subscribe => [
                   File["${confdir}/nginx.conf"],
                   File["${blockdir}/default.conf"]
                 ],
  }

  file { "${confdir}/nginx.conf":
    ensure   => file,
    mode     => '0664',
    #source  => 'puppet:///modules/nginx/nginx.conf',
    content  => epp('nginx/nginx.conf.epp',
                    {
                      user     => $user,
                      logdir   => $logdir,
                      confdir  => $confdir,
                      blockdir => $blockdir,
                    }),
    #require => Package['nginx'],
    #notify  => Service['nginx'],
  }

  file { "${blockdir}/default.conf":
    ensure  => file,
    source  => 'puppet:///modules/nginx/default.conf',
    #require => Package['nginx'],
    #notify  => Service['nginx'],
  }

}

 

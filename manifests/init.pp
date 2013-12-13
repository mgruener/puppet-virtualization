class virtualization {

  include virtualization::params
  package { $virtualization::params::packages: ensure => present }

  service { $virtualization::params::servicename:
    ensure => running,
    enable => true,
  }
}

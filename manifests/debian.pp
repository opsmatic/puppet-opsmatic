class opsmatic::debian {

  file { "opsmatic_public_debian_repo":
    path    => "/etc/apt/sources.list.d/opsmatic_public.list",
    ensure  => file,
    content => template("opsmatic/opsmatic_public.list.erb"),
    notify  => Exec["opsmatic_public_update_repo_cache"],
    before  => Exec["opsmatic_public_debian_key"]
  }

  exec { "opsmatic_public_debian_key":
    command => "/usr/bin/wget -qO - https://packagecloud.io/gpg.key | apt-key add -",
    require => File["opsmatic_public_debian_repo"],
    notify  => Exec["opsmatic_public_update_repo_cache"]
  }

  exec { "opsmatic_public_update_repo_cache":
    command     => "/usr/bin/apt-get update",
    require     => Exec["opsmatic_public_debian_key"]
  }

}

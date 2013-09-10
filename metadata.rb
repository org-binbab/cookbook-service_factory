name             "service_factory"
maintainer       "BinaryBabel OSS"
maintainer_email "projects@binarybabel.org"
license          "Apache License, Version 2.0"

description      "LWRPs to generate services using native system features and service managers. (SysV, Upstart, ...)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          "0.1.4"

depends          "unix_bin", ">= 0.2.7"
depends          "resource_masher", ">= 0.10.0"
depends          "run_action_now", ">= 0.1.0"

supports         "centos", ">= 5.0"
supports         "ubuntu", ">= 10.04"

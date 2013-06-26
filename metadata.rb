name             "service_factory"
maintainer       "BinaryBabel OSS"
maintainer_email "projects@binarybabel.org"
license          "Apache License, Version 2.0"

description      "Generate services using native system features and service managers. (SysV, Upstart, ...)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          "0.1.1"

depends          "unix_bin"
depends          "resource_masher"

supports         "centos", ">= 5.0"
supports         "ubuntu", ">= 10.04"

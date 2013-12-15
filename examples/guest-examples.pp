class guest-example {

  guest { "lotsofoptions":
    ensure => present,
    ram => 2048,
    disks => [ { source => "path=/var/lib/libvirt/images/lotsofoptions1.img",
                 size => 8,
                 bus => virtio
               },
               { source => "path=/var/lib/libvirt/images/lotsofoptions2.img",
                 size => 16,
                 bus => sata,
                 sparse => true,
               }
    ],
    arch => "x86_64",
    machine => "pc",
    vcpus => 4,
    maxvcpus => 4,
    vcpusockets => 1,
    vcpucores => 2,
    vcputhreads => 2,
    cpuset => "1-4",
    numatune => "1-8",
    numamode => "preferred",
    cpumodel => "core2duo",
    cpufeatures => [ "+x2apic","-vmx" ],
    cpuvendor => "Intel",
    cpumatch => "minimum",
    description => "This is a little bit of overkill",
    installmethod => cdrom,
    installmedia => "/var/lib/iso/Fedora-19-x86_64-netinst.iso",
    livecd => true,
    initrdinject => "/root/anaconda-ks.cfg",
    extraargs => "ks=file://anaconda-ks.cfg",
    ostype => "linux",
    osvariant => "fedora14",
    boot => "cdrom,fd,hd,network,menu=on",
    hypervisor => "kvm",
    virttype => "hvm",
    noapic => true,
    noacpi => true,
    controllers => [ { type  => "usb",
                       model => "ich9-ehci1",
                       address => "0:0:4.7",
                       index => "0"
                     },
                     { type => "usb",
                       model => "ich9-ehci1",
                       address => "0:0:5.7",
                       index => "0"
                     }
    ],
    hostdevices => [ "pci_0000_00_1c_3", "pci_0000_00_1d_0" ],
    soundhw => [ "ich6", "ac97" ],
    watchdogmodel => "default",
    watchdogaction => poweroff,
    serialports => [ { type => tcp,
                       host => "0.0.0.0:4567"
                     },
                     { type => tcp,
                       host => ":1234",
                       mode => connect
                     }
    ],
    video => vga,
    smartcards => { mode => passthrough,
                    type => spicevmc
    },
    redirdevs => { bus => usb,
                   type => tcp,
                   server => "localhost:4000"
    },
    graphics => { type => vnc,
                  keymap => local,
                  password => "test1234",
                  passwordvalidto => "2014-12-12T10:10:10"
    },
    networks => { type => "bridge=br0",
                  mac => "aa:bb:cc:dd:ee:ff"
    }
  }

  guest { "minimal":
    ensure => present,
    ram => 1024,
    disks => { source => "path=/var/lib/libvirt/images/minimal.img",
               size => 8
    }
  }
}

class virtualization::params {

  $xenpackages = $::operatingsystem ? {
    Debian => [ 'linux-image-xen-686', 'xen-hypervisor', 'xen-tools', 'xen-utils' ],
    Ubuntu => [ 'python-vm-builder', 'ubuntu-xen-server', 'libvirt-ruby' ],
    Fedora => [ 'kernel-xen', 'xen', 'ruby-libvirt' ],
  }

  $kvmpackages = $::operatingsystem ? {
    Debian => [ 'kvm', 'libvirt0', 'libvirt-bin', 'qemu', 'virtinst', 'libvirt-ruby' ],
    Ubuntu => [ 'ubuntu-virt-server', 'python-vm-builder', 'kvm', 'qemu', 'qemu-kvm', 'libvirt-ruby' ],
    Fedora => $::operatingsystemmajrelease ? {
      19      => [ 'qemu-kvm', 'qemu', 'libvirt', 'virt-install', 'ruby-libvirt' ],
      default => [ 'kvm', 'qemu', 'libvirt', 'python-virtinst', 'ruby-libvirt' ],
    }
  }

  case $::virtual {
    /^physical|^kvm/: {
      $servicename = 'libvirtd'
      $packages = $kvmpackages
    }
    /^xen/: {
      $servicename = 'libvirtd'
      $packages = $xenpackages
    }
    default: {
      $servicename = 'libvirtd'
    }
  }

}

Puppet::Type.type(:guest).provide(:libvirt) do
  desc "TODO"

  commands :virtinstall => "/usr/bin/virt-install"
  commands :virsh => "/usr/bin/virsh"

  confine :feature => :libvirt

  has_features :createguest

  defaultfor :virtual => ["kvm", "physical", "xenu"]

  def virtinstall_version
    @virtinstall_version ||= virtinstall("--version")
  end

  def virsh_version
    @virsh_version ||= virsh("--version")
  end

  def exists?
  end

  def status
  end

  def create
  end

  def remove
  end

  def purge
  end
end

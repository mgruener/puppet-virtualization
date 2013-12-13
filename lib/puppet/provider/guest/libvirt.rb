Puppet::Type.type(:guest).provide(:libvirt) do
  desc "TODO"

  commands :virtinstall => "/usr/bin/virt-install"
  commands :virsh => "/usr/bin/virsh"

  confine :feature => :libvirt

  has_features :createguest

  defaultfor :virtual => ["kvm", "physical", "xenu"]

  # Check if the domain exists.
  def exists?
    exec
    true
  rescue Libvirt::RetrieveError => e
    false # The vm with that name doesnt exist
  end

  def status
    if exists?
        return :installed
    else
      if @resource[:ensure].to_s == "purged"
        # TODO: do purged tests
        return :purged
      end
      debug "Domain %s status: absent" % [@resource[:name]]
      return :absent
    end
  end

  def create
  end

  def remove
  end

  def purge
  end

private
  def virtinstall_version
    @virtinstall_version ||= virtinstall("--version")
  end

  def virsh_version
    @virsh_version ||= virsh("--version")
  end

  def hypervisor
    case @resource[:virttype]
      when :xen_fullyvirt, :xen_paravirt then "xen:///"
      else "qemu:///system"
    end
  end

  # Executes operation over guest
  def exec
    conn = Libvirt::open(hypervisor)
    @guest = conn.lookup_domain_by_name(@resource[:name])
    ret = yield if block_given?
    conn.close
    return ret
  end

end

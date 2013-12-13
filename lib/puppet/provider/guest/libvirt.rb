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
    # the setup is non-interactive and we want
    # the guest vm to be offline after the initial setup
    args = "--force --noautoconsole --noreboot"

    virtinstall args
  end

  def remove
    debug "Trying to destroy domain %s" % [@resource[:name]]

    begin
      exec { @guest.destroy }
    rescue Libvirt::Error => e
      debug "Domain %s already Stopped" % [@resource[:name]]
    end
    exec { @guest.undefine }
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
      when :xen then "xen:///"
      when :lxc then "lxc:///"
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

  # Takes an array of hashes and creates a string of the form
  # "#{prefix} #{options[n][identifier]},#{key}=#{options[n][key]},..."
  # for each of the n elements in options. For each element,
  # a number of key=value pairs is appended to the string where
  # key != identifier.
  #
  # This creates valid virt-install options strings, for example
  # --graphics TYPE,opt1=arg1,opt2=arg2,...
  # --graphics vnc,password=foobar
  # where
  # options    -> [ { type => vnc, password => foobar } ]
  # prefix     -> "--graphics"
  # identifier -> "type"
  def flattenoptions(options, prefix, identifier)

    options = options.kind_of?(Array) ? options : [options]

    string = ""
    options.each do |option|
      string += "#{prefix} #{option[identifier]}"
      option.keys.each do |key|
        if !(identifier == key)
          string += ",#{key}=#{option[key]}"
        end
      end
      string += " "
    end
    return string.strip
  end
end

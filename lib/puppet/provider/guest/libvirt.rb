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

    if @resource[:disks]
      args << " " << flattenoptions(@resource[:disks],"--disk","source")
    end

    if @resource[:filesystems]
      args << " " << flattenoptions(@resource[:filesystems],"--filesystem",nil)
    end

    if @resource[:networks]
      args << " " << flattenoptions(@resource[:networks],"--network","type")
    end

    if @resource[:graphics]
      args << " " << flattenoptions(@resource[:graphics],"--graphics","type")
    end

    if @resource[:controllers]
      args << " " << flattenoptions(@resource[:controllers],"--controller","type")
    end

    if @resource[:serialports]
      args << " " << flattenoptions(@resource[:serialports],"--serial","type")
    end

    if @resource[:parallelports]
      args << " " << flattenoptions(@resource[:parallelports],"--parallel","type")
    end

    if @resource[:channels]
      args << " " << flattenoptions(@resource[:channels],"--channel","type")
    end

    if @resource[:consoles]
      args << " " << flattenoptions(@resource[:consoles],"--console","type")
    end

    if @resource[:smartcards]
      args << " " << flattenoptions(@resource[:smartcards],"--smartcard","mode")
    end

    if @resource[:redirdevs]
      args << " " << flattenoptions(@resource[:redirdevs],"--redirdev","bus")
    end

    [:livecd, :nodisks, :nonetworks, :hvm, :paravirt, :container, :noapic, :noacpi].each do |option|
      if @resource[option]
        args << " " << "--#{option}"
      end
    end

    [:ram, :arch,:machine,:uuid,:cpuset,:description,:init, :boot, :memballoon, :video].each do |option|
      if @resource[option]
        args << " " << "--#{option} #{@resource[option]}"
      end
    end

    if @resource[:hostdevices]
      Array(@resource[:hostdevices]).each do |device|
        args << " " << "--host-device #{device}"
      end
    end

    if @resource[:soundhw]
      Array(@resource[:soundhw]).each do |device|
        args << " " << "--soundhw #{device}"
      end
    end

    if @resource[:initrdinject]
      args << " " << "--initrd-inject #{@resource[:initrdinject]}"
    end

    if @resource[:extraargs]
      args << " " << "--extra-args #{@resource[:extraargs]}"
    end

    if @resource[:virttype]
      args << " " << "--virt-type #{@resource[:virttype]}"
    end

    if @resource[:ostype]
      args << " " << "--os-type #{@resource[:ostype]}"
    end

    if @resource[:osvariant]
      args << " " << "--os-variant #{@resource[:osvariant]}"
    end

    if @resource[:watchdogmodel]
      args << " " << "--watchdog #{@resource[:watchdogmodel]}"
      if @resource[:watchdogaction]
        args << ",action=#{@resource[:watchdogaction]}"
      end
    end

    if @resource[:vcpus]
      args << " " << "--vcpus #{@resource[:vcpus]}"
      if @resource[:maxvcpus]
        args << ",maxvcpus=#{@resource[:maxvcpus]}"
      end
      if @resource[:vcpusockets]
        args << ",sockets=#{@resource[:vcpusockets]}"
      end
      if @resource[:vcpucores]
        args << ",cores=#{@resource[:vcpucores]}"
      end
      if @resource[:vcputhreads]
        args << ",threads=#{@resource[:vcputhreads]}"
      end
    end

    if @resource[:cpumodel]
      args << " " << "--cpu #{@resource[:cpumodel]}"
      if @resource[:cpumatch]
        args << ",match=#{@resource[:cpumatch]}"
      end
      if @resource[:cpuvendor]
        args << ",vendor=#{@resource[:cpuvendor]}"
      end
      if @resource[:cpufeatures]
        Array(@resource[:cpufeatures]).each do |feature|
          args << ",#{feature}"
        end
      end
    end

    if @resource[:securitytype]
      args << " " << "--security type=#{@resource[:securitytype]}"
      if @resource[:securitylabel]
        args << ",label=#{@resource[:securitylabel]}"
      end
      if @resource[:securityrelabel]
        args << ",relabel=#{@resource[:securityrelabel]}"
      end
    else
      if @resource[:securitylabel]
        args << " " << "--security label=#{@resource[:securitylabel]}"
        if @resource[:securityrelabel]
          args << ",relabel=#{@resource[:securityrelabel]}"
        end
      end
    end

    if @resource[:numatune]
      args << " " << "--numatune \"#{@resource[:numatune]}\""
      if @resource[:numamode]
        args << ",mode=#{@resource[:numamode]}"
      end
    end

    case @resource[:installmethod]
      when :cdrom
        args << " " << "--cdrom #{@resource[:installmedia]}"
      when :location
        args << " " << "--location #{@resource[:installmedia]}"
      when :pxe
        args << " " << "--pxe"
      when :import
        args << " " << "--import"
      else "TODO"
    end

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
    remove
    # TODO purge relevant files
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
  # If identifier is nil the resulting string becomes
  # "#{prefix} #{key}=#{options[n][key]},..."
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
      string += identifier ? "#{prefix} #{option[identifier]}," : "#{prefix} "
      option.keys.each do |key|
        if !(identifier == key)
          string += "#{key}=#{option[key]},"
        end
      end
      string.chomp!(",")
      string += " "
    end
    return string.strip
  end
end

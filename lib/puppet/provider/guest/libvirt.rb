require 'rexml/document'
include REXML

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
        return :present
    else
      if @resource[:ensure].to_s == "purged"
        if @resource[:disks]
          purged = true
          diskimagefiles(@resource[:disks]).each do |file|
            if File.exists?(file)
              purged = false
            end
          end
          if purged
            return :purged
          end
        else
          return :purged
        end
      end
      debug "Domain %s status: absent" % [@resource[:name]]
      return :absent
    end
  end

  def create
    # the setup is non-interactive and we want
    # the guest vm to be offline after the initial setup
    args = ["--name", @resource[:name], "--force", "--noautoconsole", "--noreboot"]

    if @resource[:disks]
      debug "Adding disks to guest"
      args << flattenoptions(@resource[:disks],"--disk","source")
    end

    if @resource[:filesystems]
      debug "Adding filesystems to guest"
      args << flattenoptions(@resource[:filesystems],"--filesystem",nil)
    end

    if @resource[:networks]
      debug "Adding networks to guest"
      args << flattenoptions(@resource[:networks],"--network","type")
    end

    if @resource[:graphics]
      debug "Adding graphics to guest"
      args << flattenoptions(@resource[:graphics],"--graphics","type")
    end

    if @resource[:controllers]
      debug "Adding controllers to guest"
      args << flattenoptions(@resource[:controllers],"--controller","type")
    end

    if @resource[:serialports]
      debug "Adding serial ports to guest"
      args << flattenoptions(@resource[:serialports],"--serial","type")
    end

    if @resource[:parallelports]
      debug "Adding parallel ports to guest"
      args << flattenoptions(@resource[:parallelports],"--parallel","type")
    end

    if @resource[:channels]
      debug "Adding channels to guest"
      args << flattenoptions(@resource[:channels],"--channel","type")
    end

    if @resource[:consoles]
      debug "Adding consoles to guest"
      args << flattenoptions(@resource[:consoles],"--console","type")
    end

    if @resource[:smartcards]
      debug "Adding smartcards to guest"
      args << flattenoptions(@resource[:smartcards],"--smartcard","mode")
    end

    if @resource[:redirdevs]
      debug "Adding drive redirects to guest"
      args << flattenoptions(@resource[:redirdevs],"--redirdev","bus")
    end

    debug "Configuring options for guest"
    [:livecd, :nodisks, :nonetworks ].each do |option|
      if @resource[option]
        debug "option: #{option}"
        args << "--#{option}"
      end
    end

    [:noacpi, :noapic ].each do |option|
      if @resource[option] == :true
        debug "option: #{option}"
        args << "--#{option}"
      end
    end

    [:ram, :arch, :machine, :uuid, :cpuset, :description, :init, :memballoon, :video].each do |option|
      if @resource[option]
        debug "option: #{option} ; value: #{@resource[option]}"
        args << "--#{option}" << @resource[option].to_s
      end
    end

    if (@resource[:bootorder]) ||
       (@resource[:bootmenu]) ||
       (@resource[:bootfirmware]) ||
       (@resource[:bootkernel]) ||
       (@resource[:bootinitrd]) ||
       (@resource[:bootcmdline])
      args << "--boot"
      optionstring = ""
      if @resource[:bootorder]
        optionstring << "#{@resource[:bootorder].join(',')},"
      end
      if @resource[:bootorder]
        if @resource[:bootorder] == :true
          optionstring << "menu=on,"
        else
          optionstring << "menu=off,"
        end
      end
      if @resource[:bootfirmware]
        optionstring << "loader=\"#{@resource[:bootfirmware]}\","
      end
      if @resource[:bootkernel]
        optionstring << "kernel=\"#{@resource[:bootkernel]}\","
      end
      if @resource[:bootinitrd]
        optionstring << "initrd=\"#{@resource[:bootinitrd]}\","
      end
      if @resource[:bootcmdline]
        optionstring << "kernel_args=\"#{@resource[:bootcmdline]}\","
      end
      # strip any trailing ,
      args << optionstring.chomp(',')
    end

    if @resource[:hostdevices]
      debug "Adding host devices to guest"
      Array(@resource[:hostdevices]).each do |device|
        debug "Device: #{device}"
        args << "--host-device" << "#{device}"
      end
    end

    if @resource[:soundhw]
      debug "Adding sound devices to guest"
      Array(@resource[:soundhw]).each do |device|
        debug "Device: #{device}"
        args << "--soundhw" << "#{device}"
      end
    end

    if @resource[:initrdinject]
      if @resource[:installmethod] == :location
        debug "Inird injects: #{@resource[:initrdinject]}"
        args << "--initrd-inject" << @resource[:initrdinject]
      else
        debug "Parameter initrdinject given, but installmethod is not 'location', ignoring"
      end
    end

    if @resource[:extraargs]
      if @resource[:installmethod] == :location
        debug "Extra arguments: #{@resource[:extraargs]}"
        args << "--extra-args" << @resource[:extraargs]
      else
        debug "Parameter extraargs given, but installmethod is not 'location', ignoring"
      end
    end

    if @resource[:virttype]
      case @resource[:virttype]
        when :hvm
          args << "--hvm"
          debug "Using full virtualization"
        when :paravirt
          args << "--paravirt"
          debug "Using paravirtualization"
        when :container
          args << "--container"
          debug "Using container virtualization"
        else fail "No valid virtualization type choosen. Valid values are paravirt, container and hvm (default)"
      end
    end

    if @resource[:hypervisor]
      debug "hypervisor: #{@resource[:hypervisor]}"
      args << "--virt-type" << @resource[:hypervisor]
    end

    if @resource[:ostype]
      debug "OS type: #{@resource[:ostype]}"
      args << "--os-type" << @resource[:ostype]
    end

    if @resource[:osvariant]
      debug "OS variant: #{@resource[:osvariant]}"
      args << "--os-variant" << @resource[:osvariant]
    end

    if @resource[:watchdogmodel]
      debug "Adding watchdog"
      args << "--watchdog"
      tmparg = @resource[:watchdogmodel]
      if @resource[:watchdogaction]
        tmparg << ",action=#{@resource[:watchdogaction]}"
      end
      debug "Watchdog options: #{tmparg}"
      args << tmparg
    end

    if @resource[:vcpus]
      debug "Adding vcpus"
      args << "--vcpus"
      tmparg = @resource[:vcpus].to_s
      if @resource[:maxvcpus]
        tmparg << ",maxvcpus=#{@resource[:maxvcpus]}"
      end
      if @resource[:vcpusockets]
        tmparg << ",sockets=#{@resource[:vcpusockets]}"
      end
      if @resource[:vcpucores]
        tmparg << ",cores=#{@resource[:vcpucores]}"
      end
      if @resource[:vcputhreads]
        tmparg << ",threads=#{@resource[:vcputhreads]}"
      end
      debug "vcpu options: #{tmparg}"
      args << tmparg
    end

    if @resource[:cpumodel]
      debug "Setting cpu features"
      args << "--cpu"
      tmparg = @resource[:cpumodel]
      if @resource[:cpumatch]
        tmparg << ",match=#{@resource[:cpumatch]}"
      end
      if @resource[:cpuvendor]
        tmparg << ",vendor=#{@resource[:cpuvendor]}"
      end
      if @resource[:cpufeatures]
        Array(@resource[:cpufeatures]).each do |feature|
          tmparg << ",#{feature}"
        end
      end
      debug "cpu features: #{tmparg}"
      args << tmparg
    end

    if @resource[:securitytype]
      debug "Configuring guest security"
      args << "--security"
      tmparg = "type=#{@resource[:securitytype]}"
      if @resource[:securitylabel]
        tmparg << ",label=#{@resource[:securitylabel]}"
      end
      if @resource[:securityrelabel]
        tmparg << ",relabel=#{@resource[:securityrelabel]}"
      end
      debug "security options: #{tmparg}"
      args << tmparg
    else
      if @resource[:securitylabel]
        debug "Configuring guest security"
        args << "--security"
        tmparg = "label=#{@resource[:securitylabel]}"
        if @resource[:securityrelabel]
          tmparg << ",relabel=#{@resource[:securityrelabel]}"
        end
        debug "security options: #{tmparg}"
        args << tmparg
      end
    end

    if @resource[:numatune]
      debug "Tuning NUMA"
      args << "--numatune"
      tmparg = "\"#{@resource[:numatune]}\""
      if @resource[:numamode]
        tmparg << ",mode=#{@resource[:numamode]}"
      end
      debug "NUMA options: #{tmparg}"
      args << tmparg
    end

    case @resource[:installmethod]
      when :cdrom
        args << "--cdrom" << @resource[:installmedia]
        debug "Installation method: #{@resource[:installmethod]}; Media: #{@resource[:installmedia]}"
      when :location
        args << "--location" << @resource[:installmedia]
        debug "Installation method: #{@resource[:installmethod]}; Media: #{@resource[:installmedia]}"
      when :pxe
        args << "--pxe"
        debug "Installation method: #{@resource[:installmethod]}"
      when :import
        args << "--import"
        debug "Installation method: #{@resource[:installmethod]}"
      else fail "No valid installation method selected. Valid values are cdrom, location, pxe and import (default)"
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
    # do a normal undefine on the guest vm
    if exists?
      remove
    end

    # remove all diskimages
    # only purge disks where source="path=..." and device=disk
    # pool=/vol= as well as device=floppy/device=cdrom
    # have probably been created independently from the guest
    # and should remain untouched by this operation
    if @resource[:disks]
      diskimagefiles(@resource[:disks]).each do |file|
        if File.exists?(file)
          debug "Deleting disk image #{file}"
          File.delete(file)
        end
      end
    end
  end

  def ram
    get_domain_xml 
    @domain.elements["memory"].text.to_i / 1024
  end

  def ram=(value)
    @domain.elements["memory"].text = value.to_i * 1024
    @domain.elements["currentMemory"].text = value.to_i * 1024
    redefine_domain
  end

  def arch
    get_domain_xml 
    @domain.elements["os/type"].attributes["arch"]
  end

  def arch=(value)
    @domain.elements["os/type"].add_attribute("arch",value)
    redefine_domain
  end

  def maxvcpus
    get_domain_xml 
    @domain.elements["vcpu"].text.to_i
  end

  def maxvcpus=(value)
    @domain.elements["vcpu"].text = value
    redefine_domain
  end

  def vcpus
    get_domain_xml 
    if @domain.elements["vcpu"].attributes["current"]
      @domain.elements["vcpu"].attributes["current"]
    else
      maxvcpus
    end
  end

  def vcpus=(value)
    @domain.elements["vcpu"].add_attribute('current',value)
    redefine_domain
  end

  def vcpusockets
    get_domain_xml 
    if @domain.elements["cpu/topology"]
      @domain.elements["cpu/topology"].attributes["sockets"].to_i
    end
  end

  def vcpusockets=(value)
    if @domain.elements["cpu/topology"]
      @domain.elements["cpu/topology"].add_attribute("sockets",value)
    else
      @domain.elements["cpu"].add_element("topology", { "sockets" => value })
    end
    redefine_domain
  end

  def vcpucores
    get_domain_xml 
    if @domain.elements["cpu/topology"]
      @domain.elements["cpu/topology"].attributes["cores"].to_i
    end
  end

  def vcpucores=(value)
    if @domain.elements["cpu/topology"]
      @domain.elements["cpu/topology"].add_attribute("cores",value)
    else
      @domain.elements["cpu"].add_element("topology", { "cores" => value })
    end
    redefine_domain
  end

  def vcputhreads
    get_domain_xml 
    if @domain.elements["cpu/topology"]
      @domain.elements["cpu/topology"].attributes["threads"].to_i
    end
  end

  def vcputhreads=(value)
    if @domain.elements["cpu/topology"]
      @domain.elements["cpu/topology"].add_attribute("threads",value)
    else
      @domain.elements["cpu"].add_element("topology", { "threads" => value })
    end
    redefine_domain
  end

  def cpuset
    get_domain_xml 
    @domain.elements["vcpu"].attributes["cpuset"]
  end

  def cpuset=(value)
    @domain.elements["vcpu"].add_attribute("cpuset",value)
    redefine_domain
  end

  def cpumodel
    get_domain_xml 
    @domain.elements["cpu/model"].text
  end

  def cpumodel=(value)
    @domain.elements["cpu/model"].text = value
    redefine_domain
  end

  def cpuvendor
    get_domain_xml 
    @domain.elements["cpu/vendor"].text
  end

  def cpuvendor=(value)
    @domain.elements["cpu/vendor"].text = value
    redefine_domain
  end

  def cpumatch
    get_domain_xml 
    @domain.elements["cpu"].attributes["match"]
  end

  def cpumatch=(value)
    @domain.elements["cpu"].add_attribute("match",value)
    redefine_domain
  end

  def description
    get_domain_xml 
    @domain.elements["description"].text
  end

  def description=(value)
    @domain.elements["description"].text = value
    redefine_domain
  end

  def noacpi
    get_domain_xml 
    @domain.elements["features/acpi"] ? :false : :true
  end

  def noacpi=(value)
    if value == :true
      @domain.delete_element("features/acpi")
      redefine_domain
    else
      if !@domain.elements["features/acpi"]
        @domain.elements["features"].add_element("acpi")
        redefine_domain
      end
    end
  end

  def noapic
    get_domain_xml 
    @domain.elements["features/apic"] ? :false : :true
  end

  def noapic=(value)
    if value == :true
      @domain.delete_element("features/apic")
      redefine_domain
    else
      if !@domain.elements["features/apic"]
        @domain.elements["features"].add_element("apic")
        redefine_domain
      end
    end
  end

  def bootorder
    get_domain_xml 
    order = []
    @domain.elements.each("os/boot") do |bootdev|
      order << bootdev.attributes["dev"]
    end
    order
  end

  def bootorder=(value)
    # the boot order is absolute, so the existing
    # boot order is deleted before the new one is
    # defined
    @domain.elements.each("os/boot") do |dev|
      @domain.elements["os"].delete_element("boot")
    end

    Array(value).each do |dev|
      @domain.elements["os"].add_element("boot",{ "dev" => dev })
    end
    redefine_domain
  end

  def bootmenu
    get_domain_xml 
    if @domain.elements["os/bootmenu"]
      value = @domain.elements["os/bootmenu"].attributes["enable"]
      if value == "yes"
        :true
      else
        :false
      end
    end
  end

  def bootmenu=(value)
    if value == :true
      menu = "yes"
    else
      menu = "no"
    end

    if @domain.elements["os/bootmenu"]
      @domain.elements["os/bootmenu"].add_attribute("enable",menu)
    else
      @domain.elements["os"].add_element("bootmenu", { "enable" => menu })
    end
    redefine_domain
  end

  def bootfirmware
    get_domain_xml 
    if @domain.elements["os/loader"]
      @domain.elements["os/loader"].text
    end
  end

  def bootfirmware=(value)
    if !@domain.elements["os/loader"]
      @domain.elements["os"].add_element("loader")
    end
    @domain.elements["os/loader"].text = value
    redefine_domain
  end

  def bootkernel
    get_domain_xml 
    if @domain.elements["os/kernel"]
      @domain.elements["os/kernel"].text
    end
  end

  def bootkernel=(value)
    if !@domain.elements["os/kernel"]
      @domain.elements["os"].add_element("kernel")
    end
    @domain.elements["os/kernel"].text = value
    redefine_domain
  end

  def bootinitrd
    get_domain_xml 
    if @domain.elements["os/initrd"]
      @domain.elements["os/initrd"].text
    end
  end

  def bootinitrd=(value)
    if !@domain.elements["os/initrd"]
      @domain.elements["os"].add_element("initrd")
    end
    @domain.elements["os/initrd"].text = value
    redefine_domain
  end

  def bootcmdline
    get_domain_xml 
    if @domain.elements["os/cmdline"]
      @domain.elements["os/cmdline"].text
    end
  end

  def bootcmdline=(value)
    if !@domain.elements["os/cmdline"]
      @domain.elements["os"].add_element("cmdline")
    end
    @domain.elements["os/cmdline"].text = value
    redefine_domain
  end

private
  def virtinstall_version
    @virtinstall_version ||= virtinstall("--version")
  end

  def virsh_version
    @virsh_version ||= virsh("--version")
  end

  def hypervisor
    case @resource[:hypervisor]
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

  def redefine_domain
    conn = Libvirt::open('qemu:///system')
    conn.define_domain_xml(@domain.to_s)
    conn.close
  end

  def get_domain_xml
    if !@domain
      xmldoc = Document.new(exec { @guest.xml_desc 3 } )
      @domain = xmldoc.root
    end
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

    result = []
    options.each do |option|
      result << "#{prefix}"
      string = identifier ? "#{option[identifier]}," : ""
      option.each do |key,value|
        if !(identifier == key)
          string << "#{key}=#{value},"
        end
      end
      string.chomp!(",")
      result << string
    end
    return result
  end

  # disks: array of hashes [ { key = vaules, key = values }, ... ]
  #   representing the disks of a guest vm
  # returns: array of filenames where source == "path=..." and
  #   device=disk
  def diskimagefiles(disks)

    result = []
 
    disks = disks.kind_of?(Array) ? disks : [disks]
    disks.each do |disk|
      if !disk.has_key?("source")
        fail "Missing source parameter for guest disk"
      end
  
      source = disk["source"].split('=')
      if source[0] == "path"
        if (!disk.has_key?("device")) || (disk["device"] == "disk")
          result << source[1]
        end
      end
    end
    return result
  end
end

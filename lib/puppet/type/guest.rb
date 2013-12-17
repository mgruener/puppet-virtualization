Puppet::Type.newtype(:guest) do
  @doc = "TODO"

  # TODO: features
  feature :createguest,
    "Create a VM guest."

  def munge_boolean(value)
    case value
    when true, "true", :true
      :true
    when false, "false", :false
      :false
    else
      fail("munge_boolean only takes booleans")
    end
  end

  # basic type attributes
  newproperty(:ensure) do
    desc "TODO"
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.remove
    end
    newvalue(:purged) do
      provider.purge
    end

    defaultto :present

    def retrieve
      provider.status
    end
  end

  newparam(:name, :namevar => true) do
    desc "The guest's name."
  end

  # general options
  newproperty(:ram) do
    desc "TODO"

    defaultto 512
  end

  newproperty(:arch) do
    desc "TODO"
  end

  newparam(:machine) do
    desc "TODO"
  end

  newparam(:uuid) do
    desc "TODO"
  end

  newproperty(:vcpus) do
    desc "TODO"
  end

  newproperty(:maxvcpus) do
    desc "TODO"
  end

  newproperty(:vcpusockets) do
    desc "TODO"
  end

  newproperty(:vcpucores) do
    desc "TODO"
  end

  newproperty(:vcputhreads) do
    desc "TODO"
  end

  newproperty(:cpuset) do
    desc "TODO"
  end

  newparam(:numatune) do
    desc "TODO"
  end

  newparam(:numamode) do
    desc "TODO"
  end

  newproperty(:cpumodel) do
    desc "TODO"
  end

  newparam(:cpufeatures) do
    desc "TODO"
  end

  newproperty(:cpumatch) do
    desc "TODO"
  end

  newproperty(:cpuvendor) do
    desc "TODO"
  end

  newproperty(:description) do
    desc "TODO"
  end

  newparam(:securitytype) do
    desc "TODO"
  end

  newparam(:securitylabel) do
    desc "TODO"
  end

  newparam(:securityrelabel, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "TODO"
  end

  # installation options
  newparam(:installmethod) do
    desc "TODO"
    newvalues(:cdrom, :location, :pxe, :import)

    defaultto :import
  end

  newparam(:installmedia) do
    desc "TODO"
  end

  newparam(:init) do
    desc "TODO"
  end

  newparam(:livecd, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "TODO"
    defaultto false
  end

  newparam(:extraargs) do
    desc "TODO"
  end

  newparam(:initrdinject) do
    desc "TODO"
  end

  newparam(:ostype) do
    desc "TODO"
  end

  newparam(:osvariant) do
    desc "TODO"
  end

  newproperty(:bootorder, :parent => Puppet::Property::OrderedList) do
    desc "TODO"
  end

  newproperty(:bootmenut, :boolean => true) do
    desc "TODO"

    newvalue(:true)
    newvalue(:false)

    defaultto :false

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newproperty(:bootfirmware) do
    desc "TODO"
  end

  newproperty(:bootkernel) do
    desc "TODO"
  end

  newproperty(:bootinitrd) do
    desc "TODO"
  end

  newproperty(:bootcmdline) do
    desc "TODO"
  end

  # storage options
  newparam(:disks) do
    desc "TODO"
  end

  newparam(:filesystems) do
    desc "TODO"
  end

  newparam(:nodisks, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "TODO"
    defaultto false
  end

  # networking configuration
  newparam(:networks) do
    desc "TODO"
  end

  newparam(:nonetworks, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "TODO"
    defaultto false
  end

  # graphics configuration
  newparam(:graphics) do
    desc "TODO"
  end

  # virtualization type options
  newparam(:virttype) do
    desc "TODO"
    newvalues(:hvm, :paravirt, :container)

    defaultto :hvm
  end

  newparam(:hypervisor) do
    desc "TODO"
  end

  newproperty(:noapic, :boolean => true) do
    desc "TODO"

    newvalue(:true)
    newvalue(:false)

    defaultto :false

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newproperty(:noacpi, :boolean => true) do
    desc "TODO"

    newvalue(:true)
    newvalue(:false)

    defaultto :false

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  # device options
  newparam(:controllers) do
    desc "TODO"
  end

  newparam(:hostdevices) do
    desc "TODO"
  end

  newparam(:soundhw) do
    desc "TODO"
  end

  newparam(:watchdogmodel) do
    desc "TODO"

    defaultto :default
  end

  newparam(:watchdogaction) do
    desc "TODO"
  end

  newparam(:serialports) do
    desc "TODO"
  end

  newparam(:parallelports) do
    desc "TODO"
  end

  newparam(:channels) do
    desc "TODO"
  end

  newparam(:consoles) do
    desc "TODO"
  end

  newparam(:video) do
    desc "TODO"
  end

  newparam(:smartcards) do
    desc "TODO"
  end

  newparam(:redirdevs) do
    desc "TODO"
  end

  newparam(:memballoon) do
    desc "TODO"
  end
end

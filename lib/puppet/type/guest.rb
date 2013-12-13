Puppet::Type.newtype(:guest) do
  @doc = "TODO"

  # TODO: features
  feature :createguest,
    "Create a VM guest."

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

  newparam(:datastore) do
    desc "The global datastore path for guest images"
  
    defaultto "/var/lib/libvirt/images"
  end

  newparam(:gueststore) do
    desc "Directory below the datastore to store this guests files"

    defaultto "#{@resource[:datastore]}/#{@resource[:name]}"
  end

  # general options
  newparam(:memory) do
    desc "TODO"

    defaultto 512
  end

  newparam(:arch) do
    desc "TODO"
  end

  newparam(:machine) do
    desc "TODO"
  end

  newparam(:uuid) do
    desc "TODO"
  end

  newparam(:vcpus) do
    desc "TODO"
  end

  newparam(:cpuset) do
    desc "TODO"
  end

  newparam(:numatune) do
    desc "TODO"
  end

  newparam(:cpu) do
    desc "TODO"
  end

  newparam(:description) do
    desc "TODO"
  end

  newparam(:security) do
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

  newparam(:livecd) do
    desc "TODO"
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

  newparam(:boot) do
    desc "TODO"
  end

  # storage options
  newparam(:disks) do
    desc "TODO"
  end

  newparam(:filesystems) do
    desc "TODO"
  end

  newparam(:nodisks) do
    desc "TODO"
  end

  # networking configuration
  newparam(:networks) do
    desc "TODO"
  end

  newparam(:nonetworks) do
    desc "TODO"
  end

  # graphics configuration
  newparam(:graphics) do
    desc "TODO"
  end

  # virtualization type options
  newparam(:hvm) do
    desc "TODO"
  end

  newparam(:paravirt) do
    desc "TODO"
  end

  newparam(:container) do
    desc "TODO"
  end

  newparam(:virttype) do
    desc "TODO"
  end

  newparam(:noapic) do
    desc "TODO"
  end

  newparam(:noacpi) do
    desc "TODO"
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

  newparam(:watchdog) do
    desc "TODO"
  end

  newparam(:parallel) do
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

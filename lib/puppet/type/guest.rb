Puppet::Type.newtype(:guest) do
  @doc = "TODO"

  # TODO: features

  # basic type attributes
  ensurable do
    desc "TODO"
    newvalue(:present) do
    end
    newvalue(:absent) do
    end
    newvalue(:purged) do
    end
  end

  newparam(:name, :namevar => true) do
    desc "The guest's name."
  end

  # general options
  newparam(:memory) do
    desc "TODO"
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
  newparam(:cdrom) do
    desc "TODO"
  end

  newparam(:location) do
    desc "TODO"
  end

  newparam(:pxe) do
    desc "TODO"
  end

  newparam(:import) do
    desc "TODO"
  end

  newparam(:init) do
    desc "TODO"
  end

  newparam(:livecd) do
    desc "TODO"
  end

  newparam(:nodisks) do
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

  newparam(:filesystem) do
    desc "TODO"
  end

  newparam(:nodisks) do
    desc "TODO"
  end

  # networking configuration
  newparam(:network) do
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
  newparam(:hostdevice) do
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

  newparam(:serial) do
    desc "TODO"
  end

  newparam(:channel) do
    desc "TODO"
  end

  newparam(:console) do
    desc "TODO"
  end

  newparam(:video) do
    desc "TODO"
  end

  newparam(:smartcard) do
    desc "TODO"
  end
end

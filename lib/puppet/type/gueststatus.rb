Puppet::Type.newtype(:gueststatus) do
  @doc = "TODO"

  # TODO: features

  newparam(:name, :namevar => true) do
    desc "The guest's name."
  end

  newproperty(:ensure) do
    desc "TODO"
    newvalue(:running) do
    end
    newvalue(:stopped) do
    end
    newvalue(:suspended) do
    end

    defaultto :running

    def retrieve
    end
  end

  autorequire(:guest) do
    @parameters[:name]
  end
    
end

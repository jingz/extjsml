class ExtPaging < ExtNode
  def initialize(config, parent)
    @default_config = {
      start: 0,
      limit: 20,
      displayInfo: true,
      dock: "bottom",
      displayMsg: "Displaying {0} - {1} of {2}"
    }
    super('pagingtoolbar', config, parent)
  end
end

class Page
  constructor: (options = {}) ->
    @location = options.location || location
    @timestamp = options.timestampe || +new Date

module.exports = Page

class Membership
  constructor: (options) ->
    for name, value of options
      @[name] = value

module.exports = Membership

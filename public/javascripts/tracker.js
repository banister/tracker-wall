var Tracker = {};

Tracker.Story = function(options) {
  function constructor(options) {
    var name, value;

    for (name in options) {
      value = options[name];
      this[name] = value;
    }

    return this;
  }

  constructor.call(this, options);

  return this;
};

Tracker.Story.BUG = "bug";
Tracker.Story.CHORE = "chore";
Tracker.Story.FEATURE = "feature";

Tracker.Story.prototype.bug = function() {
  return this.story_type === this.constructor.BUG;
};

Tracker.Story.prototype.chore = function() {
  return this.story_type === this.constructor.CHORE;
};

Tracker.Story.prototype.feature = function() {
  return this.story_type === this.constructor.FEATURE;
};

Tracker.Story.prototype.type = function() {
  var blockedLabel = _.find(this.labels, function(label) {
    return label.name === "old-on-call";
  });

  return blockedLabel ? "on-call" : this.story_type;
};

Tracker.Iteration = function(options) {
  function constructor(options) {
    var name, storyOptions, value, _i, _len;
    for (name in options) {
      value = options[name];
      if (name === "stories") {
        this[name] = [];
        for (_i = 0, _len = value.length; _i < _len; _i++) {
          storyOptions = value[_i];
          this[name].push(new Tracker.Story(storyOptions));
        }
      } else {
        this[name] = value;
      }
    }

    return this;
  }

  constructor.call(this, options);

  return this;
};

Tracker.Iteration.prototype.reduce = function(block) {
  return _.filter(this.stories, function(story) {
    return block.call(this, story);
  });
};

Tracker.Iteration.prototype.chores = function() {
  return this.reduce(function(story) {
    return story.chore();
  });
};

Tracker.Iteration.prototype.bugs = function() {
  return this.reduce(function(story) {
    return story.bug();
  });
};

Tracker.Iteration.prototype.features = function() {
  return this.reduce(function(story) {
    return story.feature();
  });
};

Tracker.Iteration.prototype.points = function() {
  return _.reduce(this.features(), function(count, story) {
    return count + story.estimate;
  }, 0);
}


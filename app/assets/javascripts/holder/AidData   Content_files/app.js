(function() {
  $(function() {
    return $('.dropdown-toggle').dropdown();
  });

  Array.prototype.getUnique = function() {
    var a, i, item, u, _i, _len;

    u = {};
    a = [];
    for (i = _i = 0, _len = this.length; _i < _len; i = ++_i) {
      item = this[i];
      if (u.hasOwnProperty(item)) {
        continue;
      }
      a.push(item);
      u[item] = 1;
    }
    return a;
  };

  this.nice_money = function(amount) {
    if (typeof d3 !== "undefined" && d3 !== null) {
      if (1000 >= amount) {
        return "" + (d3.format("0,r")(d3.round(amount, 0)));
      } else if ((1000000 > amount && amount >= 1000)) {
        return "" + (d3.round(amount / 1000, 0)) + " K";
      } else if ((1000000000 > amount && amount >= 1000000)) {
        return "" + (d3.round(amount / 1000000, 1)) + " M";
      } else if (amount >= 1000000000) {
        return "" + (d3.format("0,r")(d3.round(amount / 1000000000, 2))) + " B";
      } else {
        return amount;
      }
    } else {
      console.log("nice_money requires D3");
      return amount;
    }
  };

  String.prototype.pluralize = function(count, plural) {
    if (count === 1) {
      return this;
    } else {
      if (!plural) {
        plural = this + 's';
      }
      return plural;
    }
  };

  this.remove_fields = function(link) {
    if (confirm("Are you sure?")) {
      this.changed = true;
      $(link).prev("input[type=hidden]").val("1");
      return $(link).closest(".fields").slideUp();
    }
  };

  this.add_fields = function(link, association, content) {
    var new_content, new_id, regexp;

    this.changed = true;
    new_id = new Date().getTime();
    regexp = new RegExp("new_" + association, "g");
    new_content = $(content.replace(regexp, new_id));
    $(link).parent().after(new_content.hide());
    return new_content.slideDown();
  };

}).call(this);

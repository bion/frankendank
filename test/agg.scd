(
  var parent_group = Group.new,
    source_group, in_group, filt_group, eq_group, out_group;

  [parent_group, source_group, in_group, filt_group, eq_group, out_group].doAdjacentPairs {|a, b|
    b = Group.new(a, \addAfter);
  };



)

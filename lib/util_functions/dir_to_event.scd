// dirPath must be an absolute path
~dirToEvent = { |dirPath|
  var matchPaths = (dirPath ++ "/*").pathMatch.takeThese { |path|
    path.basename.contains("\.scd").not;
  };
  var event = ();

  matchPaths.do {|path|
    var name = path.basename.replace("\.scd", "");
    var value = path.load;

    event[name.asSymbol] = value;
  };

  event;
};

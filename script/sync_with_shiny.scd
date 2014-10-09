var localPath = "../nrt_renders".resolveRelative;
var remotePath = "shiny.local:/Users/bion/Public/music_production/idea_1";
var rsyncCommand = "rsync -a --delete --rsh=ssh % %".format(localPath, remotePath);

if (rsyncCommand.systemCmd != 0) {
  Error("Failed to sync with shiny!").throw;
} {
  "Synced with shiny".postln;
};

"";
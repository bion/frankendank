(
"SC_EXTENSIONS_PATH".setenv(Platform.userExtensionDir);
"SC_HER_EXTENSIONS_PATH".setenv(Platform.userExtensionDir ++ "/her");
"SC_HER_LIB_PATH".setenv("../lib".resolveRelative);
"./link_her_lib_files.sh".resolveRelative.unixCmdGetStdOut;
)

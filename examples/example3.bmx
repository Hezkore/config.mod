' Load application arguments

SuperStrict

Framework brl.standardio
Import hez.config

Local myConfig:TConfig = New TConfig

' Register a normal variable
myConfig.Register("Some test variable", "general", "test", "g_test", "My default value")

' Register a variable that does not get saved to the config file
myConfig.Register("Enable awesome mode", "general", "awesome", "awesome", "My default value", False)

' LoadArgs will load any command arguments your application is started with
' You can also manually override the arguments
myConfig.LoadArgs(["-g_test", "Hello World", "-awesome"]) ' Override (leave blank for AppArgs)
' Omitting a value will set the variable to True

Print( myConfig.GetString("general", "test") )
Print( "Awesome mode: " + myConfig.GetString("general", "awesome") )
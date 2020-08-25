' Load and write configuration file

SuperStrict

Framework brl.standardio
Import hez.config

Local myConfig:TConfig = New TConfig

' This sets where any changes should be written to
myConfig.SetOutPath("test.ini")

' This loads an existing configuration file
myConfig.Load("test.ini")

' You should still register your variables
myConfig.Register("Some test variable", "general/test", "g_test", "My default value")

Print(myConfig.GetString("general/test"))

' Setting a value will update the configuration file
myConfig.Set("general/test", MilliSecs())

Print(myConfig.GetString("general/test"))
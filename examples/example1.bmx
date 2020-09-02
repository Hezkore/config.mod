' Registering a configuration variable
' Get and Set value

SuperStrict

Framework brl.standardio
Import hez.config

Local myConfig:TConfig = New TConfig

myConfig.Register("Some test variable", "general", "test", "g_test", "My default value")

' You can also use GetInt, GetFloat and GetBool
Print( myConfig.GetString("general", "test") )

myConfig.Set("general", "test", "My new value")

Print( myConfig.GetString("general", "test") )
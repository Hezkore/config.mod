SuperStrict

Framework brl.standardio
Import hez.config

Local myConfig:TConfig = New TConfig

myConfig.Register("Some test variable", "general/test", "gtest", "My default value")

Print( myConfig.GetString("general/test") )

myConfig.Set("general/test", "My new value")

Print( myConfig.GetString("general/test") )
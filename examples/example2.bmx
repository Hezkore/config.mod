' Load and write configuration file

SuperStrict

Framework brl.standardio
Import hez.config

Local myConfig:TConfig = New TConfig

' Always register your variables before loading or saving
myConfig.Register("Some test variable", "general", "time", "g_time", "My default value")
myConfig.Register("Hello world test", "general", "hello", "g_hello", "Bye")

' Set the default path for Load and Apply
myConfig.Path = "test.ini"

' Load default path configuration file
myConfig.Load() ' Same as Load("test.ini")

' Print what we got from the configuration file
Print(myConfig.GetString("general", "time"))
Print(myConfig.GetString("general", "hello"))

' Change a test variable
myConfig.Set("general", "time", MilliSecs())
Print(myConfig.GetString("general", "time"))

' Save our changes to default configuration file
myConfig.Apply() ' Same as Apply("test.ini")
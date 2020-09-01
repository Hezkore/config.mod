SuperStrict

Framework brl.standardio

rem
bbdoc: Configuration
about:
Load configuration files
endrem
Module hez.config

ModuleInfo "Author: Rob C."
ModuleInfo "License: MIT"
ModuleInfo "Copyright: 2020 Rob C."

' Dependencies
Import brl.standardio
Import brl.map
Import brl.stringbuilder
Import brl.objectList
Import brl.collections

Type TConfig
	
	Const NoCategory:String = "default"
	Global Instances:TObjectList = New TObjectList
	
	Field Path:String
	Field Variables:TStringMap = New TStringMap
	Field VariablesArgNames:TStringMap = New TStringMap
	
	Method New()
		Self.Instances.AddLast(Self)
	EndMethod
	
	Method Load(path:String = Null)
		If Not path path = Self.Path
		Local stream:TStream = OpenStream(path)
		If Not stream Return
		
		Local line:String
		Local category:String = Self.NoCategory
		Local lineSplit:String[]
		Local key:String
		Local value:String
		Local lastVariable:TConfigVariable
		While Not EOF(stream)
			line = stream.ReadLine().Trim()
			
			If line.StartsWith("[") Then
				category = line[1..]
				If category.EndsWith("]") ..
					category = category[..category.Length - 1]
			Else
				If line.Contains("=") Then
					lineSplit = line.Split("=")
					key = lineSplit[0].Trim()
					value = lineSplit[1].Trim()
				Else
					key = line.Trim()
				EndIf
				If Not key Continue
				lastVariable = Self.Get(category + "/" + key)
				If lastVariable Then lastVariable.Value = value
			EndIf
		Wend
		
		stream.Close()
	EndMethod
	
	Method Apply(path:String = Null)
		If Not path path = Self.Path
		Local stream:TStream = WriteStream(path)
		If Not stream Return
		
		Local category:String
		Local keySplit:String[]
		Local key:String
		Local value:String
		For Local rawKey:String = EachIn Self.Variables.Keys()
			If rawKey.Contains("/") Then
				keySplit = rawKey.Split("/")
				category = keySplit[0]
				key = keySplit[1]
			Else
				category = Self.NoCategory
				key = rawKey
			EndIf
			value = TConfigVariable(Self.Variables.ValueForKey(rawKey)).Value
			
			Print "["+category+"]"+key + "="+value
		Next
		
		stream.Close()
	EndMethod
	
	Method Register:TConfigVariable(description:String, path:String, argument:String, value:String = "")
		Local variable:TConfigVariable = New TConfigVariable(..
			description, path, argument, value)
		Self.Variables.Insert( path, variable )
		Self.VariablesArgNames.Insert(argument, variable)
		Return variable
	EndMethod
	
	Method Set(path:String, value:String)
		Self.Get(path).Value = value
	EndMethod
	
	Method Get:TConfigVariable(path:String)
		Return TConfigVariable(Self.Variables.ValueForKey( path ))
	EndMethod
	
	Method GetByArg:TConfigVariable(path:String)
		Return TConfigVariable(Self.VariablesArgNames.ValueForKey( path ))
	EndMethod
	
	Method GetString:String(path:String)
		Return Self.Get(path).Value
	EndMethod
	
	Method GetInt:Int(path:String)
		Return Int(Self.Get(path).Value)
	EndMethod
	
	Method GetFloat:Float(path:String)
		Return Float(Self.Get(path).Value)
	EndMethod
	
	Method GetBool:Int(path:String)
		Local value:String = Self.Get(path).Value
		If Int(value) > 0 Or value.ToLower() = "true" ..
			Return True
		Return False
	EndMethod
EndType

Type TConfigVariable
	
	Field Value:String
	Field Path:String
	Field Description:String
	Field Argument:String
	
	Method New(description:String, path:String, argument:String, value:String)
		Self.Description = description
		Self.Path = path
		Self.Argument = argument
		Self.Value = value
	EndMethod
EndType
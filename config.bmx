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
	
	Global Instances:TObjectList = New TObjectList
	
	Field OutPath:String
	Field Stream:TStream
	Field Variables:TStringMap = New TStringMap
	Field VariablesArgNames:TStringMap = New TStringMap
	
	Method New()
		Self.Instances.AddLast(Self)
	EndMethod
	
	Method SetOutPath(path:String)
		Self.OutPath = path
	EndMethod
	
	Method Load(path:String)
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
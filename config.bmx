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
	
	Field Variables:TStringMap = New TStringMap
	
	Method New()
		Self.Instances.AddLast(Self)
	EndMethod
	
	Method Register(description:String, path:String, argument:String, value:String)
		Self.Variables.Insert( path, New TConfigVariable(..
			description, path, argument, value) )
	EndMethod
	
	Method Set(path:String, value:String)
		Self.Get(path).Value = value
	EndMethod
	
	Method Get:TConfigVariable(path:String)
		Return TConfigVariable(Self.Variables.ValueForKey( path ))
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
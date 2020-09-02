SuperStrict

Framework brl.standardio
Import brl.linkedlist

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
	Field Categories:TStringMap = New TStringMap
	Field VariablesArgNames:TStringMap = New TStringMap
	
	Method New()
		Self.Instances.AddLast(Self)
	EndMethod
	
	Method Load(path:String = Null)
		rem
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
		endrem
	EndMethod
	
	Method Apply(path:String = Null)
		rem
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
			' TODO: There's got to be a way to get the key and value at the same time
			value = TConfigVariable(Self.Variables.ValueForKey(rawKey)).Value
			
			'Print "["+category+"]"+key + "="+value
		Next
		
		stream.Close()
		endrem
	EndMethod
	
	Method Register:TConfigVariable(description:String, category:String, variable:String, argument:String, value:String = "")
		Local cat:TConfigCategory = Self.Get(category)
		If Not cat Then
			cat = New TConfigCategory(category)
			Self.Categories.Insert(category,cat)
		EndIf
		
		Local vari:TConfigVariable = New TConfigVariable(..
			description, category, variable, argument, value)
		
		cat.Variables.Insert(variable, vari)
		Self.VariablesArgNames.Insert(argument, vari)
		Return vari
	EndMethod
	
	Method Set(category:String, variable:String, value:String)
		Self.Get(category).Get(variable).Value = value
	EndMethod
	
	Method Get:TConfigCategory(category:String)
		Return TConfigCategory(Self.Categories.ValueForKey(category))
	EndMethod
	
	Method GetByArg:TConfigVariable(arg:String)
		Return TConfigVariable(Self.VariablesArgNames.ValueForKey(arg))
	EndMethod
	
	Method GetString:String(category:String, variable:String)
		Return Self.Get(category).Get(variable).Value
	EndMethod
	
	Method GetInt:Int(category:String, variable:String)
		Return Int(Self.Get(category).Get(variable).Value)
	EndMethod
	
	Method GetFloat:Float(category:String, variable:String)
		Return Float(Self.Get(category).Get(variable).Value)
	EndMethod
	
	Method GetBool:Int(category:String, variable:String)
		Local value:String = Self.Get(category).Get(variable).Value
		If Int(value) > 0 Or value.ToLower() = "true" ..
			Return True
		Return False
	EndMethod
EndType

Type TConfigCategory
	
	Field Name:String
	Field Variables:TStringMap = New TStringMap
	
	Method New(name:String)
		Self.Name = name
	EndMethod
	
	Method Get:TConfigVariable(variable:String)
		Return TConfigVariable(Self.Variables.ValueForKey(variable))
	EndMethod
EndType

Type TConfigVariable
	
	Field Description:String
	Field Category:String
	Field Name:String
	Field Argument:String
	Field Value:String
	
	Method New(description:String, category:String, name:String, argument:String, value:String)
		Self.Description = description
		Self.Category = category
		Self.Name = name
		Self.Argument = argument
		Self.Value = value
	EndMethod
EndType
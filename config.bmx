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
	
	Field Path:String
	Field Categories:TStringMap = New TStringMap
	Field VariablesArgNames:TStringMap = New TStringMap
	Field LastCategory:TConfigCategory
	Field LastVariable:TConfigVariable
	Field LastByArgVariable:TConfigVariable
	
	Method Load(path:String = Null)
		If Not path path = Self.Path
		Local stream:TStream = OpenStream(path, True, False)
		If Not stream Return
		
		Local line:String
		Local categoryName:String
		Local category:TConfigCategory
		Local lineSplit:String[]
		Local variableName:String
		Local variable:TConfigVariable
		Local variableValue:String
		
		While Not EOF(stream)
			line = stream.ReadLine().Trim()
			If line.StartsWith(";") Continue ' Commend
			
			If line.StartsWith("[") Then
				categoryName = line[1..]
				If categoryName.EndsWith("]") ..
					categoryName = categoryName[..categoryName.Length - 1]
				category = Self.Get(categoryName)
			Else
				If Not category Continue
				If line.Contains("=") Then
					lineSplit = line.Split("=")
					variableName = lineSplit[0].Trim()
					variableValue = lineSplit[1].Trim()
				Else
					variableName = line.Trim()
				EndIf
				If Not variableName Continue
				variable = category.Get(variableName)
				If Not variable Continue
				variable.Value = variableValue
			EndIf
		Wend
		
		stream.Close()
	EndMethod
	
	Method Apply(path:String = Null)
		If Not path path = Self.Path
		Local stream:TStream = WriteStream(path)
		If Not stream Return
		
		Local categoryName:String
		Local category:TConfigCategory
		Local variableName:String
		Local variable:TConfigVariable
		
		For categoryName = EachIn Self.Categories.Keys()
			category = Self.Get(categoryName)
			stream.WriteLine("[" + category.Name + "]")
			For variableName = EachIn category.Variables.Keys()
				variable = category.Get(variableName)
				stream.WriteLine(variable.Name + "=" + variable.Value)
			Next
		Next
		
		stream.Close()
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
	
	Method SetCache(category:String, variable:String)
		If Not Self.LastCategory Or Self.LastCategory.Name <> category Then
			Self.LastCategory = TConfigCategory(Self.Categories.ValueForKey(category))
		EndIf
		If Not Self.LastVariable Or Self.LastVariable.Name <> variable Then
			Self.LastVariable = Self.LastCategory.Get(variable)
		EndIf
	EndMethod
	
	Method SetCache(category:String)
		If Not Self.LastCategory Or Self.LastCategory.Name <> category Then
			Self.LastCategory = TConfigCategory(Self.Categories.ValueForKey(category))
		EndIf
	EndMethod
	
	Method Set(category:String, variable:String, value:String)
		Self.SetCache(category, variable)
		Self.LastVariable.Value = value
	EndMethod
	
	Method Get:TConfigCategory(category:String)
		Self.SetCache(category)
		Return Self.LastCategory
	EndMethod
	
	Method GetByArg:TConfigVariable(arg:String)
		If Not Self.LastByArgVariable Or Self.LastByArgVariable.Argument <> arg Then
			Self.LastByArgVariable = TConfigVariable(Self.VariablesArgNames.ValueForKey(arg))
		EndIf
		Return Self.LastByArgVariable
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
	Field LastVariable:TConfigVariable
	
	Method New(name:String)
		Self.Name = name
	EndMethod
	
	Method Get:TConfigVariable(variable:String)
		If Not Self.LastVariable Or Self.LastVariable.Name <> variable Then
			Self.LastVariable = TConfigVariable(Self.Variables.ValueForKey(variable))
		EndIf
		Return Self.LastVariable
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
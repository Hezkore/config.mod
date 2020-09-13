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
	Field OnWarning(message:String) = OnWarningDefault
	
	Function OnWarningDefault(message:String)
		Print(message)
	EndFunction
	
	Method Load:Int(path:String = Null)
		If Not path path = Self.Path
		If Not path Return False
		
		Local stream:TStream = OpenStream(path, True, False)
		If Not stream Then
			Self.OnWarning("Unable to load ~q"+path+"~q")
			Return False
		EndIf
		
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
		Return True
	EndMethod
	
	Method LoadArgs(args:String[] = [])
		If Not args args = AppArgs[1..] ' Strip dir
		If Not args Return
		
		Local lastVariable:TConfigVariable
		For Local arg:String = EachIn args
			If arg.StartsWith("-") Then
				lastVariable = Self.GetByArg(arg[1..])
				If lastVariable lastVariable.Value = True
			ElseIf lastVariable
				lastVariable.value = arg
			EndIf
		Next
	EndMethod
	
	Method Apply:Int(path:String = Null)
		If Not path path = Self.Path
		Local stream:TStream = WriteStream(path)
		If Not stream Then
			Self.OnWarning("Unable to write ~q"+path+"~q")
			Return False
		EndIf
		
		Local categoryName:String
		Local category:TConfigCategory
		Local variableName:String
		Local variable:TConfigVariable
		
		For categoryName = EachIn Self.Categories.Keys()
			category = Self.Get(categoryName)
			stream.WriteLine("[" + category.Name + "]")
			For variableName = EachIn category.Variables.Keys()
				variable = category.Get(variableName)
				If variable.Save ..
					stream.WriteLine(variable.Name + "=" + variable.Value)
			Next
		Next
		
		stream.Close()
		Return True
	EndMethod
	
	Method Register:TConfigVariable(description:String, category:String, variable:String, argument:String, value:String = "", save:Int = False)
		Local cat:TConfigCategory = Self.Get(category)
		If Not cat Then
			cat = New TConfigCategory(category)
			Self.Categories.Insert(category,cat)
		EndIf
		
		Local vari:TConfigVariable = New TConfigVariable(..
			description, category, variable, argument, value, save)
		
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
	Field Save:Int = True
	
	Method New(description:String, category:String, name:String, argument:String, value:String, save:Int = True)
		Self.Description = description
		Self.Category = category
		Self.Name = name
		Self.Argument = argument
		Self.Value = value
		Self.Save = save
	EndMethod
EndType
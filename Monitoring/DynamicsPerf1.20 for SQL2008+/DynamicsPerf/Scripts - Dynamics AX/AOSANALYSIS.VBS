strSQLInstance = Wscript.Arguments.Item(0)
strAXDataBase = Wscript.Arguments.Item(1)


Const HKLM          = &H80000002
Const adInteger     = 3
Const adVarWChar    = 202
Const adlongVarWChar= 203
Const adParamInput  = &H0001
Const adCmdText     = &H0001
const REG_SZ        = 1
const REG_EXPAND_SZ = 2
const REG_BINARY    = 3
const REG_DWORD     = 4
const REG_MULTI_SZ  = 7

Dim objConnection
Dim objRecordset
Dim objCommandEvt
Dim objCommandReg

Dim prmEvt1
Dim prmEvt2
Dim prmEvt3
Dim prmEvt4
Dim prmEvt5
Dim prmEvt6

Dim prmReg1
Dim prmReg2
Dim prmReg3
Dim prmReg4
Dim prmReg5
Dim prmReg6
Dim prmReg7
Dim prmReg8


Dim strAOS
Dim strRecordset

strRecordset = "SELECT SUBSTRING(SERVERID,(CHARINDEX('@',SERVERID)+1), (LEN(SERVERID)-CHARINDEX('@',SERVERID)))FROM SYSSERVERCONFIG"

Set objConnection=CreateObject("ADODB.Connection") 
Set objRecordset=CreateObject("ADODB.Recordset")
set objCommandEvt=CreateObject("ADODB.command")
set objCommandReg=CreateObject("ADODB.command")

objConnection.Provider="SQLOLEDB"
objConnection.Properties("Data Source").Value = strSQLInstance
objConnection.Properties("Initial Catalog").Value = strAXDatabase
objConnection.Properties("Integrated Security").Value = "SSPI"

objConnection.Open

objCommandEvt.ActiveConnection=objConnection
objCommandEvt.CommandType=adCmdText
objCommandEvt.CommandText="INSERT INTO DynamicsPerf..AOS_EVENTLOG VALUES (?,?,?,?,?,?)"

Set prmEvt1=objCommandEvt.CreateParameter ("", adVarWChar,adParamInput,23)
Set prmEvt2=objCommandEvt.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmEvt3=objCommandEvt.CreateParameter ("", adInteger,adParamInput)
Set prmEvt4=objCommandEvt.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmEvt5=objCommandEvt.CreateParameter ("", adlongVarWChar,adParamInput,32768)
Set prmEvt6=objCommandEvt.CreateParameter ("", adVarWChar,adParamInput,255)

objCommandEvt.Parameters.Append prmEvt1
objCommandEvt.Parameters.Append prmEvt2
objCommandEvt.Parameters.Append prmEvt3
objCommandEvt.Parameters.Append prmEvt4
objCommandEvt.Parameters.Append prmEvt5
objCommandEvt.Parameters.Append prmEvt6

objCommandReg.ActiveConnection=objConnection
objCommandReg.CommandType=adCmdText
objCommandReg.CommandText="INSERT INTO DynamicsPerf..AOS_REGISTRY VALUES (?,?,?,?,?,?,?,?)"

Set prmReg1=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg2=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,5)
Set prmReg3=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg4=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,25)
Set prmReg5=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg6=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,1)
Set prmReg7=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg8=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,8000)

objCommandReg.Parameters.Append prmReg1
objCommandReg.Parameters.Append prmReg2
objCommandReg.Parameters.Append prmReg3
objCommandReg.Parameters.Append prmReg4
objCommandReg.Parameters.Append prmReg5
objCommandReg.Parameters.Append prmReg6
objCommandReg.Parameters.Append prmReg7
objCommandReg.Parameters.Append prmReg8

objConnection.Execute "SET DATEFORMAT MDY"
objConnection.Execute "TRUNCATE TABLE DynamicsPerf..AOS_EVENTLOG"
objConnection.Execute "TRUNCATE TABLE DynamicsPerf..AOS_REGISTRY"

objRecordset.Open strRecordset, objConnection


Do While Not objRecordset.EOF
    strAOS =  objRecordset.Fields(0) 
    WScript.Echo strAOS
    AOSevt(strAOS)
    AOSreg(strAOS)
    objRecordset.MoveNext 
Loop


objRecordset.Close
objConnection.Close

Sub AOSevt(strAOS)
  
    Const CONVERT_TO_LOCAL_TIME = True
    Set dtmStartDate = CreateObject("WbemScripting.SWbemDateTime")
    DateToCheck = CDate(DATE - 14)
    dtmStartDate.SetVarDate DateToCheck, CONVERT_TO_LOCAL_TIME
    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strAOS & "\root\cimv2")
    Set colLoggedEvents = objWMIService.ExecQuery _
	    ("Select * from Win32_NTLogEvent Where Logfile = 'Application' and (eventtype = 1 or eventtype = 2 or (eventtype = 3 and eventcode = 149)) and  TimeWritten >= '" & dtmStartDate & "'")
    For Each objEvent in colLoggedEvents
        prmEvt1.value=cUTC2Lt(objEvent.TimeWritten)
        prmEvt2.value=objEvent.ComputerName
        prmEvt3.value=objEvent.EventCode
        prmEvt4.value=objEvent.Type
        prmEvt5.value=left(objEvent.Message, 256)
        prmEvt6.value=objEvent.SourceName
        objCommandEvt.Execute
    Next	
End Sub

Sub AOSreg(strAOS)
    Const HKLM = &H80000002
    Set ObjReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & StrAOS & "\root\default:StdRegProv")
    StrKeyPath = "System\CurrentControlSet\Services\Dynamics Server"
    ObjReg.EnumKey HKLM, StrKeyPath, ArrVersions
    For Each StrVersion In ArrVersions
        ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion, ArrInstances
        If IsArray(ArrInstances) Then
            For Each StrInstance In ArrInstances 
                objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "InstanceName", strInstanceName 
                objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "Current", strCurrentConfig 
                objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "ProductVersion", strProductVersion 
                ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, ArrConfigs
                    For Each StrConfig In ArrConfigs
                        If StrConfig = StrCurrentConfig Then
                            strActive = "Y"
                        Else
                            strActive = "N"
                        End if
                        ObjReg.EnumValues HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, ArrValueNames,  ArrValueTypes
                        For I=0 To UBound(arrValueNames) 
                            StrValueName = arrValueNames(I)           
                            Select Case arrValueTypes(I)
                                Case REG_SZ
                                    objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_EXPAND_SZ
                                    objReg.GetExpandedStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_BINARY
                                     objReg.GetBinaryValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_DWORD
                                     objReg.GetDWORDValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_MULTI_SZ
                                     objReg.GetMultiStringValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                            End Select        
                            prmReg1.value=StrAOS
                            prmReg2.value=StrVersion
                            prmReg3.value=strInstanceName
                            prmReg4.value=StrProductVersion
                            prmReg5.value=StrConfig
                            prmReg6.value=strActive
                            prmReg7.value=StrValueName
                            prmReg8.value=StrValue
                            objCommandReg.Execute
                        Next
                    Next
            Next
        End If
    Next
End Sub

Function cUTC2Lt(WMITime)
'   Convert UTC Time from Event Log to DateTime format compatible with SQL Server DateTime data type
   	Dim strDate, strTime
   	Dim yyyy : yyyy = left(WMITime,4) 'year
   	Dim mm   : mm = mid(WMITime,5,2)  'month
   	Dim dd   : dd = mid(WMITime,7,2)  'day
   	Dim hh   : hh = mid(WMITime,9,2)  'hour
   	Dim mn   : mn = mid(WMITime,11,2) 'minutes
   	Dim ss   : ss = mid(WMITime,13,2) 'seconds
   	Dim ms   : ms = mid(WMITime,16,6) 'microseconds
 '  	strDate = mm & "-" & dd & "-" & yyyy
	strDate = yyyy & "-" & mm & "-" & dd
      	strTime = hh & ":" & mn & ":" & ss
      	cUTC2Lt = strDate & " " & strTime
End Function


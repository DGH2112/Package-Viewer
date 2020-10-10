(**
  
  This module contains functions for use throughout the application.

  @Author  David Hoyle
  @Version 1.016
  @Date    10 Oct 2020
  
**)
Unit DGHPackageViewerFunctions;

Interface

Type
  (** A record to describe the version information for the plug-in. **)
  TVersionInfo = Record
    iMajor : Integer;
    iMinor : Integer;
    iBugfix : Integer;
    iBuild : Integer;
  End;

  Procedure BuildNumber(Var VersionInfo: TVersionInfo);
  
Implementation

Uses
  Windows;

(**

  This method extracts the build information from the plug-ins DLL or BPL and returns the information
  in the var parameter.

  @precon  None.
  @postcon The version information for the plug-in is returned in the var parameter.

  @param   VersionInfo as a TVersionInfo as a reference

**)
Procedure BuildNumber(Var VersionInfo: TVersionInfo);

Const
  iWORDMask = $FFFF;
  iShift16 = 16;

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer: Array [0 .. MAX_PATH] Of Char;

Begin
  GetModuleFileName(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        VersionInfo.iMajor  := VerValue^.dwFileVersionMS Shr iShift16;
        VersionInfo.iMinor  := VerValue^.dwFileVersionMS And iWORDMask;
        VersionInfo.iBugfix := VerValue^.dwFileVersionLS Shr iShift16;
        VersionInfo.iBuild  := VerValue^.dwFileVersionLS And iWORDMask;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
  End;
End;

End.

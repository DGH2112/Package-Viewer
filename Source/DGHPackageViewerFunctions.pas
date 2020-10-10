(**
  
  This module contains functions for use throughout the application.

  @Author  David Hoyle
  @Version 1.327
  @Date    10 Oct 2020
  
  @license

    Package Viewer is a RAD Studio plug-in for browsing packages loaded into the IDE.
    
    Copyright (C) 2020  David Hoyle (https://github.com/DGH2112/Browse-and-Doc-It/)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
Unit DGHPackageViewerFunctions;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  Classes,
  Forms;

Type
  (** A record to describe the version information for the plug-in. **)
  TVersionInfo = Record
    iMajor : Integer;
    iMinor : Integer;
    iBugfix : Integer;
    iBuild : Integer;
  End;

  (** A record to encapsulate the functions. **)
  TPackageViewerFunctions = Record
  Strict Private
  Public
    Class Procedure BuildNumber(Var VersionInfo: TVersionInfo); Static;
    Class Procedure RegisterFormClassForTheming(Const AFormClass : TCustomFormClass;
      Const Component : TComponent = Nil); Static;
    Class Procedure ApplyTheming(Const Component : TComponent); Static;
  End;
  
Implementation

Uses
  ToolsAPI,
  SysUtils,
  Windows;

(**

  This method apply theming to the given component if theming is enabled and available.

  @precon  None.
  @postcon The component is themed if theming is available and enabled.

  @param   Component as a TComponent as a constant

**)
Class Procedure TPackageViewerFunctions.ApplyTheming(Const Component: TComponent);

{$IFDEF DXE102}
Var
  ITS : IOTAIDEThemingServices;
{$ENDIF DXE102}
  
Begin
  {$IFDEF DXE102}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
    If ITS.IDEThemingEnabled Then
      ITS.ApplyTheme(Component);
  {$ENDIF DXE102}
End;

(**

  This method extracts the build information from the plug-ins DLL or BPL and returns the information
  in the var parameter.

  @precon  None.
  @postcon The version information for the plug-in is returned in the var parameter.

  @param   VersionInfo as a TVersionInfo as a reference

**)
Class Procedure TPackageViewerFunctions.BuildNumber(Var VersionInfo: TVersionInfo);

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

(**

  This method registers the given form class for theming is theming is enabled and available.

  @precon  None.
  @postcon The form is registered for theming is available and enabled.

  @param   AFormClass as a TCustomFormClass as a constant
  @param   Component  as a TComponent as a constant

**)
Class Procedure TPackageViewerFunctions.RegisterFormClassForTheming(Const AFormClass : TCustomFormClass;
  Const Component : TComponent = Nil);

{$IFDEF DXE102}
Var
  {$IFDEF DXE104} // Breaking change to the Open Tools API - They fixed the wrongly defined interface
  ITS : IOTAIDEThemingServices;
  {$ELSE}
  ITS : IOTAIDEThemingServices250;
  {$ENDIF DXE104}
{$ENDIF DXE102}
  
Begin
  {$IFDEF DXE102}
  {$IFDEF DXE104}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
  {$ELSE}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
  {$ENDIF DXE104}
    If ITS.IDEThemingEnabled Then
      Begin
        ITS.RegisterFormClass(AFormClass);
        If Assigned(Component) Then
          ITS.ApplyTheme(Component);
      End;
  {$ENDIF DXE102}
End;

End.

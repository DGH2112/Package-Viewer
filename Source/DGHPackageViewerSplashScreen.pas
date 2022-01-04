(**
  
  This module contains the code to add a splash screen entry to the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.234
  @Date    04 Jan 2022
  
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
Unit DGHPackageViewerSplashScreen;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddSplashScreen();

Implementation

Uses
  ToolsAPI,
  SysUtils,
  Forms,
  {$IFDEF RS110}
  Graphics,
  {$ELSE}
  Windows,
  {$ENDIF}
  DGHPackageViewerFunctions,
  DGHPackageViewerResourceStrings,
  DGHPackageViewerConstants;

(**

  This method adds a splash screen entry to the RAD Studio IDE.

  @precon  None.
  @postcon The entry appears on the RAD Studio IDE splash screen.

**)
Procedure AddSplashScreen();

Const
  {$IFDEF D2007}
  strDGHPackageViewerSplashScreenBitMap = 'SplashScreen24';
  {$ELSE}
  strDGHPackageViewerSplashScreenBitMap = 'SplashScreen48';
  {$ENDIF}

Var
  VerInfo : TVersionInfo;
  {$IFDEF RS110}
  SplashScreenBitMap : TBitMap;
  {$ELSE}
  bmSplashScreen: HBITMAP;
  {$ENDIF RS110}
  SSS : IOTASplashScreenServices;
  
Begin
  TPackageViewerFunctions.BuildNumber(VerInfo);
  If Supports(SplashScreenServices, IOTASplashScreenServices, SSS) Then
    Begin
      {$IFDEF RS110}
      SplashScreenBitMap := TBitMap.Create;
      Try
        SplashScreenBitMap.LoadFromResourceName(hINstance, strDGHPackageViewerSplashScreenBitMap);
        SSS.AddPluginBitmap(
          Format(strSplashScreenName, [VerInfo.iMajor, VerInfo.iMinor, Copy(strRevision, VerInfo.iBugFix + 1, 1), Application.Title]),
          [SplashScreenBitMap],
          {$IFDEF DEBUG} True {$ELSE} False {$ENDIF DEBUG},
          Format(strSplashScreenBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild])
        );
      Finally
        SplashScreenBitMap.Free;
      End;
      {$ELSE}
      bmSplashScreen := LoadBitmap(hInstance, strDGHPackageViewerSplashScreenBitMap);
      SSS.AddPluginBitmap(
        Format(strSplashScreenName, [VerInfo.iMajor, VerInfo.iMinor, Copy(strRevision, VerInfo.iBugFix + 1, 1), Application.Title]),
        bmSplashScreen,
        {$IFDEF DEBUG} True {$ELSE} False {$ENDIF DEBUG},
        Format(strSplashScreenBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild])
      );
      {$ENDIF RS10}
    End;
End;

End.

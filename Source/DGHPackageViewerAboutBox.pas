(**
  
  This module contains code to installed and un-install an about box in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.314
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
Unit DGHPackageViewerAboutBox;

Interface

  Function AddAboutBox() : Integer;
  Procedure RemoveAboutBox(Const iIndex : Integer);
  
Implementation

{$INCLUDE CompilerDefinitions.inc}

Uses
  ToolsAPI,
  SysUtils,
  Forms,
  {$IFDEF RS110}
  Graphics,
  {$ELSE}
  Windows,
  {$ENDIF RS110}
  DGHPackageViewerFunctions,
  DGHPackageViewerConstants,
  DGHPackageViewerResourceStrings;

(**

  This method add an about box entry into the RAD Studio IDE and returns the index used to remove it
  later.

  @precon  None.
  @postcon The about box into the RAD Studio IDE and returns the index to remove it later.

  @return  an Integer

**)
Function AddAboutBox() : Integer;

Const
  strSplashScreen = 'SplashScreen48';

Var
  VerInfo: TVersionInfo;
  {$IFDEF RS110}
  AboutBoxBitMap : TBitMap;
  {$ELSE}
  bmSplashScreen: HBITMAP;
  {$ENDIF RS110}
  ABS : IOTAAboutBoxServices;

Begin
  Result := -1;
  TPackageViewerFunctions.BuildNumber(VerInfo);
  If Supports(BorlandIDEServices, IOTAAboutBoxServices, ABS) Then
    Begin
      {$IFDEF RS110}
      AboutBoxBitMap := TBitMap.Create;
      Try
        AboutBoxBitMap.LoadFromResourceName(hInstance, strSplashScreen);
        Result := ABS.AddPluginInfo(
          Format(strSplashScreenName, [VerInfo.iMajor, VerInfo.iMinor, Copy(strRevision, VerInfo.iBugFix + 1, 1), Application.Title]),
          strPluginDescription,
          [AboutBoxBitMap],
          {$IFDEF DEBUG} True {$ELSE} False {$ENDIF DEBUG},
          Format(strSplashScreenBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild]),
          Format(strSKUBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild])
        );
      Finally
        AboutBoxBitMap.Free;
      End;
      {$ELSE}
      bmSplashScreen := LoadBitmap(hInstance, strSplashScreen);
      Result := ABS.AddPluginInfo(
        Format(strSplashScreenName, [VerInfo.iMajor, VerInfo.iMinor, Copy(strRevision, VerInfo.iBugFix + 1, 1), Application.Title]),
        strPluginDescription,
        bmSplashScreen,
        {$IFDEF DEBUG} True {$ELSE} False {$ENDIF DEBUG},
        Format(strSplashScreenBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild]),
        Format(strSKUBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild])
      );
      {$ENDIF RS110}
    End;
End;

(**

  This method remove the about box entry from the RAD Studio IDE using the given index.

  @precon  None.
  @postcon The about box entry is removed from the RAD Studio IDE.

  @param   iIndex as an Integer as a constant

**)
Procedure RemoveAboutBox(Const iIndex : Integer);

Var
  ABS : IOTAAboutBoxServices;

Begin
  If iIndex > -1 Then
    If Supports(BorlandIDEServices, IOTAAboutBoxServices, ABS) Then
      ABS.RemovePluginInfo(iIndex);
End;

End.

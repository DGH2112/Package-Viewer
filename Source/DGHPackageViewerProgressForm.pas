(**

  This module contains a class which presents a progress form for displaying the progress of
  load packages from the IDE for browsing.

  @Author  David Hoyle
  @Version 1.201
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
Unit DGHPackageViewerProgressForm;

Interface

Uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls;

Type
  (** A class to represent a progress form for loading package information. **)
  TfrmDGHPackageViewerProgress = Class(TForm)
    pbProgress: TProgressBar;
    procedure FormCreate(Sender: TObject);
  Strict Private
  Strict Protected
  Public
    Procedure ShowProgress(Const iMax : Integer);
    Procedure UpdateProgress(Const iPosition : Integer);
    Procedure HideProgress;
  End;

Implementation

{$R *.dfm}

Uses
  DGHPackageViewerFunctions;

Procedure TfrmDGHPackageViewerProgress.FormCreate(Sender: TObject);

Begin
  TPackageViewerFunctions.RegisterFormClassForTheming(TfrmDGHPackageViewerProgress);
  TPackageViewerFunctions.ApplyTheming(Self);
End;

(**

  This method hides the progress form.

  @precon  None.
  @postcon The progress form is hidden.

**)
Procedure TfrmDGHPackageViewerProgress.HideProgress;

Begin
  Hide;
End;

(**

  This method displays the progress form and sets the maximum property of the property.

  @precon  None.
  @postcon The form is displayed and the maximum property of the progress bar updated.

  @param   iMax as an Integer as a constant

**)
Procedure TfrmDGHPackageViewerProgress.ShowProgress(Const iMax: Integer);

Begin
  pbProgress.Max := iMax;
  Show;
End;

(**

  This method update the position of the progress bar.

  @precon  None.
  @postcon The progress position is updated.

  @param   iPosition as an Integer as a constant

**)
Procedure TfrmDGHPackageViewerProgress.UpdateProgress(Const iPosition: Integer);

Begin
  pbProgress.Position := iPosition;
End;

End.

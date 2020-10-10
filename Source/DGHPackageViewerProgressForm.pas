(**

  This module contains a class which presents a progress form for displaying the progress of
  load packages from the IDE for browsing.

  @Author  David Hoyle
  @Version 1.085
  @Date    08 Oct 2020

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
  Strict Private
  Strict Protected
  Public
    Procedure ShowProgress(Const iMax : Integer);
    Procedure UpdateProgress(Const iPosition : Integer);
    Procedure HideProgress;
  End;

Implementation

{$R *.dfm}

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

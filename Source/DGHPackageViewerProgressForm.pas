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
  TfrmDGHPackageViewerProgress = Class(TForm)
    pbProgress: TProgressBar;
  Private
    { Private declarations }
  Public
    { Public declarations }
    Procedure ShowProgress(iMax : Integer);
    Procedure UpdateProgress(iPosition : Integer);
    Procedure HideProgress;
  End;

Var
  frmDGHPackageViewerProgress: TfrmDGHPackageViewerProgress;

Implementation

{$R *.dfm}

{ TfrmDGHPackageViewerProgress }

Procedure TfrmDGHPackageViewerProgress.HideProgress;

Begin
  Hide;
End;

Procedure TfrmDGHPackageViewerProgress.ShowProgress(iMax: Integer);

Begin
  pbProgress.Max := iMax;
  Show;
End;

Procedure TfrmDGHPackageViewerProgress.UpdateProgress(iPosition: Integer);

Begin
  pbProgress.Position := iPosition;
End;

End.

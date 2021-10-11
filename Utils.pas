{******************************************************************************}
{ Auteur  :Martin Beaudet                                                      }
{    Date :8 Octobre 2001                                                      }
{                                                                              }
{ Objectif :Initialisation d'OpenGL sur un DC (Device Context).                }
{           Autres procédures/Fonctions de services utilisés pour OpenGL.      }
{******************************************************************************}
Unit Utils;
Interface
Uses Windows, SysUtils, OpenGL;

    { Initialisation/Finalisation de OpenGL }
     Function InitOpenGL( DC :HDC; ColorBits :Integer;
                          DoubleBuffer :Boolean ) :Boolean;
     Procedure Terminer;


Implementation
Var
   hDCGlobal   :HDC;    {Context graphique de la fenêtre}
   GLContext   :HGLRC;  {Passerelle pour utiliser OpenGL sur la fenêtre}



Function InitOpenGL( DC :HDC; ColorBits :Integer;
                     DoubleBuffer :Boolean ) :Boolean;
{Objectif  :Initialiser OpenGL sous la contexte graphique passé en paramètre.
 Paramètres:

             DC           :Adresse graphique du composant qui s'apprête à être
                           lié à OpenGL
             ColorBits    :Nombre bits pour une couleurs
             DoubleBuffer :Activation du double de tampon ou pas.}

Var
    PixelFormat    :TPixelFormatDescriptor; {Format de pixel}
    cPixelFormat   :Integer;                {Index du format de pixel trouvé}
begin
     {Préparation de la structure d'information sur le format de pixels}
     FillChar( PixelFormat, SizeOf(PixelFormat), 0 );
     With PixelFormat Do
     Begin
          nSize      := Sizeof(TPixelFormatDescriptor);
          If DoubleBuffer Then
             dwFlags    := PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL
          Else
              dwFlags    := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL;
          iLayerType := PFD_MAIN_PLANE;
          iPixelType := PFD_TYPE_RGBA;
          nVersion   := 1;
          cColorBits := 16;
          CdepthBits := 16;
     End;

     {Récupération du DC passé en paramètre, dans une variable Global.}
     hDCGlobal := DC;

     {Choix du format de pixel adapté pour le DC reçu en paramètre.}
     cPixelFormat := ChoosePixelFormat(DC, @PixelFormat);

     {Vérifier si l'index du format de pixel supporté à été trouvée}
     Result := cPixelFormat <> 0;
     If Not Result Then
     Begin
          MessageBox(0, pChar(SysErrorMessage(GetLastError)),
                     'Init OpenGL', mb_OK);
          Exit;
     End;

     {Vérifier si le format de pixel trouvé peut être appliqué sur le DC}
     Result := SetPixelFormat( DC, cPixelFormat, @PixelFormat);
     If Not Result Then
     Begin
          MessageBox(0, pChar(SysErrorMessage(GetLastError)),
                    'Init OpenGL', mb_OK);
          Exit;
     End;

     {Vérifier si OpenGL créer la passerelle qui lui permettera de dessiner
      sur ce DC.}
     GLContext := wglCreateContext( DC );
     Result := GLContext <> 0;
     If Not Result Then
     Begin
          MessageBox(0, pChar(SysErrorMessage(GetLastError)),
                    'Init OpenGL', mb_OK);
          Exit;
     End;

     {Vérifier si OpenGL peut se servir de ce DC pour dessiner.}
     Result := wglMakeCurrent( DC, GLContext );
     If Not Result Then
     Begin
          MessageBox(0, pChar(SysErrorMessage(GetLastError)),
                    'Init OpenGL', mb_OK);
          Exit;
     End;
End;

Procedure Terminer;
{Objectif :Briser le lien avec OpenGL.}
Begin
     {Supression du lien entre OpenGL et notre application.}
     If Not wglMakeCurrent( hDCGlobal, 0 ) Then
     Begin
          MessageBox(0, pChar(SysErrorMessage(GetLastError)),
                    'Init OpenGL', mb_OK);
          Exit;
     End;

     If Not wglDeleteContext( GLContext ) Then
     Begin
          MessageBox(0, pChar(SysErrorMessage(GetLastError)),
                    'Init OpenGL', mb_OK);
          Exit;
     End;
End;

end.

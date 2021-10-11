unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, Utils, StdCtrls;

type
  PByte=^byte;
  TBoolTab=array[0..9,0..9] of bool;
  TForm1=class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  public
    stop,commence:bool;
    keys:set of byte;
    Id_Texture_Sol:array[0..9] of integer;
    Tab_Colors:array[0..9,0..3] of glfloat;
    Tab_Textures:array[0..9] of integer;
    Texture_Sol:array[0..9] of pointer;
    Texture_Sprite_Normal:pointer;
    Texture_Sprite_Pivote:array[0..35] of pointer;
    Id_Texture_Sprite_Pivote:array[0..35] of integer;
    MaxH,Id_Texture_Sprite_Normal:integer;
    Tabs:array[0..9] of TBoolTab;
    DeltaH,Px,Pz,Dx,Dz,Dv,DeltaV,Blend:GlFloat;
    procedure Initialise;
    procedure Remplir_Tab(var t:TBoolTab);
    procedure Dessine_Sol;
    procedure Dessine_Sprite(t:glfloat);
    procedure Load_Texture(var t:pointer;var lx,ly:integer;s:string;bb:bool;cr,cg,cb:byte);
    function test(x,y,z:integer):bool;
    procedure MainLoop;
  end;

var
  Form1:TForm1;
  Score:integer;

implementation

{$R *.dfm}

Procedure glBindTexture(target:GLEnum;texture:GLuint);Stdcall;External 'OpenGL32.dll';
Procedure glGenTextures(n:GLsizei;Textures:PGLuint);Stdcall;External 'OpenGL32.dll';
Procedure glDeleteTextures(n:GLsizei;textures: PGLuint);Stdcall;External 'OpenGL32.dll';

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitOpenGL(form1.Canvas.Handle,32,true);
  stop:=true;
  keys:=[];
  Initialise;
  px:=5;
  pz:=5;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  a:integer;
begin
  for a:=0 to 9 do freemem(Texture_Sol[a]);
  freemem(Texture_Sprite_Normal);
  for a:=0 to 35 do freemem(Texture_Sprite_Pivote[a]);
end;

procedure TForm1.MainLoop;
var
  a:integer;
  Lasttime,Begintime,t:double;
  px0,pz0:glfloat;
begin
  ShowCursor(false);
  if not stop then exit;
  windowstate:=wsmaximized;
  Score:=0;
  stop:=false;
  glClearColor(0,0,0,0);
  glMatrixMode(GL_MODELVIEW);
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
  glEnable(GL_DEPTH_TEST);
//  glEnable(GL_NORMALIZE);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
  commence:=true;
  DeltaH:=-1;
  for a:=0 to 9 do Remplir_Tab(Tabs[a]);
  dx:=0;
  dz:=0;
  px0:=px;
  pz0:=pz;
  Lasttime:=time;
  BeginTime:=Lasttime;
  t:=time;
  repeat
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    glLoadIdentity;
    gluLookAt(px,7,pz,px,-1,pz,0,0,1);
    Dessine_Sol;
    Dessine_Sprite((t-BeginTime)*Dv);
    SwapBuffers(canvas.handle);
    glFlush();
    t:=time;
    DeltaH:=DeltaH+DeltaV*(t-lasttime);
    if DeltaH>=6.3 then stop:=true;
    application.processmessages;
    if (dx<>0) or (dz<>0) then begin
      if dv*(t-Begintime)>=1 then begin
        px:=px0+dx;;
        pz:=pz0+dz;
        dx:=0;
        dz:=0;
        while not Tabs[0,trunc(px),trunc(pz)] do begin
          for a:=0 to 8 do begin
            Tabs[a]:=Tabs[a+1];
            Tab_Colors[a]:=Tab_Colors[a+1];
            Tab_Textures[a]:=Tab_Textures[a+1];
          end;
          Remplir_Tab(Tabs[9]);
          for a:=0 to 3 do Tab_Colors[9,a]:=0.2+random;
          Tab_Textures[9]:=random(10);
          DeltaH:=DeltaH-1;
          inc(score);
        end;
      end else begin
        px:=px+dv*dx*(t-Lasttime);
        pz:=pz+dv*dz*(t-Lasttime);
        Lasttime:=t;
        continue;
      end;
    end;
    Lasttime:=t;
    if 37 in keys then begin
      if px<9 then dx:=1;
    end;
    if 39 in keys then begin
      if px>0 then dx:=-1;
    end;
    if 38 in keys then begin
      if pz<9 then dz:=1;
    end;
    if 40 in keys then begin
      if pz>0 then dz:=-1;
    end;
    if (dx<>0) or (dz<>0) then begin
      Begintime:=time;
      Lasttime:=Begintime;
    end;
    px0:=px;
    pz0:=pz;
  until stop;
  commence:=false;
  releasecapture;
  terminer;
  destroy;
  ShowCursor(true);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  canclose:=stop;
  stop:=true;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0,0,ClientWidth,ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(80,ClientWidth/ClientHeight,0.1,30.0);
  glMatrixMode(GL_MODELVIEW);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  include(keys,key);
  if key=27 then begin
    stop:=true;
    ReleaseCapture;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  exclude(keys,key);
end;

procedure TForm1.Initialise;
var
  a,b,x,y:integer;
  s:string;
begin
  s:=ExtractFilePath(application.exename)+'images\';
  for a:=0 to 9 do begin
    for b:=0 to 2 do Tab_Colors[a,b]:=0.2+random;
    Tab_Textures[a]:=random(10);
    Load_Texture(Texture_Sol[a],x,y,s+'texture'+inttostr(a)+'.bmp',false,0,0,0);
    glgentextures(1,@ID_Texture_Sol[a]);
    glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    glBindTexture(GL_TEXTURE_2D,ID_Texture_Sol[a]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
    glTexImage2d(GL_TEXTURE_2D,0,GL_RGBA,x,y,0,GL_RGBA,GL_UNSIGNED_BYTE,Texture_Sol[a]);
  end;
  Load_Texture(Texture_Sprite_Normal,x,y,s+'cube00.bmp',true,0,0,0);
  glgentextures(1,@Id_Texture_Sprite_Normal);
  glPixelStorei(GL_UNPACK_ALIGNMENT,1);
  glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Normal);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
  glTexImage2d(GL_TEXTURE_2D,0,GL_RGBA,x,y,0,GL_RGBA,GL_UNSIGNED_BYTE,Texture_Sprite_Normal);
  for a:=0 to 35 do begin
    if a<9 then
      Load_Texture(Texture_Sprite_Pivote[a],x,y,s+'cube0'+inttostr(a+1)+'.bmp',true,0,0,0)
    else
      Load_Texture(Texture_Sprite_Pivote[a],x,y,s+'cube'+inttostr(a+1)+'.bmp',true,0,0,0);
    glgentextures(1,@Id_Texture_Sprite_Pivote[a]);
    glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[a]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
    glTexImage2d(GL_TEXTURE_2D,0,GL_RGBA,x,y,0,GL_RGBA,GL_UNSIGNED_BYTE,Texture_Sprite_Pivote[a]);
  end;
end;

procedure TForm1.Remplir_Tab(var t:TBoolTab);
var
  a,b:integer;
begin
  for a:=0 to 9 do
    for b:=0 to 9 do
      t[a,b]:=true;
  for a:=1 to 6 do
    t[random(10),random(10)]:=false;
end;

procedure TForm1.Dessine_Sol;
var
  a,b,c:integer;
  r:glfloat;
begin
  glPushMatrix;
  glTranslated(0,DeltaH-MaxH,0);
  for a:=MaxH downto 0 do begin
    if a<10 then glBindTexture(GL_TEXTURE_2D,ID_Texture_Sol[tab_textures[a]]);
    glPushMatrix;
    for b:=0 to 10 do begin
      glPushMatrix;
      for c:=0 to 10 do begin
        if (test(a,b-1,c-1) xor test(a,b-1,c)) xor (test(a,b,c-1) xor test(a,b,c)) then begin
          glbegin(GL_LINES);
            glVertex3d(-0.5,0.5,-0.5);
            glVertex3d(-0.5,-0.5,-0.5);
          glend;
        end;
        if (test(a,b,c-1) xor test(a,b,c)) xor (test(a-1,b,c-1) xor test(a-1,b,c)) then begin
          glbegin(GL_LINES);
            glVertex3d(0.5,0.5,-0.5);
            glVertex3d(-0.5,0.5,-0.5);
          glend;
        end;
        if (test(a-1,b-1,c) xor test(a,b-1,c)) xor (test(a-1,b,c) xor test(a,b,c)) then begin
          glbegin(GL_LINES);
            glVertex3d(-0.5,0.5,0.5);
            glVertex3d(-0.5,0.5,-0.5);
          glend;
        end;
        gltranslated(0,0,1);
      end;
       glPopMatrix;
       gltranslated(1,0,0);
    end;
    glPopMatrix;
    glPushMatrix;
    glenable(GL_TEXTURE_2D);
    glenable(GL_BLEND);
    for b:=0 to 10 do begin
      glPushMatrix;
      for c:=0 to 10 do begin
        r:=0.8*(1-sqrt(sqr(a)+sqr(b-px)+sqr(c-pz))/sqrt(2*sqr(5)))+0.2;
        glColor4f(Tab_Colors[a,0]*r,Tab_Colors[a,1]*r,Tab_Colors[a,2]*r,Blend);
        if test(a,b,c) xor test(a,b-1,c) then begin
          glbegin(GL_QUADS);
            glTexCoord2f((b+1)/10,(c+1)/10);
            glVertex3d(-0.5,0.49,0.49);
            glTexCoord2f((b+1)/10,c/10);
            glVertex3d(-0.5,0.49,-0.49);
            glTexCoord2f(b/10,c/10);
            glVertex3d(-0.5,-0.49,-0.49);
            glTexCoord2f(b/10,(c+1)/10);
            glVertex3d(-0.5,-0.49,0.49);
          glend;
        end;
        if test(a,b,c) xor test(a,b,c-1) then begin
          glbegin(GL_QUADS);
            glTexCoord2f((b+1)/10,(c+1)/10);
            glVertex3d(0.49,-0.49,-0.5);
            glTexCoord2f((b+1)/10,c/10);
            glVertex3d(-0.49,-0.49,-0.5);
            glTexCoord2f(b/10,c/10);
            glVertex3d(-0.49,0.49,-0.5);
            glTexCoord2f(b/10,(c+1)/10);
            glVertex3d(0.49,0.49,-0.5);
          glend;
        end;
        gltranslated(0,0,1);
      end;
      glPopMatrix;
      gltranslated(1,0,0);
    end;
    gldisable(GL_BLEND);
    gldisable(GL_TEXTURE_2D);
    glPopMatrix;
    glPushMatrix;
    glenable(GL_TEXTURE_2D);
    glenable(GL_BLEND);
    for b:=0 to 10 do begin
      glPushMatrix;
      for c:=0 to 10 do begin
        r:=0.8*(1-sqrt(sqr(a)+sqr(b-px)+sqr(c-pz))/sqrt(2*sqr(5)))+0.2;
        if test(a,b,c) then begin
          glColor4f(Tab_Colors[a,0]*r,Tab_Colors[a,1]*r,Tab_Colors[a,2]*r,Blend);
          glbegin(GL_QUADS);
            glTexCoord2f(b/10,(c+1)/10);
            glVertex3d(-0.5,0.499,0.5);
            glTexCoord2f(b/10,c/10);
            glVertex3d(-0.5,0.499,-0.5);
            glTexCoord2f((b+1)/10,c/10);
            glVertex3d(0.5,0.499,-0.5);
            glTexCoord2f((b+1)/10,(c+1)/10);
            glVertex3d(0.5,0.499,0.5);
          glend;
        end;
        gltranslated(0,0,1);
      end;
      glPopMatrix;
      gltranslated(1,0,0);
    end;
    gldisable(GL_BLEND);
    gldisable(GL_TEXTURE_2D);
    glColor3f(20,20,20);
    glLineWidth(2);
    glPopMatrix;
    gltranslated(0,1,0);
  end;
  glPopMatrix;
end;

procedure TForm1.Dessine_Sprite(t:glfloat);
var
  a:integer;
begin
  glPushMatrix;
  gltranslated(px,DeltaH+0.01,pz);
  glenable(GL_BLEND);
  glcolor4f(1,1,1,1);
  glenable(GL_TEXTURE_2D);
  if (dx=0) and (dz=0) then
    glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Normal)
  else begin
    if t>1 then t:=1;
    a:=round(8*t);
    if (dx=1) and (dz=0) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[9+a]);
    if (dx=-1) and (dz=0) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[17-a]);
    if (dx=0) and (dz=1) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[a]);
    if (dx=0) and (dz=-1) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[8-a]);
    if (dx=1) and (dz=-1) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[18+a]);
    if (dx=-1) and (dz=1) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[23-a]);
    if (dx=1) and (dz=1) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[27+a]);
    if (dx=-1) and (dz=-1) then glBindTexture(GL_TEXTURE_2D,Id_Texture_Sprite_Pivote[35-a]);
  end;
  glbegin(GL_QUADS);
    glTexCoord2f(0,1);
    glVertex3d(-0.5,0.5,0.5);
    glTexCoord2f(0,0);
    glVertex3d(-0.5,0.5,-0.5);
    glTexCoord2f(1,0);
    glVertex3d(0.5,0.5,-0.5);
    glTexCoord2f(1,1);
    glVertex3d(0.5,0.5,0.5);
  glend;
  gldisable(GL_TEXTURE_2D);
  gldisable(GL_BLEND);
  glPopMatrix;
end;

procedure TForm1.Load_Texture(var t:pointer;var lx,ly:integer;s:string;bb:bool;cr,cg,cb:byte);
var
  p:tbitmap;
  a,b:integer;
  q:pbytearray;
begin
  p:=tbitmap.create;
  p.LoadFromFile(s);
  p.PixelFormat:=pf24bit;
  lx:=p.Height;
  ly:=p.Width;
  getmem(t,lx*ly*4);
  for a:=0 to lx-1 do begin
    q:=p.ScanLine[lx-1-a];
    for b:=0 to ly-1 do begin
      PByte(PChar(t)+4*(a*ly+b))^:=q^[3*(ly-1-b)+2];
      PByte(PChar(t)+4*(a*ly+b)+1)^:=q^[3*(ly-1-b)+1];
      PByte(PChar(t)+4*(a*ly+b)+2)^:=q^[3*(ly-1-b)];
      if bb and (q^[3*(ly-1-b)]=255) and (q^[3*(ly-1-b)+1]=255) and (q^[3*(ly-1-b)+2]=255) then
        PByte(PChar(t)+4*(a*ly+b)+3)^:=0
      else
        PByte(PChar(t)+4*(a*ly+b)+3)^:=255;
    end;
  end;
  p.Free;
end;

function tform1.test(x,y,z:integer):bool;
begin
  test:=(x>=0) and (y>=0) and (z>=0) and (x<MaxH) and (y<10) and (z<10) and Tabs[x,y,z];
end;

end.

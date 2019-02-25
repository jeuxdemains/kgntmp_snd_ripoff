; =============================================
; =           intROKEYGen Template #1 by UFO-Pu55y             =
; =                           - GOLDEN EDITION -                                    =
; =                                  for SnD-Team                                         =
; =                     Version 1.02  ALPHA  29/04/07                        =
; =                  ! Thanks to EclipTic for the GFX !                        =
; =                 Basic opengl-stuff based on NeHe                    =
; =         Keygen calculation examples from Lena151           =
; =                   !!  Feel free to use it as it is !!                              =
; =                !! Feel free to change it as u like !!                        =
; =              But some crediting would be nice... :)                   =
; =                         ... Have phun & peace...                                 =
; =============================================
	.586
	.model flat, stdcall
	option casemap:none
	
; INCLUDES ====================================
	include windows.inc
	include kernel32.inc
	include user32.inc
	include gdi32.inc
	includelib kernel32.lib
	includelib user32.lib
	includelib gdi32.lib

	include masm32.inc
	includelib masm32.lib
	
	include OpenGL\def\gl.def
	include OpenGL\def\glu.def
	include OpenGL\def\winextra.def
	include OpenGL\def\include.def
	includelib OpenGL\opengl32.lib
	includelib OpenGL\glu32.lib
	
	include winmm.inc
	includelib winmm.lib

	includelib music\mfmplayer.lib
	include music\mfmplayer.inc
	
	include About_Text.inc

; PROTOTYPES ==================================
	WinMain					PROTO :HWND, :UINT, :WPARAM, :LPARAM
	WndProc					PROTO :HWND, :UINT, :WPARAM, :LPARAM
	CreateGLWindow 			PROTO :DWORD, :DWORD, :DWORD, :UINT
	InitGL					PROTO
	LoadGLTextures			PROTO 
	DrawGLScene				PROTO
	KillGLWindow				PROTO
	CenterString				PROTO
	PrintGLText				PROTO :DWORD, :BOOL
	ZoomCube				PROTO :WORD
	Effects					PROTO
	InitKeygen				PROTO
	DoKeygen				PROTO

; RESOURCES==================================
	ID_Cube_Logo_Outside		equ 100
	ID_Cube_Logo_Inside		equ 110
	ID_Button					equ 200
	ID_Stars					equ 300
	ID_Stars1					equ 301
	ID_Stars2					equ 302
	ID_Icon					equ 900
	ID_Chiptune				equ 999       
	
; MACROS ======================================
	; fpc MACRO allows constants to be used with floating point operations.
	; Authored by bitRAKE from Win32ASM board <http://board.win32asmcommunity.net>
	fpc MACRO val:REQ
	LOCAL w,x,y,z,zz,ww

	;; split type and value, defaulting to REAL4
	z INSTR 1,<&val>,<! >
	IF z EQ 0
		y TEXTEQU <REAL4>
		x TEXTEQU <&val>
	ELSE
		y TEXTEQU @SubStr(<&val>,1,z-1) ;; Type
		x TEXTEQU @SubStr(<&val>,z+1,)  ;; Value
	ENDIF

	;; replace . with _
	z INSTR 1,x,<!.>
	IF z EQ 0
		w TEXTEQU x
		x CATSTR x,<.0> ;; prevent error message
	ELSE
		w CATSTR @SubStr(%x,1,z-1),<_>,@SubStr(%x,z+1,)
	ENDIF

	;; replace - with _
	zz INSTR 1,w,<!->
	IF zz EQ 0
		ww TEXTEQU w
	ELSE
		ww CATSTR @SubStr(%w,1,zz-1),<_>,@SubStr(%w,zz+1,)
	ENDIF

	;; figure out global name for constant
	z SIZESTR y ;; use last char for size distiction
	ww CATSTR <__>,ww,<r>,@SubStr(%y,z,1)

	IF (OPATTR(ww)) EQ 0 ;; not defined
		CONST SEGMENT
			ww y x
		CONST ENDS
	ENDIF
	EXITM ww
	ENDM

	szText MACRO Name, Text:VARARG
	LOCAL lbl
		jmp lbl
		Name db Text,0
	lbl:
	ENDM

; INITIALISED DATA ===============================
.data
;        *** Uncomment this for bug-hunting in OpenGL-Parts ! ***
;	txt_WC_Failed				db	"Failed to register window class",0
;	txt_GL_Context_Failed		db	"Failed to create a GL device context",0
;	txt_RC_Failed				db	"Failed to create a GL rendering context",0
;	txt_PixelFormat_Failed		db	"Failed to find suitable PixelFormat",0
;	txt_ActivateRC_Failed		db	"Failed to activate GL rendering context",0
;	txt_GLInit_Failed			db	"Initialisation failed",0
;	txt_SetPixelFormat_Failed	db	"Failed to set PixelFormat",0
;	txt_WindowCreateError		db	"Window creation error",0
;	txt_Error					db	"Error",0

; Window/GL-Stuff
	WindowWidth				equ			360
	WindowHeight			equ			240
	backcolourR				REAL4		0.1f ;0.5f				; Red
	backcolourG				REAL4		0.5f ;0.4f				; Green
	backcolourB				REAL4		0.4f ;0.1f				; Blue
	backcolourA				equ			fpc(1.0f) ;fpc(1.0f)			; Alpha
	fogcolor					REAL4 		0.1f
	fogcolor2					REAL4 		0.5f
	fogcolor3					REAL4 		0.4f
	fogmode					GLuint  		GL_EXP2 ; Three types of fog: GL_EXP, GL_EXP2, GL_LINEAR
; Cube
	xrot						GLfloat		0.1f    ; X Rotation of cube
	yrot						GLfloat		0.1f    ; Y Rotation of cube
	xspeed					REAL4		0.1f    ; 0.5f X Rotation speed
	yspeed					REAL4		0.1f    ; Y Rotation speed
	z						REAL4		-4.0f   ; Depth of cube into the screen
	LogoChange				REAL4		-1.35f    ; Point on Z-Axis to flip logo
	ZoomRange				equ			160
	ZoomDone				BOOL		TRUE
	ZoomLevel				db			1
	JumpUp					BOOL		TRUE
	CornerLTFPos				REAL4		1.0f
	CornerLTFNeg				REAL4		-1.0f	
	CornerRTFPos				REAL4		1.0f
	CornerRTFNeg			REAL4		-1.0f
	CornerLBFPos				REAL4		1.0f
	CornerLBFNeg				REAL4		-1.0f
	CornerRBFPos			REAL4		1.0f
	CornerRBFNeg			REAL4		-1.0f
	CornerLTBPos				REAL4		1.0f
	CornerLTBNeg				REAL4		-1.0f
	CornerRTBPos			REAL4		1.0f
	CornerRTBNeg			REAL4		-1.0f
	CornerLBBPos				REAL4		1.0f
	CornerLBBNeg			REAL4		-1.0f
	CornerRBBPos			REAL4		1.0f
	CornerRBBNeg			REAL4		-1.0f
	CubeSpeedX				dd			0.215	
	CubeSpeedY				dd			0.055		
	CubeCos1				dd			9.40
	CubeCos2				dd			33.0
	LegDown					BOOL		TRUE
; Stars
	PulseUp					BOOL		TRUE
	SpinSpeed				GLfloat		1.1
	cnt1						dd			0.5
	cnt2						dd			0.5
	StepXf					REAL4		27.0f
	StepYf					REAL4		15.0f
	StepZf					REAL4		75.0f
	StepX2f					REAL4		15.0f
	StepY2f					REAL4		22.0f
	StarDepthf				REAL4		-5.0f
	StarDepth2f				REAL4		0.0f
	StepXfIn					REAL4		14.0f
	StarsYfIn					REAL4		0.44f
	StepZfIn					REAL4		0.0f
	StarDepthfIn				REAL4		-1.4f
	StarSizePos				REAL4		0.1f
	StarSizeNeg				REAL4		-0.1f
	StarSpeed1				dd			0.03		
	StarXRadius				REAL4		0.053f
	StarCos1					dd			10.0
	StarCos2					dd			0.0
	StarCos3					dd			20.0
	StarCos4					dd			15.0
	StarFogStop				REAL4		0.0f
	StarZAdd					REAL4		-1.23f
	FogStarPos				REAL4		2.8f
	FogStarNeg				REAL4		-2.8f
	FogStarDens				REAL4		1.0f
	DoFog					BOOL		TRUE
; Editboxes
	Cursor					db			7Ch,0
	CursorOff					db			20h,0
	AdjustMul					REAL4		0.00145
	BoxCenterXf				REAL4		0.01
	NameXf					REAL4		-0.035f
	NameYf					REAL4		0.0050f
	SerialXf					REAL4		-0.035f
	SerialYf					REAL4		-0.009f
	ButtonJumpY				REAL4		-0.0460f
	TextJumpY				REAL4		-0.044f
; Font
	fontfamily					db	"Comic Sans MS",0       ; Such a font won't be centered !
	fontfamilyThin				db	"Courier New",0       ; !!! DON'T USE FONTS WITH VARIOUS LETTER-WIDTHS HERE !!!
; Text
	txt_OpenGL				db	"OpenGL",0
	txtEnter					db	"Enter",0
	txtAbout					db	"About",0
	txtBack					db	"Back",0
	txtLeave					db	"Leave",0
	txtCopy					db	"Copy",0
	txtName					db	"Name",0
	txtSerial					db	"Serial",0

; UNINITIALISED DATA ============================
.data?
	hRC						HGLRC		?
	hDC						HDC			?   ; Open GL window structures
	hWnd					HWND		?  
	hInstance					HINSTANCE	? 
	hProcess					dd			?
	hMem					dd			?
	pMem					dd			?
; Window/GL-Stuff
	active					BOOL		?   ; window active toggle/status
	textureLogoOutside			GLuint		?   ; GL Texture
	textureLogoInside			GLuint		?   ; GL Texture
	textureButton				GLuint		?
	textureStars				GLuint		?
	textureStars1				GLuint		?
	textureStars2				GLuint		?
	ScreenWidth				dd			?
	ScreenHeight				dd			?
	hBMPOutside				dd			?
	hBMPInside				dd			?
	hBMPButton				dd			?
	hBmpStars				dd			?
	hBmpStars1				dd			?
	hBmpStars2				dd			?
	TickTimer					dd			?
	PrintBuffer				db 			150 dup (?)
; Mouse
	hitpoint					POINT		<>
; Cube
	ZoomSteps				dw			?
	ZoomedIn				BOOL		?
	ZoomedOut				BOOL		?
	ZoomingNow				BOOL		?
	JumpHeight				dw			?
	CubeJumpCoord			REAL4		?
	LogoInside				BOOL		?
	JumpingNow				BOOL		?
	JumpingHigh				BOOL		?
	RightCornerUp				BOOL		?
	LegsNow					BOOL		?
	RightLeg					BOOL		?
	LegCounter				db			?
; Stars
	Spin						GLfloat		?
	SpinMin					GLfloat		?
	Star1Xf					REAL4		?
	Star1Yf					REAL4		?
	Star1Zf					REAL4		?
	Star1Z2f					REAL4		?
	Star2Xf					REAL4		?
	Star2Yf					REAL4		?
	Star2Zf					REAL4		?
	Star2Z2f					REAL4		?
	Star3Xf					REAL4		?
	Star3Yf					REAL4		?
	Star3Zf					REAL4		?
	Star3Z2f					REAL4		?
	Star4Xf					REAL4		?
	Star4Yf					REAL4		?
	Star4Zf					REAL4		?
	Star4Z2f					REAL4		?
	Star5Xf					REAL4		?
	Star5Yf					REAL4		?
	Star5Zf					REAL4		?
	Star5Z2f					REAL4		?
	Star6Xf					REAL4		?
	Star6Yf					REAL4		?
	Star6Zf					REAL4		?
	Star6Z2f					REAL4		?
	Star7Xf					REAL4		?
	Star7Yf					REAL4		?
	Star7Zf					REAL4		?
	Star7Z2f					REAL4		?
	Star8Xf					REAL4		?
	Star8Yf					REAL4		?
	Star8Zf					REAL4		?
	Star8Z2f					REAL4		?
	StarPulse					BOOL		?
	PulseWidth				db			?
	MoreStars				BOOL		?
; Editboxes
	BoxesOn					BOOL		?
	NameInit					BOOL		?
	CursorSt					BOOL		?
	CursorCounter				dw			?
	keys						db 			256 dup (?)
	keyTimer					dd			?
	keyDelay					equ			50
	AdjustNamePos			dd			?
	AdjustSerialPos			dd			?
	nLen					dd			?
	NameChrPos				dd			?
; Font
	base					dd			?
	baseThin					dd			?
	font						dd			?
	oldfont					dd			?
	fontThin					dd			?
	oldfontThin				dd			?
; Scroller	
	SiteTimer					dw			?
	SiteCounter				dd			?
	ShowScroller				BOOL		?
	ScrTxtActHead				dd			?
	SiteShowTimeDW			dw			?
; Keygen
	NameValid				BOOL		?
; Music
	nMusicSize				DWORD		?
	pMusic					LPVOID		?
	PatPosOld				db			?
	PatAct					db			?
	PatPosAct				db			?
	XMLoop					db			?

; Let the bugs come over me... :P ====================
.code

	include DoKey.asm

start:
invoke GetModuleHandle,0
mov hInstance, eax
invoke WinMain,hInstance,0,0,0
invoke ExitProcess, eax

; PROC WinMain =================================
WinMain proc hInst:HWND, hPrevInst:UINT, CmdLine:WPARAM, CmdShow:LPARAM
	LOCAL msg:MSG, done:UINT

	invoke CreateGLWindow,addr txt_Window_Title,WindowWidth,WindowHeight,16
	.IF !eax
		ret
	.ENDIF
	
	mov done,FALSE
	
	.WHILE !done
		invoke PeekMessage,addr msg,NULL,0,0,PM_REMOVE
		.IF eax
			.IF msg.message == WM_QUIT
				mov done,TRUE
			.ELSE
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			.ENDIF
		.ELSE
;Move GLScene
			invoke GetTickCount
			mov ebx,eax
			sub eax,TickTimer
			.IF eax > 12      ; This value is kinda FPS...    1s = 1000ms -> 1 Frame every 12ms -> ~83fps
				mov TickTimer,ebx
				invoke DrawGLScene
				.IF ((active) && (!eax))
					mov done, 1
				.ELSE
					invoke SwapBuffers,hDC
				.ENDIF
				.IF ZoomDone == FALSE
					.IF ZoomedIn == FALSE
						mov ZoomingNow, TRUE
						invoke ZoomCube,ZoomRange
					.ELSE
						mov ZoomingNow, TRUE
						invoke ZoomCube,ZoomRange
					.ENDIF
				.ENDIF
				invoke Effects
			.ENDIF
	
		.ENDIF
	.ENDW
	invoke KillGLWindow
	
	mov eax,msg.wParam
	ret
WinMain endp

; PROC WndProc ================================
WndProc proc hWind:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL ps:PAINTSTRUCT

	.IF uMsg == WM_ACTIVATE
		mov eax,wParam
		.IF !ah
			mov active,TRUE
		.ELSE
			mov active,FALSE
		.ENDIF
		xor eax, eax
		ret
		
	.ELSEIF uMsg == WM_CREATE

		invoke GetCurrentProcess
		invoke SetPriorityClass,eax,128
; Initialize Text-Scroller-Line-Pointers:		
		lea eax, ScrTxt1Delay                
		lea ebx, ScrSitePtrBuffer
		mov [ebx], eax
		xor ecx,ecx
		mov cl, [eax]
		shl ecx,5
		mov SiteShowTimeDW,cx
		add eax,1
@@:
		mov cl, [eax]
		.IF cl == 0
			inc eax
			add ebx, 4
			mov [ebx],eax
			jmp @b
		.ELSEIF cl != 0FFh
			inc eax
			jmp @b
		.ENDIF
; Initialize MFMPLAYER:		
		push esi
		invoke FindResource, hInstance, ID_Chiptune, RT_RCDATA
		push eax
		invoke SizeofResource, hInstance, eax
		mov nMusicSize, eax
		pop eax
		invoke LoadResource, hInstance, eax
		invoke LockResource, eax
		mov esi, eax
		mov eax, nMusicSize
		add eax, SIZEOF nMusicSize
		invoke GlobalAlloc, GPTR, eax
		mov pMusic, eax
		mov ecx, nMusicSize
		mov dword ptr [eax], ecx
		add eax, SIZEOF nMusicSize
		mov edi, eax
		rep movsb
		pop esi
		invoke mfmPlay, pMusic
	
	.ELSEIF uMsg==WM_SYSCOMMAND
		.IF wParam == SC_SCREENSAVE or SC_MONITORPOWER
			xor eax, eax
			ret
		.ENDIF
	
	.ELSEIF uMsg == WM_KEYDOWN
 ; Following is a simulation of a window editbox:
 		.IF keyTimer == 0 
			mov eax, wParam
			mov keys[eax], 1   
			.IF al == 20h || (al >= 30h && al <= 39h) || (al >= 41h && al <= 5Ah) || ((!keys[VK_SHIFT]) && (al >= 0BBh && al <= 0BFh))
				lea edx, tbxName
				add edx, NameChrPos
				.IF !keys[VK_SHIFT] && al >= 41h && al <= 5Ah
					add al, 20h
				.ELSEIF keys[VK_SHIFT] && al >=31h && al <= 39h
					sub al, 10h
				.ELSEIF !keys[VK_SHIFT] && al >=0BBh && al <= 0BFh
					sub al, 90h
				.ELSEIF 
				.ENDIF
				.IF NameChrPos < 30
					mov [edx], ax
					add NameChrPos, 1
					invoke InitKeygen
					invoke szCatStr, addr tbxName, addr Cursor
					invoke CenterString
				.ENDIF
			.ELSEIF ax == [VK_BACK] && NameChrPos > 0
				lea edx, tbxName
				sub NameChrPos, 1
				add edx, NameChrPos
				xor al,al
				mov [edx], al
				invoke InitKeygen
				invoke szCatStr, addr tbxName, addr Cursor
				invoke CenterString
			.ENDIF
		.ELSE
			add keyTimer,1
			.IF keyTimer == keyDelay
				mov keyTimer, 0
			.ENDIF
		.ENDIF
		
	.ELSEIF uMsg == WM_KEYUP
		mov eax, wParam
		mov keys[eax], 0
	
	.ELSEIF uMsg==WM_CLOSE
		invoke mfmPlay, 0
		invoke PostQuitMessage,0
		xor eax, eax
		ret
		
	.ELSEIF uMsg==WM_LBUTTONDOWN
		mov eax,lParam
		and eax,0ffffh
		mov hitpoint.x,eax
		mov eax,lParam
		shr eax,16
		mov hitpoint.y,eax
		.IF hitpoint.x >= 0 && hitpoint.x < 63 && hitpoint.y > 219 && hitpoint.y < 238 && ZoomingNow == FALSE  ; Left button pressed ?
			.IF ZoomLevel == 0 
				invoke InitKeygen
				mov ZoomLevel,2
				mov ZoomDone,FALSE
				mov ShowScroller, FALSE
			.ELSEIF ZoomLevel == 1 
				invoke InitKeygen
				mov ZoomDone,FALSE
				mov ZoomLevel,2
			.ELSEIF ZoomLevel == 2 
				mov BoxesOn, FALSE
				mov ZoomDone,FALSE
				mov ZoomLevel,1
			.ENDIF
		.ENDIF
		.IF hitpoint.x > 295 && hitpoint.x < 358 && hitpoint.y > 219 && hitpoint.y < 238 && ZoomingNow == FALSE   ; Right button pressed ?
			.IF ZoomLevel == 0
				mov ZoomDone,FALSE
				mov ZoomLevel,1
				mov ShowScroller, FALSE
				
			.ELSEIF ZoomLevel == 1
				mov ZoomDone,FALSE
				mov ZoomLevel,0
				
			.ELSEIF ZoomLevel == 2 
				invoke lstrlen, ADDR tbxSerial	; Shitload of APIs just to copy sumthing to the clipboard... :/
				inc eax
				mov nLen, eax
				invoke OpenClipboard, 0
				invoke GlobalAlloc, GHND, nLen
				mov hMem, eax
				invoke GlobalLock, eax
				mov pMem, eax
				lea esi, tbxSerial
				mov edi, eax
				mov ecx, nLen
				rep movsb
				invoke EmptyClipboard
				invoke GlobalUnlock, hMem
				.IF NameValid
					invoke SetClipboardData, CF_TEXT, hMem
				.ENDIF
				invoke CloseClipboard
			.ENDIF
		.ENDIF
	
	.ENDIF
	  
	invoke DefWindowProc,hWind,uMsg,wParam,lParam
	ret
WndProc endp

; PROC CreateGLWindow ==========================
CreateGLWindow proc WinTitle:DWORD, WinWidth:DWORD, WinHeight:DWORD, WinBits:UINT
	LOCAL PixelFormat:GLuint, pfd:PIXELFORMATDESCRIPTOR
	LOCAL WindowRect:RECT, dmScreenSettings:DEVMODE, wc:WNDCLASS
	LOCAL ratio:GLdouble

	mov WindowRect.left,0
	mov WindowRect.top,0
	push WinWidth
	pop WindowRect.right
	push WinHeight
	pop WindowRect.bottom
	
	mov wc.style,CS_HREDRAW or CS_VREDRAW or CS_OWNDC
	mov wc.lpfnWndProc, offset WndProc
	mov wc.cbClsExtra,0
	mov wc.cbWndExtra,0
	push hInstance
	pop wc.hInstance
	mov wc.hbrBackground,NULL
	mov wc.lpszMenuName,NULL
	mov wc.lpszClassName,offset txt_OpenGL
	invoke LoadIcon,hInstance,ID_Icon
	mov wc.hIcon,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
; Register the window class
	invoke RegisterClass,addr wc
	.IF !eax
; Uncomment this for Bug-hunting !
;		invoke MessageBox,NULL,addr txt_WC_Failed,addr txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax,FALSE
		ret
	.ENDIF

	invoke AdjustWindowRectEx,addr WindowRect,
					WS_OVERLAPPEDWINDOW,
					FALSE,
					WS_EX_APPWINDOW or WS_EX_WINDOWEDGE
	mov eax, WindowRect.left
	sub WindowRect.right,eax
	mov eax, WindowRect.top
	sub WindowRect.bottom, eax
	
;  Center window
	invoke GetSystemMetrics,SM_CXSCREEN
	sub eax,WindowWidth  
	shr eax,1
	mov ScreenWidth,eax
	invoke GetSystemMetrics,SM_CYSCREEN
	sub eax,WindowHeight  
	shr eax,1
	mov ScreenHeight,eax
	
	invoke CreateWindowEx,
				WS_EX_APPWINDOW or WS_EX_CLIENTEDGE,
				addr txt_OpenGL,addr txt_Window_Title,
				WS_SYSMENU or WS_MINIMIZEBOX,
				ScreenWidth,ScreenHeight,WindowRect.right,WindowRect.bottom,
				NULL,NULL,hInstance,NULL
	.IF !eax
		invoke KillGLWindow
; Uncomment this for Bug-hunting !
;		invoke MessageBox,NULL,txt_WindowCreateError,txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax, FALSE
		ret
	.ENDIF
	mov hWnd,eax

	ZeroMemory &pfd,sizeof(PIXELFORMATDESCRIPTOR)
	mov pfd.nSize,sizeof(PIXELFORMATDESCRIPTOR)
	mov pfd.nVersion,1
	mov pfd.dwFlags,PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER 
	mov pfd.iPixelType,PFD_TYPE_RGBA
	mov pfd.cColorBits,16
	mov pfd.cDepthBits,16
	mov pfd.dwLayerMask,PFD_MAIN_PLANE
	
; Try to get a device context
	invoke GetDC,hWnd
	.IF !eax
		invoke KillGLWindow
; Uncomment this for Bug-hunting !
;	invoke MessageBox,NULL,addr txt_GL_Context_Failed,addr txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax,FALSE
		ret
	.ENDIF
	mov hDC,eax
; Select pixel format
	invoke ChoosePixelFormat,hDC,addr pfd
	.IF !eax
		invoke KillGLWindow
; Uncomment this for Bug-hunting !
;		invoke MessageBox,NULL,addr txt_PixelFormat_Failed,addr txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax,FALSE
		ret
	.ENDIF
	mov PixelFormat,eax
; Set pixel format
	invoke SetPixelFormat,hDC,PixelFormat,addr pfd
	.IF !eax
		invoke KillGLWindow
; Uncomment this for Bug-hunting !
;		invoke MessageBox,NULL,addr txt_SetPixelFormat_Failed,addr txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax,FALSE
		ret
	.ENDIF
; Get rendering context
	invoke wglCreateContext,hDC
	.IF !eax
		invoke KillGLWindow
; Uncomment this for Bug-hunting !
;		invoke MessageBox,NULL,addr txt_RC_Failed,addr txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax,FALSE
		ret
	.ENDIF
	mov hRC,eax
; Activate rendering context
	invoke wglMakeCurrent,hDC,hRC
	.IF !eax
		invoke KillGLWindow
; Uncomment this for Bug-hunting !
;		invoke MessageBox,NULL,addr txt_ActivateRC_Failed,addr txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax,FALSE
		ret
	.ENDIF
	
	invoke ShowWindow,hWnd,SW_SHOW
	invoke SetForegroundWindow,hWnd
	invoke SetFocus,hWnd
	invoke glViewport, 0, 0, WinWidth, WinHeight
	invoke glMatrixMode, GL_PROJECTION
	invoke glLoadIdentity  
	fild WinWidth
	fild WinHeight
	fdivp st(1),st(0)
	fstp ratio
	_gluPerspective 45.0f, ratio, 0.1f, 100.0f
	invoke glMatrixMode, GL_MODELVIEW
	invoke glLoadIdentity
	
	invoke InitGL
	.IF !eax
		invoke KillGLWindow
; Uncomment this for Bug-hunting !
;		invoke MessageBox,NULL,addr txt_GLInit_Failed,addr txt_Error,MB_OK or MB_ICONEXCLAMATION
		mov eax,FALSE
		ret
	.ENDIF
	    
	mov eax,TRUE
	ret
CreateGLWindow endp

; PROC InitGL ===================================
InitGL proc

	invoke LoadGLTextures   ; Load textures
	.IF (eax == NULL)       ; Exit if the textures failed to load
		ret
	.ENDIF
	    
	invoke glEnable, GL_TEXTURE_2D                              ; Enable texture mapping
	invoke glShadeModel,GL_SMOOTH                               ; Enable smooth shading
	invoke glClearColor, backcolourR, backcolourG, backcolourB ,backcolourA
	_glClearDepth 1.0f                                          ; Depth buffer setup
	invoke glEnable, GL_DEPTH_TEST                              ; Enable depth testing
	invoke glDepthFunc, GL_LEQUAL                               ; Set type of depth test
	invoke glHint,GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST      ; Set nice perspective calculations
	
	invoke glGenLists, 96
	mov base, eax 
	invoke CreateFont, -13, 7, 0, 0, FW_BOLD, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, PROOF_QUALITY, FF_DONTCARE, addr fontfamily 
	mov font, eax
	invoke SelectObject, hDC, font
	mov oldfont, eax
	invoke wglUseFontBitmaps, hDC, 32, 96, base
	invoke SelectObject, hDC, oldfont
	invoke DeleteObject, font 
	
	invoke glGenLists, 96
	mov baseThin, eax 
	invoke CreateFont, -20, 8, 0, 0, FW_BOLD, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, PROOF_QUALITY, FF_DONTCARE, addr fontfamilyThin 
	mov fontThin, eax
	invoke SelectObject, hDC, fontThin
	mov oldfontThin, eax
	invoke wglUseFontBitmaps, hDC, 32, 96, baseThin
	invoke SelectObject, hDC, oldfontThin
	invoke DeleteObject, fontThin 
	
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	invoke glEnable, GL_BLEND;_DST ;or GL_LIGHT1
	invoke glFogi, GL_FOG_MODE, fogmode    ; Fog mode
	invoke glFogfv, GL_FOG_COLOR, addr fogcolor ; Set fog color
	_glFogf GL_FOG_DENSITY, 0.28f               ; How dense will the fog be
	invoke glHint, GL_FOG_HINT, GL_DONT_CARE    ; Fog hint value
	_glFogf GL_FOG_START, 2.5f                  ; Fog start depth
	_glFogf GL_FOG_END, 6.0f                    ; Fog End depth
	invoke glEnable, GL_FOG                     ; Enable fog
	
	mov eax, 1          
	ret
InitGL endp

; PROC LoadGLTextures ===========================
LoadGLTextures proc
	LOCAL ImgInfo:BITMAP

; Logo_Outside
	invoke glGenTextures, 1, ADDR textureLogoOutside   ; Create  texture
	invoke LoadImage, hInstance, ID_Cube_Logo_Outside, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION
	.IF (eax == NULL)   ; Quit if file load failed
		ret
	.ENDIF
	mov hBMPOutside, eax
	invoke GetObject, hBMPOutside, sizeof BITMAP, ADDR ImgInfo
	invoke glBindTexture, GL_TEXTURE_2D, textureLogoOutside
	invoke glTexImage2D, GL_TEXTURE_2D, 0, 3, ImgInfo.bmWidth, ImgInfo.bmHeight,\
					0, GL_BGR_EXT, GL_UNSIGNED_BYTE, ImgInfo.bmBits
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST

; Logo_Inside
	invoke glGenTextures, 1, ADDR textureLogoInside   ; Create  texture
	invoke LoadImage, hInstance, ID_Cube_Logo_Inside, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION
	.IF (eax == NULL)   ; Quit if file load failed
		ret
	.ENDIF
	mov hBMPInside, eax
	invoke GetObject, hBMPInside, sizeof BITMAP, ADDR ImgInfo
	invoke glBindTexture, GL_TEXTURE_2D, textureLogoInside
	invoke glTexImage2D, GL_TEXTURE_2D, 0, 3, ImgInfo.bmWidth, ImgInfo.bmHeight,\
					0, GL_BGR_EXT, GL_UNSIGNED_BYTE, ImgInfo.bmBits
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST

; Blank_Button
	invoke glGenTextures, 1, ADDR textureButton   ; Create  texture
	invoke LoadImage, hInstance, ID_Button, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION
	.IF (eax == NULL)   ; Quit if file load failed
		ret
	.ENDIF
	mov hBMPButton, eax
	invoke GetObject, hBMPButton, sizeof BITMAP, ADDR ImgInfo
	invoke glBindTexture, GL_TEXTURE_2D, textureButton
	invoke glTexImage2D, GL_TEXTURE_2D, 0, 3, ImgInfo.bmWidth, ImgInfo.bmHeight,\
					0, GL_BGR_EXT, GL_UNSIGNED_BYTE, ImgInfo.bmBits
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST

; Stars
	invoke glGenTextures, 1, ADDR textureStars
	invoke LoadImage, hInstance, ID_Stars, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION
	.IF (eax == NULL)   ; Quit if file load failed
		ret
	.ENDIF
	mov hBmpStars, eax
	invoke GetObject, hBmpStars, sizeof BITMAP, ADDR ImgInfo
	invoke glBindTexture, GL_TEXTURE_2D, textureStars
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
	invoke glTexImage2D, GL_TEXTURE_2D, 0, 4, ImgInfo.bmWidth, ImgInfo.bmHeight,\
	                         0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, ImgInfo.bmBits                         

	invoke glGenTextures, 1, ADDR textureStars1
	invoke LoadImage, hInstance, ID_Stars1, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION
	.IF (eax == NULL)   ; Quit if file load failed
		ret
	.ENDIF
	mov hBmpStars1, eax
	invoke GetObject, hBmpStars1, sizeof BITMAP, ADDR ImgInfo
	invoke glBindTexture, GL_TEXTURE_2D, textureStars1
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
	invoke glTexImage2D, GL_TEXTURE_2D, 0, 4, ImgInfo.bmWidth, ImgInfo.bmHeight,\
	                         0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, ImgInfo.bmBits                         

	invoke glGenTextures, 1, ADDR textureStars2
	invoke LoadImage, hInstance, ID_Stars2, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION
	.IF (eax == NULL)   ; Quit if file load failed
		ret
	.ENDIF
	mov hBmpStars2, eax
	invoke GetObject, hBmpStars2, sizeof BITMAP, ADDR ImgInfo
	invoke glBindTexture, GL_TEXTURE_2D, textureStars2
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
	invoke glTexImage2D, GL_TEXTURE_2D, 0, 4, ImgInfo.bmWidth, ImgInfo.bmHeight,\
	                         0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, ImgInfo.bmBits                         
	
	mov eax, 1
	ret
LoadGLTextures endp 

; PROC DrawGLScene ============================
DrawGLScene proc
	LOCAL ScrSin:REAL4, ScrCos:REAL4, ColCos:REAL4, ScrCos2:REAL4
	LOCAL Sinus1:REAL4, Cosinus1:REAL4
	LOCAL Sinus2:REAL4, Cosinus2:REAL4
	LOCAL Sinus3:REAL4, Cosinus3:REAL4
	LOCAL Sinus4:REAL4, Cosinus4:REAL4

; Clear !!!!!!!
	invoke glClearColor, backcolourR, backcolourG, backcolourB ,backcolourA
	invoke glClear,GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
	
; ********** CUBE **********
	invoke glLoadIdentity
	_glTranslatef 0.0f, CubeJumpCoord, z
	_glRotatef xrot, 0.0f, 0.0f, 1.0f
	_glRotatef yrot, 0.0f, 1.0f, 0.0f
	.IF LogoInside == FALSE
		invoke glBindTexture, GL_TEXTURE_2D, textureLogoOutside
	.ELSE
		invoke glBindTexture, GL_TEXTURE_2D, textureLogoInside
	.ENDIF
	invoke glColor4ub, 255, 255, 255, 255
	invoke glBegin, GL_QUADS
	;front
	_glNormal3f 0.0f,0.0f,1.0f
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f CornerLBFNeg,CornerLBFNeg, CornerLBFPos
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f  CornerRBFPos,CornerRBFNeg, CornerRBFPos
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f  CornerRTFPos, CornerRTFPos, CornerRTFPos
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f CornerLTFNeg, CornerLTFPos, CornerLTFPos
	;back
	_glNormal3f 0.0f,0.0f,-1.0f
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f CornerLBBNeg,CornerLBBNeg,CornerLBBNeg
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f CornerLTBNeg, CornerLTBPos,CornerLTBNeg
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f  CornerRTBPos, CornerRTBPos,CornerRTBNeg
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f  CornerRBBPos,CornerRBBNeg,CornerRBBNeg
	;top
	_glNormal3f 0.0f,1.0f,0.0f
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f CornerLTBNeg, CornerLTBPos,CornerLTBNeg
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f CornerLTFNeg, CornerLTFPos, CornerLTFPos
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f  CornerRTFPos, CornerRTFPos, CornerRTFPos
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f  CornerRTBPos, CornerRTBPos,CornerRTBNeg
	;bottom
	_glNormal3f 0.0f,-1.0f,0.0f
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f CornerLBBNeg,CornerLBBNeg,CornerLBBNeg
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f  CornerRBBPos,CornerRBBNeg,CornerRBBNeg
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f  CornerRBFPos,CornerRBFNeg, CornerRBFPos
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f CornerLBFNeg,CornerLBFNeg, CornerLBFPos
	;right
	_glNormal3f 1.0f,0.0f,0.0f
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f  CornerRBBPos,CornerRBBNeg,CornerRBBNeg
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f  CornerRTBPos,CornerRTBPos,CornerRTBNeg
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f  CornerRTFPos, CornerRTFPos, CornerRTFPos
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f  CornerRBFPos,CornerRBFNeg, CornerRBFPos
	;left
	_glNormal3f -1.0f,0.0f,0.0f
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f CornerLBBNeg,CornerLBBNeg,CornerLBBNeg
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f CornerLBFNeg,CornerLBFNeg, CornerLBFPos
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f CornerLTFNeg, CornerLTFPos, CornerLTFPos
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f CornerLTBNeg, CornerLTBPos,CornerLTBNeg
	invoke glEnd
; Rotation
	fld xrot    ; xrot += xspeed
	fadd xspeed
	fstp xrot
	fld yrot    ; yrot += yspeed
	fadd yspeed
	fstp yrot


	
; ********** BLANK_BUTTONS **********
; * Button_Enter/Leave *
	invoke glLoadIdentity
	_glTranslatef -0.0615f, ButtonJumpY, -0.12f           ; POSITION !
	invoke glBindTexture, GL_TEXTURE_2D, textureButton
	invoke glColor4ub, 255, 255, 255, 170
	invoke glBegin, GL_POLYGON
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f -0.0130f,-0.0037f,0.0f
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f 0.0130f,-0.0037f,0.0f
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f 0.0130f,0.0037f,0.0f
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f -0.0130f,0.0037f,0.0f
	invoke glEnd
; * Button_Exit/Copy/Back *
	invoke glLoadIdentity
	_glTranslatef 0.0608f, ButtonJumpY, -0.12f           ; POSITION !
	invoke glBegin, GL_POLYGON
	_glTexCoord2f 0.0f,0.0f
	_glVertex3f -0.0130f,-0.0037f,0.0f
	_glTexCoord2f 1.0f,0.0f
	_glVertex3f 0.0130f,-0.0037f,0.0f
	_glTexCoord2f 1.0f,1.0f
	_glVertex3f 0.0130f,0.0037f,0.0f
	_glTexCoord2f 0.0f,1.0f
	_glVertex3f -0.0130f,0.0037f,0.0f
	invoke glEnd
; * Label_Name/Serial *
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		invoke glLoadIdentity
		_glTranslatef -0.059f, 0.0078f, -0.12f           ; POSITION !
		invoke glColor4ub, 255, 255, 255, 200
		invoke glBegin, GL_POLYGON
		_glTexCoord2f 0.0f,0.0f
		_glVertex3f -0.0122f,-0.0037f,0.0f
		_glTexCoord2f 1.0f,0.0f
		_glVertex3f 0.0122f,-0.0037f,0.0f
		_glTexCoord2f 1.0f,1.0f
		_glVertex3f 0.0122f,0.0037f,0.0f
		_glTexCoord2f 0.0f,1.0f
		_glVertex3f -0.0122f,0.0037f,0.0f
		invoke glEnd
		invoke glLoadIdentity
		_glTranslatef -0.059f, -0.0075f, -0.12f           ; POSITION !
		invoke glBegin, GL_POLYGON
		_glTexCoord2f 0.0f,0.0f
		_glVertex3f -0.0122f,-0.0037f,0.0f
		_glTexCoord2f 1.0f,0.0f
		_glVertex3f 0.0122f,-0.0037f,0.0f
		_glTexCoord2f 1.0f,1.0f
		_glVertex3f 0.0122f,0.0037f,0.0f
		_glTexCoord2f 0.0f,1.0f
		_glVertex3f -0.0122f,0.0037f,0.0f
		invoke glEnd
; * Editbox_Name/Serial *
		invoke glLoadIdentity
		_glTranslatef 0.013f, 0.0079f, -0.12f           ; POSITION !
		invoke glBegin, GL_POLYGON
		_glTexCoord2f 0.0f,0.0f
		_glVertex3f -0.0560f,-0.0053f,0.0f
		_glTexCoord2f 1.0f,0.0f
		_glVertex3f 0.0560f,-0.0053f,0.0f
		_glTexCoord2f 1.0f,1.0f
		_glVertex3f 0.0560f,0.0053f,0.0f
		_glTexCoord2f 0.0f,1.0f
		_glVertex3f -0.0560f,0.0053f,0.0f
		invoke glEnd
		invoke glLoadIdentity
		_glTranslatef 0.013f, -0.0074f, -0.12f           ; POSITION !
		invoke glBegin, GL_POLYGON
		_glTexCoord2f 0.0f,0.0f
		_glVertex3f -0.0560f,-0.0053f,0.0f
		_glTexCoord2f 1.0f,0.0f
		_glVertex3f 0.0560f,-0.0053f,0.0f
		_glTexCoord2f 1.0f,1.0f
		_glVertex3f 0.0560f,0.0053f,0.0f
		_glTexCoord2f 0.0f,1.0f
		_glVertex3f -0.0560f,0.0053f,0.0f
		invoke glEnd
	.ENDIF
	
	
; ********** STARS **********
; * 1st Star *
	.IF PatAct > 0
		invoke glLoadIdentity
			_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star1Xf, Star1Yf, Star1Zf
		invoke glBindTexture, GL_TEXTURE_2D, textureStars1
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 55, 0, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ELSEIF DoFog  ;  *** FOG-STAR ***
		invoke glLoadIdentity
		invoke glTranslatef,fpc(0.0f), fpc(0.0f), fpc(-1.0f)
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4f, fpc(1.0f), fpc(0.9f), fpc(0.5f), FogStarDens
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,FogStarNeg,FogStarNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, FogStarPos,FogStarNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, FogStarPos,FogStarPos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, FogStarNeg,FogStarPos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star1Xf, Star1Yf, Star1Z2f
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 64, 0, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
; * 2nd Star *
	.IF PatAct > 0
		invoke glLoadIdentity
			_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star2Xf, Star2Yf, Star2Zf
		invoke glBindTexture, GL_TEXTURE_2D, textureStars1
		_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 0, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star2Xf, Star2Yf, Star2Z2f
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 0, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
; * 3rd Star *
	.IF PatAct > 0
		invoke glLoadIdentity
				_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star3Xf, Star3Yf, Star3Zf     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars2
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 32, 0, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star3Xf, Star3Yf, Star3Z2f 
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 32, 0, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
; * 4th Star *
	.IF PatAct > 0
		invoke glLoadIdentity
				_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star4Xf, Star4Yf, Star4Zf     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars2
		_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 90, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star4Xf, Star4Yf, Star4Z2f   
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 90, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
; * 5th Star *
	.IF PatAct > 1
		invoke glLoadIdentity
				_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star5Xf, Star5Yf, Star5Zf     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars1
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 64, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star5Xf, Star5Yf, Star5Z2f 
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 64, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
; * 6th Star *
	.IF PatAct > 1
		invoke glLoadIdentity
				_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star6Xf, Star6Yf, Star6Zf     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars1
		_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 32, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star6Xf, Star6Yf, Star6Z2f     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 0, 32, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
; * 7th Star *
	.IF PatAct > 1
		invoke glLoadIdentity
				_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star7Xf, Star7Yf, Star7Zf     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars2
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 32, 64, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star7Xf, Star7Yf, Star7Z2f      
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 32, 64, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
; * 8th Star *
	.IF PatAct > 1
		invoke glLoadIdentity
				_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glTranslatef,Star8Xf, Star8Yf, Star8Zf     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars2
		_glRotatef SpinMin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 32, 32, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	.IF MoreStars && !LogoInside
		invoke glLoadIdentity
		invoke glTranslatef,Star8Xf, Star8Yf, Star8Z2f     
		invoke glBindTexture, GL_TEXTURE_2D, textureStars
		_glRotatef Spin,0.0f,0.0f,1.0f
		invoke glColor4ub, 255, 32, 32, 255
		invoke glBegin, GL_QUADS
		_glTexCoord2f 0.0f,0.0f
		invoke glVertex3f,StarSizeNeg,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,0.0f
		invoke glVertex3f, StarSizePos,StarSizeNeg,fpc(0.0f)
		_glTexCoord2f 1.0f,1.0f
		invoke glVertex3f, StarSizePos,StarSizePos,fpc(0.0f)
		_glTexCoord2f 0.0f,1.0f
		invoke glVertex3f, StarSizeNeg,StarSizePos,fpc(0.0f)
		invoke glEnd
	.ENDIF
	
	fld Spin
	fsub SpinSpeed
	fst Spin
	fchs
	fstp SpinMin
	
	fld StarCos1
	fcos
	fstp Sinus1
	fld StarCos1
	fsin 
	fstp Cosinus1
	fld Sinus1
	fmul StarXRadius
	fstp Sinus1
	fld Cosinus1
	fmul StarXRadius
	fstp Cosinus1
	
	fld StarCos2
	fsin 
	fstp Sinus2
	fld StarCos2
	fcos 
	fstp Cosinus2
	fld Sinus2
	fmul StarXRadius
	fstp Sinus2
	fld Cosinus2
	fmul StarXRadius
	fstp Cosinus2

	fld StarCos3
	fcos 
	fstp Sinus3
	fld StarCos3
	fsin 
	fstp Cosinus3
	fld Sinus3
	fmul StarXRadius
	fstp Sinus3
	fld Cosinus3
	fmul StarXRadius
	fstp Cosinus3
	
	fld StarCos4
	fcos 
	fstp Sinus4
	fld StarCos4
	fsin 
	fstp Cosinus4
	fld Sinus4
	fmul StarXRadius
	fstp Sinus4
	fld Cosinus4
	fmul StarXRadius
	fstp Cosinus4
	
	fld Sinus1
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		fmul StepXfIn
		fst Star1Xf
		fst Star3Xf
		fchs
		fst Star2Xf
		fstp Star4Xf
	.ELSE
		fmul StepXf
		fst Star1Xf
		fstp Star2Xf
		fld Sinus2
		fmul StepXf
		fst Star3Xf
		fstp Star4Xf
	.ENDIF
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		fld StarsYfIn
		fst Star2Yf
		fchs
		fst Star1Yf
		fdiv fpc(-2.0)
		fst Star3Yf
		fchs
		fstp Star4Yf
	.ELSE
		fld Sinus1
		fmul StepYf
		fst Star2Yf
		fchs
		fstp Star1Yf
		fld Sinus2
		fmul StepYf
		fdiv fpc(2.0)
		fst Star4Yf
		fchs
		fstp Star3Yf
	.ENDIF
	fld Cosinus1
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		fstp Star2Zf
		fld StarDepthfIn
		fst Star1Zf
		fst Star2Zf
		fst Star3Zf
		fstp Star4Zf
	.ELSE
		fmul StepZf
		fadd StarDepthf
		fst Star2Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fst Star2Z2f
		fsub StarDepthf
		fdiv StarZAdd
		fchs
		fadd StarDepthf
		fst Star1Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fstp Star1Z2f
		fld Cosinus2
		fmul StepZf
		fadd StarDepthf
		fst Star4Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fst Star4Z2f
		fsub StarDepthf
		fdiv StarZAdd
		fchs
		fadd StarDepthf
		fst Star3Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fstp Star3Z2f
		fwait
	.ENDIF
	
	fld Sinus3
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		fmul StepXfIn
		fst Star5Xf
		fst Star7Xf
		fchs
		fst Star6Xf
		fstp Star8Xf
	.ELSE
		fmul StepX2f
		fst Star5Xf
		fstp Star6Xf
		fld Sinus4
		fmul StepX2f
		fdiv fpc(-2.0)
		fst Star7Xf
		fstp Star8Xf
	.ENDIF
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		fld StarsYfIn
		fst Star6Yf
		fchs
		fst Star5Yf
		fdiv fpc(-2.0)
		fst Star7Yf
		fchs
		fstp Star8Yf
	.ELSE
		fld Sinus3
		fmul StepY2f
		fst Star6Yf
		fchs
		fstp Star5Yf
		fld Sinus4
		fmul StepY2f
		fst Star8Yf
		fchs
		fstp Star7Yf
	.ENDIF
	fld Cosinus3
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		fstp Star6Zf
		fld StarDepthfIn
		fst Star5Zf
		fst Star6Zf
		fst Star7Zf
		fstp Star8Zf
	.ELSE
		fmul StepZf
		fadd StarDepthf
		fst Star6Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fst Star6Z2f
		fsub StarDepthf
		fdiv StarZAdd
		fchs
		fadd StarDepthf
		fst Star5Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fstp Star5Z2f
		fld Cosinus4
		fmul StepZf
		fadd StarDepthf
		fst Star8Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fst Star8Z2f
		fsub StarDepthf
		fdiv StarZAdd
		fchs
		fadd StarDepthf
		fst Star7Zf
		fsub StarDepthf
		fmul StarZAdd
		fadd StarDepthf
		fstp Star7Z2f
		fwait
	.ENDIF

	fld StarCos1
	fadd  StarSpeed1   
	fstp StarCos1
	fld StarCos2
	fadd  StarSpeed1   
	fstp StarCos2

	fld StarCos3
	fadd  StarSpeed1  
	fstp StarCos3
	fld StarCos4
	fadd  StarSpeed1   
	fstp StarCos4
	
	
; ********** BUTTON/BOX_TEXT **********
	invoke glBindTexture, GL_TEXTURE_2D, NULL   ; !!!!!!!!!!!!! Deactivate Textures !!!!!!!!!!!!
	invoke glLoadIdentity                               ;reset modelview matrix
	_glTranslatef -0.0f,0.0f,-0.11f
	_glColor3f 0.9f,0.8f,0.6f
; * Button_Text   Enter/Leave+About/Copy/Back *
	.IF ZoomedIn == FALSE
		_glRasterPos2f -0.0635f,TextJumpY
		invoke PrintGLText, ADDR txtEnter, FALSE
		.IF ZoomedOut
			_glRasterPos2f 0.0495f,TextJumpY
			invoke PrintGLText, ADDR txtBack, FALSE
		.ELSE
			_glRasterPos2f 0.0483f,TextJumpY
			invoke PrintGLText, ADDR txtAbout, FALSE
		.ENDIF
	.ELSE
		_glRasterPos2f -0.064f,TextJumpY
		invoke PrintGLText, ADDR txtLeave, FALSE
		_glRasterPos2f 0.05f,TextJumpY
		invoke PrintGLText, ADDR txtCopy, FALSE
	.ENDIF
; * Label/Editbox_Text  Name/Serial *
	.IF ZoomDone == TRUE && ZoomedIn ==TRUE && ZoomingNow == FALSE
		_glRasterPos2f -0.0615f,0.0055f
		invoke PrintGLText, ADDR txtName, FALSE
		_glRasterPos2f -0.0618f,-0.0085f
		invoke PrintGLText, ADDR txtSerial, FALSE
		invoke glRasterPos2f, NameXf,NameYf
		.IF CursorCounter == 30
			.IF CursorSt
				lea edx, tbxName
				add edx, NameChrPos
				mov cl, Cursor
				xor ch,ch
				mov [edx], cx
				mov CursorSt, FALSE
			.ELSE
				lea edx, tbxName
				add edx, NameChrPos
				mov cl, CursorOff
				xor ch,ch
				mov [edx], cx
				mov CursorSt, TRUE
			.ENDIF
			mov CursorCounter,0
		.ELSE
			add CursorCounter,1
		.ENDIF
		invoke PrintGLText, ADDR tbxName, TRUE ;tbxNameConst
		invoke glRasterPos2f, SerialXf,SerialYf
		invoke PrintGLText, ADDR tbxSerial, TRUE
	.ENDIF
	
	
; ********** ABOUT_TEXTSCROLLER **********
	.IF ShowScroller
		invoke glLoadIdentity                  
		_glTranslatef -0.0f,0.0f,-0.95f
		finit
		fld cnt1
		fcos 
		fstp ScrSin
		fld cnt2
		fsin 
		fst ScrCos
		fdiv fpc(4.0f)
		fadd fpc(0.9f)
		fstp ColCos  
		fwait
		invoke glColor3f, fpc(1.0f), ColCos, ColCos           
		fld ScrSin
		fmul fpc(0.08f)
		fadd fpc(-0.47f)   ; PosX-Adjust
		fstp ScrSin
		fld ScrCos
		fmul fpc(0.08f)
		fadd fpc(0.24f)   ; PosY-Adjust
		fstp ScrCos
		fwait
		
		mov ax,SiteShowTimeDW
		.IF SiteTimer == ax
			.IF SiteCounter == SiteNum-1
				.IF AboutLoop == TRUE
					lea eax, ScrSitePtrBuffer 
					mov ebx,[eax]
					xor ecx,ecx
					mov cl, [ebx]
					shl ecx,5
					mov SiteShowTimeDW,cx
					mov [eax],ebx
					mov ScrTxtActHead, eax	
					mov SiteCounter, 0
				.ELSE
					lea eax, ScrTxt1Delay                
					xor ecx,ecx
					mov cl, [eax]
					shl ecx,5
					mov SiteShowTimeDW,cx
					mov ZoomDone,FALSE
					mov ZoomLevel,1
					mov ShowScroller, FALSE
				.ENDIF
			.ELSE
				add ScrTxtActHead, 1Ch
				mov ebx,ScrTxtActHead
				mov eax,[ebx]
				xor ecx,ecx
				mov cl,[eax]
				shl ecx,5
				mov SiteShowTimeDW,cx
				mov [ebx],eax
				add SiteCounter, 1
			.ENDIF	
			mov SiteTimer,0
		.ELSE
			add SiteTimer,1
		.ENDIF
		
		invoke glRasterPos2f, ScrSin, ScrCos
		mov eax, ScrTxtActHead
		mov ebx, [eax]
		add ebx,1
		invoke PrintGLText, ebx, FALSE
		fld ScrCos
		fsub fpc(0.08f)
		fstp ScrCos2
		fwait
		invoke glRasterPos2f, ScrSin, ScrCos2
		mov eax, ScrTxtActHead
		mov ebx, [eax]+04h
		invoke PrintGLText, ebx, FALSE
		fld ScrCos2
		fsub fpc(0.08f)
		fstp ScrCos2
		fwait
		invoke glRasterPos2f, ScrSin, ScrCos2
		mov eax, ScrTxtActHead
		mov ebx, [eax]+08h
		invoke PrintGLText, ebx, FALSE
		fld ScrCos2
		fsub fpc(0.08f)
		fstp ScrCos2
		fwait
		invoke glRasterPos2f, ScrSin, ScrCos2
		mov eax, ScrTxtActHead
		mov ebx, [eax]+0Ch
		invoke PrintGLText, ebx, FALSE
		fld ScrCos2
		fsub fpc(0.08f)
		fstp ScrCos2
		fwait
		invoke glRasterPos2f, ScrSin, ScrCos2
		mov eax, ScrTxtActHead
		mov ebx, [eax]+10h
		invoke PrintGLText, ebx, FALSE
		fld ScrCos2
		fsub fpc(0.08f)
		fstp ScrCos2
		fwait
		invoke glRasterPos2f, ScrSin, ScrCos2
		mov eax, ScrTxtActHead
		mov ebx, [eax]+14h
		invoke PrintGLText, ebx, FALSE
		fld ScrCos2
		fsub fpc(0.08f)
		fstp ScrCos2
		fwait
		invoke glRasterPos2f, ScrSin, ScrCos2
		mov eax, ScrTxtActHead
		mov ebx, [eax]+18h
		invoke PrintGLText, ebx, FALSE
		
		fld cnt1
		fadd  fpc(0.05f)    ;   X-Speed
		fstp cnt1
		fld cnt2
		fadd  fpc(0.1f)   ;  Y-Speed
		fstp cnt2  
		fwait
	.ENDIF
	
	mov eax, 1
	ret
DrawGLScene endp

; PROC KillGLWindow =============================
KillGLWindow proc

	.IF hRC
		invoke wglMakeCurrent,NULL,NULL
		invoke wglDeleteContext,hRC
		mov hRC,NULL
	.ENDIF
	.IF hDC
		invoke ReleaseDC,hWnd,hDC
		mov hDC,NULL
	.ENDIF
	.IF hWnd
		invoke DestroyWindow,hWnd
		mov hWnd,NULL
	.ENDIF
	invoke UnregisterClass,addr txt_OpenGL,hInstance
	mov hInstance,NULL
	ret
KillGLWindow endp

; PROC CenterString ==============================
CenterString proc

	.IF NameChrPos > 0
		invoke lstrlen, ADDR tbxName
		fld BoxCenterXf
		fstp NameXf
@@:
		fld NameXf
		fsub AdjustMul
		fstp NameXf
		dec al
		jnz @b
		
		invoke lstrlen, ADDR tbxSerial
		fld BoxCenterXf
		fstp SerialXf
@@:
		fld SerialXf
		fsub AdjustMul
		fstp SerialXf
		dec al
		jnz @b
	.ENDIF
	
	Ret
CenterString EndP

; PROC PrintGLText ===============================
PrintGLText proc TextLine:DWORD, Thin:BOOL

	invoke RtlZeroMemory,  ADDR PrintBuffer, sizeof PrintBuffer 
	invoke szCatStr, addr PrintBuffer, TextLine
	invoke glPushAttrib, GL_LIST_BIT 
	.IF Thin
		mov eax , baseThin        ; Use font which can be centered in an easy way...
	.ELSE
		mov eax , base
	.ENDIF
	sub eax, 32
	invoke glListBase, eax
	invoke StrLen, ADDR PrintBuffer
	invoke glCallLists, eax, GL_UNSIGNED_BYTE, ADDR PrintBuffer
	invoke glPopAttrib

	Ret
PrintGLText EndP

; PROC ZoomCube===============================
ZoomCube proc Steps:WORD

	.IF ZoomLevel == 0
		fld z
		fsub fpc(0.025)
		fst z
		fadd StarDepth2f
		fstp StarDepthf
		sub ZoomSteps,1
		mov ax,-50
		.IF ax == ZoomSteps
			mov ZoomDone, TRUE
			mov ZoomedOut, TRUE
			mov ZoomingNow, FALSE
			mov ShowScroller, TRUE
			lea eax, ScrSitePtrBuffer
			mov ScrTxtActHead, eax	
			mov SiteTimer,0
			mov SiteCounter,0
		.ENDIF
	.ELSEIF ZoomLevel == 1 && ZoomedIn == FALSE
		fld z
		fadd fpc(0.025)
		fst z
		fadd StarDepth2f
		fstp StarDepthf
		add ZoomSteps,1
		mov ax,-50
		sub ax,1
		.IF ZoomSteps == 0
			mov ZoomDone, TRUE
			mov ZoomedOut, FALSE
			mov ZoomingNow, FALSE
		.ENDIF
	.ELSEIF ZoomLevel == 1 && ZoomedIn == TRUE
		fld z
		fsub fpc(0.025)
		fcom LogoChange
		fstsw ax
		fwait
		sahf
		ja @f
		mov LogoInside,FALSE	;Change logo
@@:							;No logo change	
		fst z
		fadd StarDepth2f
		fstp StarDepthf
		sub ZoomSteps,1
		mov ax,Steps
		sub ax,1
		.IF ZoomSteps == 0
			mov ZoomDone, TRUE
			mov ZoomedIn, FALSE
			mov ZoomingNow, FALSE
		.ENDIF
	.ELSEIF ZoomLevel == 2
		fld z
		fadd fpc(0.025)
		fcom LogoChange
		fstsw ax
		fwait
		sahf
		jb @f
		mov LogoInside,TRUE	;Change logo
@@:							;No logo change	
		fst z
		fadd StarDepth2f
		fstp StarDepthf
		add ZoomSteps,1
		mov ax,Steps
		.IF ax == ZoomSteps
			mov ZoomDone, TRUE
			mov ZoomedIn, TRUE
			mov ZoomedOut, FALSE
			mov ZoomingNow, FALSE
			mov BoxesOn, TRUE
			invoke InitKeygen
		.ENDIF
	.ENDIF
	
	ret
ZoomCube endp

; PROC GFX-Effects ===============================
Effects proc

	invoke mfmGetPos
	and dl,63                  ;  0-63 -> take 64 Pattern-Positions to allocate with gfx-effects
	mov PatPosAct, dl
	and al,31
	mov PatAct,al
	.IF dl != PatPosOld      ;  This is to prevent doubleusing of fast gfx-effects in one pattern's position -> but sometimes it' could be even nice too allow them ;)
		mov PatPosOld, dl
		.IF !JumpingNow && (((dl == 6 || dl == 14 || dl == 22 || dl == 30 || dl == 38 || dl == 46 || dl == 54 || dl == 62) && al >= 1) || (dl == 62 && al == 0))
			mov JumpingNow, TRUE
			mov JumpingHigh, TRUE
		.ENDIF
		.IF !JumpingNow && (((dl == 2 || dl == 10 || dl == 18 || dl == 26 || dl == 34 || dl == 42 || dl == 50 || dl == 58) && al >= 1) || (dl == 58 && al == 0))
			mov JumpingNow, TRUE
			mov JumpingHigh, FALSE
		.ENDIF
		.IF !LegsNow && (((dl == 61 && XMLoop == 1) || (al > 3 && (dl == 5 || dl == 13 || dl == 21 || dl == 25 || dl == 29 || dl == 37 || dl == 45 || dl == 53 ||  dl == 57 ||  dl == 61))) \
					|| (XMLoop == 1 && ((dl == 29 || dl == 61) && al > 0) || (dl == 61 && al == 0)))
			mov LegsNow, TRUE
		.ENDIF
		.IF PatAct >= 3 
			mov MoreStars, TRUE
		.ELSE
			mov MoreStars, FALSE
		.ENDIF
		.IF !StarPulse && (dl == 3 || dl == 7 || dl == 11 || dl == 15 || dl == 19 || dl == 23 || dl == 27 || dl == 31 \
					|| dl == 35 || dl == 39 || dl == 43 || dl == 47 || dl == 51 || dl == 55 || dl == 59 || dl == 63) && al >= 0 && PatAct != 0
			mov StarPulse, TRUE
		.ENDIF
	.ENDIF

; * Cube Legs *
	.IF LegsNow
		.IF LegDown
			.IF RightLeg
				fld CornerRBFPos
				fadd fpc(0.1f)
				fst CornerRBFPos
				fchs
				fstp CornerRBFNeg
				fwait		
				.IF LegCounter == 2
					mov LegDown, FALSE
				.ELSE
					add LegCounter,1
				.ENDIF
			.ELSE
				fld CornerLBFPos
				fadd fpc(0.1f)
				fst CornerLBFPos
				fchs
				fstp CornerLBFNeg
				fwait		
				.IF LegCounter == 2
					mov LegDown, FALSE
				.ELSE
					add LegCounter,1
				.ENDIF
			.ENDIF
			.IF PatAct > 3 || (PatAct == 3 && PatPosAct >= 61)
				fld backcolourR
				fadd fpc(0.2f)
				fst backcolourR
				fsub fpc(0.1f)
				fst backcolourG
				fsub fpc(0.3f)
				fstp backcolourB
				fwait
			.ENDIF
		.ELSE
			.IF RightLeg
				fld CornerRBFPos
				fsub fpc(0.1f)
				fst CornerRBFPos
				fchs
				fstp CornerRBFNeg
				fwait		
				.IF LegCounter == 0
					mov LegDown, TRUE
					mov LegsNow, FALSE
					mov RightLeg, FALSE
				.ELSE
					sub LegCounter,1
				.ENDIF
			.ELSE
				fld CornerLBFPos
				fsub fpc(0.1f)
				fst CornerLBFPos
				fchs
				fstp CornerLBFNeg
				fwait		
				.IF LegCounter == 0
					mov LegDown, TRUE
					mov RightLeg, TRUE
				.ELSE
					sub LegCounter,1
				.ENDIF
			.ENDIF
			.IF LegCounter == 0
				fld fpc(0.1f)
				fstp backcolourR
				fld fpc(0.4f)
				fstp backcolourG
				fld fpc(0.5f)
				fstp backcolourB
			.ELSEIF PatAct > 3 || (PatAct == 3 && PatPosAct >= 61)
				fld backcolourR
				fsub fpc(0.2f)
				fst backcolourR
				fsub fpc(0.1f)
				fst backcolourG
				fsub fpc(0.3f)
				fstp backcolourB
				fwait
			.ENDIF
		.ENDIF
	.ENDIF
	
; * Show Fog *
	.IF PatAct == 0 && DoFog
		finit
		fld FogStarDens
		fsub fpc(0.003f)
		fcom StarFogStop
		fstsw ax
		fwait
		sahf
		ja FogFading
		mov DoFog,FALSE
		fstp FogStarDens
		fld fpc(1.0f)
		fstp FogStarDens
		jmp FogFadedOut
	FogFading:
		fstp FogStarDens
	.ELSEIF PatAct > 1
		mov DoFog,TRUE
	.ENDIF
	FogFadedOut:
	
; * Rotate Cube *
	.IF PatAct >= 1 && XMLoop == 0	; Don't rotate cube at the beginning
		mov XMLoop,1
	.ENDIF
	.IF XMLoop == 1
		finit
		fld CubeCos1
		fcos
		fmul fpc(2.0f)
		fstp yspeed
		fld CubeCos2
		fsin
		fmul fpc(1.9f)
		fstp xspeed
		fld CubeCos2
		fadd  CubeSpeedX 
		fstp CubeCos2
		fld CubeCos1
		fadd  CubeSpeedY   
		fstp CubeCos1
	.ENDIF
	
; * Cube Jumping + Cube Arms *
	.IF JumpingNow
		.IF JumpUp == TRUE
			.IF JumpingHigh
				finit
				fld CubeJumpCoord
				fadd fpc(0.07)
				fstp CubeJumpCoord
			.ELSE
				finit
				fld ButtonJumpY
				fadd fpc(0.001)
				fstp ButtonJumpY
				fld TextJumpY
				fadd fpc(0.001)
				fstp TextJumpY
				fwait
				.IF RightCornerUp
					fld CornerRTFPos
					fadd fpc(0.1f)
					fst CornerRTFPos
					fchs
					fstp CornerRTFNeg
					fwait
				.ELSE
					fld CornerLTFPos
					fadd fpc(0.1f)
					fst CornerLTFPos
					fchs
					fstp CornerLTFNeg
					fwait
				.ENDIF
			.ENDIF
			.IF JumpHeight == 4
				mov JumpUp, FALSE
			.ELSE
				add JumpHeight,1
			.ENDIF
		.ELSE
			.IF JumpingHigh
				finit
				fld CubeJumpCoord
				fsub fpc(0.07)
				fstp CubeJumpCoord
			.ELSE
				finit
				fld ButtonJumpY
				fsub fpc(0.001)
				fstp ButtonJumpY
				fld TextJumpY
				fsub fpc(0.001)
				fstp TextJumpY
				fwait
				.IF RightCornerUp
					fld CornerRTFPos
					fsub fpc(0.1f)
					fst CornerRTFPos
					fchs
					fstp CornerRTFNeg
					fwait
				.ELSE
					fld CornerLTFPos
					fsub fpc(0.1f)
					fst CornerLTFPos
					fchs
					fstp CornerLTFNeg
					fwait
				.ENDIF
			.ENDIF
			.IF JumpHeight == 0
				mov JumpUp, TRUE
				mov JumpingNow, FALSE
				.IF RightCornerUp && !JumpingHigh
					mov RightCornerUp,FALSE
				.ELSEIF !RightCornerUp && !JumpingHigh
					mov RightCornerUp,TRUE
				.ENDIF
			.ELSE
				sub JumpHeight,1
			.ENDIF
		.ENDIF
	.ENDIF
; * Star Pulsing *
	.IF StarPulse
		.IF PulseUp == TRUE
			finit
			fld StarSizePos
			fadd fpc(0.05)
			fst StarSizePos
			fchs
			fstp StarSizeNeg
			.IF PulseWidth == 3
				mov PulseUp, FALSE
			.ELSE
				add PulseWidth,1
			.ENDIF
		.ELSE
			finit
			fld StarSizePos
			fsub fpc(0.05)
			fst StarSizePos
			fchs
			fstp StarSizeNeg
			.IF PulseWidth == 0
				mov PulseUp, TRUE
				mov StarPulse, FALSE
			.ELSE
				sub PulseWidth,1
			.ENDIF
		.ENDIF
	.ENDIF
	
	ret
Effects endp

; PROC InitKeygen ===============================
InitKeygen proc

	invoke RtlZeroMemory,addr tbxSerial,sizeof tbxSerial
	.IF !NameInit     ; Show keygenners name at startup
		invoke lstrcpy,ADDR tbxName,ADDR tbxNameConst
		invoke lstrlen, ADDR tbxNameConst
		mov NameChrPos,eax
		invoke DoKeygen
		invoke CenterString
		mov NameInit,TRUE
		mov NameValid, TRUE
	.ELSE
		invoke lstrlen, ADDR tbxName
		.IF al > 0 && NameChrPos > 0
			.IF al < KeygenCharMin
				invoke lstrcpy,addr tbxSerial,addr txtMoreChars
				mov NameValid, FALSE
			.ELSEIF al > KeygenCharMax
				invoke lstrcpy,addr tbxSerial,addr txtLessChars
				mov NameValid, FALSE
			.ELSEIF al >= KeygenCharMin && al <= KeygenCharMax
				lea edx, tbxName
				add edx, NameChrPos
				xor cx,cx
				mov [edx], cx
				mov CursorSt, FALSE
				invoke DoKeygen
				mov NameValid, TRUE
			.ENDIF			
			invoke CenterString
		.ENDIF
	.ENDIF
	
	ret
InitKeygen endp

end start
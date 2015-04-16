IFNDEF HEAD_INC
HEAD_INC equ 1
;Import .INC files
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include comctl32.inc
include shlwapi.inc
include shell32.inc
include comdlg32.inc
include msvcrt.inc
include gdiplus.inc
include fpu.inc
include winmm.inc
include imm32.inc


;Import .LIB files
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shlwapi.lib
includelib comdlg32.lib
includelib shell32.lib
includelib msvcrt.lib
includelib gdiplus.lib
includelib fpu.lib
includelib winmm.lib
includelib imm32.lib


WinMain proto :DWORD, :DWORD, :DWORD, :DWORD

PlayMp3File PROTO hWin:DWORD,NameOfFile:DWORD
testoutput PROTO, num1: SDWORD, num2:SDWORD			;测试用
hitBall PROTO sx: sdword, sy: sdword, svx: sdword, svy: sdword
manHitBall PROTO mx: sdword, my: sdword, sx: sdword, sy: sdword, speed: sdword
hitBallDegree PROTO sx: sdword, sy: sdword, v0:sdword, deg: sdword
sincos PROTO xx: sdword, deg: sdword
sqrt PROTO xx:sdword
drawMan PROTO who:dword
keydown PROTO w:WPARAM
keyup PROTO w:WPARAM
getDistance PROTO x1:sdword,y1:sdword,x2:sdword,y2:sdword
getSpeed PROTO who:sdword

.CONST
wWidth equ 990							; 窗口大小
wHeight equ 660							
midWidth equ 495						; 球网水平位置
humanHeight equ 522						; 球网高&人中心高
groundHeight equ 619					; 地面高
ballHeight equ 573						; 发球时球的高度
leftLimit equ 53						; 左边界，球碰到会反弹
leftManLimit equ 89						; 人能运动到的最左的位置
ballLeft equ 39						; 发球时球距离左边距离
manArmX equ 90							; 人手的位置
manArmY equ 79
armLen equ 120							; 胳膊长

bSquare equ 8
bSize equ 80
btnLength equ 24
btnLeft equ (bSize * Square - btnLength) / 2 ;控制开始按钮位置的
lInterval equ 6

IDC_START equ 1							;开始按钮的编号
idTimer1 dd 1							;定时器编号


.DATA

Mp3DeviceID dd 0
Mp3Device   db "MPEGVideo",0
bgmfilename	db "bgm.mp3",0
hitfilename db "hit.wav",0 

myMessage db '%d,  %d', 0ah, 0dh, 0
tmp sdword ?
szClassName db 'Huochaiman',0
szAppName db 'Stick Figure Badminton',0				;窗口名称什么的
LButtonDown BOOLEAN FALSE							;当前是否有鼠标按键按下的那个状态
RButtonDown BOOLEAN FALSE
bOpByte dw 0

bInterval db lInterval dup(0)

CLOCK DWORD 0							;全局的计数器

Ball STRUCT
	mx sdword 0
	my sdword 0
	mvx real4 0.
	mvy real4 0.
	max real4 0.
	may real4 0.
	marc real4 0.  ;头部朝向
	hitgroundtime dword 0  ;打击地面次数
	cannothit dword 0	;是否可以击打
    deg tbyte 0
Ball ENDS

Man STRUCT
	mx sdword 0		;中心点的位置
	my sdword 0 
	mvx real4 0.
	mvy real4 0.
	player dword 1	;2 or 1
	move sdword 0	;0:不动，1:向前，-1:向后
	hit dword 0;
	frame1 dword 0	;挥拍动作的帧数，是个倒计时
	frame2 dword 0	
	score dword 0
	lkey dword 0	;键盘按下左键
	rkey dword 0
Man ENDS

;球在上一帧的坐标
ballPreX	sdword ballLeft
ballPreY	sdword ballHeight

man1preX    sdword leftManLimit
man1preY    sdword humanHeight
man2preX    sdword wWidth-leftManLimit-200
man2preY    sdword humanHeight

theBall Ball <ballLeft, ballHeight,22.,-22.,0.,0.,0.,0,0>
hitGroundTimer dword 120

man1 Man <leftManLimit, humanHeight, 0.,0.,1, 0, 0, 0, 0, 0, 0, 0>
man2 Man <wWidth-leftManLimit-200, humanHeight,0.,0., 2, 0, 0, 0, 0, 0, 0, 0>

;因为FLD不能直接加浮点数，所以定义这些变量				
zero real4 0.
two real4 2.
four real4 4.
six real4 6.
eight real4 8.
ten real4 10.
twelve real4 12.
forteen real4 14.
negfour real4 -4.
negsix real4 -6.

b1 real4 0.0		
u1 real4 0.37		;羽毛球下落加速度
u2 real4 0.045		;空气粘滞系数
u3 real4 0.55		;人下落加速度
vvv sdword 24		;球的初始速度，需要加一个向量做修正
manv real4 5.5
manvneg real4 -5.5
manjmpv real4 10.5


tmvx sdword ?		;临时变量
tmvy sdword ?

mypoint POINT <100,100>,<200,50>,<200,300>
bx1 sdword -26
bx2 sdword -26
bx3 sdword 26
by1 sdword -26
by2 sdword 26
by3 sdword -26
bxp sdword 0
byp sdword 0

;KEYS:
kw		byte 0
ka		byte 0
ks		byte 0
kd		byte 0
kup		byte 0
kdown	byte 0
kleft	byte 0
kright	byte 0
kenter	byte 0

leftAIon		byte 1
rightAIon		byte 1
leftAIhitted	byte 0
rightAIhitted	byte 0

startingBall	byte 1	;0:不在发球，1:左边发球，2:右边发球
startingBallPre	byte 1
p1wins db "P1 Wins!", 0
p2wins db "P2 Wins!", 0
MsgCaption   db "Game Over",0

choosingMode byte 1
someoneWins byte 0
drawingTitle byte 1
drawingInst byte 1

score1 sdword 0
score2 sdword 0

titleaddress db 'image\title.png',0
instaddress db 'image\inst.png',0
startaddress db 'image\start.png',0
backaddress db 'image\bg.png',0
balladdress db 'image\ball.png',0
bodyaddress db 'image\body.png',0
shadowaddress db 'image\shadow.png',0
hand1address db 'image\hand1.png',0
hand2address db 'image\hand2.png',0
hand3address db 'image\hand3.png',0
hand4address db 'image\hand4.png',0
hand5address db 'image\hand5.png',0
hand6address db 'image\hand6.png',0
hand7address db 'image\hand7.png',0
hand8address db 'image\hand8.png',0
hand9address db 'image\hand9.png',0
hand10address db 'image\hand10.png',0
hand11address db 'image\hand11.png',0
hand12address db 'image\hand12.png',0
hand13address db 'image\hand13.png',0
hand14address db 'image\hand14.png',0
hand15address db 'image\hand15.png',0
leg1address db 'image\leg1.png',0
leg2address db 'image\leg2.png',0
leg3address db 'image\leg3.png',0
leg4address db 'image\leg4.png',0
leg5address db 'image\leg5.png',0
leg6address db 'image\leg6.png',0
leg7address db 'image\leg7.png',0
point0address db 'image\0.png',0
point1address db 'image\1.png',0
point2address db 'image\2.png',0
point3address db 'image\3.png',0
point4address db 'image\4.png',0
point5address db 'image\5.png',0
point6address db 'image\6.png',0
point7address db 'image\7.png',0

GpInput GdiplusStartupInput<1,0,0,0>

readpicture byte 0

.DATA?
hInstance HINSTANCE ?
szCommandLine LPSTR ?
hDC HDC ?								;画笔
hWnd HWND ?								;窗口
dwTimerId1 dd ?



graphics dd ?
graphics2 dd ?
titleimage dd ?
instimage dd ?
backimage dd ?
ballimage dd ?
startimage dd ?
bodyimage dd ?
shadowimage dd ?
hand1image dd ?
hand2image dd ?
hand3image dd ?
hand4image dd ?
hand5image dd ?
hand6image dd ?
hand7image dd ?
hand8image dd ?
hand9image dd ?
hand10image dd ?
hand11image dd ?
hand12image dd ?
hand13image dd ?
hand14image dd ?
hand15image dd ?
leg1image dd ?
leg2image dd ?
leg3image dd ?
leg4image dd ?
leg5image dd ?
leg6image dd ?
leg7image dd ?
point0image dd ?
point1image dd ?
point2image dd ?
point3image dd ?
point4image dd ?
point5image dd ?
point6image dd ?
point7image dd ?
Token        dd    ?
address db 50 dup(?)
mybitmap dd ?
oldbitmap dd ?
bitmaphdc HDC ?

; Macros
RGB Macro red,green,blue				;定义RGB宏，设置完之后颜色存在eax里面
        xor eax, eax 
        mov ah, blue 
        shl eax, 8 
        mov ah, green 
        mov al, red 
EndM 

ENDIF
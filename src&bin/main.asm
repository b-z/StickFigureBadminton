IFDEF XIA_MIAN_SHI_YI_XIE_FEI_HUA

`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
`	火柴人打羽毛球
`
`	作者: 种璐瑶 | 周伯威 | 钱珺
`
`	2015.04
`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`

`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
`	目前为止遇到过的难点
`	· 点击start按钮后焦点停留在按钮上，无法触发键盘事件。解决: 移动焦点到hWnd
`	· 进入游戏默认为中文输入法，影响游戏。解决: 禁用输入法
`	· 窗口大小和我给的大小不一样。解决: 有个函数能算上窗口的边界，调整一下就好了
`	· 窗口初始位置不居中。解决: 获取显示器分辨率，减去窗口大小，除以二，作为左上角的坐标
`	· BGM无法循环播放。解决: 音乐结束后会产生一个uMsg，捕捉到后停止音乐再打开
`	· 帧率。。。解决不了，预期60fps只有40，预期100才会达到60
`	· 物理模型，问题很多很多，需要做很多与现实世界物理定律不一样的改动才能达到一个比较好的手感
`	· 三角函数、开根号等浮点计算: 使用fpu库来完成
`	· 画png图，比较复杂，先把图片load进内存，再把hDC与graphics关联起来，然后调用函数画图
`	· 画图卡卡卡卡卡卡，局部刷新
`	bug:
`	· 个别时候，音乐放完后会卡死。。
`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`

`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
`	配置方法
`	把main.asm放进VS工程
`	其余的head.inc、bgm.mp3、fpu.lib放在同一文件夹下，无需放入VS
`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`


next to do:
·各种绘图。。
·击球点位置的限制
·不能击球两次、过网击球	//落地击球问题ok
·发球的位置
·比分				//OK
·AI						//太欢乐。。得改一下。加一点随机因素
·游戏模式选择

ENDIF


.386
.model flat, stdcall
option casemap:none

include head.inc

.CODE

testoutput PROC, num1: SDWORD, num2:SDWORD				;用来测试输出一个数
	pushad
	mov eax, 0
	mov ebx, 0
	mov al, ka
	mov bl, kd
	mov eax, num1
	mov ebx, num2
	invoke crt_printf, addr myMessage, eax, ebx
	popad
	ret
testoutput ENDP

GetPicture PROC; 读取图片	  
	invoke MultiByteToWideChar,CP_ACP,NULL,offset backaddress,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr backimage
	invoke MultiByteToWideChar,CP_ACP,NULL,offset balladdress,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr ballimage
	invoke MultiByteToWideChar,CP_ACP,NULL,offset titleaddress,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr titleimage
	invoke MultiByteToWideChar,CP_ACP,NULL,offset instaddress,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr instimage
	invoke MultiByteToWideChar,CP_ACP,NULL,offset startaddress,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr startimage
	invoke MultiByteToWideChar,CP_ACP,NULL,offset bodyaddress,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr bodyimage
	invoke MultiByteToWideChar,CP_ACP,NULL,offset shadowaddress,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr shadowimage
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand1address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand1image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand2address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand2image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand3address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand3image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand4address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand4image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand5address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand5image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand6address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand6image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand7address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand7image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand8address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand8image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand9address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand9image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand10address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand10image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand11address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand11image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand12address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand12image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand13address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand13image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand14address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand14image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset hand15address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr hand15image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset leg1address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr leg1image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset leg2address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr leg2image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset leg3address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr leg3image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset leg4address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr leg4image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset leg5address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr leg5image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset leg6address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr leg6image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset leg7address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr leg7image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point0address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point0image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point1address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point1image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point2address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point2image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point3address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point3image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point4address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point4image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point5address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point5image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point6address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point6image
	invoke MultiByteToWideChar,CP_ACP,NULL,offset point7address,-1,offset address,sizeof address
	invoke GdipLoadImageFromFile, offset address,addr point7image
	ret
GetPicture ENDP


Start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	下面这一部分是窗口创建等的代码
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get Module Handle
invoke GetModuleHandle, NULL
mov hInstance, eax

invoke GetCommandLine
mov szCommandLine, eax

invoke GdiplusStartup,offset Token,offset GpInput,NULL 
invoke WinMain, hInstance, NULL, szCommandLine, SW_SHOWDEFAULT
invoke GdipDeleteGraphics, graphics
invoke GdiplusShutdown,Token 
invoke ExitProcess, eax

WinMain Proc hInst: HINSTANCE, hPrevInst: HINSTANCE, szCmdLine: LPSTR, nShowCmd: DWORD 
	LOCAL wcex: WNDCLASSEX				;是一个窗口类
	LOCAL msg:MSG
	LOCAL rect:RECT
 	mov   wcex.cbSize,SIZEOF WNDCLASSEX
	mov   wcex.style, CS_HREDRAW or CS_VREDRAW 
 	mov   wcex.lpfnWndProc, OFFSET WndProc 
	mov   wcex.cbClsExtra, NULL 
	mov   wcex.cbWndExtra, NULL 
	push  hInstance 
	pop   wcex.hInstance 
	mov   wcex.hbrBackground, COLOR_WINDOW+1  ;不知道为啥加一就变成白色了，不加是很难看的米黄色= =
	mov   wcex.lpszClassName, OFFSET szClassName 
	invoke LoadIcon, NULL, IDI_WINLOGO;  程序图标
	mov   wcex.hIcon, eax 
	mov   wcex.hIconSm, eax 
	invoke LoadCursor, NULL, IDC_ARROW 
	mov   wcex.hCursor, eax 
	invoke RegisterClassEx, addr wcex

	
	mov rect.left, 0
	mov rect.top, 0
	mov rect.right, wWidth				;窗口宽高
	mov rect.bottom, wHeight
	invoke AdjustWindowRectEx, ADDR rect,\
		WS_CAPTION or WS_SYSMENU or WS_BORDER, FALSE, 0
	mov ecx, rect.right
	mov edx, rect.bottom
	sub ecx, rect.left
	sub edx, rect.top
	;下面这一大串能让窗口在创建的时候居中= =
	push ecx
	push edx
	invoke GetSystemMetrics, SM_CYSCREEN;获取水平分辨率
	pop edx
	pop ecx
	sub eax, edx
	push edx
	mov edx, 0
	mov esi, 2
	div esi
	pop edx
	mov ebx, eax
	push ecx
	push edx
	push ebx
	invoke GetSystemMetrics, SM_CXSCREEN
	pop ebx
	pop edx
	pop ecx
	sub eax, ecx
	push edx
	mov edx, 0
	mov esi, 2
	div esi
	pop edx

	invoke CreateWindowEx, NULL,\ 
                ADDR szClassName,\ 
                ADDR szAppName,\ 
                WS_CAPTION or WS_SYSMENU or WS_BORDER ,\
                eax,\;这个和下个是窗口左上角在屏幕中的坐标CW_USEDEFAULT,\ 
                ebx,\;CW_USEDEFAULT,\ 
                ecx,\ 
                edx ,\ 
                NULL,\ 
                NULL,\ 
                hInst,\ 
                NULL 
	mov   hWnd, eax 
		
	invoke ShowWindow, hWnd, nShowCmd
	invoke UpdateWindow, hWnd

	.WHILE TRUE					;不断接收消息
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
	.ENDW 
	mov     eax,msg.wParam 

	RET
WinMain EndP

OnCreate Proc					;初始化窗口
LOCAL icc:INITCOMMONCONTROLSEX
.DATA
	ButtonClassName db 'Button',0
	szBtnStart db 'Start', 0
.DATA?
	hBtnStart HWND ?	
	hEdtInterval HWND ?
.CODE

;Initialize Control
	mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
	mov icc.dwICC, ICC_COOL_CLASSES
	invoke InitCommonControlsEx, addr icc 

;Start Button
       ;invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR szBtnStart,\ 
       ;         WS_CHILD or WS_VISIBLE or BS_FLAT,\ 
        ;        bSize * bSquare + 20 , bSize * bSquare - 110 , 90, 25, hWnd,IDC_START , hInstance, NULL 
		;		;上面这个函数添加一个按钮
	mov hBtnStart, eax	

	invoke PlayMp3File,hWnd,ADDR bgmfilename	;放音乐
	invoke ImmAssociateContext, hWnd, NULL		;imm32.inc, 禁用掉输入法。。否则每次都出来很烦人啊啊。。

	RET
OnCreate EndP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawTitle PROC
	invoke GdipDrawImageRectI, graphics,titleimage,0,0,990,660
	ret
drawTitle ENDP

drawInst PROC
	invoke GdipDrawImageRectI, graphics,instimage,0,0,990,660
	ret
drawInst ENDP

drawChooseMode PROC 
	invoke GdipDrawImageRectI, graphics,startimage,0,0,990,660
	ret
drawChooseMode ENDP


drawMan PROC uses eax ebx ecx edx who:dword
	.IF who==1
		mov eax, man1.mx
		sub eax, 145
		mov ebx, man1.my
		sub ebx, 88
		invoke GdipDrawImageRectI,graphics2,bodyimage,eax,ebx,246,213
		mov eax, man1.mx
		sub eax, 145
		invoke GdipDrawImageRectI,graphics2,shadowimage,eax,434,246,213
		mov eax, man1.mx
		sub eax, 145
		mov ebx, man1.my
		sub ebx, 88
		.IF man1.frame2==0
			invoke GdipDrawImageRectI,graphics2,leg1image,eax,ebx,246,213
			.IF man1.move!=0
			mov man1.frame2,11
			.ENDIF
		.ElSEIF man1.frame2==1
			invoke GdipDrawImageRectI,graphics2,leg2image,eax,ebx,246,213
			dec man1.frame2
			mov man1.move, 0 
		.ELSEIF man1.frame2==11
			invoke GdipDrawImageRectI,graphics2,leg2image,eax,ebx,246,213
			dec man1.frame2
		.ElSEIF man1.frame2==2||man1.frame2==10
			invoke GdipDrawImageRectI,graphics2,leg3image,eax,ebx,246,213
			dec man1.frame2
		.ElSEIF man1.frame2==3||man1.frame2==9
			invoke GdipDrawImageRectI,graphics2,leg4image,eax,ebx,246,213
			dec man1.frame2
		.ElSEIF man1.frame2==4||man1.frame2==8
			invoke GdipDrawImageRectI,graphics2,leg5image,eax,ebx,246,213
			dec man1.frame2
		.ElSEIF man1.frame2==5||man1.frame2==7
			invoke GdipDrawImageRectI,graphics2,leg6image,eax,ebx,246,213
			dec man1.frame2
		.ElSEIF man1.frame2==6
			invoke GdipDrawImageRectI,graphics2,leg7image,eax,ebx,246,213
			dec man1.frame2
		.ENDIF
		mov eax, man1.mx
		sub eax, 140
		mov ebx, man1.my
		sub ebx, 145
		.IF man1.frame1>16||startingBall==1
			add ebx, 57
			sub eax, 5
		.ENDIF
		.IF startingBall==1
			invoke GdipDrawImageRectI,graphics2,hand9image,eax,ebx,246,213
		.ELSEIF man1.frame1==0
			invoke GdipDrawImageRectI,graphics2,hand1image,eax,ebx,246,213
		.ElSEIF man1.frame1==1
			invoke GdipDrawImageRectI,graphics2,hand2image,eax,ebx,246,213
			dec man1.frame1
			mov man1.hit, 0
		.ElSEIF man1.frame1==2
			invoke GdipDrawImageRectI,graphics2,hand3image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==3
			invoke GdipDrawImageRectI,graphics2,hand4image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF	man1.frame1==4
			invoke GdipDrawImageRectI,graphics2,hand5image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==5
			invoke GdipDrawImageRectI,graphics2,hand6image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==6
			invoke GdipDrawImageRectI,graphics2,hand7image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==7
			invoke GdipDrawImageRectI,graphics2,hand8image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==21
			invoke GdipDrawImageRectI,graphics2,hand15image,eax,ebx,246,213
			mov man1.frame1, 7 
			mov man1.hit, 0
		.ElSEIF man1.frame1==22
			invoke GdipDrawImageRectI,graphics2,hand14image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==23
			invoke GdipDrawImageRectI,graphics2,hand13image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==24
			invoke GdipDrawImageRectI,graphics2,hand12image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==25
			invoke GdipDrawImageRectI,graphics2,hand11image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==26
			invoke GdipDrawImageRectI,graphics2,hand10image,eax,ebx,246,213
			dec man1.frame1
		.ElSEIF man1.frame1==27
			invoke GdipDrawImageRectI,graphics2,hand9image,eax,ebx,246,213
			dec man1.frame1
		.ENDIF
	.ELSE
		mov eax, man2.mx
		add eax, 145
		mov ebx, man2.my
		sub ebx, 88
		invoke GdipDrawImageRectI,graphics2,bodyimage,eax,ebx,-246,213
		mov eax, man2.mx
		add eax, 145
		invoke GdipDrawImageRectI,graphics2,shadowimage,eax,434,-246,213
		mov eax, man2.mx
		add eax, 145
		mov ebx, man2.my
		sub ebx, 88
		.IF man2.frame2==0
			invoke GdipDrawImageRectI,graphics2,leg1image,eax,ebx,-246,213
			.IF man2.move!=0
			mov man2.frame2,11
			.ENDIF
		.ElSEIF man2.frame2==1
			invoke GdipDrawImageRectI,graphics2,leg2image,eax,ebx,-246,213
			dec man2.frame2
			mov man2.move, 0 
		.ELSEIF man2.frame2==11
			invoke GdipDrawImageRectI,graphics2,leg2image,eax,ebx,-246,213
			dec man2.frame2
		.ElSEIF man2.frame2==2||man2.frame2==10
			invoke GdipDrawImageRectI,graphics2,leg3image,eax,ebx,-246,213
			dec man2.frame2
		.ElSEIF man2.frame2==3||man2.frame2==9
			invoke GdipDrawImageRectI,graphics2,leg4image,eax,ebx,-246,213
			dec man2.frame2
		.ElSEIF man2.frame2==4||man2.frame2==8
			invoke GdipDrawImageRectI,graphics2,leg5image,eax,ebx,-246,213
			dec man2.frame2
		.ElSEIF man2.frame2==5||man2.frame2==7
			invoke GdipDrawImageRectI,graphics2,leg6image,eax,ebx,-246,213
			dec man2.frame2
		.ElSEIF man2.frame2==6
			invoke GdipDrawImageRectI,graphics2,leg7image,eax,ebx,-246,213
			dec man2.frame2
		.ENDIF
		mov eax, man2.mx
		add eax, 140
		mov ebx, man2.my
		sub ebx, 145
		.IF man2.frame1>16||startingBall==2
			add ebx, 57
			add eax, 5
		.ENDIF
		.IF startingBall==2
			invoke GdipDrawImageRectI,graphics2,hand9image,eax,ebx,-246,213
		.ELSEIF man2.frame1==0
			invoke GdipDrawImageRectI,graphics2,hand1image,eax,ebx,-246,213
		.ElSEIF man2.frame1==1
			invoke GdipDrawImageRectI,graphics2,hand2image,eax,ebx,-246,213
			dec man2.frame1
			mov man2.hit, 0
		.ElSEIF man2.frame1==2
			invoke GdipDrawImageRectI,graphics2,hand3image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==3
			invoke GdipDrawImageRectI,graphics2,hand4image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==4
			invoke GdipDrawImageRectI,graphics2,hand5image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==5
			invoke GdipDrawImageRectI,graphics2,hand6image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==6
			invoke GdipDrawImageRectI,graphics2,hand7image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==7
			invoke GdipDrawImageRectI,graphics2,hand8image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==21
			invoke GdipDrawImageRectI,graphics2,hand15image,eax,ebx,-246,213
			mov man2.frame1, 7 
			mov man2.hit, 0
		.ElSEIF man2.frame1==22
			invoke GdipDrawImageRectI,graphics2,hand14image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==23
			invoke GdipDrawImageRectI,graphics2,hand13image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==24
			invoke GdipDrawImageRectI,graphics2,hand12image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==25
			invoke GdipDrawImageRectI,graphics2,hand11image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==26
			invoke GdipDrawImageRectI,graphics2,hand10image,eax,ebx,-246,213
			dec man2.frame1
		.ElSEIF man2.frame1==27
			invoke GdipDrawImageRectI,graphics2,hand9image,eax,ebx,-246,213
			dec man2.frame1
		.ENDIF
	.ENDIF
	ret
drawMan ENDP

drawBall PROC
	mov eax, bx3
	sub eax, bx1  
    cdq         
    mov ecx, 2 
    idiv ecx
	add eax, bx1
	sub eax, bx2
	mov bxp, eax
	mov eax, by3
	sub eax, by1  
    cdq         
    mov ecx, 2 
    idiv ecx
	add eax, by1
	sub eax, by2
	mov byp, eax
	mov ebx, offset mypoint
	mov eax,theBall.mx
	;sub eax,bxp
	add eax,bx1
	mov [ebx],eax
	mov eax,theBall.my
	;sub eax,byp
	add eax, by1
	mov [ebx+4],eax
	mov eax,theBall.mx
	add eax,bx2
	mov [ebx+8],eax
	mov eax,theBall.my
	add eax,by2
	;sub eax,byp
	mov [ebx+12],eax
	mov eax,theBall.mx
	add eax,bx3
	;sub eax,bxp
	mov [ebx+16],eax
	mov eax,theBall.my
	add eax,by3
	;sub eax,byp
	mov [ebx+20],eax
	invoke GdipDrawImagePointsI, graphics2,ballimage,addr mypoint,3

	;mov eax, theBall.mx
	;mov ebx, theBall.my
	;add eax, 5
	;add ebx, 5
	;mov ecx, eax
	;mov edx, ebx
	;sub ecx, 10
	;sub edx, 10
	;invoke Rectangle, hDC, ecx, edx, eax, ebx
	ret
drawBall ENDP

drawPoint PROC
	.IF score1 == 0
		invoke GdipDrawImageRectI,graphics2,point0image,448,34,22,34
	.ELSEIF score1 == 1
		invoke GdipDrawImageRectI,graphics2,point1image,448,34,22,34
	.ELSEIF score1 == 2
		invoke GdipDrawImageRectI,graphics2,point2image,448,34,22,34
	.ELSEIF score1 == 3
		invoke GdipDrawImageRectI,graphics2,point3image,448,34,22,34
	.ELSEIF score1 == 4
		invoke GdipDrawImageRectI,graphics2,point4image,448,34,22,34
	.ELSEIF score1 == 5
		invoke GdipDrawImageRectI,graphics2,point5image,448,34,22,34
	.ELSEIF score1 == 6
		invoke GdipDrawImageRectI,graphics2,point6image,448,34,22,34
	.ELSEIF score1 == 7
		invoke GdipDrawImageRectI,graphics2,point7image,448,34,22,34
	.ENDIF
	.IF score2 == 0
		invoke GdipDrawImageRectI,graphics2,point0image,518,34,22,34
	.ELSEIF score2 == 1
		invoke GdipDrawImageRectI,graphics2,point1image,518,34,22,34
	.ELSEIF score2 == 2
		invoke GdipDrawImageRectI,graphics2,point2image,518,34,22,34
	.ELSEIF score2 == 3
		invoke GdipDrawImageRectI,graphics2,point3image,518,34,22,34
	.ELSEIF score2 == 4
		invoke GdipDrawImageRectI,graphics2,point4image,518,34,22,34
	.ELSEIF score2 == 5
		invoke GdipDrawImageRectI,graphics2,point5image,518,34,22,34
	.ELSEIF score2 == 6
		invoke GdipDrawImageRectI,graphics2,point6image,518,34,22,34
	.ELSEIF score2 == 7
		invoke GdipDrawImageRectI,graphics2,point7image,518,34,22,34
	.ENDIF
	ret
drawPoint ENDP


sincos PROC xx:sdword, deg:sdword
;	eax=xx*sin deg
;	ebx=xx*cos deg
.data
	t TBYTE ?
	s1 SDWORD ?
	s2 SDWORD ?
.code
	invoke FpuSin, deg, addr t, SRC1_DIMM
	invoke FpuMul, addr t, xx, addr t, SRC1_REAL or SRC2_DIMM or DEST_MEM
	invoke FpuRound, addr t, addr s1, DEST_IMEM or SRC1_REAL
	invoke FpuCos, deg, addr t, SRC1_DIMM
	invoke FpuMul, addr t, xx, addr t, SRC1_REAL or SRC2_DIMM or DEST_MEM
	invoke FpuRound, addr t, addr s2, DEST_IMEM or SRC1_REAL
	mov eax, s1
	mov ebx, s2
	ret
sincos ENDP

sqrt PROC xx:sdword
.data
	src sdword ?
	res TBYTE ?
.code
	mov eax, xx
	mov src, eax
	invoke FpuSqrt, addr src, addr res, SRC1_DMEM or DEST_MEM
	invoke FpuRound, addr res, addr src, SRC1_REAL or DEST_IMEM
	mov eax, src
	ret
sqrt ENDP

FPLUS PROC,r1:real4,r2:real4
	 FLD r1
	 FLD r2
	 FADD
	 ret
FPLUS ENDP

FSUBT PROC,r1:real4,r2:real4
	FLD r1
	FLD r2
	FSUB 
	ret
FSUBT ENDP

FMULT PROC,r1:real4,r2:real4
	FLD r1
	FLD r2
	FMUL
	ret
FMULT ENDP

FDIVI PROC,r1:real4,r2:real4
	FLD r1
	FLD r2
	FDIV
	ret
FDIVI ENDP

ballHitWall PROC
	;水平速度反向，水平位移做翻转
	finit
	.IF theBall.mx>wWidth-leftLimit
		;mvx=-mvx
		;mx=2*(wWidth-leftLimit)-mx
		
		invoke FSUBT, zero, theBall.mvx
		FST theBall.mvx
		sub theBall.mx, 2*(wWidth-leftLimit)
		neg theBall.mx
		;invoke hitBall, wWidth-ballLeft, ballHeight, -17, -17
	.ENDIF
	.IF theBall.mx<leftLimit
		;mvx=-mvx
		;mx=2*leftLimit-mx

		invoke FSUBT, zero, theBall.mvx
		FST theBall.mvx
		sub theBall.mx, 2*leftLimit
		neg theBall.mx
		;invoke hitBall, ballLeft, ballHeight, 17, -17
	.ENDIF
	ret
ballHitWall ENDP

ballHitGround PROC
	;垂直速度反向&减半，垂直位移做翻转，改变得分，改变可击打状态
	finit
	;mvy=-mvy/2
	;my=2*groundHeight-my
	invoke FSUBT, zero, theBall.mvy
	FST theBall.mvy
	invoke FDIVI, theBall.mvy, four
	FST theBall.mvy
	invoke FDIVI, theBall.mvx, two
	FST theBall.mvx

	sub theBall.my, 2*groundHeight
	neg theBall.my

	inc theBall.hitgroundtime
	mov theBall.cannothit, 1
	.IF theBall.hitgroundtime==1
		.IF ballPreX<midWidth
			inc man2.score
			inc score2
		.ELSE
			inc man1.score
			inc score1	
		.ENDIF
	.ENDIF
	.IF theBall.hitgroundtime!=1
		ret
	.ENDIF
	.IF ballPreX<wWidth/2
		mov startingBallPre, 2
	.ELSE
		mov startingBallPre, 1
	.ENDIF
		
	;invoke hitBall, ballLeft, ballHeight, 17, -17
	ret
ballHitGround ENDP

ballStop PROC
	finit
	mov theBall.my, groundHeight
	FLD zero
	FST theBall.mvx
	FLD zero
	FST theBall.mvy
	FLD zero
	FST theBall.max
	FLD zero
	FST theBall.may

	.IF someoneWins==0
		dec hitGroundTimer
	.ENDIF

	.IF hitGroundTimer == 0
		mov theBall.hitgroundtime, 0
		mov hitGroundTimer, 30
		mov theBall.cannothit, 0
		;invoke Rectangle, hDC, 0, 0, wWidth,wHeight
	.ELSE
		ret
	.ENDIF
	mov al, startingBallPre
	mov startingBall, al
	.IF theBall.mx<wWidth/2
		mov ecx, man2.mx
		mov edx, man2.my
		add ecx, manArmX
		sub edx, manArmY
		;mov startingBall, 2
		mov leftAIhitted, 0
		;invoke manHitBall, man2.mx, man2.my, ecx, edx, vvv
		mov rightAIhitted, 1
		;invoke hitBallDegree, ecx, edx, vvv, 120
	.ELSE
		mov ecx, man1.mx
		mov edx, man1.my
		sub ecx, manArmX
		sub edx, manArmY
		;mov startingBall, 1
		mov rightAIhitted, 0
		;invoke manHitBall, man1.mx, man1.my, ecx, edx, vvv
		mov leftAIhitted, 1
		;invoke hitBallDegree, ecx, edx, vvv, 20
	.ENDIF
	ret
ballStop ENDP

ballHitNet PROC
	;在hitwall的基础上，改变得分&可击打状态
	finit
	;mx=wWidth-mx
	;mvx=-mvx/2
	invoke FSUBT, zero, theBall.mvx
	FST theBall.mvx
	invoke FDIVI, theBall.mvx, two
	FST theBall.mvx

	sub theBall.mx, wWidth
	neg theBall.mx
	
	ret
ballHitNet ENDP

checkBallStatus PROC USES eax ebx ecx edx esi
	;检查球是否撞墙等
	.IF theBall.my>groundHeight
		call ballHitGround
	.ENDIF
	.IF theBall.mx>wWidth-leftLimit || theBall.mx<leftLimit
		call ballHitWall
	.ENDIF
	.IF (theBall.mx>=midWidth&&ballPreX<=midWidth)||(theBall.mx<=midWidth&&ballPreX>=midWidth)
		.IF theBall.my>=humanHeight&&theBall.my<=groundHeight&&ballPreY>=humanHeight&&ballPreY<=groundHeight
			call ballHitNet
		.ENDIF
	.ENDIF
	.IF theBall.hitgroundtime>3
		call ballStop
	.ENDIF
	
	ret
checkBallStatus ENDP


ballDeg PROC
.data
	tmp00	TBYTE	?
	tmp01	TBYTE	?
	tmpvx	sdword	?
	tmpvy	sdword	?
	tmpvv	real4	1000.
.code
	finit
	fld theBall.mvx
	fld tmpvv
	fmul
	fist tmpvx
	fld theBall.mvy
	fld tmpvv
	fmul
	fist tmpvy
	.IF tmpvx==0
		.IF tmpvy>0
			invoke FpuAdd, 0, 90, addr theBall.deg, SRC1_DIMM or SRC2_DIMM
		.ELSE
			invoke FpuAdd, 0, -90, addr theBall.deg, SRC1_DIMM or SRC2_DIMM
		.ENDIF
;		mov theBall.deg, tmp00
		call ballThreePoint
		ret
	.ELSE
		invoke FpuDiv, addr tmpvy, addr tmpvx, 0, SRC1_DMEM or SRC2_DMEM or DEST_FPU
		invoke FpuArctan, 0, addr tmp01, SRC1_FPU
		.IF tmpvx<0
			invoke FpuAdd, 180, addr tmp01, addr theBall.deg, SRC1_DIMM or SRC2_REAL 
		.ELSE
			invoke FpuAdd, 0, addr tmp01, addr theBall.deg, SRC1_DIMM or SRC2_REAL
		.ENDIF
		;invoke FpuRound, addr theBall.deg, addr tmpvx, SRC1_REAL or DEST_IMEM
		;mov theBall.deg, tmp00
	.ENDIF
	call ballThreePoint
	ret
ballDeg ENDP

ballThreePoint PROC
	;球半对角线长:37px
.data
	tmpdeg	tbyte	?
	tmpt	sdword	?
.code
	invoke FpuAdd, 45, addr theBall.deg, addr tmpdeg, SRC1_DIMM or SRC2_REAL	;tmpdeg=theBall.deg+45
;	invoke FpuRound, addr theBall.deg, addr tmpt, SRC1_REAL or DEST_IMEM
	invoke FpuRound, addr tmpdeg, addr tmpt, SRC1_REAL or DEST_IMEM
	invoke sincos, 37, tmpt;ebx=r cos tmpdeg, eax=r sin tmpdeg
	mov bx2, ebx
	mov by2, eax
	invoke FpuAdd, 135, addr theBall.deg, addr tmpdeg, SRC1_DIMM or SRC2_REAL	;tmpdeg=theBall.deg+45
	invoke FpuRound, addr tmpdeg, addr tmpt, SRC1_REAL or DEST_IMEM
	invoke sincos, 37, tmpt;ebx=r cos tmpdeg, eax=r sin tmpdeg
	mov bx1, ebx
	mov by1, eax
	invoke FpuAdd, 225, addr theBall.deg, addr tmpdeg, SRC1_DIMM or SRC2_REAL	;tmpdeg=theBall.deg+45
	invoke FpuRound, addr tmpdeg, addr tmpt, SRC1_REAL or DEST_IMEM
	invoke sincos, 37, tmpt;ebx=r cos tmpdeg, eax=r sin tmpdeg
	mov bx3, ebx
	mov by3, eax
	ret
ballThreePoint ENDP


ballMove PROC USES eax
	.IF startingBall==0
		finit
		INVOKE FMULT,theBall.mvx,u2
		FST theBall.max
		INVOKE FSUBT,b1,theBall.max
		FST theBall.max           ;max=-mvx*u2;
		INVOKE FMULT,theBall.mvy,u2
		FST theBall.may
		INVOKE FSUBT,u1,theBall.may
		FST theBall.may           ;may=u1-mvy*u2;
		INVOKE FPLUS,theBall.mvx,theBall.max
		FST theBall.mvx           ;mvx+=max;	
		FIST tmvx
		INVOKE FPLUS,theBall.mvy,theBall.may     
		FST theBall.mvy           ;mvy+=may;
		FIST tmvy
		mov eax,theBall.mx
		mov ballPreX, eax
		add eax,tmvx
		mov theBall.mx,eax      ;mx+=mvx
		mov eax,theBall.my
		mov ballPreY, eax
		add eax,tmvy
		mov theBall.my,eax        ;my+=mvy

		call ballDeg
		call checkBallStatus
	.ELSE 
		.IF startingBall==1
			mov eax, man1.mx
			add eax, ballLeft
			.IF leftAIon==0
				sub eax, 10
			.ENDIF
			mov theBall.mx, eax
			mov eax, ballHeight
			sub eax, humanHeight
			add eax, man1.my 
			mov theBall.my, eax
		.ELSE
			mov eax, man2.mx
			sub eax, ballLeft
			.IF rightAIon==0
				add eax, 10
			.ENDIF
			mov theBall.mx, eax
			mov eax, ballHeight
			sub eax, humanHeight
			add eax, man2.my 
			mov theBall.my, eax
		.ENDIF
	.ENDIF
	ret
ballMove ENDP

manMove PROC uses eax
.data
	temp real4 ?
.code
	mov eax,man1.mx
	mov man1preX,eax
	mov eax,man1.my
	mov man1preY,eax
	mov eax,man2.mx
	mov man2preX,eax
	mov eax,man2.my
	mov man2preY,eax
	finit
	.IF ka==1&&kd==0
		FLD manvneg
		FST man1.mvx
		mov man1.move,1
	.ELSEIF kd==1&&ka==0
		FLD manv
		FST man1.mvx
		mov man1.move,1
	.ELSE
		FLD zero
		FST man1.mvx
	.ENDIF
	.IF kleft==1&&kright==0
		FLD manvneg  
		FST man2.mvx
		mov man2.move,1
	.ELSEIF kright==1&&kleft==0
		FLD manv
		FST man2.mvx
		mov man2.move,1
	.ELSE
		FLD zero
		FST man2.mvx
	.ENDIF
	.IF kw==1&&man1.my==humanHeight
		mov kw, 0
	 	FLD manjmpv
		FST man1.mvy
	.ENDIF
	.IF kup==1&&man2.my==humanHeight
		mov kup, 0
		FLD manjmpv
		FST man2.mvy
	.ENDIF

	;mx+=mvx
	;mvy-=0.1
	;my+=mvy

	FILD man1.mx
	FST temp
	invoke FPLUS, temp, man1.mvx
	FIST man1.mx
	finit
	FILD man2.mx
	FST temp
	invoke FPLUS, temp, man2.mvx
	FIST man2.mx
	  
	finit
	invoke FSUBT, man1.mvy, u3
	FST man1.mvy
	invoke FSUBT, man2.mvy, u3
	FST man2.mvy
	 
	FILD man1.my
	FST temp
	invoke FSUBT, temp, man1.mvy
	FIST man1.my

	FILD man2.my
	FST temp
	invoke FSUBT, temp, man2.mvy
	FIST man2.my

	;if my>humanHeight
	;my=humanHeight
	.IF man1.my>humanHeight
		mov man1.my, humanHeight
		FLD zero
		FST man1.mvy
	.ENDIF
	.IF man2.my>humanHeight
		mov man2.my, humanHeight
		FLD zero
		FST man2.mvy
	.ENDIF

	.IF man1.mx<leftManLimit
		mov man1.mx, leftManLimit
	.ENDIF
	.IF man1.mx>midWidth-leftLimit
		mov man1.mx, midWidth-leftLimit
	.ENDIF
	.IF man2.mx>wWidth-leftManLimit
		mov man2.mx, wWidth-leftManLimit
	.ENDIF
	.IF man2.mx<midWidth+leftLimit
		mov man2.mx, midWidth+leftLimit
	.ENDIF
	.IF startingBall==1 && man1.mx>280
		mov man1.mx, 280
	.ENDIF
	.IF startingBall==2 && man2.mx<wWidth-280
		mov man2.mx, wWidth-280
	.ENDIF

	ret
manMove ENDP

getDistance PROC x1:sdword,y1:sdword,x2:sdword,y2:sdword
	mov eax, y2
	mov ebx, x2
	sub eax, y1
	sub	ebx, x1
	imul eax
	mov ecx, eax
	mov eax, ebx
	imul ebx
	mov ebx, eax
	mov eax, ecx
	add ebx, eax
	invoke sqrt, ebx
	;结果在eax里面	
	ret
getDistance ENDP


getSpeed PROC uses ebx ecx edx who:sdword
.data
	tmp0 sdword ?
	tmp1 sdword ?
.code
	;速度=vvv*球到人距离/拍子最大长度
	;如果不在拍子范围则返回0
	.IF who==1		;这段代码判断球在拍子后面的那个扇形里面
		mov edx, theBall.mx
		.IF edx<man1.mx
			mov ebx, man1.mx
			sub ebx, theBall.mx
			mov eax, theBall.my
			sub eax, man1.my
			mov tmp1, eax
			.IF tmp1<0
				neg eax
			.ENDIF	
			mov ecx, 90
			imul ecx
			mov tmp0, eax
			mov eax, ebx
			mov ecx, 79
			imul ecx
			;tmp0: 90eax  eax: 79ebx
			.IF tmp0<eax
				mov eax, 0
				ret
			.ENDIF
		.ENDIF
	.ELSE
		mov edx, theBall.mx
		.IF edx>man2.mx
			mov ebx, theBall.mx
			sub ebx, man2.mx
			mov eax, theBall.my
			sub eax, man2.my
			mov tmp1, eax
			.IF tmp1<0
				neg eax
			.ENDIF	
			mov ecx, 90
			imul ecx
			mov tmp0, eax
			mov eax, ebx
			mov ecx, 79
			imul ecx
			;tmp0: 90eax  eax: 79ebx
			.IF tmp0<eax
				mov eax, 0
				ret
			.ENDIF
		.ENDIF
	.ENDIF
	.IF who==1
		invoke getDistance, man1.mx, man1.my, theBall.mx, theBall.my
	.ELSE
		invoke getDistance, man2.mx, man2.my, theBall.mx, theBall.my
	.ENDIF

	mov tmp0, eax
	.IF tmp0>=45&&tmp0<=150
		mov edx, 0
		mov ecx, 120
		imul vvv
		idiv ecx
		;结果在eax里
		ret
	.ENDIF
	mov eax, 0
	ret
getSpeed ENDP

checkHitBall PROC
	.IF ks==1
		.IF startingBall==1
			mov startingBall, 0
			ret
		.ENDIF
		mov ks, 0
		.IF man1.hit==0
			mov ecx, man1.my
			;sub ecx, 57
			.IF theBall.my>ecx
				mov man1.frame1, 27
			.ElSE
				mov man1.frame1, 7
			.ENDIF
			mov man1.hit, 1
		.ENDIF
		.IF theBall.cannothit==0
			invoke getSpeed, 1
			.IF eax!=0&&theBall.mx<midWidth
				invoke manHitBall, man1.mx, man1.my, theBall.mx, theBall.my, vvv;eax
			.ENDIF
		.ENDIF
	.ENDIF
	.IF kdown==1
		.IF startingBall==2
			mov startingBall, 0
			ret
		.ENDIF
		mov kdown, 0
		.IF man2.hit==0
			mov ecx, man2.my
			;sub ecx, 57
			.IF theBall.my>ecx
				mov man2.frame1, 27
			.ElSE
				mov man2.frame1, 7
			.ENDIF
			mov man2.hit, 1
		.ENDIF
		.IF theBall.cannothit==0
			invoke getSpeed, 2
			.IF eax!=0&&theBall.mx>midWidth
				invoke manHitBall, man2.mx, man2.my, theBall.mx, theBall.my, vvv;eax
			.ENDIF
		.ENDIF
	.ENDIF
	ret
checkHitBall ENDP

hitBall PROC USES eax, sx: sdword, sy: sdword, svx: sdword, svy: sdword
	;把这些值赋给theBall
	finit
	mov eax, sx
	mov theBall.mx, eax
	mov eax, sy
	mov theBall.my, eax
	fild svx
	fst theBall.mvx
	fild svy
	fst theBall.mvy
	invoke PlaySound,addr hitfilename,NULL,SND_ASYNC
	ret
hitBall ENDP

hitBallDegree PROC USES eax ebx ecx sx: sdword, sy: sdword, v0: sdword, deg: sdword
	;以一个角度击打球，球的初速度为v
	mov ecx, deg
	neg ecx
	invoke sincos, v0, ecx
	invoke hitBall, sx, sy, ebx, eax
	ret
hitBallDegree ENDP

manHitBall PROC uses eax edx mx: sdword, my: sdword, sx: sdword, sy: sdword, speed: sdword
.data
	symy2 sdword ?
	sxmx2 sdword ?
	a2    sdword ?
	b2    sdword ?
	symysxmx    sdword ?
	a     sdword ?
	b     sdword ?
.code
	mov eax, sy
	mov symy2, eax
	mov eax, my
	sub symy2, eax
	mov eax, symy2
	imul symy2
	mov symy2, eax
	mov eax, sx
	mov sxmx2, eax
	mov eax, mx
	sub sxmx2, eax
	mov eax, sxmx2
	imul sxmx2
	mov sxmx2, eax
	
	mov eax, symy2
	mov symysxmx, eax
	mov eax, sxmx2
	add symysxmx, eax

	mov eax, speed
	mov edx, 0
	imul speed		;v^2
	imul symy2		;v^2*(sy-my)^2
	idiv symysxmx	;v^2*(sy-my)^2/((sy-my)^2+(sx-mx)^2)
	mov a2, eax
	
	mov eax, speed
	imul speed
	sub eax, a2		;b^2=v^2-a^2
	mov b2, eax

	invoke sqrt, a2
	mov a, eax
	invoke sqrt, b2
	mov b, eax

	mov eax, sx
	.IF eax>mx
		neg a
	.ENDIF
	mov eax, sy
	.IF eax<my
		neg b
	.ENDIF
	.IF mx<midWidth&&a<0
		neg a
		neg b
	.ENDIF
	.IF mx>midWidth&&a>0
		neg a
		neg b
	.ENDIF
	
	.IF mx<midWidth
		add a, 12
		sub b, 12
	.ELSE
		sub a, 12
		sub b, 12
	.ENDIF

	mov eax, sy
	.IF eax>my
		.IF mx<midWidth
			mov a, 29
			mov b, -29
		.ELSE
			mov a, -29
			mov b, -29
		.ENDIF
	.ENDIF

	;invoke MoveToEx, hDC, mx, my, NULL
	;invoke LineTo, hDC, sx, sy

	invoke hitBall, sx,sy,a,b
	ret
manHitBall ENDP
leftAIconsider PROC
.data
	temp2 dword ?
.code
IF 0
how to 写一个AI ?
	· 下面提示要注意的一定不能改
	· 写AI也就是根据当前各个物体的状态参数等，确定要完成的键盘操作
	· 左边AI可用的键盘操作有kw/ka/ks/kd
	· 按下按键就是把kw等等变成1，抬起就是变成0
	· 随机数取法: 有个全局变量CLOCK，是计时用的，随便把它mod一个比较小的数，就可认为是随机数
ENDIF
;注意! 下面这三行不能删!!!
	.IF theBall.mx>midWidth
		mov leftAIhitted, 0
	.ENDIF
;控制左右移动的逻辑，会跟随球的横坐标
	.IF theBall.mx>midWidth
		.IF man1.mx > midWidth/4
			mov ka, 1
			mov kd, 0
		.ELSEIF man1.mx < midWidth/4
			mov kd, 1
			mov ka, 0
		.ENDIF
	.ELSE
		mov eax, man1.mx
		add eax, 150
		mov ebx, man1.mx
		sub ebx, 30
		.IF theBall.mx>eax
			mov kd, 1
			mov ka, 0
		.ELSEIF ebx>theBall.mx
			mov ka, 1
			mov kd, 0
		.ELSE
			mov ka, 0
			mov kd, 0
		.ENDIF
	.ENDIF
;控制跳跃的逻辑，会跟随球的横坐标
;控制击球动作的逻辑
;注意! 击球动作发出前，必须判断leftAIhitted为0，击球后要将之置为1!!!!!!
	.IF leftAIhitted==0
		invoke getDistance, theBall.mx, theBall.my, man1.mx, man1.my
		mov temp2, eax
	;如果球与人的距离合适，发出一个击球动作，并告诉电脑，直到球过网之前都不可以击球，否则就一直在打打打
		mov eax,theBall.my
		.IF	temp2<110&&temp2>45
			mov ks, 1
			mov leftAIhitted, 1
		.ELSEIF 
		.ENDIF
	.ENDIF
	ret
leftAIconsider ENDP

rightAIconsider PROC
.data
	temp1 dword ?
.code
	.IF theBall.mx<midWidth
		mov rightAIhitted, 0
		mov eax, midWidth+midWidth/2
		add eax, 30
		mov ebx, midWidth+midWidth/2
		sub ebx, 30
		.IF man2.mx<ebx
			mov kright, 1
			mov kleft, 0
		.ELSEIF eax<man2.mx
			mov kleft, 1
			mov kright, 0
		.ELSE
			mov kleft, 0
			mov kright, 0
		.ENDIF
	.ELSE
		mov eax, man2.mx
		add eax, 30
		mov ebx, man2.mx
		sub ebx, 30
		mov ecx, theBall.mx
		add ecx, 50
		.IF ecx>eax
			mov kright, 1
			mov kleft, 0
		.ELSEIF ebx>ecx
			mov kleft, 1
			mov kright, 0
		.ELSE
			mov kleft, 0
			mov kright, 0
		.ENDIF
	.ENDIF

	.IF rightAIhitted==0
		invoke getDistance, theBall.mx, theBall.my, man2.mx, man2.my
		mov temp1, eax
		.IF	temp1<110&&temp1>45
			mov kdown, 1
			mov rightAIhitted, 1
		.ENDIF
	.ELSE
		mov kup, 0
		ret
	.ENDIF

	mov ebx, man2.my
	sub ebx, 80
	invoke getDistance, theBall.mx, theBall.my, man2.mx, ebx
	mov temp1, eax
	.IF temp1<110&&temp2>45
		mov kup, 1
	.ENDIF
	ret
rightAIconsider ENDP

DrawOneFrame PROC				;每一帧画什么
	local myrect:RECT
	LOCAL ps: PAINTSTRUCT
	.IF choosingMode==1
		mov readpicture,1
		invoke InvalidateRect,hWnd,NULL ,0
	.ELSE
		invoke InvalidateRect,hWnd,NULL ,0
	.ENDIF
	ret
DrawOneFrame ENDP

StepOver Proc					;每次定时器触发时做什么
	invoke testoutput, CLOCK, CLOCK;man1.score, man2.score
	inc CLOCK
	call DrawOneFrame
	call ballMove
	call manMove
	call checkHitBall
	.IF leftAIon==1
		call leftAIconsider
	.ENDIF
	.IF rightAIon==1
		call rightAIconsider
	.ENDIF
		.IF man1.score==7
		mov man1.score, 0
		mov man2.score, 0
		mov someoneWins, 1
		invoke MessageBox,hWnd,addr p1wins,addr MsgCaption,MB_OK
		mov choosingMode, 1
		invoke drawChooseMode
	.ENDIF
	.IF man2.score==7
		mov man1.score, 0
		mov man2.score, 0
		mov someoneWins, 1
		invoke MessageBox,hWnd,addr p2wins,addr MsgCaption,MB_OK
		mov choosingMode, 1
		invoke drawChooseMode
	.ENDIF
	ret
StepOver EndP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OnPaint Proc					;好像是可以获取到hDC
LOCAL ps: PAINTSTRUCT
;LOCAL rect: RECT
	PUSH ebx
	invoke BeginPaint, hWnd, addr ps
	mov hDC, eax
	invoke GdipCreateFromHDC, hDC, addr graphics 
	.IF readpicture==0
		;invoke SelectObject, hDC, eax
		;xor ecx, ecx
		invoke GetPicture
		invoke drawTitle
		mov readpicture,1
	.ELSE
		.IF drawingTitle==1
			invoke drawTitle
		.ELSEIF drawingInst==1
			invoke drawInst
		.ELSEIF choosingMode==1
			invoke drawChooseMode
			invoke InvalidateRect,hWnd,NULL ,0
		.ELSE 
			invoke CreateCompatibleDC,bitmaphdc
			mov bitmaphdc,eax
			invoke CreateCompatibleBitmap,hDC,990,660
			mov mybitmap,eax
			invoke SelectObject, bitmaphdc, mybitmap

			mov oldbitmap, eax

			invoke GdipCreateFromHDC, bitmaphdc, addr graphics2
			invoke GdipDrawImageRectI,graphics2,backimage,0,0,990,660
			invoke drawPoint
			invoke drawMan, 1
			invoke drawMan, 2
			invoke drawBall
			invoke BitBlt,hDC,0,0,990,660,bitmaphdc,0,0,SRCCOPY
			invoke GdipDeleteGraphics, graphics2
			
			invoke SelectObject, bitmaphdc, oldbitmap

			invoke DeleteObject,mybitmap
			invoke DeleteDC, bitmaphdc
		.ENDIF
	.ENDIF
	invoke GdipReleaseDC, graphics, hDC
	invoke GdipDeleteGraphics, graphics
	invoke EndPaint, hWnd, addr ps

	;invoke GetDC, hWnd
	;mov hDC, eax
;--------------------------
	POP ebx
	RET
OnPaint EndP

OnQuit Proc
	RET
OnQuit EndP

OnBtnStart Proc				;点击开始按钮之后干什么
	invoke GetWindowText, hEdtInterval, addr bInterval, lInterval
	invoke StrToInt, addr bInterval	
	
	invoke SetTimer, hWnd, idTimer1, 15, addr StepOver
	mov dwTimerId1, eax
	mov man1.mx, leftManLimit
	mov man1.my, humanHeight
	mov man2.mx, wWidth-leftManLimit-200
	mov man2.my, humanHeight
	mov hitGroundTimer, 30
	mov someoneWins, 0
	mov startingBall, 1
	mov startingBallPre, 1
	mov leftAIhitted, 0
	mov rightAIhitted, 0
	mov theBall.hitgroundtime, 0
	mov theBall.cannothit, 0
	mov kw, 0
	mov ka, 0
	mov ks, 0
	mov kd, 0
	mov kleft, 0
	mov kright, 0
	mov kup, 0
	mov kdown, 0
	mov score1, 0
	mov score2, 0
	mov CLOCK, 0
	RET
OnBtnStart EndP

keydown PROC w:WPARAM
	.IF leftAIon==0
		.IF w ==  VK_W
			mov kw, 1
		.ELSEIF w == VK_A
			mov ka, 1
		.ELSEIF w == VK_S
			mov ks, 1
		.ELSEIF w == VK_D
			mov kd, 1
		.ENDIF
	.ENDIF
	.IF rightAIon==0
		.IF w == VK_UP
			mov kup, 1
		.ELSEIF w == VK_DOWN
			mov kdown, 1
		.ELSEIF w == VK_LEFT
			mov kleft, 1
		.ELSEIF w == VK_RIGHT
			mov kright, 1
		.ENDIF
	.ENDIF
	ret
keydown ENDP

keyup PROC w:WPARAM
	.IF leftAIon==0
		.IF w ==  VK_W
			mov kw, 0
		.ELSEIF w == VK_A
			mov ka, 0
		.ELSEIF w == VK_S
			mov ks, 0
		.ELSEIF w == VK_D
			mov kd, 0
		.ENDIF
	.ENDIF
	.IF rightAIon==0
		.IF w == VK_UP
			mov kup, 0
		.ELSEIF w == VK_DOWN
			mov kdown, 0
		.ELSEIF w == VK_LEFT
			mov kleft, 0
		.ELSEIF w == VK_RIGHT
			mov kright, 0
		.ENDIF
	.ENDIF
	ret
keyup ENDP


PlayMp3File proc hWin:DWORD,NameOfFile:DWORD
	LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS
		mov eax,hWin        
		mov mciPlayParms.dwCallback,eax
		mov eax,OFFSET Mp3Device
		mov mciOpenParms.lpstrDeviceType,eax
		mov eax,NameOfFile
		mov mciOpenParms.lpstrElementName,eax
		invoke mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
		mov eax,mciOpenParms.wDeviceID
		mov Mp3DeviceID,eax
		invoke mciSendCommand,Mp3DeviceID,MCI_PLAY,00010000h,ADDR mciPlayParms
		ret  
PlayMp3File endp

OnLButtonUp PROC wParam:WPARAM, lParam:LPARAM
.data
	mousex sword ?
	mousey sword ?
.code
	.IF drawingTitle==1
		mov drawingTitle, 0
		invoke InvalidateRect,hWnd,NULL ,0
		ret
	.ENDIF
	.IF drawingInst==1
		mov drawingInst, 0
		invoke InvalidateRect,hWnd,NULL ,0
		ret
	.ENDIF
	.IF choosingMode==0
		ret
	.ENDIF
	mov eax, lParam
	mov mousex, ax
	shr eax, 16
	mov mousey, ax
	;invoke Rectangle, hDC, mousex, mousey, 10, 10
	;320
	;380
	;440
	;500
	;560
	;620

	.IF mousex<900&&mousex>650
		.IF mousey>320&&mousey<380
			mov leftAIon, 0
			mov rightAIon, 0
			mov choosingMode, 0
			call OnBtnStart
		.ELSEIF mousey>380&&mousey<440
			mov leftAIon, 0
			mov rightAIon, 1
			mov choosingMode, 0
			call OnBtnStart
		.ELSEIF mousey>440&&mousey<500
			mov leftAIon, 1
			mov rightAIon, 0
			mov choosingMode, 0
			call OnBtnStart
		.ELSEIF mousey>500&&mousey<560
			mov leftAIon, 1
			mov rightAIon, 1
			mov choosingMode, 0
			call OnBtnStart
		.ELSEIF mousey>560&&mousey<620
			invoke PostQuitMessage, NULL
		.ENDIF
	.ENDIF
	;650 -- 900
	ret
OnLButtonUp ENDP


WndProc Proc hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM ;各种消息处理
	push hwnd
	pop hWnd
	.IF uMsg == WM_DESTROY 
		invoke PostQuitMessage, NULL
	.ELSEIF uMsg == WM_CREATE
		invoke OnCreate
	.ELSEIF uMsg == WM_PAINT
		invoke OnPaint
	.ELSEIF uMsg == WM_LBUTTONDOWN
;		invoke OnLButtonDown, wParam, lParam
	.ELSEIF uMsg == WM_LBUTTONUP
		invoke OnLButtonUp, wParam, lParam
	.ELSEIF uMsg == WM_RBUTTONDOWN
;		invoke OnRButtonDown, wParam, lParam
	.ELSEIF uMsg == WM_RBUTTONUP
;		invoke OnRButtonUp, wParam, lParam
	.ELSEIF uMsg == WM_MOUSEMOVE
;		invoke OnMouseMove, wParam, lParam
	.ELSEIF uMsg == WM_DROPFILES
;		invoke OnDropFile, wParam
    .ELSEIF uMsg == MM_MCINOTIFY
		;invoke mciSendCommand,Mp3DeviceID,MCI_CLOSE,0,0
		;invoke PlayMp3File,hWnd,ADDR bgmfilename
	.ELSEIF uMsg == WM_QUIT
		invoke OnQuit
	.ELSEIF uMsg == WM_COMMAND
		mov eax, wParam  
		.IF lParam == 0
		.ELSE
			mov ebx, eax
			shr ebx,16
			.IF bx == BN_CLICKED
				.IF ax == IDC_START			;如果点击按钮的编号是start的话就触发
					invoke SetFocus, hWnd
					invoke OnBtnStart
				.ENDIF
			.ENDIF
		.ENDIF
	.ELSEIF uMsg == WM_KEYDOWN
		invoke keydown, wParam
	.ELSEIF uMsg == WM_KEYUP
		invoke keyup, wParam
	.ELSE
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
     	ret
	.ENDIF
	xor eax, eax
	RET
WndProc EndP

End Start

;三角函数
;	t TBYTE ?
;	s DWORD ?
;	invoke FpuSin, 30, addr t, SRC1_DIMM
;	invoke FpuMul, addr t, 1000, addr t, SRC1_REAL or SRC2_DIMM or DEST_MEM
;	invoke FpuRound, addr t, addr s, DEST_IMEM or SRC1_REAL
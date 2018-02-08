/*
IFDEF XIA_MIAN_SHI_YI_XIE_FEI_HUA

`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
`   火柴人打羽毛球
`
`   作者: 种璐瑶 | 周伯威 | 钱珺
`
`   2015.04
`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`

`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
`   目前为止遇到过的难点
`   · 点击start按钮后焦点停留在按钮上，无法触发键盘事件。解决: 移动焦点到hWnd
`   · 进入游戏默认为中文输入法，影响游戏。解决: 禁用输入法
`   · 窗口大小和我给的大小不一样。解决: 有个函数能算上窗口的边界，调整一下就好了
`   · 窗口初始位置不居中。解决: 获取显示器分辨率，减去窗口大小，除以二，作为左上角的坐标
`   · BGM无法循环播放。解决: 音乐结束后会产生一个uMsg，捕捉到后停止音乐再打开
`   · 帧率。。。解决不了，预期60fps只有40，预期100才会达到60
`   · 物理模型，问题很多很多，需要做很多与现实世界物理定律不一样的改动才能达到一个比较好的手感
`   · 三角函数、开根号等浮点计算: 使用fpu库来完成
`   · 画png图，比较复杂，先把图片load进内存，再把hDC与graphics关联起来，然后调用函数画图
`   · 画图卡卡卡卡卡卡，局部刷新
`   bug:
`   · 个别时候，音乐放完后会卡死。。
`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`

`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
`   配置方法
`   把main.asm放进VS工程
`   其余的head.inc、bgm.mp3、fpu.lib放在同一文件夹下，无需放入VS
`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`


next to do:
·各种绘图。。
·击球点位置的限制
·不能击球两次、过网击球    //落地击球问题ok
·发球的位置
·比分             //OK
·AI                     //太欢乐。。得改一下。加一点随机因素
·游戏模式选择

ENDIF
*/

// const
wWidth = 990;                          // 窗口大小
wHeight = 660;                         
midWidth = 495;                        // 球网水平位置
humanHeight = 522;                     // 球网高&人中心高
groundHeight = 619;                    // 地面高
ballHeight = 573;                      // 发球时球的高度
leftLimit = 53;                        // 左边界，球碰到会反弹
leftManLimit = 89;                     // 人能运动到的最左的位置
ballLeft = 39;                     // 发球时球距离左边距离
manArmX = 90;                          // 人手的位置
manArmY = 79;
armLen = 120;                          // 胳膊长

bSquare = 8;
bSize = 80;
btnLength = 24;
btnLeft = (bSize * bSquare - btnLength) / 2; // 控制开始按钮位置的
lInterval = 6;

// IDC_START = 1                         ;开始按钮的编号
// idTimer1 dd 1                           ;定时器编号

CLOCK = 0;
theBall = {
    mx: ballLeft,
    my: ballHeight,
    mvx: 22,
    mvy: -22,
    max: 0,
    may: 0,
    marc: 0, // ;头部朝向
    hitGroundTime: 0,
    cannotHit: 0,
    deg: 0
};
man1 = {
    mx: leftManLimit, //;中心点的位置
    my: humanHeight,
    mvx: 0,
    mvy: 0,
    player: 1,
    move: 0, //;0:不动，1:向前，-1:向后
    hit: 0,
    frame1: 0, //;挥拍动作的帧数，是个倒计时
    frame2: 0,
    score: 0,
    lkey: 0,
    rkey: 0,
};
man2 = {
    mx: wWidth-leftManLimit-200, //;中心点的位置
    my: humanHeight,
    mvx: 0,
    mvy: 0,
    player: 2,
    move: 0, //;0:不动，1:向前，-1:向后
    hit: 0,
    frame1: 0, //;挥拍动作的帧数，是个倒计时
    frame2: 0,
    score: 0,
    lkey: 0,
    rkey: 0,
};

ballPreX = ballLeft;
ballPreY = ballHeight;

man1preX = leftManLimit;
man1preY = humanHeight;
man2preX = wWidth - leftManLimit - 200;
man2preY = humanHeight;

hitGroundTimer = 120;

b1 = 0.0;        
u1 = 0.37;       //;羽毛球下落加速度
u2 = 0.045;      //;空气粘滞系数
u3 = 0.55;       //;人下落加速度
vvv = 24;        //;球的初始速度，需要加一个向量做修正
manv = 5.5;
manvneg = -5.5;
manjmpv = 10.5;

bx1 = -26;
bx2 = -26;
bx3 = 26;
by1 = -26;
by2 = 26;
by3 = -26;
bxp = 0;
byp = 0;

mypoint = [0, 0, 0, 0, 0, 0];

kw     = 0;
ka     = 0;
ks     = 0;
kd     = 0;
kup    = 0;
kdown  = 0;
kleft  = 0;
kright = 0;
kenter = 0;

leftAIon      = 1;
rightAIon     = 1;
leftAIhitted  = 0;
rightAIhitted = 0;

startingBall    = 1;//  ;0:不在发球，1:左边发球，2:右边发球
startingBallPre = 1;

choosingMode = 1;
someoneWins = 0;
drawingTitle = 1;
drawingInst = 1;

score1 = 0;
score2 = 0;

readPicture = 0;

ctx = $('#canv')[0].getContext('2d');

function drawTitle() {
    ctx.drawImage(images.title, 0, 0, wWidth, wHeight);
}

function drawInst() {
    ctx.drawImage(images.inst, 0, 0, wWidth, wHeight);
}

function drawChooseMode() {
    ctx.drawImage(images.start, 0, 0, wWidth, wHeight);
}

function drawBackground() {
    ctx.drawImage(images.bg, 0, 0, wWidth, wHeight);
}

function drawImage(img, x, y, w, h) {
    if (w > 0) {
        ctx.drawImage(img, x, y, w, h);
    } else {
        ctx.drawImage(img, x, y, w, h);
    }
}

function drawImage2(img, x, y, deg) {
    // ctx.drawImage(img, )
}

function drawMan(who) {
    var eax, ebx;
    if (who == 1) {
        drawImage(images.body, man1.mx - 145, man1.my - 88, 246, 213);
        drawImage(images.shadow, man1.mx - 145, 434, 246, 213);
        eax = man1.mx - 145;
        ebx = man1.my - 88;
        switch (man1.frame2) {
            case 0:
                drawImage(images.leg1, eax, ebx, 246, 213);
                if (man1.move != 0) {
                    man1.frame2 = 11;
                }
                break;
            case 1:
                drawImage(images.leg2, eax, ebx, 246, 213);
                man1.frame2--;
                man1.move = 0;
                break;
            case 11:
                drawImage(images.leg2, eax, ebx, 246, 213);
                man1.frame2--;
                break;
            case 2: case 10:
                drawImage(images.leg3, eax, ebx, 246, 213);
                man1.frame2--;
                break;
            case 3: case 9:
                drawImage(images.leg4, eax, ebx, 246, 213);
                man1.frame2--;
                break;
            case 4: case 8:
                drawImage(images.leg5, eax, ebx, 246, 213);
                man1.frame2--;
                break;
            case 5: case 7:
                drawImage(images.leg6, eax, ebx, 246, 213);
                man1.frame2--;
                break;
            case 6:
                drawImage(images.leg7, eax, ebx, 246, 213);
                man1.frame2--;
                break;
        }
        eax = man1.mx - 140;
        ebx = man1.my - 145;
        if (man1.frame1 > 16 || startingBall == 1) {
            ebx += 57;
            eax -= 5;
        }
        if (startingBall == 1) {
            drawImage(images.hand9, eax, ebx, 246, 213);
        } else {
            switch (man1.frame1) {
                case 0:
                    drawImage(images.hand1, eax, ebx, 246, 213);
                    break;
                case 1:
                    drawImage(images.hand2, eax, ebx, 246, 213);
                    man1.frame1--;
                    man1.hit = 0;
                    break;
                case 2:
                    drawImage(images.hand3, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 3:
                    drawImage(images.hand4, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 4:
                    drawImage(images.hand5, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 5:
                    drawImage(images.hand6, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 6:
                    drawImage(images.hand7, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 7:
                    drawImage(images.hand8, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 21:
                    drawImage(images.hand15, eax, ebx, 246, 213);
                    man1.frame1 = 7;
                    man1.hit = 0;
                    break;
                case 22:
                    drawImage(images.hand14, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 23:
                    drawImage(images.hand13, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 24:
                    drawImage(images.hand12, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 25:
                    drawImage(images.hand11, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 26:
                    drawImage(images.hand10, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
                case 27:
                    drawImage(images.hand9, eax, ebx, 246, 213);
                    man1.frame1--;
                    break;
            }
        }
    } else {
        eax = man2.mx + 145;
        ebx = man2.my - 88;
        drawImage(images.body, eax, ebx, -246, 213);
        drawImage(images.shadow, eax, 434, -246, 213);
        switch (man2.frame2) {
            case 0:
                drawImage(images.leg1, eax, ebx, -246, 213);
                if (man2.move != 0) {
                    man2.frame2 = 11;
                }
                break;
            case 1:
                drawImage(images.leg2, eax, ebx, -246, 213);
                man2.frame2--;
                man2.move = 0;
                break;
            case 11:
                drawImage(images.leg2, eax, ebx, -246, 213);
                man2.frame2--;
                break;
            case 2: case 10:
                drawImage(images.leg3, eax, ebx, -246, 213);
                man2.frame2--;
                break;
            case 3: case 9:
                drawImage(images.leg4, eax, ebx, -246, 213);
                man2.frame2--;
                break;
            case 4: case 8:
                drawImage(images.leg5, eax, ebx, -246, 213);
                man2.frame2--;
                break;
            case 5: case 7:
                drawImage(images.leg6, eax, ebx, -246, 213);
                man2.frame2--;
                break;
            case 6:
                drawImage(images.leg7, eax, ebx, -246, 213);
                man2.frame2--;
                break;
        }
        eax = man2.mx + 140;
        ebx = man2.my - 145;
        if (man2.frame1 > 16 || startingBall == 2) {
            ebx += 57;
            eax += 5;
        }
        if (startingBall == 2) {
            drawImage(images.hand9, eax, ebx, -246, 213);
        } else {
            switch (man2.frame1) {
                case 0:
                    drawImage(images.hand1, eax, ebx, -246, 213);
                    break;
                case 1:
                    drawImage(images.hand2, eax, ebx, -246, 213);
                    man2.frame1--;
                    man2.hit = 0;
                    break;
                case 2:
                    drawImage(images.hand3, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 3:
                    drawImage(images.hand4, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 4:
                    drawImage(images.hand5, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 5:
                    drawImage(images.hand6, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 6:
                    drawImage(images.hand7, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 7:
                    drawImage(images.hand8, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 21:
                    drawImage(images.hand15, eax, ebx, -246, 213);
                    man2.frame1 = 7;
                    man2.hit = 0;
                    break;
                case 22:
                    drawImage(images.hand14, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 23:
                    drawImage(images.hand13, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 24:
                    drawImage(images.hand12, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 25:
                    drawImage(images.hand11, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 26:
                    drawImage(images.hand10, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
                case 27:
                    drawImage(images.hand9, eax, ebx, -246, 213);
                    man2.frame1--;
                    break;
            }
        }
    }
}

function drawBall() {
    var bxp = (bx3 - bx1) / 2 + bx1 - bx2;
    var byp = (by3 - by1) / 2 + by1 - by2;
    mypoint[0] = theBall.mx + bx1;
    mypoint[1] = theBall.my + by1;
    mypoint[2] = theBall.mx + bx2;
    mypoint[3] = theBall.my + by2;
    mypoint[4] = theBall.mx + bx3;
    mypoint[5] = theBall.my + by3;
    // drawImage2(images.ball, mypoint);
    drawImage(images.ball, theBall.mx, theBall.my, bx1, by1);
}

function drawPoint() {
    drawImage(images['_' + score1], 448, 34, 22, 34);
    drawImage(images['_' + score2], 518, 34, 22, 34);
}

// sincos函数: 输入x、deg，让eax=x*sin(deg) ebx=x*cos(deg)
// sqrt函数: 输入x，让eax=sqrt(x)

function ballHitWall() {
    if (theBall.mx > wWidth - leftLimit) {
        theBall.mvx *= -1;
        theBall.mx -= 2 * (wWidth - leftLimit);
        theBall.mx *= -1;
    }
    if (theBall.mx < leftLimit) {
        theBall.mvx *= -1;
        theBall.mx -= 2 * leftLimit;
        theBall.mx *= -1;
    }
}

function ballHitGround() {
    theBall.mvy *= -1;
    theBall.mvy /= 4;
    theBall.mvx /= 2;

    theBall.my -= 2 * groundHeight;
    theBall.my *= -1;

    theBall.hitGroundTime++;
    theBall.cannotHit = 1;
    if (theBall.hitGroundTime == 1) {
        if (ballPreX < midWidth) {
            man2.score++;
            score2++;
        } else {
            man1.score++;
            score1++;
        }
    }
    if (theBall.hitGroundTime != 1) return;
    if (ballPreX < wWidth / 2) {
        startingBallPre = 2;
    } else {
        startingBallPre = 1;
    }
}

function ballStop() {
    theBall.my = groundHeight;
    theBall.mvx = 0;
    theBall.mvy = 0;
    theBall.max = 0;
    theBall.may = 0;

    if (someoneWins == 0) {
        hitGroundTimer--;
    }

    if (hitGroundTimer == 0) {
        theBall.hitGroundTime = 0;
        hitGroundTimer = 30;
        theBall.cannotHit = 0;
    } else {
        return;
    }
    startingBall = startingBallPre;
    if (theBall.mx < wWidth / 2) {
        leftAIhitted = 0;
        rightAIhitted = 1;
    } else {
        leftAIhitted = 1;
        rightAIhitted = 0;
    }
}

function ballHitNet() {
    theBall.mvx /= -2;
    theBall.mx -= wWidth;
    theBall.mx *= -1;
}

function checkBallStatus() {
    if (theBall.my > groundHeight) ballHitGround();
    if (theBall.mx > wWidth - leftLimit || theBall.mx < leftLimit) ballHitWall();
    if ((theBall.mx >= midWidth) ^ (ballPreX >= midWidth)) {
        if (theBall.my >= humanHeight && theBall.my <= groundHeight && ballPreY >= humanHeight && ballPreY <= groundHeight) {
            ballHitNet();
        }
    }
    if (theBall.hitGroundTime > 3) ballStop();
}

function ballDeg() {
    var tmp00, tmp01, tmpvx, tmpvy, tmpvv = 1000;
    tmpvx = theBall.mvx * tmpvv;
    tmpvy = theBall.mvy * tmpvv;
    if (tmpvx == 0) {
        if (tmpvy > 0) {

        }
    }
}

function ballThreePoint() {

}

function ballMove() {
    if (startingBall == 0) {
        theBall.max = -theBall.mvx * u2;
        theBall.may = u1 - theBall.mvy * u2;
        theBall.mvx += theBall.max;
        theBall.mvy += theBall.may;
        ballPreX = theBall.mx;
        theBall.mx += theBall.mvx;
        ballPreY = theBall.my;
        theBall.my += theBall.mvy;
        ballDeg();
        checkBallStatus();
    } else {
        if (startingBall == 1) {
            var eax = man1.mx;
            eax += ballLeft;
            if (leftAIon == 0) {
                eax -= 10;
            }
            theBall.mx = eax;
            eax = ballHeight;
            eax -= humanHeight;
            eax += man1.my;
            theBall.my = eax;
        } else {
            var eax = man2.mx;
            eax -= ballLeft;
            if (rightAIon == 0) {
                eax += 10;
            }
            theBall.mx = eax;
            eax = ballHeight;
            eax -= humanHeight;
            eax += man2.my;
            theBall.my = eax;
        }
    }
}

function manMove() {
    var temp;
    man1preX = man1.mx;
    man1preY = man1.my;
    man2preX = man2.mx;
    man2preY = man2.my;
    if (ka == 1 && kd == 0) {
        man1.mvx = manvneg;
        man1.move = 1;
    } else if (kd == 1 && ka == 0) {
        man1.mvx = manv;
        man1.move = 1;
    } else {
        man1.mvx = 0;
    }
    if (kleft == 1 && kright == 0) {
        man2.mvx = manvneg;
        man2.move = 1;
    } else if (kright == 1 && kleft == 0) {
        man2.mvx = manv;
        man2.move = 1;
    } else {
        man2.mvx = 0;
    }
    if (kw == 1 && man1.my == humanHeight) {
        kw = 0;
        man1.mvy = manjmpv;
    }
    if (kup == 1 && man2.my == humanHeight) {
        kup = 0;
        man2.mvy = manjmpv;
    }

    man1.mx += man1.mvx;
    man2.mx += man2.mvx;

    man1.mvy -= u3;
    man2.mvy -= u3;

    man1.my -= man1.mvy;
    man2.my -= man2.mvy;

    if (man1.my > humanHeight) {
        man1.my = humanHeight;
        man1.mvy = 0;
    }
    if (man2.my > humanHeight) {
        man2.my = humanHeight;
        man2.mvy = 0;
    }

    if (man1.mx < leftManLimit) man1.mx = leftManLimit;
    if (man1.mx > midWidth - leftLimit) man1.mx = midWidth - leftLimit;
    if (man2.mx > wWidth - leftManLimit) man2.mx = wWidth - leftManLimit;
    if (man2.mx < midWidth + leftLimit) man2.mx = midWidth + leftLimit;
    if (startingBall == 1 && man1.mx > 280) man1.mx = 280;
    if (startingBall == 2 && man2.mx < wWidth - 280) man2.mx = wWidth - 280;
}

function getDistance(x1, y1, x2, y2) {
    return Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
}

function getSpeed(who) {
    var tmp0, tmp1;
    // ;速度=vvv*球到人距离/拍子最大长度
    // ;如果不在拍子范围则返回0
    var eax, ebx;
    if (who == 1) {
        // ;这段代码判断球在拍子后面的那个扇形里面
        if (theBall.mx < man1.mx) {
            ebx = man1.mx;
            ebx -= theBall.mx;
            eax = theBall.my;
            eax -= man1.my;
            tmp1 = eax;
            if (tmp1 < 0) eax *= -1;
            eax *= 90;
            tmp0 = eax;
            eax = ebx;
            eax *= 79;
            if (tmp0 < eax) {
                eax = 0;
                return eax;
            }
        }
    } else {
        if (theBall.mx > man2.mx) {
            ebx = theBall.mx;
            ebx -= man2.mx;
            eax = theBall.my;
            eax -= man2.my;
            tmp1 = eax;
            if (tmp1 < 0) eax *= -1;
            eax *= 90;
            tmp0 = eax;
            eax = ebx;
            eax *= 79;
            if (tmp0 < eax) {
                eax = 0;
                return;
            }
        }
    }
    if (who == 1) {
        eax = getDistance(man1.mx, man1.my, theBall.mx, theBall.my);
    } else {
        eax = getDistance(man2.mx, man2.my, theBall.mx, theBall.my);
    }
    tmp0 = eax;
    if (tmp0 >= 45 && tmp0 <= 150) {
        eax *= vvv;
        eax /= 120;
        return eax;
    }
    eax = 0;
    return eax;
}

function checkHitBall() {
    if (ks == 1) {
        if (startingBall == 1) {
            startingBall = 0;
            return;
        }
        ks = 0;
        if (man1.hit == 0) {
            if (man1.my < theBall.my) {
                man1.frame1 = 27;
            } else {
                man1.frame1 = 7;
            }
            man1.hit = 1;
        }
        if (theBall.cannotHit == 0) {
            if (getSpeed(1) != 0 && theBall.mx < midWidth) {
                manHitBall(man1.mx, man1.my, theBall.mx, theBall.my, vvv);
            }
        }
    }
    if (kdown == 1) {
        if (startingBall == 2) {
            startingBall = 0;
            return;
        }
        kdown = 0;
        if (man2.hit == 0) {
            if (man2.my < theBall.my) {
                man2.frame1 = 27;
            } else {
                man2.frame1 = 7;
            }
            man2.hit = 1;
        }
        if (theBall.cannotHit == 0) {
            if (getSpeed(2) != 0 && theBall.mx > midWidth) {
                manHitBall(man2.mx, man2.my, theBall.mx, theBall.my, vvv);
            }
        }
    }
}

function hitBall(sx, sy, svx, svy) {
    theBall.mx = sx;
    theBall.my = sy;
    theBall.mvx = svx;
    theBall.mvy = svy;
    playHitBallSound();
}

function playHitBallSound() {

}

function hitBallDegree(sx, sy, v0, deg) {
    hitBall(sx, sy, v0 * cos(-deg), v0 * sin(-deg));
}

function manHitBall(mx, my, sx, sy, speed) {
    var symy2, sxmx2, a2, b2, symysxmx, a, b;
    symy2 = Math.pow(sy - my, 2);
    sxmx2 = Math.pow(sx - mx, 2);
    symysxmx = symy2 + sxmx2;
    a2 = Math.pow(speed, 2) * symy2 / symysxmx;
    b2 = Math.pow(speed, 2) - a2;

    a = Math.sqrt(a2);
    b = Math.sqrt(b2);

    if (sx > mx) a *= -1;
    if (sy < my) b *= -1;
    if (mx < midWidth && a < 0) {
        a *= -1;
        b *= -1;
    }
    if (mx > midWidth && a > 0) {
        a *= -1;
        b *= -1;
    }
    if (mx < midWidth) {
        a += 12;
        b -= 12;
    } else {
        a -= 12;
        b -= 12; // ?
    }

    if (sy > my) {
        if (mx < midWidth) {
            a = 29;
            b = -29;
        } else {
            a = -29;
            b = -29;
        }
    }
    hitBall(sx, sy, a, b);
}

/*
how to 写一个AI ?
    · 下面提示要注意的一定不能改
    · 写AI也就是根据当前各个物体的状态参数等，确定要完成的键盘操作
    · 左边AI可用的键盘操作有kw/ka/ks/kd
    · 按下按键就是把kw等等变成1，抬起就是变成0
    · 随机数取法: 有个全局变量CLOCK，是计时用的，随便把它mod一个比较小的数，就可认为是随机数

*/
function leftAIconsider() {
    var temp2;
    // ;注意! 下面这三行不能删!!!
    if (theBall.mx > midWidth) {
        leftAIhitted = 0;
    }
    // ;控制左右移动的逻辑，会跟随球的横坐标
    if (theBall.mx > midWidth) {
        if (man1.mx > midWidth / 4) {
            ka = 1;
            kd = 0;
        } else if (man1.mx < midWidth / 4) {
            kd = 1;
            ka = 0;
        }
    } else {
        if (theBall.mx > man1.mx + 150) {
            kd = 1;
            ka = 0;
        } else if (man1.mx - 30 > theBall.mx) {
            ka = 1;
            kd = 0;
        } else {
            ka = 0;
            kd = 0;
        }
    }
    // ;控制跳跃的逻辑，会跟随球的横坐标
    // ;控制击球动作的逻辑
    // ;注意! 击球动作发出前，必须判断leftAIhitted为0，击球后要将之置为1!!!!!!
    if (leftAIhitted == 0) {
        temp2 = getDistance(theBall.mx, theBall.my, man1.mx, man1.my);
        if (temp2 < 110 && temp2 > 45) {
            ks = 1;
            leftAIhitted = 1;
        }
    }
}

function rightAIconsider() {
    var temp1, eax, ebx, ecx;
    if (theBall.mx < midWidth) {
        rightAIhitted = 0;
        eax = midWidth * 1.5 + 30;
        ebx = midWidth * 1.5 - 30;
        if (man2.mx < ebx) {
            kright = 1;
            kleft = 0;
        } else if (eax < man2.mx) {
            kleft = 1;
            kright = 0;
        } else {
            kleft = 0;
            kright = 0;
        }
    } else {
        eax = man2.mx + 30;
        ebx = man2.mx - 30;
        ecx = theBall.mx + 50;
        if (ecx > eax) {
            kright = 1;
            kleft = 0;
        } else if (ebx > ecx) {
            kleft = 1;
            kright = 0;
        } else {
            kleft = 0;
            kright = 0;
        }
    }
    if (rightAIhitted == 0) {
        temp1 = getDistance(theBall.mx, theBall.my, man2.mx, man2.my);
        if (temp1 < 110 && temp1 > 45) {
            kdown = 1;
            rightAIhitted = 1;
        }
    } else {
        kup = 0;
        return;
    }
    ebx = man2.my - 80;
    temp1 = getDistance(theBall.mx, theBall.my, man2.mx, ebx);
    if (temp1 < 110 && temp1 > 45) {
        kup = 1;
    }
}

function drawOneFrame() {
    if (choosingMode == 1) {
        readPicture = 1;
    }
    onPaint();
}

function stepOver() {
    CLOCK++;
    drawOneFrame();
    ballMove();
    manMove();
    checkHitBall();
    if (leftAIon == 1) leftAIconsider();
    if (rightAIon == 1) rightAIconsider();

    if (man1.score == 7) {
        man1.score = 0;
        man2.score = 0;
        someoneWins = 1;
        showWinMessageBox(1);
        choosingMode = 1;
        drawChooseMode();
    }
    if (man2.score == 7) {
        man1.score = 0;
        man2.score = 0;
        someoneWins = 1;
        showWinMessageBox(2);
        choosingMode = 1;
        drawChooseMode();
    }
    // console.log(kw, ks, ka, kd);
}

function onPaint() {
    if (readPicture == 0) {
        // loadImages();
        drawTitle();
        readPicture = 1;
    } else {
        if (drawingTitle == 1) {
            drawTitle();
        } else if (drawingInst == 1) {
            drawInst();
        } else if (choosingMode == 1) {
            drawChooseMode();
            // onPaint();
        } else {
            drawBackground();
            drawPoint();
            drawMan(1);
            drawMan(2);
            drawBall();
        }
    }
}

function onBtnStart() {
    console.log('onBtnStart');
    man1.mx = leftManLimit;
    man1.my = humanHeight;
    man2.mx = wWidth - leftManLimit - 200;
    man2.my = humanHeight;
    hitGroundTimer = 30;
    someoneWins = 0;
    startingBall = 1;
    startingBallPre = 1;
    leftAIhitted = 0;
    rightAIhitted = 0;
    theBall.hitGroundTime = 0;
    theBall.cannotHit = 0;
    kw = 0;
    ka = 0;
    ks = 0;
    kd = 0;
    kleft = 0;
    kright = 0;
    kup = 0;
    kright = 0;
    score1 = 0;
    score2 = 0;
    CLOCK = 0;
    TIMER = setInterval(stepOver, 15);
}

document.addEventListener('keydown', function(e) {
    // console.log(e);
    if (leftAIon == 0) {
        switch (e.code) {
            case 'KeyW': kw = 1; break;
            case 'KeyS': ks = 1; break;
            case 'KeyA': ka = 1; break;
            case 'KeyD': kd = 1; break;
        }
    }
    if (rightAIon == 0) {
        switch (e.code) {
            case 'ArrowUp': kup = 1; break;
            case 'ArrowDown': kdown = 1; break;
            case 'ArrowLeft': kleft = 1; break;
            case 'ArrowRight': kright = 1; break;
        }
    }
});

document.addEventListener('keyup', function(e) {
    // console.log(e);
    if (leftAIon == 0) {
        switch (e.code) {
            case 'KeyW': kw = 0; break;
            case 'KeyS': ks = 0; break;
            case 'KeyA': ka = 0; break;
            case 'KeyD': kd = 0; break;
        }
    }
    if (rightAIon == 0) {
        switch (e.code) {
            case 'ArrowUp': kup = 0; break;
            case 'ArrowDown': kdown = 0; break;
            case 'ArrowLeft': kleft = 0; break;
            case 'ArrowRight': kright = 0; break;
        }
    }
});

document.addEventListener('mouseup', function(e) {
    if (drawingTitle == 1) {
        drawingTitle = 0;
        onPaint();
        return;
    }
    if (drawingInst == 1) {
        drawingInst = 0;
        onPaint();
        return;
    }
    if (choosingMode == 0) {
        return;
    }
    var mousex = e.x;
    var mousey = e.y;
    console.log(mousex, mousey);

    if (mousex < 900 && mousex > 650) {
        if (mousey > 320 && mousey < 380) {
            leftAIon = 0;
            rightAIon = 0;
            choosingMode = 0;
             onBtnStart();
        } else if (mousey > 380 && mousey < 440) {
            leftAIon = 0;
            rightAIon = 1;
            choosingMode = 0;
            onBtnStart();
        } else if (mousey > 440 && mousey < 500) {
            leftAIon = 1;
            rightAIon = 0;
            choosingMode = 0;
            onBtnStart();
        } else if (mousey > 500 && mousey < 560) {
            leftAIon = 1;
            rightAIon = 1;
            choosingMode = 0;
            onBtnStart();
        } else if (mousey > 560 && mousey < 620) {
            // invoke PostQuitMessage, NULL
        }
    }
});

function imageLoadComplete() {
    // onBtnStart();
    onPaint();
}

function loadImages() {
    IMAGE_LOADED = 0;
    var count = 37;
    images = {
        _0: new Image(),
        _1: new Image(),
        _2: new Image(),
        _3: new Image(),
        _4: new Image(),
        _5: new Image(),
        _6: new Image(),
        _7: new Image(),
        ball: new Image(),
        bg: new Image(),
        body: new Image(),
        hand1: new Image(),
        hand2: new Image(),
        hand3: new Image(),
        hand4: new Image(),
        hand5: new Image(),
        hand6: new Image(),
        hand7: new Image(),
        hand8: new Image(),
        hand9: new Image(),
        hand10: new Image(),
        hand11: new Image(),
        hand12: new Image(),
        hand13: new Image(),
        hand14: new Image(),
        hand15: new Image(),
        inst: new Image(),
        leg1: new Image(),
        leg2: new Image(),
        leg3: new Image(),
        leg4: new Image(),
        leg5: new Image(),
        leg6: new Image(),
        leg7: new Image(),
        shadow: new Image(),
        start: new Image(),
        title: new Image(),
    };
    with(images) {
        _0.src = 'img/0.png';
        _1.src = 'img/1.png';
        _2.src = 'img/2.png';
        _3.src = 'img/3.png';
        _4.src = 'img/4.png';
        _5.src = 'img/5.png';
        _6.src = 'img/6.png';
        _7.src = 'img/7.png';
        ball.src = 'img/ball.png';
        bg.src = 'img/bg.jpg';
        body.src = 'img/body.png';
        hand1.src = 'img/hand1.png';
        hand2.src = 'img/hand2.png';
        hand3.src = 'img/hand3.png';
        hand4.src = 'img/hand4.png';
        hand5.src = 'img/hand5.png';
        hand6.src = 'img/hand6.png';
        hand7.src = 'img/hand7.png';
        hand8.src = 'img/hand8.png';
        hand9.src = 'img/hand9.png';
        hand10.src = 'img/hand10.png';
        hand11.src = 'img/hand11.png';
        hand12.src = 'img/hand12.png';
        hand13.src = 'img/hand13.png';
        hand14.src = 'img/hand14.png';
        hand15.src = 'img/hand15.png';
        inst.src = 'img/inst.jpg';
        leg1.src = 'img/leg1.png';
        leg2.src = 'img/leg2.png';
        leg3.src = 'img/leg3.png';
        leg4.src = 'img/leg4.png';
        leg5.src = 'img/leg5.png';
        leg6.src = 'img/leg6.png';
        leg7.src = 'img/leg7.png';
        shadow.src = 'img/shadow.png';
        start.src = 'img/start.jpg';
        title.src = 'img/title.jpg';
    }
    for (var p in images) {
        images[p].onload = function() {
            IMAGE_LOADED++;
            if (IMAGE_LOADED == count) {
                imageLoadComplete();
            }
        }
    }
}

loadImages();
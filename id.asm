stack segment stack
     db 200 dup(0)
stack ends

data segment
            id db 20,?,20 dup('$')
         info1 db 'Please input your id:$'     ;提示输入id
         info2 db 'Your province is:$'         ;输出省份信息
         info3 db 'The number length is incorrect!$'   ;输入身份证号码位数不对
         info4 db 'The id number is of correct length!!$'  ;长度正确
         info5 db 'Id card number valid!!$'     ;进行多重检查后最后提示检查合格
         info6 db 'your gender is:$'        ;输出性别
         info7 db 'woman!$'
         info8 db 'man!$'
         info9 db 'The id number ends correctly!$'   ;身份证号尾数正确
        info10 db 'The last digit of the id number is incorrect!$'  ;尾数不正确
        info11 db 'Province information exists!$'  ;省份信息存在
        info12 db 'The province information does not exist!$'   ;省份信息不存在
       info13  db 'The current year is a leap year! Reasonable year of birth!$'   ;闰年
        info14 db 'The current year is not a leap year! The year of birth is not reasonable!$'   ;不是闰年
        info15 db 'Reasonable date of birth!$'   ;出生日期合理
        info16 db 'The date of birth is not reasonable!$'   ;出生日期不合理
        info17 db 'Congratulations, the id number entered is legal and valid!$'   ;最终判断合法且有效
        info18 db 'Your identity information is:$'    ;身份证信息为
        info19 db 'Your date of birth is:$'    ;输出出生日期
        info20 db 'Your age is:$'      ;输出年龄
      province db 11h,'BJ',12h,'TJ',13h,'HE',14h,'SX',15h,'NM'
               db 21h,'LN',22h,'JN',23h,'HL',31h,'SH'
               db 32h,'JS',33h,'ZJ',34h,'AH',35h,'FJ',36h,'JX'
               db 37h,'SD',41h,'HA',42h,'HB',43h,'HN'
               db 44h,'GD',45h,'GX',46h,'HI',50h,'CQ',51h,'SC'
               db 52h,'GZ',53h,'YN',54h,'XZ',61h,'SN'
               db 62h,'GS',63h,'QH',64h,'NX',65h,'XJ',71h,'TW'
               db 81h,'HK',82h,'MO',91h,'FOREIGN';省份编号
          coef db 7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2   ;计算第18位数字时的系数
         final db 1,0,'X',9,8,7,6,5,4,3,2     ;第18位可能的取值
      leapyear db 31,29,31,30,31,30,31,31,30, 31,30,31    ;闰年每月的天数
   notleapyear db 31,28,31,30,31,30,31,31,30,31,30,31     ;平年每月的天数
      divisors dw 10000,1000,100,10,1      ;将ax中的16进制年龄转成十进制然后输出
        result db 0,0,0,0,0,'$'     ;存放年龄
data ends

code segment
assume cs:code,ds:data,ss:stack

   checkbirth MACRO        ;判断出生日期是否合法
      local no
      local judge
      local yes
      local ff
      local leap
      clc
      push ax
      push bx
      push cx
      push dx
      push si
      push di
      xor ax,ax
      xor bx,bx
      xor cx,cx
      xor dx,dx
      mov al,id[12]   ;获取四位出生有效日期，不含年份
      mov bl,id[13]
      mov cl,id[14]
      mov dl,id[15]
      sub al,30h   ;01h
      sub bl,30h   ;02h
      sub cl,30h   ;00h
      sub dl,30h   ;08h
      mov di,10
      mov si,dx
      mul di   ;dx:ax=ax*di
      add ax,bx
      mov bx,ax   ;bx存储月份数12=c
      mov ax,cx
      mul di
      add ax,si  ;ax里面存储着天数8=8
      mov si,12
      cmp bx,si
      ja no   ;月份数大于12，不合理，直接退出
      mov si,0
      cmp bx,si
      jbe no   ;月份数<=0，不合理，直接退出
      jmp judge   ;月份数都合理，转向判断日期的部分
   no:display info16  ;出身日期不合理，请重新输入
      clc
      stc
      jmp exit
  yes:display info15   ;出生日期合理
      clc
      jmp exit

judge:xor cx,cx   ;先根据月份数找到可能的两种日期，即平年和闰年,分别存在cx,dx里面
      xor dx,dx
      mov si,bx
      mov cl,leapyear[si-1]    ;两种可能的天数
      mov dl,notleapyear[si-1]
      cmp cl,dl
      jz ff   ;两个日期数相同，就不需要判断是否为闰年了，只需要判断大小月是否满足
      mov si,29   ;该月份为2月
      cmp ax,si
      ja no   ;大于29显然不合理
      mov si,0
      cmp ax,si
      jbe no  ;<=0显然也不合理,否则就要判断是否是闰年了
      mov si,29
      cmp ax,si
      jz leap   ;日期为29则判断是不是闰年
      jmp yes  ;否则合理

leap:checkleapyear
     jc yes    ;返回CF=1说明是闰年，出生日期有效
     jnc no
  ff: cmp ax,cx      ;两个可能的天数一致，只需要判断大小月，即只需要判断天数是否在有有效区间内
      ja no   ;大于可能的最大日期，直接判断不合理
      mov si,0
      cmp ax,si
      jbe no    ;<=0也不合理
      jmp yes    ;否则一定会理的

 exit:pop di
      pop si
      pop dx
      pop cx
      pop bx
      pop ax
   ENDM

   checkleapyear MACRO     ;判断是不是闰年
      local yes
      local no
      local exit
      clc
      push ax
      push bx
      push cx
      push dx
      push si
      xor ax,ax
      xor bx,bx
      xor cx,cx
      xor dx,dx
      mov al,id[8]  ;1
      sub al,30h
      mov bl,id[9]  ;9
      sub bl,30h 
      mov cl,id[10] ;9
      sub cl,30h
      mov dl,id[11] ;9           ;获取年份数
      sub dl,30h
      mov bp,dx
      xor si,si  ;存放最终的年份数
      mov di,1000h
      mul di   ;ax=1*1000=1000
      add si,ax    ;si=1000
      mov ax,bx  ;9
      mov di,100h
      mul di   ;ax=9*100=100
      add si,ax   ;si=1900
      mov ax,cx
      mov di,10h
      mul di
      add si,ax   ;si=1990
      add si,bp    ;si=1999
      mov ax,si  ;ax=1999h
      xor dx,dx
      mov cx,400h
      div cx   ;余数在dx中，若为0则说明为闰年
      xor bx,bx
      cmp dl,bl
      jz  yes   ;为闰年，否则继续判断是否满足能被4整除但同时不能被100整除
      mov ax,si  ;  ax=1999h
      xor dx,dx
      mov cx,4
      div cx   ;除以4的余数放在dx中
      mov bx,0
      cmp dl,bl
      jnz no   ;不能被4整除直接跳到no，否则继续判断是不是不能被100整除
      mov ax,si
      xor dx,dx
      mov cx,100
      div cx   ;除以100的余数放在dx
      mov bx,0
      cmp dl,bl
      jnz yes    ;不能被100整除跳到yes

  yes:clc     ;防止某些系统操作使得CF=1影响结果
      stc  ;是闰年,cf=1
      jmp exit
   no:clc   ;不是闰年,cf=0
 exit:pop si
      pop dx
      pop cx
      pop bx
      pop ax
   ENDM
     
   checkend MACRO   ;检查第十八位是否合法
     local agn
     local find
     local corr
     clc
     push dx
     push si
     push bx
     push cx
     push ax
     push di
     xor bx,bx
     xor ax,ax
     xor dx,dx
     mov cx,17
     mov si,2
     mov di,0
  agn:mov al,[id+si]
      mov bl,coef[di]
      sub al,30h
      mul bl   ;ax=al*bl
      add dl,al     ;累加结果存在dx中
      adc dh,0     ;可能会有进位
      inc si
      inc di
      xor ax,ax
      xor bx,bx
      loop agn
      mov ax,dx
      xor dx,dx  ;dx先清零
      mov cx,11
      div cx  ;dx:ax/cx,余数在dx
      xor ax,ax
      xor bx,bx
      xor cx,cx
      mov al,id[19]  ;输入的尾数
      mov si,dx   ;cl存储需要移动的位数
      mov bl,final[si]   ;正确的尾数
      add bl,30h
      xor dx,dx
      cmp al,bl
      newline
      lea dx,info9  ;正确
      jz corr
      lea dx,info10  ;不正确
      clc
      stc   ;cf=1表示不正确
 corr:mov ah,09h
      int 21h
      pop di
      pop ax
      pop cx
      pop bx
      pop si
      pop dx
   ENDM


   checkgender MACRO
      local woman
      local man
      local exit
      push bx
      xor bx,bx
      mov bl,id[18]  ;第17位，表示性别
      display info6
      test bl,01h    ;与1进行与运算判断奇偶
      jz woman
      lea dx,info8
      mov ah,09h
      int 21h
      jmp exit
 woman:lea dx,info7
       mov ah,09h
       int 21h
  exit:pop bx
   ENDM

   checklength MACRO   ;检查长度是否合格
      local corr
      local wrong
      local exit
      clc
      push ax
      mov al,[id+1]   ;id字符串的长度存在地址首位的下一位
      cmp al,18
      jnz wrong
corr:display info4
     jmp exit
wrong:display info3
      clc
      stc   ;cf=1表示长度不正确，继续输入
exit: pop ax
   ENDM


   checkprovince MACRO   ;检查前两位省份信息是否正确
      local ng
      local exit
      local agn
      clc
      push ax
      push dx
      push bx
      push cx
      push di
      mov al,id[2]  ;35h(假设输入头两位是51)
      mov bl,id[3]  ;31h
      sub bl,30h   ;01h
      sub al,30h   ;05h
      mov cl,10h
      mul cl
      add al,bl  ;此时al里面存着51h
      mov cl,120
      xor si,si
      xor dx,dx
  agn:cmp al,province[si]    ;在province中遍历，若能找到前面的编号，那么省份信息一定存在
      jz ng    ;省份信息存在
      inc si
      inc bx
      loop agn
      display info12   ;省份信息不存在,cf=1
      clc
      stc   ;cf=1表示不存在该信息，继续输入
      jmp exit
   ng:display info11
      jmp exit
 exit:pop di
      pop cx
      pop bx
      pop dx
      pop ax
   ENDM


   display MACRO x    ;输出字符串并换行
      push ax
      push dx
      newline
      mov ah,09h
      lea dx,x
      int 21h
      pop dx
      pop ax
   ENDM


   dispchar MACRO x    ;输出单个字符并换行
      push dx
      push ax
      newline
      mov ah,02h
      mov dl,x
      int 21h
      pop ax
      pop dx
   ENDM


   dispchar2 MACRO x    ;输出单个字符不换行，用于输出省份信息
      push dx
      push ax
      mov ah,02h
      mov dl,x
      int 21h
      pop ax
      pop dx
   ENDM


   
   assign MACRO r1,c1,r2,c2  ;这里犯了一个致命错误，就是把cx,dx压入堆栈，导致数据初始化不成功
      mov ch,r1
      mov cl,c1
      mov dh,r2
      mov dl,c2
   ENDM



   cls MACRO r1,c1,r2,c2,x   ;清屏并将光标置于左上角
      push ax
      push bx
      push dx
      mov ah,06h
      mov al,0
      mov bh,x
      assign r1,c1,r2,c2   ;设置入口值
      int 10h
      mov ah,02h  ;置光标位置
      mov bh,0
      mov dh,0
      mov dl,0
      int 10h
      pop dx
      pop bx
      pop ax
   ENDM


   getprovince MACRO   ;根据id获取省份信息
      local agn
      local res
      local fore
      local pp
      local exit
      push si
      push cx
      push dx
      push bx
      mov al,id[2]  ;35h(假设输入头两位是51)
      mov bl,id[3]  ;31h
      sub bl,30h   ;01h
      sub al,30h   ;05h
      mov cl,10h
      mul cl
      add al,bl  ;此时al里面存着51h
      xor si,si
      mov cx,150
  agn:cmp al,province[si]  ;注意长度要一致
      jz res     ;在province里面找到了省份编号51h，说明省份信息存在
      inc si
      loop agn
  res:display info2
      cmp province[si+2],'O'    ;可能是外国人
      jz fore
      xor ax,ax
      xor bx,bx       ;si下两位就是省份信息
      mov al,province[si+1]     ;al='s'
      dispchar2 al
      mov bl,province[si+2]     ;bl='c'
      dispchar2 bl
      jmp exit
 fore:mov cx,7    ;外国人需要输出7位信息
      inc si
   pp:mov al,province[si]
      dispchar2 al
      inc si
      loop pp
 exit:newline
      pop bx
      pop dx
      pop cx
      pop si
   ENDM
   

   getbirth MACRO    ;获取出生日期
      display info19
      dispchar2 id[8]
      dispchar2 id[9]
      dispchar2 id[10]
      dispchar2 id[11]
      dispchar2 2dh    ;输出间隔符号-
      dispchar2 id[12]
      dispchar2 id[13]
      dispchar2 2dh
      dispchar2 id[14]
      dispchar2 id[15]
      newline
   ENDM


   getage MACRO   ;获取年龄
      local less
      local exit
      local aa
      local bb
      local print
      push ax
      push bx
      push cx
      push dx
      push si
      xor ax,ax
      xor bx,bx
      xor cx,cx
      xor dx,dx
      mov al,id[8]  ;1
      sub al,30h
      mov bl,id[9]  ;9
      sub bl,30h 
      mov cl,id[10] ;9
      sub cl,30h
      mov dl,id[11] ;9
      sub dl,30h
      mov bp,dx
      xor si,si  ;存放最终的年份数
      mov di,1000
      mul di   ;ax=1*1000=1000
      add si,ax    ;si=1000
      mov ax,bx  ;9
      mov di,100
      mul di   ;ax=9*100=100
      add si,ax   ;si=1900
      mov ax,cx
      mov di,10
      mul di
      add si,ax   ;si=1990
      add si,bp    ;si=1999
      mov bx,2020
      sub bx,si   ;bx里面存着年龄
      xor ax,ax
      xor cx,cx
      mov al,id[12] 
      sub al,30h   ;0
      mov cl,id[13]
      sub cl,30h   ;3
      mov si,10
      mul si
      add al,cl   ;3    ;最终月份数
      cmp al,6       ;需要判断月份数与当前月份6月的大小关系
      jnb less
      jb exit
 less:dec bx   ;不到六月份，年龄减去1
 exit:display info20      ;将ax中年龄数转成十进制输出
      mov ax,bx           ;依次除以10000,1000,100,10,1,再把每次得到的商加上48输出即可
      lea si,divisors
      lea di,result
      mov cx,5
   aa:mov dx,0
      div word ptr [si]
      add al,48    ;商加上48变成ASCII码
      mov byte ptr [di],al
      inc di
      add si,2
      mov ax,dx
      loop aa
      mov cx,4
      lea di,result
   bb:cmp byte ptr [di],'0'      ;不输出前导0
      jne print
      inc di
      loop bb
print:mov dx,di
      mov ah,9
      int 21h  
      newline
      pop si
      pop dx
      pop cx
      pop bx
      pop ax
      
   ENDM

   newline MACRO   ;回车换行
      push ax
      push dx
      mov ah,02h
      mov dl,0ah
      int 21h
      mov ah,02h
      mov dl,0dh
      int 21h
      pop dx
      pop ax
   ENDM

main: mov ax,data          ;主程序
      mov ds,ax
      cls 0,0,99,99,0bh
      clc   ;先将cf清零，下面备用
  agn:newline
      display info1
      mov ah,0ah    ;不合理则循环输入
      lea dx,id
      int 21h
      checkprovince   ;若不合理就让cf=1
      jc agn
      checklength     ;同样长度不为18就继续要求输入
      jc agn
      checkbirth    ;出生日期不合理
      jc agn
      checkend
      jc agn
      newline
      display info17  ;提示有效
      newline
      display info18   ;开始显示信息
      mov cx,30
      newline
 line1:mov dl,2dh    ;显示分割线------
      mov ah,02h
      int 21h
      loop line1
      getprovince    ;显示身份信息
      getbirth       ;显示出身日期
      getage        ;显示年龄信息
      checkgender    ;显示性别信息
      newline
      mov cx,30
line2:mov dl,2dh     ;显示分割线------
      mov ah,02h
      int 21h
      loop line2
      mov ah,4ch
      int 21h
code ends
     end main


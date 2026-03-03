
obj/__user_divzero.out:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  800020:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  800025:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  800028:	e8 64 03 00 00       	call   800391 <umain>
1:  jmp 1b
  80002d:	eb fe                	jmp    80002d <_start+0xd>

0080002f <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  80002f:	55                   	push   %ebp
  800030:	89 e5                	mov    %esp,%ebp
  800032:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800035:	8d 45 14             	lea    0x14(%ebp),%eax
  800038:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80003b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80003e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800042:	8b 45 08             	mov    0x8(%ebp),%eax
  800045:	89 44 24 04          	mov    %eax,0x4(%esp)
  800049:	c7 04 24 40 10 80 00 	movl   $0x801040,(%esp)
  800050:	e8 c3 00 00 00       	call   800118 <cprintf>
    vcprintf(fmt, ap);
  800055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	8b 45 10             	mov    0x10(%ebp),%eax
  80005f:	89 04 24             	mov    %eax,(%esp)
  800062:	e8 7e 00 00 00       	call   8000e5 <vcprintf>
    cprintf("\n");
  800067:	c7 04 24 5a 10 80 00 	movl   $0x80105a,(%esp)
  80006e:	e8 a5 00 00 00       	call   800118 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800073:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80007a:	e8 56 02 00 00       	call   8002d5 <exit>

0080007f <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  800085:	8d 45 14             	lea    0x14(%ebp),%eax
  800088:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  80008b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800092:	8b 45 08             	mov    0x8(%ebp),%eax
  800095:	89 44 24 04          	mov    %eax,0x4(%esp)
  800099:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  8000a0:	e8 73 00 00 00       	call   800118 <cprintf>
    vcprintf(fmt, ap);
  8000a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8000af:	89 04 24             	mov    %eax,(%esp)
  8000b2:	e8 2e 00 00 00       	call   8000e5 <vcprintf>
    cprintf("\n");
  8000b7:	c7 04 24 5a 10 80 00 	movl   $0x80105a,(%esp)
  8000be:	e8 55 00 00 00       	call   800118 <cprintf>
    va_end(ap);
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8000cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ce:	89 04 24             	mov    %eax,(%esp)
  8000d1:	e8 a1 01 00 00       	call   800277 <sys_putc>
    (*cnt) ++;
  8000d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d9:	8b 00                	mov    (%eax),%eax
  8000db:	8d 50 01             	lea    0x1(%eax),%edx
  8000de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e1:	89 10                	mov    %edx,(%eax)
}
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    

008000e5 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8000eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800103:	89 44 24 04          	mov    %eax,0x4(%esp)
  800107:	c7 04 24 c5 00 80 00 	movl   $0x8000c5,(%esp)
  80010e:	e8 85 04 00 00       	call   800598 <vprintfmt>
    return cnt;
  800113:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  80011e:	8d 45 0c             	lea    0xc(%ebp),%eax
  800121:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  800124:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012b:	8b 45 08             	mov    0x8(%ebp),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 af ff ff ff       	call   8000e5 <vcprintf>
  800136:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800139:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  800144:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  80014b:	eb 13                	jmp    800160 <cputs+0x22>
        cputch(c, &cnt);
  80014d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800151:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800154:	89 54 24 04          	mov    %edx,0x4(%esp)
  800158:	89 04 24             	mov    %eax,(%esp)
  80015b:	e8 65 ff ff ff       	call   8000c5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  800160:	8b 45 08             	mov    0x8(%ebp),%eax
  800163:	8d 50 01             	lea    0x1(%eax),%edx
  800166:	89 55 08             	mov    %edx,0x8(%ebp)
  800169:	0f b6 00             	movzbl (%eax),%eax
  80016c:	88 45 f7             	mov    %al,-0x9(%ebp)
  80016f:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800173:	75 d8                	jne    80014d <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  800175:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800183:	e8 3d ff ff ff       	call   8000c5 <cputch>
    return cnt;
  800188:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
  800199:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  80019c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8001a3:	eb 16                	jmp    8001bb <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  8001a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8001a8:	8d 50 04             	lea    0x4(%eax),%edx
  8001ab:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001ae:	8b 10                	mov    (%eax),%edx
  8001b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001b3:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8001b7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8001bb:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8001bf:	7e e4                	jle    8001a5 <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8001c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8001c4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8001c7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8001ca:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8001cd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    asm volatile (
  8001d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d3:	cd 80                	int    $0x80
  8001d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
  8001d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  8001db:	83 c4 20             	add    $0x20,%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_exit>:

int
sys_exit(int error_code) {
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  8001e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001f7:	e8 91 ff ff ff       	call   80018d <syscall>
}
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <sys_fork>:

int
sys_fork(void) {
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  800204:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80020b:	e8 7d ff ff ff       	call   80018d <syscall>
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <sys_wait>:

int
sys_wait(int pid, int *store) {
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021f:	8b 45 08             	mov    0x8(%ebp),%eax
  800222:	89 44 24 04          	mov    %eax,0x4(%esp)
  800226:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80022d:	e8 5b ff ff ff       	call   80018d <syscall>
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <sys_yield>:

int
sys_yield(void) {
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  80023a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800241:	e8 47 ff ff ff       	call   80018d <syscall>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <sys_kill>:

int
sys_kill(int pid) {
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80025c:	e8 2c ff ff ff       	call   80018d <syscall>
}
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <sys_getpid>:

int
sys_getpid(void) {
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  800269:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  800270:	e8 18 ff ff ff       	call   80018d <syscall>
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <sys_putc>:

int
sys_putc(int c) {
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  80028b:	e8 fd fe ff ff       	call   80018d <syscall>
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <sys_pgdir>:

int
sys_pgdir(void) {
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  800298:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  80029f:	e8 e9 fe ff ff       	call   80018d <syscall>
}
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <sys_gettime>:

size_t
sys_gettime(void) {
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_gettime);
  8002ac:	c7 04 24 11 00 00 00 	movl   $0x11,(%esp)
  8002b3:	e8 d5 fe ff ff       	call   80018d <syscall>
}
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 08             	sub    $0x8,%esp
    syscall(SYS_lab6_set_priority, priority);
  8002c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	c7 04 24 ff 00 00 00 	movl   $0xff,(%esp)
  8002ce:	e8 ba fe ff ff       	call   80018d <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8002db:	8b 45 08             	mov    0x8(%ebp),%eax
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	e8 fd fe ff ff       	call   8001e3 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8002e6:	c7 04 24 78 10 80 00 	movl   $0x801078,(%esp)
  8002ed:	e8 26 fe ff ff       	call   800118 <cprintf>
    while (1);
  8002f2:	eb fe                	jmp    8002f2 <exit+0x1d>

008002f4 <fork>:
}

int
fork(void) {
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8002fa:	e8 ff fe ff ff       	call   8001fe <sys_fork>
}
  8002ff:	c9                   	leave  
  800300:	c3                   	ret    

00800301 <wait>:

int
wait(void) {
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800307:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80030e:	00 
  80030f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800316:	e8 f7 fe ff ff       	call   800212 <sys_wait>
}
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <waitpid>:

int
waitpid(int pid, int *store) {
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
  800326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	89 04 24             	mov    %eax,(%esp)
  800330:	e8 dd fe ff ff       	call   800212 <sys_wait>
}
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <yield>:

void
yield(void) {
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  80033d:	e8 f2 fe ff ff       	call   800234 <sys_yield>
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <kill>:

int
kill(int pid) {
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	89 04 24             	mov    %eax,(%esp)
  800350:	e8 f3 fe ff ff       	call   800248 <sys_kill>
}
  800355:	c9                   	leave  
  800356:	c3                   	ret    

00800357 <getpid>:

int
getpid(void) {
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  80035d:	e8 01 ff ff ff       	call   800263 <sys_getpid>
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  80036a:	e8 23 ff ff ff       	call   800292 <sys_pgdir>
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <gettime_msec>:

unsigned int
gettime_msec(void) {
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  800377:	e8 2a ff ff ff       	call   8002a6 <sys_gettime>
}
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  800384:	8b 45 08             	mov    0x8(%ebp),%eax
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	e8 2b ff ff ff       	call   8002ba <sys_lab6_set_priority>
}
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  800397:	e8 44 0c 00 00       	call   800fe0 <main>
  80039c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  80039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003a2:	89 04 24             	mov    %eax,(%esp)
  8003a5:	e8 2b ff ff ff       	call   8002d5 <exit>

008003aa <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  8003b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  8003bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8003c1:	2b 45 0c             	sub    0xc(%ebp),%eax
  8003c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8003c7:	89 c1                	mov    %eax,%ecx
  8003c9:	d3 ea                	shr    %cl,%edx
  8003cb:	89 d0                	mov    %edx,%eax
}
  8003cd:	c9                   	leave  
  8003ce:	c3                   	ret    

008003cf <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 58             	sub    $0x58,%esp
  8003d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  8003e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8003ea:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  8003ed:	8b 45 18             	mov    0x18(%ebp),%eax
  8003f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8003f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8003f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fc:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8003ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800402:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800405:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800409:	74 1c                	je     800427 <printnum+0x58>
  80040b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	f7 75 e4             	divl   -0x1c(%ebp)
  800416:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80041c:	ba 00 00 00 00       	mov    $0x0,%edx
  800421:	f7 75 e4             	divl   -0x1c(%ebp)
  800424:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800427:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80042d:	f7 75 e4             	divl   -0x1c(%ebp)
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800436:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800439:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80043c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80043f:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800442:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800445:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800448:	8b 45 18             	mov    0x18(%ebp),%eax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
  800450:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800453:	77 56                	ja     8004ab <printnum+0xdc>
  800455:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800458:	72 05                	jb     80045f <printnum+0x90>
  80045a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  80045d:	77 4c                	ja     8004ab <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  80045f:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800462:	8d 50 ff             	lea    -0x1(%eax),%edx
  800465:	8b 45 20             	mov    0x20(%ebp),%eax
  800468:	89 44 24 18          	mov    %eax,0x18(%esp)
  80046c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800470:	8b 45 18             	mov    0x18(%ebp),%eax
  800473:	89 44 24 10          	mov    %eax,0x10(%esp)
  800477:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80047a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80047d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800481:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800485:	8b 45 0c             	mov    0xc(%ebp),%eax
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	8b 45 08             	mov    0x8(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 38 ff ff ff       	call   8003cf <printnum>
  800497:	eb 1c                	jmp    8004b5 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  800499:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a0:	8b 45 20             	mov    0x20(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a9:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8004ab:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8004af:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8004b3:	7f e4                	jg     800499 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8004b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004b8:	05 a4 11 80 00       	add    $0x8011a4,%eax
  8004bd:	0f b6 00             	movzbl (%eax),%eax
  8004c0:	0f be c0             	movsbl %al,%eax
  8004c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ca:	89 04 24             	mov    %eax,(%esp)
  8004cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d0:	ff d0                	call   *%eax
}
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  8004d7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8004db:	7e 14                	jle    8004f1 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	8d 48 08             	lea    0x8(%eax),%ecx
  8004e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e8:	89 0a                	mov    %ecx,(%edx)
  8004ea:	8b 50 04             	mov    0x4(%eax),%edx
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	eb 30                	jmp    800521 <getuint+0x4d>
    }
    else if (lflag) {
  8004f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004f5:	74 16                	je     80050d <getuint+0x39>
        return va_arg(*ap, unsigned long);
  8004f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800502:	89 0a                	mov    %ecx,(%edx)
  800504:	8b 00                	mov    (%eax),%eax
  800506:	ba 00 00 00 00       	mov    $0x0,%edx
  80050b:	eb 14                	jmp    800521 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  80050d:	8b 45 08             	mov    0x8(%ebp),%eax
  800510:	8b 00                	mov    (%eax),%eax
  800512:	8d 48 04             	lea    0x4(%eax),%ecx
  800515:	8b 55 08             	mov    0x8(%ebp),%edx
  800518:	89 0a                	mov    %ecx,(%edx)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800521:	5d                   	pop    %ebp
  800522:	c3                   	ret    

00800523 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800526:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80052a:	7e 14                	jle    800540 <getint+0x1d>
        return va_arg(*ap, long long);
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	8d 48 08             	lea    0x8(%eax),%ecx
  800534:	8b 55 08             	mov    0x8(%ebp),%edx
  800537:	89 0a                	mov    %ecx,(%edx)
  800539:	8b 50 04             	mov    0x4(%eax),%edx
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	eb 28                	jmp    800568 <getint+0x45>
    }
    else if (lflag) {
  800540:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800544:	74 12                	je     800558 <getint+0x35>
        return va_arg(*ap, long);
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	8d 48 04             	lea    0x4(%eax),%ecx
  80054e:	8b 55 08             	mov    0x8(%ebp),%edx
  800551:	89 0a                	mov    %ecx,(%edx)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	eb 10                	jmp    800568 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	8d 48 04             	lea    0x4(%eax),%ecx
  800560:	8b 55 08             	mov    0x8(%ebp),%edx
  800563:	89 0a                	mov    %ecx,(%edx)
  800565:	8b 00                	mov    (%eax),%eax
  800567:	99                   	cltd   
    }
}
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800570:	8d 45 14             	lea    0x14(%ebp),%eax
  800573:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  800576:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057d:	8b 45 10             	mov    0x10(%ebp),%eax
  800580:	89 44 24 08          	mov    %eax,0x8(%esp)
  800584:	8b 45 0c             	mov    0xc(%ebp),%eax
  800587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	e8 02 00 00 00       	call   800598 <vprintfmt>
    va_end(ap);
}
  800596:	c9                   	leave  
  800597:	c3                   	ret    

00800598 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	56                   	push   %esi
  80059c:	53                   	push   %ebx
  80059d:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8005a0:	eb 18                	jmp    8005ba <vprintfmt+0x22>
            if (ch == '\0') {
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	75 05                	jne    8005ab <vprintfmt+0x13>
                return;
  8005a6:	e9 d1 03 00 00       	jmp    80097c <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  8005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b2:	89 1c 24             	mov    %ebx,(%esp)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8005ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8005bd:	8d 50 01             	lea    0x1(%eax),%edx
  8005c0:	89 55 10             	mov    %edx,0x10(%ebp)
  8005c3:	0f b6 00             	movzbl (%eax),%eax
  8005c6:	0f b6 d8             	movzbl %al,%ebx
  8005c9:	83 fb 25             	cmp    $0x25,%ebx
  8005cc:	75 d4                	jne    8005a2 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  8005ce:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  8005d2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  8005df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e9:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8005ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ef:	8d 50 01             	lea    0x1(%eax),%edx
  8005f2:	89 55 10             	mov    %edx,0x10(%ebp)
  8005f5:	0f b6 00             	movzbl (%eax),%eax
  8005f8:	0f b6 d8             	movzbl %al,%ebx
  8005fb:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8005fe:	83 f8 55             	cmp    $0x55,%eax
  800601:	0f 87 44 03 00 00    	ja     80094b <vprintfmt+0x3b3>
  800607:	8b 04 85 c8 11 80 00 	mov    0x8011c8(,%eax,4),%eax
  80060e:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800610:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800614:	eb d6                	jmp    8005ec <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800616:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  80061a:	eb d0                	jmp    8005ec <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  80061c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800623:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800626:	89 d0                	mov    %edx,%eax
  800628:	c1 e0 02             	shl    $0x2,%eax
  80062b:	01 d0                	add    %edx,%eax
  80062d:	01 c0                	add    %eax,%eax
  80062f:	01 d8                	add    %ebx,%eax
  800631:	83 e8 30             	sub    $0x30,%eax
  800634:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800637:	8b 45 10             	mov    0x10(%ebp),%eax
  80063a:	0f b6 00             	movzbl (%eax),%eax
  80063d:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800640:	83 fb 2f             	cmp    $0x2f,%ebx
  800643:	7e 0b                	jle    800650 <vprintfmt+0xb8>
  800645:	83 fb 39             	cmp    $0x39,%ebx
  800648:	7f 06                	jg     800650 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  80064a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  80064e:	eb d3                	jmp    800623 <vprintfmt+0x8b>
            goto process_precision;
  800650:	eb 33                	jmp    800685 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800660:	eb 23                	jmp    800685 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  800662:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800666:	79 0c                	jns    800674 <vprintfmt+0xdc>
                width = 0;
  800668:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  80066f:	e9 78 ff ff ff       	jmp    8005ec <vprintfmt+0x54>
  800674:	e9 73 ff ff ff       	jmp    8005ec <vprintfmt+0x54>

        case '#':
            altflag = 1;
  800679:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800680:	e9 67 ff ff ff       	jmp    8005ec <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  800685:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800689:	79 12                	jns    80069d <vprintfmt+0x105>
                width = precision, precision = -1;
  80068b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80068e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800691:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800698:	e9 4f ff ff ff       	jmp    8005ec <vprintfmt+0x54>
  80069d:	e9 4a ff ff ff       	jmp    8005ec <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  8006a2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  8006a6:	e9 41 ff ff ff       	jmp    8005ec <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8d 50 04             	lea    0x4(%eax),%edx
  8006b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b4:	8b 00                	mov    (%eax),%eax
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	ff d0                	call   *%eax
            break;
  8006c5:	e9 ac 02 00 00       	jmp    800976 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  8006d5:	85 db                	test   %ebx,%ebx
  8006d7:	79 02                	jns    8006db <vprintfmt+0x143>
                err = -err;
  8006d9:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8006db:	83 fb 18             	cmp    $0x18,%ebx
  8006de:	7f 0b                	jg     8006eb <vprintfmt+0x153>
  8006e0:	8b 34 9d 40 11 80 00 	mov    0x801140(,%ebx,4),%esi
  8006e7:	85 f6                	test   %esi,%esi
  8006e9:	75 23                	jne    80070e <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  8006eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006ef:	c7 44 24 08 b5 11 80 	movl   $0x8011b5,0x8(%esp)
  8006f6:	00 
  8006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	89 04 24             	mov    %eax,(%esp)
  800704:	e8 61 fe ff ff       	call   80056a <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800709:	e9 68 02 00 00       	jmp    800976 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  80070e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800712:	c7 44 24 08 be 11 80 	movl   $0x8011be,0x8(%esp)
  800719:	00 
  80071a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	e8 3e fe ff ff       	call   80056a <printfmt>
            }
            break;
  80072c:	e9 45 02 00 00       	jmp    800976 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 30                	mov    (%eax),%esi
  80073c:	85 f6                	test   %esi,%esi
  80073e:	75 05                	jne    800745 <vprintfmt+0x1ad>
                p = "(null)";
  800740:	be c1 11 80 00       	mov    $0x8011c1,%esi
            }
            if (width > 0 && padc != '-') {
  800745:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800749:	7e 3e                	jle    800789 <vprintfmt+0x1f1>
  80074b:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80074f:	74 38                	je     800789 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800751:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075b:	89 34 24             	mov    %esi,(%esp)
  80075e:	e8 ed 03 00 00       	call   800b50 <strnlen>
  800763:	29 c3                	sub    %eax,%ebx
  800765:	89 d8                	mov    %ebx,%eax
  800767:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80076a:	eb 17                	jmp    800783 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  80076c:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800770:	8b 55 0c             	mov    0xc(%ebp),%edx
  800773:	89 54 24 04          	mov    %edx,0x4(%esp)
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  80077f:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800783:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800787:	7f e3                	jg     80076c <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800789:	eb 38                	jmp    8007c3 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  80078b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80078f:	74 1f                	je     8007b0 <vprintfmt+0x218>
  800791:	83 fb 1f             	cmp    $0x1f,%ebx
  800794:	7e 05                	jle    80079b <vprintfmt+0x203>
  800796:	83 fb 7e             	cmp    $0x7e,%ebx
  800799:	7e 15                	jle    8007b0 <vprintfmt+0x218>
                    putch('?', putdat);
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	ff d0                	call   *%eax
  8007ae:	eb 0f                	jmp    8007bf <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  8007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b7:	89 1c 24             	mov    %ebx,(%esp)
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8007bf:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  8007c3:	89 f0                	mov    %esi,%eax
  8007c5:	8d 70 01             	lea    0x1(%eax),%esi
  8007c8:	0f b6 00             	movzbl (%eax),%eax
  8007cb:	0f be d8             	movsbl %al,%ebx
  8007ce:	85 db                	test   %ebx,%ebx
  8007d0:	74 10                	je     8007e2 <vprintfmt+0x24a>
  8007d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d6:	78 b3                	js     80078b <vprintfmt+0x1f3>
  8007d8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8007dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e0:	79 a9                	jns    80078b <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  8007e2:	eb 17                	jmp    8007fb <vprintfmt+0x263>
                putch(' ', putdat);
  8007e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  8007f7:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  8007fb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8007ff:	7f e3                	jg     8007e4 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  800801:	e9 70 01 00 00       	jmp    800976 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800806:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080d:	8d 45 14             	lea    0x14(%ebp),%eax
  800810:	89 04 24             	mov    %eax,(%esp)
  800813:	e8 0b fd ff ff       	call   800523 <getint>
  800818:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80081b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  80081e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	79 26                	jns    80084e <vprintfmt+0x2b6>
                putch('-', putdat);
  800828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	ff d0                	call   *%eax
                num = -(long long)num;
  80083b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800841:	f7 d8                	neg    %eax
  800843:	83 d2 00             	adc    $0x0,%edx
  800846:	f7 da                	neg    %edx
  800848:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80084b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  80084e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800855:	e9 a8 00 00 00       	jmp    800902 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  80085a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80085d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800861:	8d 45 14             	lea    0x14(%ebp),%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 68 fc ff ff       	call   8004d4 <getuint>
  80086c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80086f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800872:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800879:	e9 84 00 00 00       	jmp    800902 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  80087e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	8d 45 14             	lea    0x14(%ebp),%eax
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	e8 44 fc ff ff       	call   8004d4 <getuint>
  800890:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800893:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800896:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  80089d:	eb 63                	jmp    800902 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	ff d0                	call   *%eax
            putch('x', putdat);
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8d 50 04             	lea    0x4(%eax),%edx
  8008cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ce:	8b 00                	mov    (%eax),%eax
  8008d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  8008da:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  8008e1:	eb 1f                	jmp    800902 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  8008e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	e8 df fb ff ff       	call   8004d4 <getuint>
  8008f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008f8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  8008fb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800902:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800906:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800909:	89 54 24 18          	mov    %edx,0x18(%esp)
  80090d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800910:	89 54 24 14          	mov    %edx,0x14(%esp)
  800914:	89 44 24 10          	mov    %eax,0x10(%esp)
  800918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80091e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800922:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800926:	8b 45 0c             	mov    0xc(%ebp),%eax
  800929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	89 04 24             	mov    %eax,(%esp)
  800933:	e8 97 fa ff ff       	call   8003cf <printnum>
            break;
  800938:	eb 3c                	jmp    800976 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	89 1c 24             	mov    %ebx,(%esp)
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	ff d0                	call   *%eax
            break;
  800949:	eb 2b                	jmp    800976 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  80095e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800962:	eb 04                	jmp    800968 <vprintfmt+0x3d0>
  800964:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800968:	8b 45 10             	mov    0x10(%ebp),%eax
  80096b:	83 e8 01             	sub    $0x1,%eax
  80096e:	0f b6 00             	movzbl (%eax),%eax
  800971:	3c 25                	cmp    $0x25,%al
  800973:	75 ef                	jne    800964 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  800975:	90                   	nop
        }
    }
  800976:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800977:	e9 3e fc ff ff       	jmp    8005ba <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80097c:	83 c4 40             	add    $0x40,%esp
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800986:	8b 45 0c             	mov    0xc(%ebp),%eax
  800989:	8b 40 08             	mov    0x8(%eax),%eax
  80098c:	8d 50 01             	lea    0x1(%eax),%edx
  80098f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800992:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	8b 10                	mov    (%eax),%edx
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	8b 40 04             	mov    0x4(%eax),%eax
  8009a0:	39 c2                	cmp    %eax,%edx
  8009a2:	73 12                	jae    8009b6 <sprintputch+0x33>
        *b->buf ++ = ch;
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	8b 00                	mov    (%eax),%eax
  8009a9:	8d 48 01             	lea    0x1(%eax),%ecx
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 0a                	mov    %ecx,(%edx)
  8009b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b4:	88 10                	mov    %dl,(%eax)
    }
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  8009be:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  8009c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	89 04 24             	mov    %eax,(%esp)
  8009df:	e8 08 00 00 00       	call   8009ec <vsnprintf>
  8009e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  8009e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	01 d0                	add    %edx,%eax
  800a03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800a0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a11:	74 0a                	je     800a1d <vsnprintf+0x31>
  800a13:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a19:	39 c2                	cmp    %eax,%edx
  800a1b:	76 07                	jbe    800a24 <vsnprintf+0x38>
        return -E_INVAL;
  800a1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a22:	eb 2a                	jmp    800a4e <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a24:	8b 45 14             	mov    0x14(%ebp),%eax
  800a27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a32:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a39:	c7 04 24 83 09 80 00 	movl   $0x800983,(%esp)
  800a40:	e8 53 fb ff ff       	call   800598 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a48:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800a59:	a1 00 20 80 00       	mov    0x802000,%eax
  800a5e:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800a64:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800a6a:	6b f0 05             	imul   $0x5,%eax,%esi
  800a6d:	01 f7                	add    %esi,%edi
  800a6f:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
  800a74:	f7 e6                	mul    %esi
  800a76:	8d 34 17             	lea    (%edi,%edx,1),%esi
  800a79:	89 f2                	mov    %esi,%edx
  800a7b:	83 c0 0b             	add    $0xb,%eax
  800a7e:	83 d2 00             	adc    $0x0,%edx
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	83 e7 ff             	and    $0xffffffff,%edi
  800a86:	89 f9                	mov    %edi,%ecx
  800a88:	0f b7 da             	movzwl %dx,%ebx
  800a8b:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800a91:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800a97:	a1 00 20 80 00       	mov    0x802000,%eax
  800a9c:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800aa2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800aa6:	c1 ea 0c             	shr    $0xc,%edx
  800aa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800aaf:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800ab6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ab9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800abc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800abf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800ac2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ac8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800acc:	74 1c                	je     800aea <rand+0x9a>
  800ace:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	f7 75 dc             	divl   -0x24(%ebp)
  800ad9:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800adf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae4:	f7 75 dc             	divl   -0x24(%ebp)
  800ae7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800aea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aed:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800af0:	f7 75 dc             	divl   -0x24(%ebp)
  800af3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800af9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800afc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800aff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b02:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800b08:	83 c4 24             	add    $0x24,%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
    next = seed;
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	a3 00 20 80 00       	mov    %eax,0x802000
  800b20:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800b2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  800b35:	eb 04                	jmp    800b3b <strlen+0x13>
        cnt ++;
  800b37:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8d 50 01             	lea    0x1(%eax),%edx
  800b41:	89 55 08             	mov    %edx,0x8(%ebp)
  800b44:	0f b6 00             	movzbl (%eax),%eax
  800b47:	84 c0                	test   %al,%al
  800b49:	75 ec                	jne    800b37 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  800b4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b4e:	c9                   	leave  
  800b4f:	c3                   	ret    

00800b50 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800b56:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800b5d:	eb 04                	jmp    800b63 <strnlen+0x13>
        cnt ++;
  800b5f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800b63:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b66:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800b69:	73 10                	jae    800b7b <strnlen+0x2b>
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8d 50 01             	lea    0x1(%eax),%edx
  800b71:	89 55 08             	mov    %edx,0x8(%ebp)
  800b74:	0f b6 00             	movzbl (%eax),%eax
  800b77:	84 c0                	test   %al,%al
  800b79:	75 e4                	jne    800b5f <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  800b7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	83 ec 20             	sub    $0x20,%esp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800b94:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b9a:	89 d1                	mov    %edx,%ecx
  800b9c:	89 c2                	mov    %eax,%edx
  800b9e:	89 ce                	mov    %ecx,%esi
  800ba0:	89 d7                	mov    %edx,%edi
  800ba2:	ac                   	lods   %ds:(%esi),%al
  800ba3:	aa                   	stos   %al,%es:(%edi)
  800ba4:	84 c0                	test   %al,%al
  800ba6:	75 fa                	jne    800ba2 <strcpy+0x22>
  800ba8:	89 fa                	mov    %edi,%edx
  800baa:	89 f1                	mov    %esi,%ecx
  800bac:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800baf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800bb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800bb8:	83 c4 20             	add    $0x20,%esp
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800bcb:	eb 21                	jmp    800bee <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  800bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd0:	0f b6 10             	movzbl (%eax),%edx
  800bd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bd6:	88 10                	mov    %dl,(%eax)
  800bd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bdb:	0f b6 00             	movzbl (%eax),%eax
  800bde:	84 c0                	test   %al,%al
  800be0:	74 04                	je     800be6 <strncpy+0x27>
            src ++;
  800be2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  800be6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800bea:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  800bee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bf2:	75 d9                	jne    800bcd <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	83 ec 20             	sub    $0x20,%esp
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  800c0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	89 c2                	mov    %eax,%edx
  800c17:	89 ce                	mov    %ecx,%esi
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	ac                   	lods   %ds:(%esi),%al
  800c1c:	ae                   	scas   %es:(%edi),%al
  800c1d:	75 08                	jne    800c27 <strcmp+0x2e>
  800c1f:	84 c0                	test   %al,%al
  800c21:	75 f8                	jne    800c1b <strcmp+0x22>
  800c23:	31 c0                	xor    %eax,%eax
  800c25:	eb 04                	jmp    800c2b <strcmp+0x32>
  800c27:	19 c0                	sbb    %eax,%eax
  800c29:	0c 01                	or     $0x1,%al
  800c2b:	89 fa                	mov    %edi,%edx
  800c2d:	89 f1                	mov    %esi,%ecx
  800c2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c32:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800c35:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  800c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  800c3b:	83 c4 20             	add    $0x20,%esp
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800c45:	eb 0c                	jmp    800c53 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  800c47:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800c4b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c4f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800c53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c57:	74 1a                	je     800c73 <strncmp+0x31>
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	0f b6 00             	movzbl (%eax),%eax
  800c5f:	84 c0                	test   %al,%al
  800c61:	74 10                	je     800c73 <strncmp+0x31>
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	0f b6 10             	movzbl (%eax),%edx
  800c69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6c:	0f b6 00             	movzbl (%eax),%eax
  800c6f:	38 c2                	cmp    %al,%dl
  800c71:	74 d4                	je     800c47 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800c73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c77:	74 18                	je     800c91 <strncmp+0x4f>
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	0f b6 00             	movzbl (%eax),%eax
  800c7f:	0f b6 d0             	movzbl %al,%edx
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c85:	0f b6 00             	movzbl (%eax),%eax
  800c88:	0f b6 c0             	movzbl %al,%eax
  800c8b:	29 c2                	sub    %eax,%edx
  800c8d:	89 d0                	mov    %edx,%eax
  800c8f:	eb 05                	jmp    800c96 <strncmp+0x54>
  800c91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 04             	sub    $0x4,%esp
  800c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800ca4:	eb 14                	jmp    800cba <strchr+0x22>
        if (*s == c) {
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	0f b6 00             	movzbl (%eax),%eax
  800cac:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800caf:	75 05                	jne    800cb6 <strchr+0x1e>
            return (char *)s;
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	eb 13                	jmp    800cc9 <strchr+0x31>
        }
        s ++;
  800cb6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	0f b6 00             	movzbl (%eax),%eax
  800cc0:	84 c0                	test   %al,%al
  800cc2:	75 e2                	jne    800ca6 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  800cc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 04             	sub    $0x4,%esp
  800cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800cd7:	eb 11                	jmp    800cea <strfind+0x1f>
        if (*s == c) {
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	0f b6 00             	movzbl (%eax),%eax
  800cdf:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ce2:	75 02                	jne    800ce6 <strfind+0x1b>
            break;
  800ce4:	eb 0e                	jmp    800cf4 <strfind+0x29>
        }
        s ++;
  800ce6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	0f b6 00             	movzbl (%eax),%eax
  800cf0:	84 c0                	test   %al,%al
  800cf2:	75 e5                	jne    800cd9 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    

00800cf9 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800cff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800d06:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800d0d:	eb 04                	jmp    800d13 <strtol+0x1a>
        s ++;
  800d0f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	0f b6 00             	movzbl (%eax),%eax
  800d19:	3c 20                	cmp    $0x20,%al
  800d1b:	74 f2                	je     800d0f <strtol+0x16>
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	0f b6 00             	movzbl (%eax),%eax
  800d23:	3c 09                	cmp    $0x9,%al
  800d25:	74 e8                	je     800d0f <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	0f b6 00             	movzbl (%eax),%eax
  800d2d:	3c 2b                	cmp    $0x2b,%al
  800d2f:	75 06                	jne    800d37 <strtol+0x3e>
        s ++;
  800d31:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d35:	eb 15                	jmp    800d4c <strtol+0x53>
    }
    else if (*s == '-') {
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	0f b6 00             	movzbl (%eax),%eax
  800d3d:	3c 2d                	cmp    $0x2d,%al
  800d3f:	75 0b                	jne    800d4c <strtol+0x53>
        s ++, neg = 1;
  800d41:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d45:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  800d4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d50:	74 06                	je     800d58 <strtol+0x5f>
  800d52:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d56:	75 24                	jne    800d7c <strtol+0x83>
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	3c 30                	cmp    $0x30,%al
  800d60:	75 1a                	jne    800d7c <strtol+0x83>
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	83 c0 01             	add    $0x1,%eax
  800d68:	0f b6 00             	movzbl (%eax),%eax
  800d6b:	3c 78                	cmp    $0x78,%al
  800d6d:	75 0d                	jne    800d7c <strtol+0x83>
        s += 2, base = 16;
  800d6f:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d73:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d7a:	eb 2a                	jmp    800da6 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  800d7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d80:	75 17                	jne    800d99 <strtol+0xa0>
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	0f b6 00             	movzbl (%eax),%eax
  800d88:	3c 30                	cmp    $0x30,%al
  800d8a:	75 0d                	jne    800d99 <strtol+0xa0>
        s ++, base = 8;
  800d8c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d90:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d97:	eb 0d                	jmp    800da6 <strtol+0xad>
    }
    else if (base == 0) {
  800d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9d:	75 07                	jne    800da6 <strtol+0xad>
        base = 10;
  800d9f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	0f b6 00             	movzbl (%eax),%eax
  800dac:	3c 2f                	cmp    $0x2f,%al
  800dae:	7e 1b                	jle    800dcb <strtol+0xd2>
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	0f b6 00             	movzbl (%eax),%eax
  800db6:	3c 39                	cmp    $0x39,%al
  800db8:	7f 11                	jg     800dcb <strtol+0xd2>
            dig = *s - '0';
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	0f b6 00             	movzbl (%eax),%eax
  800dc0:	0f be c0             	movsbl %al,%eax
  800dc3:	83 e8 30             	sub    $0x30,%eax
  800dc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dc9:	eb 48                	jmp    800e13 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	0f b6 00             	movzbl (%eax),%eax
  800dd1:	3c 60                	cmp    $0x60,%al
  800dd3:	7e 1b                	jle    800df0 <strtol+0xf7>
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	0f b6 00             	movzbl (%eax),%eax
  800ddb:	3c 7a                	cmp    $0x7a,%al
  800ddd:	7f 11                	jg     800df0 <strtol+0xf7>
            dig = *s - 'a' + 10;
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 00             	movzbl (%eax),%eax
  800de5:	0f be c0             	movsbl %al,%eax
  800de8:	83 e8 57             	sub    $0x57,%eax
  800deb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dee:	eb 23                	jmp    800e13 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	3c 40                	cmp    $0x40,%al
  800df8:	7e 3d                	jle    800e37 <strtol+0x13e>
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	3c 5a                	cmp    $0x5a,%al
  800e02:	7f 33                	jg     800e37 <strtol+0x13e>
            dig = *s - 'A' + 10;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	0f b6 00             	movzbl (%eax),%eax
  800e0a:	0f be c0             	movsbl %al,%eax
  800e0d:	83 e8 37             	sub    $0x37,%eax
  800e10:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e16:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e19:	7c 02                	jl     800e1d <strtol+0x124>
            break;
  800e1b:	eb 1a                	jmp    800e37 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  800e1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e21:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e24:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e28:	89 c2                	mov    %eax,%edx
  800e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2d:	01 d0                	add    %edx,%eax
  800e2f:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  800e32:	e9 6f ff ff ff       	jmp    800da6 <strtol+0xad>

    if (endptr) {
  800e37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e3b:	74 08                	je     800e45 <strtol+0x14c>
        *endptr = (char *) s;
  800e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  800e45:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e49:	74 07                	je     800e52 <strtol+0x159>
  800e4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e4e:	f7 d8                	neg    %eax
  800e50:	eb 03                	jmp    800e55 <strtol+0x15c>
  800e52:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	83 ec 24             	sub    $0x24,%esp
  800e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e61:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800e64:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800e6e:	88 45 f7             	mov    %al,-0x9(%ebp)
  800e71:	8b 45 10             	mov    0x10(%ebp),%eax
  800e74:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800e77:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800e7e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800e81:	89 d7                	mov    %edx,%edi
  800e83:	f3 aa                	rep stos %al,%es:(%edi)
  800e85:	89 fa                	mov    %edi,%edx
  800e87:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800e8a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800e8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800e90:	83 c4 24             	add    $0x24,%esp
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 30             	sub    $0x30,%esp
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800eab:	8b 45 10             	mov    0x10(%ebp),%eax
  800eae:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800eb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800eb7:	73 42                	jae    800efb <memmove+0x65>
  800eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ec2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ec5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ec8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800ecb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ece:	c1 e8 02             	shr    $0x2,%eax
  800ed1:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  800ed3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ed6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ed9:	89 d7                	mov    %edx,%edi
  800edb:	89 c6                	mov    %eax,%esi
  800edd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800edf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ee2:	83 e1 03             	and    $0x3,%ecx
  800ee5:	74 02                	je     800ee9 <memmove+0x53>
  800ee7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	89 fa                	mov    %edi,%edx
  800eed:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800ef0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ef3:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  800ef6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ef9:	eb 36                	jmp    800f31 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800efb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800efe:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f04:	01 c2                	add    %eax,%edx
  800f06:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f09:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0f:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  800f12:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f15:	89 c1                	mov    %eax,%ecx
  800f17:	89 d8                	mov    %ebx,%eax
  800f19:	89 d6                	mov    %edx,%esi
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	fd                   	std    
  800f1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f20:	fc                   	cld    
  800f21:	89 f8                	mov    %edi,%eax
  800f23:	89 f2                	mov    %esi,%edx
  800f25:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800f28:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800f2b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  800f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800f31:	83 c4 30             	add    $0x30,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	83 ec 20             	sub    $0x20,%esp
  800f41:	8b 45 08             	mov    0x8(%ebp),%eax
  800f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f50:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f56:	c1 e8 02             	shr    $0x2,%eax
  800f59:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  800f5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f61:	89 d7                	mov    %edx,%edi
  800f63:	89 c6                	mov    %eax,%esi
  800f65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f67:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f6a:	83 e1 03             	and    $0x3,%ecx
  800f6d:	74 02                	je     800f71 <memcpy+0x38>
  800f6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	89 fa                	mov    %edi,%edx
  800f75:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800f78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  800f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800f81:	83 c4 20             	add    $0x20,%esp
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f97:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  800f9a:	eb 30                	jmp    800fcc <memcmp+0x44>
        if (*s1 != *s2) {
  800f9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f9f:	0f b6 10             	movzbl (%eax),%edx
  800fa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fa5:	0f b6 00             	movzbl (%eax),%eax
  800fa8:	38 c2                	cmp    %al,%dl
  800faa:	74 18                	je     800fc4 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800fac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800faf:	0f b6 00             	movzbl (%eax),%eax
  800fb2:	0f b6 d0             	movzbl %al,%edx
  800fb5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fb8:	0f b6 00             	movzbl (%eax),%eax
  800fbb:	0f b6 c0             	movzbl %al,%eax
  800fbe:	29 c2                	sub    %eax,%edx
  800fc0:	89 d0                	mov    %edx,%eax
  800fc2:	eb 1a                	jmp    800fde <memcmp+0x56>
        }
        s1 ++, s2 ++;
  800fc4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fc8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  800fcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fcf:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fd2:	89 55 10             	mov    %edx,0x10(%ebp)
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	75 c3                	jne    800f9c <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  800fd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <main>:
#include <ulib.h>

int zero;

int
main(void) {
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 e4 f0             	and    $0xfffffff0,%esp
  800fe6:	83 ec 10             	sub    $0x10,%esp
    cprintf("value is %d.\n", 1 / zero);
  800fe9:	8b 0d 08 20 80 00    	mov    0x802008,%ecx
  800fef:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff4:	99                   	cltd   
  800ff5:	f7 f9                	idiv   %ecx
  800ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffb:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  801002:	e8 11 f1 ff ff       	call   800118 <cprintf>
    panic("FAIL: T.T\n");
  801007:	c7 44 24 08 2e 13 80 	movl   $0x80132e,0x8(%esp)
  80100e:	00 
  80100f:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  801016:	00 
  801017:	c7 04 24 39 13 80 00 	movl   $0x801339,(%esp)
  80101e:	e8 0c f0 ff ff       	call   80002f <__panic>

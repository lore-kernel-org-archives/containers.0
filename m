From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: c/r failure
Date: Wed, 23 Mar 2011 17:52:30 -0700
Message-ID: <20110324005230.GD22601@count0.beaverton.ibm.com>
References: <20110307193503.GA16777@hallyn.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="rS8CxjVDS/+yyDmU"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110307193503.GA16777-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


--rS8CxjVDS/+yyDmU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 07, 2011 at 01:35:03PM -0600, Serge E. Hallyn wrote:
> Hey,
> 
> I'm using ckpt-v23-rc1-pids branches of both linux-cr and user-cr (with
> a few trivial fixes, packaged at
> https://launchpad.net/~appcr/+archive/ppa).  Checkpoint is being done
> using
> 	/usr/bin/appcheckpoint -N -l $vardir/log $pid > $vardir/ckpt
> and restart with
> 	/usr/bin/apprestart -vd --mntns --mount-pty --pids -l $vardir/rlog < $vardir/ckpt
> 
> The resulting checkpoint file is attached as 'ckpt', the result
> of 'ckptinfo -vp $ckpt' is in ckpt-ckptinfo, and the kernel log
> (partial) from the checkpoint operation is in kernel.log.  When I
> restart, it fails with console output shown in restart.console.out.

Hi Serge,

	Unfortunately ckptinfo is broken. My most recent series of 18 patches
to user-cr fixes it. I've attached the output using an earlier version
of the kernel headers than found in the -pids branch. Consequently there are a
couple "UNKOWN" hdrs but otherwise it should provide you with much
more useful information since the broken version fails to iterate over
the entire checkpoint file.

<snip>

> <1012>====== TASKS
> <1012>  [  0] pid     0(  1) (tgid   1) ppid     0(  0)  (pgid -4097) sid    -1(-4097) creator     0(  0)
> <1012>  [  1] pid     0(  2) (tgid   2) ppid     0(  1)  (pgid   2) sid     0(  2) creator     0(  0) prev 301
> <1012>  [  2] pid     0(  3) (tgid   3) ppid     0(  1)  (pgid -4097) sid    -1(-4097) creator   301(  0)   S
> <1012>  [  3] pid     0(  4) (tgid   4) ppid     0(  1)  (pgid   4) sid     0(  4) creator     0(  0) next 301 prev   0      
> <1012>  [  4] pid     0(  5) (tgid   5) ppid     0(  4)  (pgid   5) sid     0(  5) creator     0(  0) next   0 prev   0      
> <1012>  [  5] pid     0(  6) (tgid   6) ppid     0(  5)  (pgid   5) sid     0(  5) creator     0(  0) next   0 placeholder 301
> <1012>  [  6] pid   301(  7) (tgid  -1) ppid     0(  1)  (pgid  -1) sid    -1(-4097) creator     0(  0) next   0 prev   0      D
> <1012>............
> <1012>new pidns without init
> <1012>forking coordinator in new pidns
> <1>fork child vpid 0 flags 0x1
> <1>task 0 forking with flags 11 numpids 1
> <1>task 0 pids: 0
> <1>...
> <1>forked child vpid 2 (asked 0)
> failed to create specific pid with eclone
> <1013>====== PIDS ARRAY
> <1013>[0] pid 0 depth 0
> <1013>[1] pid 0 depth 0
> <1013>[2] pid 0 depth 0
> <1013>[3] pid 0 depth 0
> <1013>[4] pid 0 depth 0
> <1013>[5] pid 0 depth 0
> <1013>............
> <1012>Coordinator failed to report status
> <1012>SIGCHLD: child not ready
> <1012>SIGCHLD: already collected
> <1012>c/r failed ?
> restart: Input/output error
> Restart failed
> root@cr-natty-i386:/home/serge#

I've been having trouble with earlier versions of user-cr than the -pids
branch. The symptoms were that sys_restart() failed to read a single
byte of the checkpoint image -- despite the stdio output of the restart
userspace program above. To see if you're experiencing the same problem,
look at dmesg and see that it dies at "pos 0" in the checkpoint file with
"Expecting type 1" -- that indicates it hasn't even read the first hdr!

It seems like the "fork feeders" aren't outputting anything and/or the pipes
are hooked up wrong in user-cr's restart, because I get EPIPE right at the
beginning. This was masked by some troubles with ckpt_err() which I still
haven't been able to figure out -- the "error" reported in dmesg above
is -512 but really should be -32 (EPIPE). You rewrote that code, didn't you? ;)

Anyhow, today I managed to bisect my user-cr troubles down to:

5b97422c4c1342a128df508cda7c4639ecb24a36

Revert was not clean and the resolved conflicts on top of the revert did
not seem to fix the problem, soo... :/ all I can recommend at the moment is
sticking to the earlier branches.

Hope that helps. Again, sorry for the delay.

Cheers,
	-Matt Helsley

--rS8CxjVDS/+yyDmU
Content-Type: application/x-info
Content-Description: ckptinfo output
Content-Disposition: attachment; filename="serge-ckpt.img.info"
Content-Transfer-Encoding: quoted-printable

info: [@8] object   1 HDR_HEADER len 72=0Ainfo: [@80] object   4 HDR_BUFFER=
 len 73=0Ainfo: [@153] object   4 HDR_BUFFER len 73=0Ainfo: [@226] object  =
 4 HDR_BUFFER len 73=0Ainfo: [@299] object   2 HDR_HEADER_ARCH len 16=0Ainf=
o: [@315] object   3 HDR_CONTAINER len 8=0Ainfo: [@323] object   4 HDR_BUFF=
ER len 19=0Ainfo: [@342] object   7 HDR_LSM_INFO len 13=0Ainfo: [@355] obje=
ct 101 HDR_TREE len 24=0Ainfo: [@379] object   4 HDR_BUFFER len 56=0ATask 0=
: pid 4 ppid 56 tgid 0pgid 0 sid 0 depth 0=0ATask 1: pid 0 ppid 0 tgid 0pgi=
d 0 sid 0 depth 0=0ATask 2: pid 0 ppid 0 tgid 0pgid 135033 sid 0 depth 0=0A=
Task 3: pid 0 ppid 0 tgid 0pgid 0 sid 0 depth 0=0ATask 4: pid 0 ppid 0 tgid=
 0pgid 0 sid 0 depth 0=0ATask 5: pid 0 ppid 0 tgid 0pgid 0 sid 0 depth 0=0A=
info: [@435] object 102 HDR_TASK len 16=0Ainfo: [@451] object   4 HDR_BUFFE=
R len 152=0Ainfo: [@603] object 103 HDR_TASK_NS len 80=0Ainfo: [@683] objec=
t   5 HDR_STRING len 24=0Ainfo: [@707] object 107 HDR_CPU len 48=0A	ax=3D0x=
00000000 bx=3D0x00000000 cx=3D0x00000000 dx=3D0x00000004 si=3D0x00000001 di=
=3D0x00000001=0A	ip=3D0x00000002 bp=3D0x00000000 sp=3D0x00000002 fs=3D0x000=
00003(0x0000) gs=3D0x00000003(0x0000)=0A	orig_ax=3D0x00000000 flags=3D0x000=
00002 cs=3D0x0000 ds=3D0x0004 es=3D0x0000 ss=3D0x0000=0Ainfo: [@755] object=
 106 HDR_THREAD len 56=0Ainfo: [@811] object 108 HDR_NS len 192=0Ainfo: [@1=
003] object 201 HDR_CPU_FPU len 520=0Ainfo: [@1523] object   6 HDR_OBJREF l=
en 16=0A	OBJ_USER ref 7=0Ainfo: [@1539] object   6 HDR_OBJREF len 16=0A	OBJ=
_SOCK ref 8=0Ainfo: [@1555] object 117 HDR_TASK_CREDS len 20=0Ainfo: [@1575=
] object   6 HDR_OBJREF len 16=0A	OBJ_GROUPINFO ref 9=0Ainfo: [@1591] objec=
t   6 HDR_OBJREF len 16=0A	OBJ_CRED ref 10=0Ainfo: [@1607] object 114 HDR_C=
RED len 16=0Ainfo: [@1623] object 116 HDR_GROUPINFO len 16=0Ainfo: [@1639] =
object 115 HDR_USER len 96=0Ainfo: [@1735] object 118 ---UNKNOWN--- len 16=
=0Ainfo: [@1751] object   6 HDR_OBJREF len 16=0A	OBJ_UTS_NS ref 12=0Ainfo: =
[@1767] object   6 HDR_OBJREF len 16=0A	OBJ_IPC_NS ref 13=0Ainfo: [@1783] o=
bject 110 HDR_IPC_NS len 400=0Ainfo: [@2183] object   6 HDR_OBJREF len 16=
=0A	OBJ_MNT_NS ref 14=0Ainfo: [@2199] object 111 HDR_MNT_NS len 56=0Ainfo: =
[@2255] object 501 HDR_IPC len 16=0Ainfo: [@2271] object 501 HDR_IPC len 16=
=0Ainfo: [@2287] object 501 HDR_IPC len 16=0Ainfo: [@2303] object   6 HDR_O=
BJREF len 16=0A	OBJ_NETDEV ref 15=0Ainfo: [@2319] object 707 HDR_NET_NS len=
 16=0Ainfo: [@2335] object   6 HDR_OBJREF len 16=0A	OBJ_SEM_UNDO ref 16=0Ai=
nfo: [@2351] object 708 HDR_NETDEV len 40=0Ainfo: [@2391] object   4 HDR_BU=
FFER len 24=0Ainfo: [@2415] object   6 HDR_OBJREF len 16=0A	OBJ_SEM_UNDO re=
f 17=0Ainfo: [@2431] object 708 HDR_NETDEV len 40=0Ainfo: [@2471] object   =
4 HDR_BUFFER len 24=0Ainfo: [@2495] object   4 HDR_BUFFER len 24=0Ainfo: [@=
2519] object   4 HDR_BUFFER len 32=0Ainfo: [@2551] object   6 HDR_OBJREF le=
n 16=0A	OBJ_SEM_UNDO ref 18=0Ainfo: [@2567] object 708 HDR_NETDEV len 40=0A=
info: [@2607] object   4 HDR_BUFFER len 24=0Ainfo: [@2631] object   4 HDR_B=
UFFER len 24=0Ainfo: [@2655] object   4 HDR_BUFFER len 32=0Ainfo: [@2687] o=
bject 109 HDR_UTS_NS len 24=0Ainfo: [@2711] object 104 HDR_TASK_OBJS len 16=
=0Ainfo: [@2727] object   6 HDR_OBJREF len 16=0A	OBJ_FILE ref 19=0Ainfo: [@=
2743] object 301 HDR_FILE_TABLE len 16=0Ainfo: [@2759] object   6 HDR_OBJRE=
F len 16=0A	OBJ_MM ref 20=0Ainfo: [@2775] object 304 HDR_FILE len 48=0A	FIL=
E_GENERIC=0Ainfo: [@2823] object 303 HDR_FILE_NAME len 18=0Ainfo: [@2841] o=
bject 302 HDR_FILE_DESC len 24=0Ainfo: [@2865] object   6 HDR_OBJREF len 16=
=0A	OBJ_MM ref 22=0Ainfo: [@2881] object 304 HDR_FILE len 48=0A	FILE_GENERI=
C=0Ainfo: [@2929] object 303 HDR_FILE_NAME len 30=0Ainfo: [@2959] object 30=
2 HDR_FILE_DESC len 24=0Ainfo: [@2983] object   6 HDR_OBJREF len 16=0A	OBJ_=
MM ref 24=0Ainfo: [@2999] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo=
: [@3047] object 303 HDR_FILE_NAME len 30=0Ainfo: [@3077] object 302 HDR_FI=
LE_DESC len 24=0Ainfo: [@3101] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 2=
6=0Ainfo: [@3117] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@3165=
] object 303 HDR_FILE_NAME len 28=0Ainfo: [@3193] object 302 HDR_FILE_DESC =
len 24=0Ainfo: [@3217] object   6 HDR_OBJREF len 16=0A	OBJ_FS ref 28=0Ainfo=
: [@3233] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 29=0Ainfo: [@3249] obj=
ect   6 HDR_OBJREF len 16=0A	OBJ_USER ref 30=0Ainfo: [@3265] object 115 HDR=
_USER len 96=0Ainfo: [@3361] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ai=
nfo: [@3409] object 303 HDR_FILE_NAME len 18=0Ainfo: [@3427] object 401 HDR=
_MM len 120=0Ainfo: [@3547] object   4 HDR_BUFFER len 360=0Ainfo: [@3907] o=
bject 402 HDR_VMA len 72=0A	VMA_FILE vmaref 29 inoref 0=0Ainfo: [@3979] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@3995] object 402 HDR_VMA len 72=0A	VMA_F=
ILE vmaref 29 inoref 0=0Ainfo: [@4067] object 403 HDR_PGARR len 16=0Ainfo: =
[@4083] object   4 HDR_BUFFER len 4108=0Ainfo: [@8191] object 403 HDR_PGARR=
 len 16=0Ainfo: [@8207] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 29 ino=
ref 0=0Ainfo: [@8279] object 403 HDR_PGARR len 16=0Ainfo: [@8295] object   =
4 HDR_BUFFER len 12308=0Ainfo: [@20603] object 403 HDR_PGARR len 16=0Ainfo:=
 [@20619] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [=
@20691] object 403 HDR_PGARR len 16=0Ainfo: [@20707] object   4 HDR_BUFFER =
len 20508=0Ainfo: [@41215] object 403 HDR_PGARR len 16=0Ainfo: [@41231] obj=
ect 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@41303] objec=
t 403 HDR_PGARR len 16=0Ainfo: [@41319] object   4 HDR_BUFFER len 45108=0Ai=
nfo: [@86427] object 403 HDR_PGARR len 16=0Ainfo: [@86443] object   6 HDR_O=
BJREF len 16=0A	OBJ_MM ref 33=0Ainfo: [@86459] object 304 HDR_FILE len 48=
=0A	FILE_GENERIC=0Ainfo: [@86507] object 303 HDR_FILE_NAME len 43=0Ainfo: [=
@86550] object 402 HDR_VMA len 72=0A	VMA_SHM_FILE vmaref 33 inoref 35=0Ainf=
o: [@86622] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 36=0Ainfo: [@86638] =
object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@86686] object 303 HDR_=
FILE_NAME len 39=0Ainfo: [@86725] object 402 HDR_VMA len 72=0A	VMA_FILE vma=
ref 36 inoref 0=0Ainfo: [@86797] object 403 HDR_PGARR len 16=0Ainfo: [@8681=
3] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@86885]=
 object 403 HDR_PGARR len 16=0Ainfo: [@86901] object   4 HDR_BUFFER len 410=
8=0Ainfo: [@91009] object 403 HDR_PGARR len 16=0Ainfo: [@91025] object   6 =
HDR_OBJREF len 16=0A	OBJ_MM ref 38=0Ainfo: [@91041] object 304 HDR_FILE len=
 48=0A	FILE_GENERIC=0Ainfo: [@91089] object 303 HDR_FILE_NAME len 26=0Ainfo=
: [@91115] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 38 inoref 0=0Ainfo:=
 [@91187] object 403 HDR_PGARR len 16=0Ainfo: [@91203] object 402 HDR_VMA l=
en 72=0A	VMA_FILE vmaref 38 inoref 0=0Ainfo: [@91275] object 403 HDR_PGARR =
len 16=0Ainfo: [@91291] object   4 HDR_BUFFER len 8208=0Ainfo: [@99499] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@99515] object 402 HDR_VMA len 72=0A	VMA_=
FILE vmaref 38 inoref 0=0Ainfo: [@99587] object 403 HDR_PGARR len 16=0Ainfo=
: [@99603] object   4 HDR_BUFFER len 4108=0Ainfo: [@103711] object 403 HDR_=
PGARR len 16=0Ainfo: [@103727] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref=
 0 inoref 0=0Ainfo: [@103799] object 403 HDR_PGARR len 16=0Ainfo: [@103815]=
 object   4 HDR_BUFFER len 12308=0Ainfo: [@116123] object 403 HDR_PGARR len=
 16=0Ainfo: [@116139] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 40=0Ainfo:=
 [@116155] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@116203] obj=
ect 303 HDR_FILE_NAME len 27=0Ainfo: [@116230] object 402 HDR_VMA len 72=0A=
	VMA_FILE vmaref 40 inoref 0=0Ainfo: [@116302] object 403 HDR_PGARR len 16=
=0Ainfo: [@116318] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 40 inoref 0=
=0Ainfo: [@116390] object 403 HDR_PGARR len 16=0Ainfo: [@116406] object   4=
 HDR_BUFFER len 4108=0Ainfo: [@120514] object 403 HDR_PGARR len 16=0Ainfo: =
[@120530] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 40 inoref 0=0Ainfo: =
[@120602] object 403 HDR_PGARR len 16=0Ainfo: [@120618] object   4 HDR_BUFF=
ER len 4108=0Ainfo: [@124726] object 403 HDR_PGARR len 16=0Ainfo: [@124742]=
 object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 42=0Ainfo: [@124758] object 304=
 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@124806] object 303 HDR_FILE_NAME=
 len 31=0Ainfo: [@124837] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 42 i=
noref 0=0Ainfo: [@124909] object 403 HDR_PGARR len 16=0Ainfo: [@124925] obj=
ect 402 HDR_VMA len 72=0A	VMA_FILE vmaref 42 inoref 0=0Ainfo: [@124997] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@125013] object 402 HDR_VMA len 72=0A	VMA=
_FILE vmaref 42 inoref 0=0Ainfo: [@125085] object 403 HDR_PGARR len 16=0Ain=
fo: [@125101] object   4 HDR_BUFFER len 8208=0Ainfo: [@133309] object 403 H=
DR_PGARR len 16=0Ainfo: [@133325] object 402 HDR_VMA len 72=0A	VMA_FILE vma=
ref 42 inoref 0=0Ainfo: [@133397] object 403 HDR_PGARR len 16=0Ainfo: [@133=
413] object   4 HDR_BUFFER len 4108=0Ainfo: [@137521] object 403 HDR_PGARR =
len 16=0Ainfo: [@137537] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 ino=
ref 0=0Ainfo: [@137609] object 403 HDR_PGARR len 16=0Ainfo: [@137625] objec=
t   4 HDR_BUFFER len 8208=0Ainfo: [@145833] object 403 HDR_PGARR len 16=0Ai=
nfo: [@145849] object 402 HDR_VMA len 72=0A	VMA_VDSO vmaref 0 inoref 0=0Ain=
fo: [@145921] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 44=0Ainfo: [@14593=
7] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@145985] object 303 =
HDR_FILE_NAME len 24=0Ainfo: [@146009] object 402 HDR_VMA len 72=0A	VMA_FIL=
E vmaref 44 inoref 0=0Ainfo: [@146081] object 403 HDR_PGARR len 16=0Ainfo: =
[@146097] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 44 inoref 0=0Ainfo: =
[@146169] object 403 HDR_PGARR len 16=0Ainfo: [@146185] object   4 HDR_BUFF=
ER len 4108=0Ainfo: [@150293] object 403 HDR_PGARR len 16=0Ainfo: [@150309]=
 object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 44 inoref 0=0Ainfo: [@150381]=
 object 403 HDR_PGARR len 16=0Ainfo: [@150397] object   4 HDR_BUFFER len 41=
08=0Ainfo: [@154505] object 403 HDR_PGARR len 16=0Ainfo: [@154521] object 4=
02 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@154593] object 40=
3 HDR_PGARR len 16=0Ainfo: [@154609] object   4 HDR_BUFFER len 16408=0Ainfo=
: [@171017] object 403 HDR_PGARR len 16=0Ainfo: [@171033] object 404 HDR_MM=
_CONTEXT len 24=0Ainfo: [@171057] object 202 HDR_MM_CONTEXT_LDT len 8=0Ainf=
o: [@171065] object   6 HDR_OBJREF len 16=0A	OBJ_SIGHAND ref 46=0Ainfo: [@1=
71081] object 451 HDR_FS len 16=0Ainfo: [@171097] object 303 HDR_FILE_NAME =
len 20=0Ainfo: [@171117] object 303 HDR_FILE_NAME len 10=0Ainfo: [@171127] =
object   6 HDR_OBJREF len 16=0A	OBJ_SIGNAL ref 47=0Ainfo: [@171143] object =
601 HDR_SIGHAND len 2056=0Ainfo: [@173199] object 105 HDR_RESTART_BLOCK len=
 32=0Ainfo: [@173231] object 602 HDR_SIGNAL len 328=0Ainfo: [@173559] objec=
t 604 HDR_SIGPENDING len 24=0Ainfo: [@173583] object 604 HDR_SIGPENDING len=
 24=0Ainfo: [@173607] object 603 HDR_SIGNAL_TASK len 16=0Ainfo: [@173623] o=
bject 103 HDR_TASK_NS len 80=0Ainfo: [@173703] object   5 HDR_STRING len 24=
=0Ainfo: [@173727] object 107 HDR_CPU len 48=0A	ax=3D0x00000000 bx=3D0x0000=
0000 cx=3D0x00000000 dx=3D0xffffffff si=3D0xffffffff di=3D0xffffffff=0A	ip=
=3D0x00000400 bp=3D0x00000000 sp=3D0x00010000 fs=3D0xffffffff(0xffff) gs=3D=
0xffffffff(0xffff)=0A	orig_ax=3D0x00000400 flags=3D0x00010000 cs=3D0x0000 d=
s=3D0xffff es=3D0xffff ss=3D0x0000=0Ainfo: [@173775] object 106 HDR_THREAD =
len 56=0Ainfo: [@173831] object 108 HDR_NS len 192=0Ainfo: [@174023] object=
 201 HDR_CPU_FPU len 520=0Ainfo: [@174543] object   6 HDR_OBJREF len 16=0A	=
OBJ_USER ref 49=0Ainfo: [@174559] object   6 HDR_OBJREF len 16=0A	OBJ_SOCK =
ref 50=0Ainfo: [@174575] object 117 HDR_TASK_CREDS len 16=0Ainfo: [@174591]=
 object 115 HDR_USER len 96=0Ainfo: [@174687] object 118 ---UNKNOWN--- len =
16=0Ainfo: [@174703] object 104 HDR_TASK_OBJS len 16=0Ainfo: [@174719] obje=
ct   6 HDR_OBJREF len 16=0A	OBJ_FILE ref 52=0Ainfo: [@174735] object 301 HD=
R_FILE_TABLE len 16=0Ainfo: [@174751] object   6 HDR_OBJREF len 16=0A	OBJ_M=
M ref 53=0Ainfo: [@174767] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainf=
o: [@174815] object 303 HDR_FILE_NAME len 18=0Ainfo: [@174833] object 302 H=
DR_FILE_DESC len 24=0Ainfo: [@174857] object 302 HDR_FILE_DESC len 24=0Ainf=
o: [@174881] object 302 HDR_FILE_DESC len 24=0Ainfo: [@174905] object   6 H=
DR_OBJREF len 16=0A	OBJ_MM ref 55=0Ainfo: [@174921] object   6 HDR_OBJREF l=
en 16=0A	OBJ_TTY ref 56=0Ainfo: [@174937] object 701 HDR_SOCKET len 120=0Ai=
nfo: [@175057] object 706 HDR_SOCKET_INET len 328=0Ainfo: [@175385] object =
304 HDR_FILE len 56=0A	FILE_SOCKET=0Ainfo: [@175441] object 302 HDR_FILE_DE=
SC len 24=0Ainfo: [@175465] object   6 HDR_OBJREF len 16=0A	OBJ_FS ref 58=
=0Ainfo: [@175481] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 59=0Ainfo: [@=
175497] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 60=0Ainfo: [@175513] o=
bject 115 HDR_USER len 96=0Ainfo: [@175609] object 304 HDR_FILE len 48=0A	F=
ILE_GENERIC=0Ainfo: [@175657] object 303 HDR_FILE_NAME len 23=0Ainfo: [@175=
680] object 401 HDR_MM len 120=0Ainfo: [@175800] object   4 HDR_BUFFER len =
360=0Ainfo: [@176160] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 63=0Ainfo:=
 [@176176] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 64=0Ainfo: [@176192=
] object   6 HDR_OBJREF len 16=0A	OBJ_SOCK ref 65=0Ainfo: [@176208] object =
117 HDR_TASK_CREDS len 16=0Ainfo: [@176224] object 115 HDR_USER len 96=0Ain=
fo: [@176320] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@176368] =
object 303 HDR_FILE_NAME len 34=0Ainfo: [@176402] object 402 HDR_VMA len 72=
=0A	VMA_FILE vmaref 63 inoref 0=0Ainfo: [@176474] object 403 HDR_PGARR len =
16=0Ainfo: [@176490] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 63 inoref=
 0=0Ainfo: [@176562] object 403 HDR_PGARR len 16=0Ainfo: [@176578] object  =
 4 HDR_BUFFER len 4108=0Ainfo: [@180686] object 403 HDR_PGARR len 16=0Ainfo=
: [@180702] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 63 inoref 0=0Ainfo=
: [@180774] object 403 HDR_PGARR len 16=0Ainfo: [@180790] object   4 HDR_BU=
FFER len 4108=0Ainfo: [@184898] object 403 HDR_PGARR len 16=0Ainfo: [@18491=
4] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 68=0Ainfo: [@184930] object 3=
04 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@184978] object 303 HDR_FILE_NA=
ME len 32=0Ainfo: [@185010] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 68=
 inoref 0=0Ainfo: [@185082] object 403 HDR_PGARR len 16=0Ainfo: [@185098] o=
bject 402 HDR_VMA len 72=0A	VMA_FILE vmaref 68 inoref 0=0Ainfo: [@185170] o=
bject 403 HDR_PGARR len 16=0Ainfo: [@185186] object   4 HDR_BUFFER len 4108=
=0Ainfo: [@189294] object 403 HDR_PGARR len 16=0Ainfo: [@189310] object 402=
 HDR_VMA len 72=0A	VMA_FILE vmaref 68 inoref 0=0Ainfo: [@189382] object 403=
 HDR_PGARR len 16=0Ainfo: [@189398] object   4 HDR_BUFFER len 4108=0Ainfo: =
[@193506] object 403 HDR_PGARR len 16=0Ainfo: [@193522] object   6 HDR_OBJR=
EF len 16=0A	OBJ_MM ref 70=0Ainfo: [@193538] object 304 HDR_FILE len 48=0A	=
FILE_GENERIC=0Ainfo: [@193586] object 303 HDR_FILE_NAME len 35=0Ainfo: [@19=
3621] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 70 inoref 0=0Ainfo: [@19=
3693] object 403 HDR_PGARR len 16=0Ainfo: [@193709] object 402 HDR_VMA len =
72=0A	VMA_FILE vmaref 70 inoref 0=0Ainfo: [@193781] object 403 HDR_PGARR le=
n 16=0Ainfo: [@193797] object   4 HDR_BUFFER len 4108=0Ainfo: [@197905] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@197921] object 402 HDR_VMA len 72=0A	VMA=
_FILE vmaref 70 inoref 0=0Ainfo: [@197993] object 403 HDR_PGARR len 16=0Ain=
fo: [@198009] object   4 HDR_BUFFER len 4108=0Ainfo: [@202117] object 403 H=
DR_PGARR len 16=0Ainfo: [@202133] object 402 HDR_VMA len 72=0A	VMA_ANON vma=
ref 0 inoref 0=0Ainfo: [@202205] object 403 HDR_PGARR len 16=0Ainfo: [@2022=
21] object   4 HDR_BUFFER len 8208=0Ainfo: [@210429] object 403 HDR_PGARR l=
en 16=0Ainfo: [@210445] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 72=0Ainf=
o: [@210461] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 73=0Ainfo: [@2104=
77] object 115 HDR_USER len 96=0Ainfo: [@210573] object 304 HDR_FILE len 48=
=0A	FILE_GENERIC=0Ainfo: [@210621] object 303 HDR_FILE_NAME len 31=0Ainfo: =
[@210652] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 72 inoref 0=0Ainfo: =
[@210724] object 403 HDR_PGARR len 16=0Ainfo: [@210740] object 402 HDR_VMA =
len 72=0A	VMA_FILE vmaref 72 inoref 0=0Ainfo: [@210812] object 403 HDR_PGAR=
R len 16=0Ainfo: [@210828] object   4 HDR_BUFFER len 4108=0Ainfo: [@214936]=
 object 403 HDR_PGARR len 16=0Ainfo: [@214952] object 402 HDR_VMA len 72=0A=
	VMA_FILE vmaref 72 inoref 0=0Ainfo: [@215024] object 403 HDR_PGARR len 16=
=0Ainfo: [@215040] object   4 HDR_BUFFER len 4108=0Ainfo: [@219148] object =
403 HDR_PGARR len 16=0Ainfo: [@219164] object 402 HDR_VMA len 72=0A	VMA_ANO=
N vmaref 0 inoref 0=0Ainfo: [@219236] object 403 HDR_PGARR len 16=0Ainfo: [=
@219252] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 76=0Ainfo: [@219268] ob=
ject 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@219316] object 303 HDR_F=
ILE_NAME len 32=0Ainfo: [@219348] object 402 HDR_VMA len 72=0A	VMA_FILE vma=
ref 76 inoref 0=0Ainfo: [@219420] object 403 HDR_PGARR len 16=0Ainfo: [@219=
436] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 76 inoref 0=0Ainfo: [@219=
508] object 403 HDR_PGARR len 16=0Ainfo: [@219524] object   4 HDR_BUFFER le=
n 4108=0Ainfo: [@223632] object 403 HDR_PGARR len 16=0Ainfo: [@223648] obje=
ct 402 HDR_VMA len 72=0A	VMA_FILE vmaref 76 inoref 0=0Ainfo: [@223720] obje=
ct 403 HDR_PGARR len 16=0Ainfo: [@223736] object   4 HDR_BUFFER len 4108=0A=
info: [@227844] object 403 HDR_PGARR len 16=0Ainfo: [@227860] object   6 HD=
R_OBJREF len 16=0A	OBJ_MM ref 78=0Ainfo: [@227876] object 304 HDR_FILE len =
48=0A	FILE_GENERIC=0Ainfo: [@227924] object 303 HDR_FILE_NAME len 39=0Ainfo=
: [@227963] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 78 inoref 0=0Ainfo=
: [@228035] object 403 HDR_PGARR len 16=0Ainfo: [@228051] object 402 HDR_VM=
A len 72=0A	VMA_FILE vmaref 78 inoref 0=0Ainfo: [@228123] object 403 HDR_PG=
ARR len 16=0Ainfo: [@228139] object   4 HDR_BUFFER len 4108=0Ainfo: [@23224=
7] object 403 HDR_PGARR len 16=0Ainfo: [@232263] object 402 HDR_VMA len 72=
=0A	VMA_FILE vmaref 78 inoref 0=0Ainfo: [@232335] object 403 HDR_PGARR len =
16=0Ainfo: [@232351] object   4 HDR_BUFFER len 4108=0Ainfo: [@236459] objec=
t 403 HDR_PGARR len 16=0Ainfo: [@236475] object   6 HDR_OBJREF len 16=0A	OB=
J_MM ref 80=0Ainfo: [@236491] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0A=
info: [@236539] object 303 HDR_FILE_NAME len 36=0Ainfo: [@236575] object 40=
2 HDR_VMA len 72=0A	VMA_FILE vmaref 80 inoref 0=0Ainfo: [@236647] object 40=
3 HDR_PGARR len 16=0Ainfo: [@236663] object 402 HDR_VMA len 72=0A	VMA_FILE =
vmaref 80 inoref 0=0Ainfo: [@236735] object 403 HDR_PGARR len 16=0Ainfo: [@=
236751] object   4 HDR_BUFFER len 4108=0Ainfo: [@240859] object 403 HDR_PGA=
RR len 16=0Ainfo: [@240875] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 80=
 inoref 0=0Ainfo: [@240947] object 403 HDR_PGARR len 16=0Ainfo: [@240963] o=
bject   4 HDR_BUFFER len 4108=0Ainfo: [@245071] object 403 HDR_PGARR len 16=
=0Ainfo: [@245087] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=
=0Ainfo: [@245159] object 403 HDR_PGARR len 16=0Ainfo: [@245175] object   4=
 HDR_BUFFER len 4108=0Ainfo: [@249283] object 403 HDR_PGARR len 16=0Ainfo: =
[@249299] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 82=0Ainfo: [@249315] o=
bject 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@249363] object 303 HDR_=
FILE_NAME len 27=0Ainfo: [@249390] object 402 HDR_VMA len 72=0A	VMA_FILE vm=
aref 82 inoref 0=0Ainfo: [@249462] object 403 HDR_PGARR len 16=0Ainfo: [@24=
9478] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 82 inoref 0=0Ainfo: [@24=
9550] object 403 HDR_PGARR len 16=0Ainfo: [@249566] object   4 HDR_BUFFER l=
en 4108=0Ainfo: [@253674] object 403 HDR_PGARR len 16=0Ainfo: [@253690] obj=
ect 402 HDR_VMA len 72=0A	VMA_FILE vmaref 82 inoref 0=0Ainfo: [@253762] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@253778] object   4 HDR_BUFFER len 4108=
=0Ainfo: [@257886] object 403 HDR_PGARR len 16=0Ainfo: [@257902] object   6=
 HDR_OBJREF len 16=0A	OBJ_MM ref 84=0Ainfo: [@257918] object 304 HDR_FILE l=
en 48=0A	FILE_GENERIC=0Ainfo: [@257966] object 303 HDR_FILE_NAME len 28=0Ai=
nfo: [@257994] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 84 inoref 0=0Ai=
nfo: [@258066] object 403 HDR_PGARR len 16=0Ainfo: [@258082] object 402 HDR=
_VMA len 72=0A	VMA_FILE vmaref 84 inoref 0=0Ainfo: [@258154] object 403 HDR=
_PGARR len 16=0Ainfo: [@258170] object   4 HDR_BUFFER len 4108=0Ainfo: [@26=
2278] object 403 HDR_PGARR len 16=0Ainfo: [@262294] object 402 HDR_VMA len =
72=0A	VMA_FILE vmaref 84 inoref 0=0Ainfo: [@262366] object 403 HDR_PGARR le=
n 16=0Ainfo: [@262382] object   4 HDR_BUFFER len 4108=0Ainfo: [@266490] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@266506] object 402 HDR_VMA len 72=0A	VMA=
_ANON vmaref 0 inoref 0=0Ainfo: [@266578] object 403 HDR_PGARR len 16=0Ainf=
o: [@266594] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 86=0Ainfo: [@266610=
] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@266658] object 303 H=
DR_FILE_NAME len 26=0Ainfo: [@266684] object 402 HDR_VMA len 72=0A	VMA_FILE=
 vmaref 86 inoref 0=0Ainfo: [@266756] object 403 HDR_PGARR len 16=0Ainfo: [=
@266772] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 86 inoref 0=0Ainfo: [=
@266844] object 403 HDR_PGARR len 16=0Ainfo: [@266860] object   4 HDR_BUFFE=
R len 8208=0Ainfo: [@275068] object 403 HDR_PGARR len 16=0Ainfo: [@275084] =
object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 86 inoref 0=0Ainfo: [@275156] =
object 403 HDR_PGARR len 16=0Ainfo: [@275172] object   4 HDR_BUFFER len 410=
8=0Ainfo: [@279280] object 403 HDR_PGARR len 16=0Ainfo: [@279296] object 40=
2 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@279368] object 403=
 HDR_PGARR len 16=0Ainfo: [@279384] object   4 HDR_BUFFER len 12308=0Ainfo:=
 [@291692] object 403 HDR_PGARR len 16=0Ainfo: [@291708] object   6 HDR_OBJ=
REF len 16=0A	OBJ_MM ref 88=0Ainfo: [@291724] object 304 HDR_FILE len 48=0A=
	FILE_GENERIC=0Ainfo: [@291772] object 303 HDR_FILE_NAME len 31=0Ainfo: [@2=
91803] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 88 inoref 0=0Ainfo: [@2=
91875] object 403 HDR_PGARR len 16=0Ainfo: [@291891] object 402 HDR_VMA len=
 72=0A	VMA_FILE vmaref 88 inoref 0=0Ainfo: [@291963] object 403 HDR_PGARR l=
en 16=0Ainfo: [@291979] object   4 HDR_BUFFER len 4108=0Ainfo: [@296087] ob=
ject 403 HDR_PGARR len 16=0Ainfo: [@296103] object 402 HDR_VMA len 72=0A	VM=
A_FILE vmaref 88 inoref 0=0Ainfo: [@296175] object 403 HDR_PGARR len 16=0Ai=
nfo: [@296191] object   4 HDR_BUFFER len 4108=0Ainfo: [@300299] object 403 =
HDR_PGARR len 16=0Ainfo: [@300315] object   6 HDR_OBJREF len 16=0A	OBJ_MM r=
ef 90=0Ainfo: [@300331] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: =
[@300379] object 303 HDR_FILE_NAME len 32=0Ainfo: [@300411] object 402 HDR_=
VMA len 72=0A	VMA_FILE vmaref 90 inoref 0=0Ainfo: [@300483] object 403 HDR_=
PGARR len 16=0Ainfo: [@300499] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref=
 90 inoref 0=0Ainfo: [@300571] object 403 HDR_PGARR len 16=0Ainfo: [@300587=
] object   4 HDR_BUFFER len 20508=0Ainfo: [@321095] object 403 HDR_PGARR le=
n 16=0Ainfo: [@321111] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 90 inor=
ef 0=0Ainfo: [@321183] object 403 HDR_PGARR len 16=0Ainfo: [@321199] object=
   4 HDR_BUFFER len 4108=0Ainfo: [@325307] object 403 HDR_PGARR len 16=0Ain=
fo: [@325323] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 92=0Ainfo: [@32533=
9] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@325387] object 303 =
HDR_FILE_NAME len 39=0Ainfo: [@325426] object 402 HDR_VMA len 72=0A	VMA_FIL=
E vmaref 92 inoref 0=0Ainfo: [@325498] object 403 HDR_PGARR len 16=0Ainfo: =
[@325514] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 92 inoref 0=0Ainfo: =
[@325586] object 403 HDR_PGARR len 16=0Ainfo: [@325602] object   4 HDR_BUFF=
ER len 4108=0Ainfo: [@329710] object 403 HDR_PGARR len 16=0Ainfo: [@329726]=
 object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 92 inoref 0=0Ainfo: [@329798]=
 object 403 HDR_PGARR len 16=0Ainfo: [@329814] object   4 HDR_BUFFER len 41=
08=0Ainfo: [@333922] object 403 HDR_PGARR len 16=0Ainfo: [@333938] object 4=
02 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@334010] object 40=
3 HDR_PGARR len 16=0Ainfo: [@334026] object   4 HDR_BUFFER len 4108=0Ainfo:=
 [@338134] object 403 HDR_PGARR len 16=0Ainfo: [@338150] object   6 HDR_OBJ=
REF len 16=0A	OBJ_MM ref 94=0Ainfo: [@338166] object 304 HDR_FILE len 48=0A=
	FILE_GENERIC=0Ainfo: [@338214] object 303 HDR_FILE_NAME len 30=0Ainfo: [@3=
38244] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 94 inoref 0=0Ainfo: [@3=
38316] object 403 HDR_PGARR len 16=0Ainfo: [@338332] object 402 HDR_VMA len=
 72=0A	VMA_FILE vmaref 94 inoref 0=0Ainfo: [@338404] object 403 HDR_PGARR l=
en 16=0Ainfo: [@338420] object   4 HDR_BUFFER len 4108=0Ainfo: [@342528] ob=
ject 403 HDR_PGARR len 16=0Ainfo: [@342544] object 402 HDR_VMA len 72=0A	VM=
A_FILE vmaref 94 inoref 0=0Ainfo: [@342616] object 403 HDR_PGARR len 16=0Ai=
nfo: [@342632] object   4 HDR_BUFFER len 4108=0Ainfo: [@346740] object 403 =
HDR_PGARR len 16=0Ainfo: [@346756] object 402 HDR_VMA len 72=0A	VMA_ANON vm=
aref 0 inoref 0=0Ainfo: [@346828] object 403 HDR_PGARR len 16=0Ainfo: [@346=
844] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 96=0Ainfo: [@346860] object=
 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@346908] object 303 HDR_FILE_=
NAME len 29=0Ainfo: [@346937] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref =
96 inoref 0=0Ainfo: [@347009] object 403 HDR_PGARR len 16=0Ainfo: [@347025]=
 object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 96 inoref 0=0Ainfo: [@347097]=
 object 403 HDR_PGARR len 16=0Ainfo: [@347113] object   4 HDR_BUFFER len 41=
08=0Ainfo: [@351221] object 403 HDR_PGARR len 16=0Ainfo: [@351237] object 4=
02 HDR_VMA len 72=0A	VMA_FILE vmaref 96 inoref 0=0Ainfo: [@351309] object 4=
03 HDR_PGARR len 16=0Ainfo: [@351325] object   4 HDR_BUFFER len 4108=0Ainfo=
: [@355433] object 403 HDR_PGARR len 16=0Ainfo: [@355449] object   6 HDR_OB=
JREF len 16=0A	OBJ_MM ref 98=0Ainfo: [@355465] object 304 HDR_FILE len 48=
=0A	FILE_GENERIC=0Ainfo: [@355513] object 303 HDR_FILE_NAME len 29=0Ainfo: =
[@355542] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 98 inoref 0=0Ainfo: =
[@355614] object 403 HDR_PGARR len 16=0Ainfo: [@355630] object 402 HDR_VMA =
len 72=0A	VMA_FILE vmaref 98 inoref 0=0Ainfo: [@355702] object 403 HDR_PGAR=
R len 16=0Ainfo: [@355718] object   4 HDR_BUFFER len 4108=0Ainfo: [@359826]=
 object 403 HDR_PGARR len 16=0Ainfo: [@359842] object 402 HDR_VMA len 72=0A=
	VMA_FILE vmaref 98 inoref 0=0Ainfo: [@359914] object 403 HDR_PGARR len 16=
=0Ainfo: [@359930] object   4 HDR_BUFFER len 4108=0Ainfo: [@364038] object =
403 HDR_PGARR len 16=0Ainfo: [@364054] object   6 HDR_OBJREF len 16=0A	OBJ_=
MM ref 100=0Ainfo: [@364070] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ai=
nfo: [@364118] object 303 HDR_FILE_NAME len 32=0Ainfo: [@364150] object 402=
 HDR_VMA len 72=0A	VMA_FILE vmaref 100 inoref 0=0Ainfo: [@364222] object 40=
3 HDR_PGARR len 16=0Ainfo: [@364238] object 402 HDR_VMA len 72=0A	VMA_FILE =
vmaref 100 inoref 0=0Ainfo: [@364310] object 403 HDR_PGARR len 16=0Ainfo: [=
@364326] object   4 HDR_BUFFER len 32808=0Ainfo: [@397134] object 403 HDR_P=
GARR len 16=0Ainfo: [@397150] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref =
100 inoref 0=0Ainfo: [@397222] object 403 HDR_PGARR len 16=0Ainfo: [@397238=
] object   4 HDR_BUFFER len 61508=0Ainfo: [@458746] object 403 HDR_PGARR le=
n 16=0Ainfo: [@458762] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inore=
f 0=0Ainfo: [@458834] object 403 HDR_PGARR len 16=0Ainfo: [@458850] object =
  4 HDR_BUFFER len 4108=0Ainfo: [@462958] object 403 HDR_PGARR len 16=0Ainf=
o: [@462974] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 102=0Ainfo: [@46299=
0] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@463038] object 303 =
HDR_FILE_NAME len 32=0Ainfo: [@463070] object 402 HDR_VMA len 72=0A	VMA_FIL=
E vmaref 102 inoref 0=0Ainfo: [@463142] object 403 HDR_PGARR len 16=0Ainfo:=
 [@463158] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 102 inoref 0=0Ainfo=
: [@463230] object 403 HDR_PGARR len 16=0Ainfo: [@463246] object 402 HDR_VM=
A len 72=0A	VMA_FILE vmaref 102 inoref 0=0Ainfo: [@463318] object 403 HDR_P=
GARR len 16=0Ainfo: [@463334] object   4 HDR_BUFFER len 4108=0Ainfo: [@4674=
42] object 403 HDR_PGARR len 16=0Ainfo: [@467458] object 402 HDR_VMA len 72=
=0A	VMA_FILE vmaref 102 inoref 0=0Ainfo: [@467530] object 403 HDR_PGARR len=
 16=0Ainfo: [@467546] object   4 HDR_BUFFER len 4108=0Ainfo: [@471654] obje=
ct 403 HDR_PGARR len 16=0Ainfo: [@471670] object 402 HDR_VMA len 72=0A	VMA_=
ANON vmaref 0 inoref 0=0Ainfo: [@471742] object 403 HDR_PGARR len 16=0Ainfo=
: [@471758] object   4 HDR_BUFFER len 4108=0Ainfo: [@475866] object 403 HDR=
_PGARR len 16=0Ainfo: [@475882] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref =
104=0Ainfo: [@475898] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@=
475946] object 303 HDR_FILE_NAME len 29=0Ainfo: [@475975] object 402 HDR_VM=
A len 72=0A	VMA_FILE vmaref 104 inoref 0=0Ainfo: [@476047] object 403 HDR_P=
GARR len 16=0Ainfo: [@476063] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref =
104 inoref 0=0Ainfo: [@476135] object 403 HDR_PGARR len 16=0Ainfo: [@476151=
] object   4 HDR_BUFFER len 4108=0Ainfo: [@480259] object 403 HDR_PGARR len=
 16=0Ainfo: [@480275] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 104 inor=
ef 0=0Ainfo: [@480347] object 403 HDR_PGARR len 16=0Ainfo: [@480363] object=
   4 HDR_BUFFER len 4108=0Ainfo: [@484471] object 403 HDR_PGARR len 16=0Ain=
fo: [@484487] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainf=
o: [@484559] object 403 HDR_PGARR len 16=0Ainfo: [@484575] object   4 HDR_B=
UFFER len 4108=0Ainfo: [@488683] object 403 HDR_PGARR len 16=0Ainfo: [@4886=
99] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 106=0Ainfo: [@488715] object=
 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@488763] object 303 HDR_FILE_=
NAME len 30=0Ainfo: [@488793] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref =
106 inoref 0=0Ainfo: [@488865] object 403 HDR_PGARR len 16=0Ainfo: [@488881=
] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 106 inoref 0=0Ainfo: [@48895=
3] object 403 HDR_PGARR len 16=0Ainfo: [@488969] object   4 HDR_BUFFER len =
4108=0Ainfo: [@493077] object 403 HDR_PGARR len 16=0Ainfo: [@493093] object=
 402 HDR_VMA len 72=0A	VMA_FILE vmaref 106 inoref 0=0Ainfo: [@493165] objec=
t 403 HDR_PGARR len 16=0Ainfo: [@493181] object   4 HDR_BUFFER len 4108=0Ai=
nfo: [@497289] object 403 HDR_PGARR len 16=0Ainfo: [@497305] object   6 HDR=
_OBJREF len 16=0A	OBJ_MM ref 108=0Ainfo: [@497321] object 304 HDR_FILE len =
48=0A	FILE_GENERIC=0Ainfo: [@497369] object 303 HDR_FILE_NAME len 30=0Ainfo=
: [@497399] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 108 inoref 0=0Ainf=
o: [@497471] object 403 HDR_PGARR len 16=0Ainfo: [@497487] object 402 HDR_V=
MA len 72=0A	VMA_FILE vmaref 108 inoref 0=0Ainfo: [@497559] object 403 HDR_=
PGARR len 16=0Ainfo: [@497575] object   4 HDR_BUFFER len 4108=0Ainfo: [@501=
683] object 403 HDR_PGARR len 16=0Ainfo: [@501699] object 402 HDR_VMA len 7=
2=0A	VMA_FILE vmaref 108 inoref 0=0Ainfo: [@501771] object 403 HDR_PGARR le=
n 16=0Ainfo: [@501787] object   4 HDR_BUFFER len 4108=0Ainfo: [@505895] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@505911] object 402 HDR_VMA len 72=0A	VMA=
_ANON vmaref 0 inoref 0=0Ainfo: [@505983] object 403 HDR_PGARR len 16=0Ainf=
o: [@505999] object   4 HDR_BUFFER len 8208=0Ainfo: [@514207] object 403 HD=
R_PGARR len 16=0Ainfo: [@514223] object 402 HDR_VMA len 72=0A	VMA_VDSO vmar=
ef 0 inoref 0=0Ainfo: [@514295] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref =
110=0Ainfo: [@514311] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@=
514359] object 303 HDR_FILE_NAME len 24=0Ainfo: [@514383] object 402 HDR_VM=
A len 72=0A	VMA_FILE vmaref 110 inoref 0=0Ainfo: [@514455] object 403 HDR_P=
GARR len 16=0Ainfo: [@514471] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref =
110 inoref 0=0Ainfo: [@514543] object 403 HDR_PGARR len 16=0Ainfo: [@514559=
] object   4 HDR_BUFFER len 4108=0Ainfo: [@518667] object 403 HDR_PGARR len=
 16=0Ainfo: [@518683] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 110 inor=
ef 0=0Ainfo: [@518755] object 403 HDR_PGARR len 16=0Ainfo: [@518771] object=
   4 HDR_BUFFER len 4108=0Ainfo: [@522879] object 403 HDR_PGARR len 16=0Ain=
fo: [@522895] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 59 inoref 0=0Ain=
fo: [@522967] object 403 HDR_PGARR len 16=0Ainfo: [@522983] object 402 HDR_=
VMA len 72=0A	VMA_FILE vmaref 59 inoref 0=0Ainfo: [@523055] object 403 HDR_=
PGARR len 16=0Ainfo: [@523071] object   4 HDR_BUFFER len 8208=0Ainfo: [@531=
279] object 403 HDR_PGARR len 16=0Ainfo: [@531295] object 402 HDR_VMA len 7=
2=0A	VMA_FILE vmaref 59 inoref 0=0Ainfo: [@531367] object 403 HDR_PGARR len=
 16=0Ainfo: [@531383] object   4 HDR_BUFFER len 4108=0Ainfo: [@535491] obje=
ct 403 HDR_PGARR len 16=0Ainfo: [@535507] object 402 HDR_VMA len 72=0A	VMA_=
ANON vmaref 0 inoref 0=0Ainfo: [@535579] object 403 HDR_PGARR len 16=0Ainfo=
: [@535595] object   4 HDR_BUFFER len 20508=0Ainfo: [@556103] object 403 HD=
R_PGARR len 16=0Ainfo: [@556119] object 402 HDR_VMA len 72=0A	VMA_ANON vmar=
ef 0 inoref 0=0Ainfo: [@556191] object 403 HDR_PGARR len 16=0Ainfo: [@55620=
7] object   4 HDR_BUFFER len 53308=0Ainfo: [@609515] object 403 HDR_PGARR l=
en 16=0Ainfo: [@609531] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inor=
ef 0=0Ainfo: [@609603] object 403 HDR_PGARR len 16=0Ainfo: [@609619] object=
   4 HDR_BUFFER len 20508=0Ainfo: [@630127] object 403 HDR_PGARR len 16=0Ai=
nfo: [@630143] object 404 HDR_MM_CONTEXT len 24=0Ainfo: [@630167] object 20=
2 HDR_MM_CONTEXT_LDT len 8=0Ainfo: [@630175] object   6 HDR_OBJREF len 16=
=0A	OBJ_SIGHAND ref 112=0Ainfo: [@630191] object 451 HDR_FS len 16=0Ainfo: =
[@630207] object 303 HDR_FILE_NAME len 10=0Ainfo: [@630217] object 303 HDR_=
FILE_NAME len 10=0Ainfo: [@630227] object   6 HDR_OBJREF len 16=0A	OBJ_SIGN=
AL ref 113=0Ainfo: [@630243] object 601 HDR_SIGHAND len 2056=0Ainfo: [@6322=
99] object 105 HDR_RESTART_BLOCK len 32=0Ainfo: [@632331] object 602 HDR_SI=
GNAL len 328=0Ainfo: [@632659] object 604 HDR_SIGPENDING len 24=0Ainfo: [@6=
32683] object 604 HDR_SIGPENDING len 24=0Ainfo: [@632707] object 603 HDR_SI=
GNAL_TASK len 16=0Ainfo: [@632723] object 103 HDR_TASK_NS len 80=0Ainfo: [@=
632803] object   5 HDR_STRING len 24=0Ainfo: [@632827] object 107 HDR_CPU l=
en 48=0A	ax=3D0x00000000 bx=3D0x00000000 cx=3D0x00000000 dx=3D0xffffffff si=
=3D0xffffffff di=3D0xffffffff=0A	ip=3D0x00000400 bp=3D0x00000000 sp=3D0x000=
10000 fs=3D0xffffffff(0xffff) gs=3D0xffffffff(0xffff)=0A	orig_ax=3D0x000004=
00 flags=3D0x00010000 cs=3D0x0000 ds=3D0xffff es=3D0xffff ss=3D0x0000=0Ainf=
o: [@632875] object 106 HDR_THREAD len 56=0Ainfo: [@632931] object 108 HDR_=
NS len 192=0Ainfo: [@633123] object 201 HDR_CPU_FPU len 520=0Ainfo: [@63364=
3] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 115=0Ainfo: [@633659] objec=
t 115 HDR_USER len 96=0Ainfo: [@633755] object 118 ---UNKNOWN--- len 16=0Ai=
nfo: [@633771] object 104 HDR_TASK_OBJS len 16=0Ainfo: [@633787] object   6=
 HDR_OBJREF len 16=0A	OBJ_FILE ref 117=0Ainfo: [@633803] object 301 HDR_FIL=
E_TABLE len 16=0Ainfo: [@633819] object 302 HDR_FILE_DESC len 24=0Ainfo: [@=
633843] object 302 HDR_FILE_DESC len 24=0Ainfo: [@633867] object 302 HDR_FI=
LE_DESC len 24=0Ainfo: [@633891] object   6 HDR_OBJREF len 16=0A	OBJ_FS ref=
 118=0Ainfo: [@633907] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 119=0Ainf=
o: [@633923] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 120=0Ainfo: [@633=
939] object 115 HDR_USER len 96=0Ainfo: [@634035] object 304 HDR_FILE len 4=
8=0A	FILE_GENERIC=0Ainfo: [@634083] object 303 HDR_FILE_NAME len 19=0Ainfo:=
 [@634102] object 401 HDR_MM len 120=0Ainfo: [@634222] object   4 HDR_BUFFE=
R len 360=0Ainfo: [@634582] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 11=
9 inoref 0=0Ainfo: [@634654] object 403 HDR_PGARR len 16=0Ainfo: [@634670] =
object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 119 inoref 0=0Ainfo: [@634742]=
 object 403 HDR_PGARR len 16=0Ainfo: [@634758] object   4 HDR_BUFFER len 41=
08=0Ainfo: [@638866] object 403 HDR_PGARR len 16=0Ainfo: [@638882] object 4=
02 HDR_VMA len 72=0A	VMA_FILE vmaref 119 inoref 0=0Ainfo: [@638954] object =
403 HDR_PGARR len 16=0Ainfo: [@638970] object   4 HDR_BUFFER len 4108=0Ainf=
o: [@643078] object 403 HDR_PGARR len 16=0Ainfo: [@643094] object 402 HDR_V=
MA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@643166] object 403 HDR_PG=
ARR len 16=0Ainfo: [@643182] object   4 HDR_BUFFER len 4108=0Ainfo: [@64729=
0] object 403 HDR_PGARR len 16=0Ainfo: [@647306] object   6 HDR_OBJREF len =
16=0A	OBJ_MM ref 123=0Ainfo: [@647322] object 304 HDR_FILE len 48=0A	FILE_G=
ENERIC=0Ainfo: [@647370] object 303 HDR_FILE_NAME len 39=0Ainfo: [@647409] =
object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 123 inoref 0=0Ainfo: [@647481]=
 object 403 HDR_PGARR len 16=0Ainfo: [@647497] object 402 HDR_VMA len 72=0A=
	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@647569] object 403 HDR_PGARR len 16=
=0Ainfo: [@647585] object   4 HDR_BUFFER len 4108=0Ainfo: [@651693] object =
403 HDR_PGARR len 16=0Ainfo: [@651709] object   6 HDR_OBJREF len 16=0A	OBJ_=
MM ref 125=0Ainfo: [@651725] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ai=
nfo: [@651773] object 303 HDR_FILE_NAME len 26=0Ainfo: [@651799] object 402=
 HDR_VMA len 72=0A	VMA_FILE vmaref 125 inoref 0=0Ainfo: [@651871] object 40=
3 HDR_PGARR len 16=0Ainfo: [@651887] object 402 HDR_VMA len 72=0A	VMA_FILE =
vmaref 125 inoref 0=0Ainfo: [@651959] object 403 HDR_PGARR len 16=0Ainfo: [=
@651975] object   4 HDR_BUFFER len 8208=0Ainfo: [@660183] object 403 HDR_PG=
ARR len 16=0Ainfo: [@660199] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 1=
25 inoref 0=0Ainfo: [@660271] object 403 HDR_PGARR len 16=0Ainfo: [@660287]=
 object   4 HDR_BUFFER len 4108=0Ainfo: [@664395] object 403 HDR_PGARR len =
16=0Ainfo: [@664411] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref =
0=0Ainfo: [@664483] object 403 HDR_PGARR len 16=0Ainfo: [@664499] object   =
4 HDR_BUFFER len 8208=0Ainfo: [@672707] object 403 HDR_PGARR len 16=0Ainfo:=
 [@672723] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: =
[@672795] object 403 HDR_PGARR len 16=0Ainfo: [@672811] object   4 HDR_BUFF=
ER len 8208=0Ainfo: [@681019] object 403 HDR_PGARR len 16=0Ainfo: [@681035]=
 object 402 HDR_VMA len 72=0A	VMA_VDSO vmaref 0 inoref 0=0Ainfo: [@681107] =
object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 127=0Ainfo: [@681123] object 304=
 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@681171] object 303 HDR_FILE_NAME=
 len 24=0Ainfo: [@681195] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 127 =
inoref 0=0Ainfo: [@681267] object 403 HDR_PGARR len 16=0Ainfo: [@681283] ob=
ject 402 HDR_VMA len 72=0A	VMA_FILE vmaref 127 inoref 0=0Ainfo: [@681355] o=
bject 403 HDR_PGARR len 16=0Ainfo: [@681371] object   4 HDR_BUFFER len 4108=
=0Ainfo: [@685479] object 403 HDR_PGARR len 16=0Ainfo: [@685495] object 402=
 HDR_VMA len 72=0A	VMA_FILE vmaref 127 inoref 0=0Ainfo: [@685567] object 40=
3 HDR_PGARR len 16=0Ainfo: [@685583] object   4 HDR_BUFFER len 4108=0Ainfo:=
 [@689691] object 403 HDR_PGARR len 16=0Ainfo: [@689707] object 402 HDR_VMA=
 len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@689779] object 403 HDR_PGAR=
R len 16=0Ainfo: [@689795] object   4 HDR_BUFFER len 8208=0Ainfo: [@698003]=
 object 403 HDR_PGARR len 16=0Ainfo: [@698019] object 404 HDR_MM_CONTEXT le=
n 24=0Ainfo: [@698043] object 202 HDR_MM_CONTEXT_LDT len 8=0Ainfo: [@698051=
] object   6 HDR_OBJREF len 16=0A	OBJ_SIGHAND ref 129=0Ainfo: [@698067] obj=
ect 451 HDR_FS len 16=0Ainfo: [@698083] object 303 HDR_FILE_NAME len 20=0Ai=
nfo: [@698103] object 303 HDR_FILE_NAME len 10=0Ainfo: [@698113] object   6=
 HDR_OBJREF len 16=0A	OBJ_SIGNAL ref 130=0Ainfo: [@698129] object 601 HDR_S=
IGHAND len 2056=0Ainfo: [@700185] object 105 HDR_RESTART_BLOCK len 32=0Ainf=
o: [@700217] object 602 HDR_SIGNAL len 328=0Ainfo: [@700545] object 604 HDR=
_SIGPENDING len 24=0Ainfo: [@700569] object 604 HDR_SIGPENDING len 24=0Ainf=
o: [@700593] object 603 HDR_SIGNAL_TASK len 16=0Ainfo: [@700609] object 103=
 HDR_TASK_NS len 80=0Ainfo: [@700689] object   5 HDR_STRING len 24=0Ainfo: =
[@700713] object 107 HDR_CPU len 48=0A	ax=3D0x00000000 bx=3D0x00000000 cx=
=3D0x00000000 dx=3D0xffffffff si=3D0xffffffff di=3D0xffffffff=0A	ip=3D0x000=
00400 bp=3D0x00000000 sp=3D0x00010000 fs=3D0xffffffff(0xffff) gs=3D0xffffff=
ff(0xffff)=0A	orig_ax=3D0x00000400 flags=3D0x00010000 cs=3D0x0000 ds=3D0xff=
ff es=3D0xffff ss=3D0x0000=0Ainfo: [@700761] object 106 HDR_THREAD len 56=
=0Ainfo: [@700817] object 108 HDR_NS len 192=0Ainfo: [@701009] object 201 H=
DR_CPU_FPU len 520=0Ainfo: [@701529] object   6 HDR_OBJREF len 16=0A	OBJ_US=
ER ref 132=0Ainfo: [@701545] object   6 HDR_OBJREF len 16=0A	OBJ_SOCK ref 1=
33=0Ainfo: [@701561] object 117 HDR_TASK_CREDS len 20=0Ainfo: [@701581] obj=
ect 115 HDR_USER len 96=0Ainfo: [@701677] object 118 ---UNKNOWN--- len 16=
=0Ainfo: [@701693] object 104 HDR_TASK_OBJS len 16=0Ainfo: [@701709] object=
   6 HDR_OBJREF len 16=0A	OBJ_FILE ref 135=0Ainfo: [@701725] object 301 HDR=
_FILE_TABLE len 16=0Ainfo: [@701741] object   6 HDR_OBJREF len 16=0A	OBJ_MM=
 ref 136=0Ainfo: [@701757] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 137=
=0Ainfo: [@701773] object 115 HDR_USER len 96=0Ainfo: [@701869] object 304 =
HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@701917] object 303 HDR_FILE_NAME =
len 18=0Ainfo: [@701935] object 302 HDR_FILE_DESC len 24=0Ainfo: [@701959] =
object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 140=0Ainfo: [@701975] object 304=
 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@702023] object 303 HDR_FILE_NAME=
 len 18=0Ainfo: [@702041] object 302 HDR_FILE_DESC len 24=0Ainfo: [@702065]=
 object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 142=0Ainfo: [@702081] object 30=
4 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@702129] object 303 HDR_FILE_NAM=
E len 18=0Ainfo: [@702147] object 302 HDR_FILE_DESC len 24=0Ainfo: [@702171=
] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 144=0Ainfo: [@702187] object  =
 6 HDR_OBJREF len 16=0A	OBJ_USER ref 146=0Ainfo: [@702203] object 115 HDR_U=
SER len 96=0Ainfo: [@702299] object 304 HDR_FILE len 56=0A	FILE_FIFO=0Ainfo=
: [@702355] object 303 HDR_FILE_NAME len 40=0Ainfo: [@702395] object 305 HD=
R_PIPE_BUF len 8=0Ainfo: [@702403] object 302 HDR_FILE_DESC len 24=0Ainfo: =
[@702427] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 149=0Ainfo: [@702443] =
object   6 HDR_OBJREF len 16=0A	OBJ_SECURITY_PTR ref 150=0Ainfo: [@702459] =
object 306 HDR_TTY len 96=0Ainfo: [@702555] object 307 HDR_TTY_LDISC len 56=
0=0Ainfo: [@703115] object   6 HDR_OBJREF len 16=0A	OBJ_SECURITY_PTR ref 15=
2=0Ainfo: [@703131] object 306 HDR_TTY len 96=0Ainfo: [@703227] object 307 =
HDR_TTY_LDISC len 560=0Ainfo: [@703787] object 304 HDR_FILE len 56=0A	FILE_=
TTY=0Ainfo: [@703843] object 302 HDR_FILE_DESC len 24=0Ainfo: [@703867] obj=
ect   6 HDR_OBJREF len 16=0A	OBJ_FS ref 154=0Ainfo: [@703883] object   6 HD=
R_OBJREF len 16=0A	OBJ_MM ref 155=0Ainfo: [@703899] object   6 HDR_OBJREF l=
en 16=0A	OBJ_USER ref 156=0Ainfo: [@703915] object 115 HDR_USER len 96=0Ain=
fo: [@704011] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@704059] =
object 303 HDR_FILE_NAME len 24=0Ainfo: [@704083] object 401 HDR_MM len 120=
=0Ainfo: [@704203] object   4 HDR_BUFFER len 360=0Ainfo: [@704563] object 4=
02 HDR_VMA len 72=0A	VMA_FILE vmaref 155 inoref 0=0Ainfo: [@704635] object =
403 HDR_PGARR len 16=0Ainfo: [@704651] object 402 HDR_VMA len 72=0A	VMA_FIL=
E vmaref 155 inoref 0=0Ainfo: [@704723] object 403 HDR_PGARR len 16=0Ainfo:=
 [@704739] object   4 HDR_BUFFER len 4108=0Ainfo: [@708847] object 403 HDR_=
PGARR len 16=0Ainfo: [@708863] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref=
 155 inoref 0=0Ainfo: [@708935] object 403 HDR_PGARR len 16=0Ainfo: [@70895=
1] object   4 HDR_BUFFER len 8208=0Ainfo: [@717159] object 403 HDR_PGARR le=
n 16=0Ainfo: [@717175] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inore=
f 0=0Ainfo: [@717247] object 403 HDR_PGARR len 16=0Ainfo: [@717263] object =
  4 HDR_BUFFER len 32808=0Ainfo: [@750071] object 403 HDR_PGARR len 16=0Ain=
fo: [@750087] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainf=
o: [@750159] object 403 HDR_PGARR len 16=0Ainfo: [@750175] object   4 HDR_B=
UFFER len 151708=0Ainfo: [@901883] object 403 HDR_PGARR len 16=0Ainfo: [@90=
1899] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 159=0Ainfo: [@901915] obje=
ct   6 HDR_OBJREF len 16=0A	OBJ_USER ref 160=0Ainfo: [@901931] object 115 H=
DR_USER len 96=0Ainfo: [@902027] object 304 HDR_FILE len 48=0A	FILE_GENERIC=
=0Ainfo: [@902075] object 303 HDR_FILE_NAME len 43=0Ainfo: [@902118] object=
 402 HDR_VMA len 72=0A	VMA_SHM_FILE vmaref 159 inoref 35=0Ainfo: [@902190] =
object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 163=0Ainfo: [@902206] object   6=
 HDR_OBJREF len 16=0A	OBJ_USER ref 164=0Ainfo: [@902222] object 115 HDR_USE=
R len 96=0Ainfo: [@902318] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainf=
o: [@902366] object 303 HDR_FILE_NAME len 34=0Ainfo: [@902400] object 402 H=
DR_VMA len 72=0A	VMA_FILE vmaref 163 inoref 0=0Ainfo: [@902472] object 403 =
HDR_PGARR len 16=0Ainfo: [@902488] object 402 HDR_VMA len 72=0A	VMA_FILE vm=
aref 163 inoref 0=0Ainfo: [@902560] object 403 HDR_PGARR len 16=0Ainfo: [@9=
02576] object   4 HDR_BUFFER len 4108=0Ainfo: [@906684] object 403 HDR_PGAR=
R len 16=0Ainfo: [@906700] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 163=
 inoref 0=0Ainfo: [@906772] object 403 HDR_PGARR len 16=0Ainfo: [@906788] o=
bject   4 HDR_BUFFER len 4108=0Ainfo: [@910896] object 403 HDR_PGARR len 16=
=0Ainfo: [@910912] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 167=0Ainfo: [=
@910928] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@910976] objec=
t 303 HDR_FILE_NAME len 32=0Ainfo: [@911008] object 402 HDR_VMA len 72=0A	V=
MA_FILE vmaref 167 inoref 0=0Ainfo: [@911080] object 403 HDR_PGARR len 16=
=0Ainfo: [@911096] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 167 inoref =
0=0Ainfo: [@911168] object 403 HDR_PGARR len 16=0Ainfo: [@911184] object   =
4 HDR_BUFFER len 4108=0Ainfo: [@915292] object 403 HDR_PGARR len 16=0Ainfo:=
 [@915308] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 167 inoref 0=0Ainfo=
: [@915380] object 403 HDR_PGARR len 16=0Ainfo: [@915396] object   4 HDR_BU=
FFER len 4108=0Ainfo: [@919504] object 403 HDR_PGARR len 16=0Ainfo: [@91952=
0] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 169=0Ainfo: [@919536] object =
304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@919584] object 303 HDR_FILE_N=
AME len 28=0Ainfo: [@919612] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 1=
69 inoref 0=0Ainfo: [@919684] object 403 HDR_PGARR len 16=0Ainfo: [@919700]=
 object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 169 inoref 0=0Ainfo: [@919772=
] object 403 HDR_PGARR len 16=0Ainfo: [@919788] object   4 HDR_BUFFER len 4=
108=0Ainfo: [@923896] object 403 HDR_PGARR len 16=0Ainfo: [@923912] object =
402 HDR_VMA len 72=0A	VMA_FILE vmaref 169 inoref 0=0Ainfo: [@923984] object=
 403 HDR_PGARR len 16=0Ainfo: [@924000] object   4 HDR_BUFFER len 4108=0Ain=
fo: [@928108] object 403 HDR_PGARR len 16=0Ainfo: [@928124] object 402 HDR_=
VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@928196] object 403 HDR_P=
GARR len 16=0Ainfo: [@928212] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 17=
1=0Ainfo: [@928228] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@92=
8276] object 303 HDR_FILE_NAME len 35=0Ainfo: [@928311] object 402 HDR_VMA =
len 72=0A	VMA_FILE vmaref 171 inoref 0=0Ainfo: [@928383] object 403 HDR_PGA=
RR len 16=0Ainfo: [@928399] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 17=
1 inoref 0=0Ainfo: [@928471] object 403 HDR_PGARR len 16=0Ainfo: [@928487] =
object   4 HDR_BUFFER len 4108=0Ainfo: [@932595] object 403 HDR_PGARR len 1=
6=0Ainfo: [@932611] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 171 inoref=
 0=0Ainfo: [@932683] object 403 HDR_PGARR len 16=0Ainfo: [@932699] object  =
 4 HDR_BUFFER len 4108=0Ainfo: [@936807] object 403 HDR_PGARR len 16=0Ainfo=
: [@936823] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 173=0Ainfo: [@936839=
] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@936887] object 303 H=
DR_FILE_NAME len 39=0Ainfo: [@936926] object 402 HDR_VMA len 72=0A	VMA_FILE=
 vmaref 173 inoref 0=0Ainfo: [@936998] object 403 HDR_PGARR len 16=0Ainfo: =
[@937014] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [=
@937086] object 403 HDR_PGARR len 16=0Ainfo: [@937102] object   4 HDR_BUFFE=
R len 4108=0Ainfo: [@941210] object 403 HDR_PGARR len 16=0Ainfo: [@941226] =
object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 175=0Ainfo: [@941242] object 304=
 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@941290] object 303 HDR_FILE_NAME=
 len 27=0Ainfo: [@941317] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 175 =
inoref 0=0Ainfo: [@941389] object 403 HDR_PGARR len 16=0Ainfo: [@941405] ob=
ject 402 HDR_VMA len 72=0A	VMA_FILE vmaref 175 inoref 0=0Ainfo: [@941477] o=
bject 403 HDR_PGARR len 16=0Ainfo: [@941493] object   4 HDR_BUFFER len 4108=
=0Ainfo: [@945601] object 403 HDR_PGARR len 16=0Ainfo: [@945617] object 402=
 HDR_VMA len 72=0A	VMA_FILE vmaref 175 inoref 0=0Ainfo: [@945689] object 40=
3 HDR_PGARR len 16=0Ainfo: [@945705] object   4 HDR_BUFFER len 4108=0Ainfo:=
 [@949813] object 403 HDR_PGARR len 16=0Ainfo: [@949829] object   6 HDR_OBJ=
REF len 16=0A	OBJ_MM ref 177=0Ainfo: [@949845] object 304 HDR_FILE len 48=
=0A	FILE_GENERIC=0Ainfo: [@949893] object 303 HDR_FILE_NAME len 26=0Ainfo: =
[@949919] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 177 inoref 0=0Ainfo:=
 [@949991] object 403 HDR_PGARR len 16=0Ainfo: [@950007] object 402 HDR_VMA=
 len 72=0A	VMA_FILE vmaref 177 inoref 0=0Ainfo: [@950079] object 403 HDR_PG=
ARR len 16=0Ainfo: [@950095] object   4 HDR_BUFFER len 8208=0Ainfo: [@95830=
3] object 403 HDR_PGARR len 16=0Ainfo: [@958319] object 402 HDR_VMA len 72=
=0A	VMA_FILE vmaref 177 inoref 0=0Ainfo: [@958391] object 403 HDR_PGARR len=
 16=0Ainfo: [@958407] object   4 HDR_BUFFER len 4108=0Ainfo: [@962515] obje=
ct 403 HDR_PGARR len 16=0Ainfo: [@962531] object 402 HDR_VMA len 72=0A	VMA_=
ANON vmaref 0 inoref 0=0Ainfo: [@962603] object 403 HDR_PGARR len 16=0Ainfo=
: [@962619] object   4 HDR_BUFFER len 12308=0Ainfo: [@974927] object 403 HD=
R_PGARR len 16=0Ainfo: [@974943] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref=
 179=0Ainfo: [@974959] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [=
@975007] object 303 HDR_FILE_NAME len 30=0Ainfo: [@975037] object 402 HDR_V=
MA len 72=0A	VMA_FILE vmaref 179 inoref 0=0Ainfo: [@975109] object 403 HDR_=
PGARR len 16=0Ainfo: [@975125] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref=
 179 inoref 0=0Ainfo: [@975197] object 403 HDR_PGARR len 16=0Ainfo: [@97521=
3] object   4 HDR_BUFFER len 4108=0Ainfo: [@979321] object 403 HDR_PGARR le=
n 16=0Ainfo: [@979337] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 179 ino=
ref 0=0Ainfo: [@979409] object 403 HDR_PGARR len 16=0Ainfo: [@979425] objec=
t   4 HDR_BUFFER len 4108=0Ainfo: [@983533] object 403 HDR_PGARR len 16=0Ai=
nfo: [@983549] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ain=
fo: [@983621] object 403 HDR_PGARR len 16=0Ainfo: [@983637] object   4 HDR_=
BUFFER len 4108=0Ainfo: [@987745] object 403 HDR_PGARR len 16=0Ainfo: [@987=
761] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 181=0Ainfo: [@987777] objec=
t 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@987825] object 303 HDR_FILE=
_NAME len 30=0Ainfo: [@987855] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref=
 181 inoref 0=0Ainfo: [@987927] object 403 HDR_PGARR len 16=0Ainfo: [@98794=
3] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 181 inoref 0=0Ainfo: [@9880=
15] object 403 HDR_PGARR len 16=0Ainfo: [@988031] object   4 HDR_BUFFER len=
 4108=0Ainfo: [@992139] object 403 HDR_PGARR len 16=0Ainfo: [@992155] objec=
t 402 HDR_VMA len 72=0A	VMA_FILE vmaref 181 inoref 0=0Ainfo: [@992227] obje=
ct 403 HDR_PGARR len 16=0Ainfo: [@992243] object   4 HDR_BUFFER len 4108=0A=
info: [@996351] object 403 HDR_PGARR len 16=0Ainfo: [@996367] object 402 HD=
R_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@996439] object 403 HDR=
_PGARR len 16=0Ainfo: [@996455] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref =
183=0Ainfo: [@996471] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@=
996519] object 303 HDR_FILE_NAME len 32=0Ainfo: [@996551] object 402 HDR_VM=
A len 72=0A	VMA_FILE vmaref 183 inoref 0=0Ainfo: [@996623] object 403 HDR_P=
GARR len 16=0Ainfo: [@996639] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref =
183 inoref 0=0Ainfo: [@996711] object 403 HDR_PGARR len 16=0Ainfo: [@996727=
] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 183 inoref 0=0Ainfo: [@99679=
9] object 403 HDR_PGARR len 16=0Ainfo: [@996815] object   4 HDR_BUFFER len =
8208=0Ainfo: [@1005023] object 403 HDR_PGARR len 16=0Ainfo: [@1005039] obje=
ct 402 HDR_VMA len 72=0A	VMA_FILE vmaref 183 inoref 0=0Ainfo: [@1005111] ob=
ject 403 HDR_PGARR len 16=0Ainfo: [@1005127] object   4 HDR_BUFFER len 4108=
=0Ainfo: [@1009235] object 403 HDR_PGARR len 16=0Ainfo: [@1009251] object 4=
02 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@1009323] object 4=
03 HDR_PGARR len 16=0Ainfo: [@1009339] object   4 HDR_BUFFER len 8208=0Ainf=
o: [@1017547] object 403 HDR_PGARR len 16=0Ainfo: [@1017563] object 402 HDR=
_VMA len 72=0A	VMA_VDSO vmaref 0 inoref 0=0Ainfo: [@1017635] object   6 HDR=
_OBJREF len 16=0A	OBJ_MM ref 185=0Ainfo: [@1017651] object 304 HDR_FILE len=
 48=0A	FILE_GENERIC=0Ainfo: [@1017699] object 303 HDR_FILE_NAME len 24=0Ain=
fo: [@1017723] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 185 inoref 0=0A=
info: [@1017795] object 403 HDR_PGARR len 16=0Ainfo: [@1017811] object 402 =
HDR_VMA len 72=0A	VMA_FILE vmaref 185 inoref 0=0Ainfo: [@1017883] object 40=
3 HDR_PGARR len 16=0Ainfo: [@1017899] object   4 HDR_BUFFER len 4108=0Ainfo=
: [@1022007] object 403 HDR_PGARR len 16=0Ainfo: [@1022023] object 402 HDR_=
VMA len 72=0A	VMA_FILE vmaref 185 inoref 0=0Ainfo: [@1022095] object 403 HD=
R_PGARR len 16=0Ainfo: [@1022111] object   4 HDR_BUFFER len 4108=0Ainfo: [@=
1026219] object 403 HDR_PGARR len 16=0Ainfo: [@1026235] object 402 HDR_VMA =
len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@1026307] object 403 HDR_PGAR=
R len 16=0Ainfo: [@1026323] object   4 HDR_BUFFER len 28708=0Ainfo: [@10550=
31] object 403 HDR_PGARR len 16=0Ainfo: [@1055047] object 404 HDR_MM_CONTEX=
T len 24=0Ainfo: [@1055071] object 202 HDR_MM_CONTEXT_LDT len 8=0Ainfo: [@1=
055079] object   6 HDR_OBJREF len 16=0A	OBJ_SIGHAND ref 187=0Ainfo: [@10550=
95] object 451 HDR_FS len 16=0Ainfo: [@1055111] object 303 HDR_FILE_NAME le=
n 14=0Ainfo: [@1055125] object 303 HDR_FILE_NAME len 10=0Ainfo: [@1055135] =
object   6 HDR_OBJREF len 16=0A	OBJ_SIGNAL ref 188=0Ainfo: [@1055151] objec=
t 601 HDR_SIGHAND len 2056=0Ainfo: [@1057207] object 105 HDR_RESTART_BLOCK =
len 32=0Ainfo: [@1057239] object 602 HDR_SIGNAL len 328=0Ainfo: [@1057567] =
object 604 HDR_SIGPENDING len 24=0Ainfo: [@1057591] object 604 HDR_SIGPENDI=
NG len 24=0Ainfo: [@1057615] object 603 HDR_SIGNAL_TASK len 16=0Ainfo: [@10=
57631] object 103 HDR_TASK_NS len 80=0Ainfo: [@1057711] object   5 HDR_STRI=
NG len 24=0Ainfo: [@1057735] object 107 HDR_CPU len 48=0A	ax=3D0x00000000 b=
x=3D0x00000000 cx=3D0x00000000 dx=3D0xffffffff si=3D0xffffffff di=3D0xfffff=
fff=0A	ip=3D0x00000400 bp=3D0x00000000 sp=3D0x00010000 fs=3D0xffffffff(0xff=
ff) gs=3D0xffffffff(0xffff)=0A	orig_ax=3D0x00000400 flags=3D0x00010000 cs=
=3D0x0000 ds=3D0xffff es=3D0xffff ss=3D0x0000=0Ainfo: [@1057783] object 106=
 HDR_THREAD len 56=0Ainfo: [@1057839] object 108 HDR_NS len 192=0Ainfo: [@1=
058031] object 201 HDR_CPU_FPU len 520=0Ainfo: [@1058551] object   6 HDR_OB=
JREF len 16=0A	OBJ_USER ref 190=0Ainfo: [@1058567] object 115 HDR_USER len =
96=0Ainfo: [@1058663] object 118 ---UNKNOWN--- len 16=0Ainfo: [@1058679] ob=
ject 104 HDR_TASK_OBJS len 16=0Ainfo: [@1058695] object   6 HDR_OBJREF len =
16=0A	OBJ_FILE ref 192=0Ainfo: [@1058711] object 301 HDR_FILE_TABLE len 16=
=0Ainfo: [@1058727] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 193=0Ainfo: =
[@1058743] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 194=0Ainfo: [@10587=
59] object 115 HDR_USER len 96=0Ainfo: [@1058855] object 304 HDR_FILE len 5=
6=0A	FILE_TTY=0Ainfo: [@1058911] object 302 HDR_FILE_DESC len 24=0Ainfo: [@=
1058935] object 302 HDR_FILE_DESC len 24=0Ainfo: [@1058959] object 302 HDR_=
FILE_DESC len 24=0Ainfo: [@1058983] object   6 HDR_OBJREF len 16=0A	OBJ_MM =
ref 197=0Ainfo: [@1058999] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainf=
o: [@1059047] object 303 HDR_FILE_NAME len 39=0Ainfo: [@1059086] object 302=
 HDR_FILE_DESC len 24=0Ainfo: [@1059110] object   6 HDR_OBJREF len 16=0A	OB=
J_FS ref 199=0Ainfo: [@1059126] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref =
200=0Ainfo: [@1059142] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [=
@1059190] object 303 HDR_FILE_NAME len 18=0Ainfo: [@1059208] object 401 HDR=
_MM len 120=0Ainfo: [@1059328] object   4 HDR_BUFFER len 360=0Ainfo: [@1059=
688] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 200 inoref 0=0Ainfo: [@10=
59760] object 403 HDR_PGARR len 16=0Ainfo: [@1059776] object 402 HDR_VMA le=
n 72=0A	VMA_FILE vmaref 200 inoref 0=0Ainfo: [@1059848] object 403 HDR_PGAR=
R len 16=0Ainfo: [@1059864] object   4 HDR_BUFFER len 4108=0Ainfo: [@106397=
2] object 403 HDR_PGARR len 16=0Ainfo: [@1063988] object 402 HDR_VMA len 72=
=0A	VMA_FILE vmaref 200 inoref 0=0Ainfo: [@1064060] object 403 HDR_PGARR le=
n 16=0Ainfo: [@1064076] object   4 HDR_BUFFER len 4108=0Ainfo: [@1068184] o=
bject 403 HDR_PGARR len 16=0Ainfo: [@1068200] object 402 HDR_VMA len 72=0A	=
VMA_ANON vmaref 0 inoref 0=0Ainfo: [@1068272] object 403 HDR_PGARR len 16=
=0Ainfo: [@1068288] object   4 HDR_BUFFER len 4108=0Ainfo: [@1072396] objec=
t 403 HDR_PGARR len 16=0Ainfo: [@1072412] object 402 HDR_VMA len 72=0A	VMA_=
ANON vmaref 0 inoref 0=0Ainfo: [@1072484] object 403 HDR_PGARR len 16=0Ainf=
o: [@1072500] object   4 HDR_BUFFER len 8208=0Ainfo: [@1080708] object 403 =
HDR_PGARR len 16=0Ainfo: [@1080724] object 402 HDR_VMA len 72=0A	VMA_ANON v=
maref 0 inoref 0=0Ainfo: [@1080796] object 403 HDR_PGARR len 16=0Ainfo: [@1=
080812] object   4 HDR_BUFFER len 4108=0Ainfo: [@1084920] object 403 HDR_PG=
ARR len 16=0Ainfo: [@1084936] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 20=
2=0Ainfo: [@1084952] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@1=
085000] object 303 HDR_FILE_NAME len 26=0Ainfo: [@1085026] object 402 HDR_V=
MA len 72=0A	VMA_FILE vmaref 202 inoref 0=0Ainfo: [@1085098] object 403 HDR=
_PGARR len 16=0Ainfo: [@1085114] object 402 HDR_VMA len 72=0A	VMA_FILE vmar=
ef 202 inoref 0=0Ainfo: [@1085186] object 403 HDR_PGARR len 16=0Ainfo: [@10=
85202] object   4 HDR_BUFFER len 8208=0Ainfo: [@1093410] object 403 HDR_PGA=
RR len 16=0Ainfo: [@1093426] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 2=
02 inoref 0=0Ainfo: [@1093498] object 403 HDR_PGARR len 16=0Ainfo: [@109351=
4] object   4 HDR_BUFFER len 4108=0Ainfo: [@1097622] object 403 HDR_PGARR l=
en 16=0Ainfo: [@1097638] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 ino=
ref 0=0Ainfo: [@1097710] object 403 HDR_PGARR len 16=0Ainfo: [@1097726] obj=
ect   4 HDR_BUFFER len 8208=0Ainfo: [@1105934] object 403 HDR_PGARR len 16=
=0Ainfo: [@1105950] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=
=0Ainfo: [@1106022] object 403 HDR_PGARR len 16=0Ainfo: [@1106038] object  =
 4 HDR_BUFFER len 8208=0Ainfo: [@1114246] object 403 HDR_PGARR len 16=0Ainf=
o: [@1114262] object 402 HDR_VMA len 72=0A	VMA_VDSO vmaref 0 inoref 0=0Ainf=
o: [@1114334] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 204=0Ainfo: [@1114=
350] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@1114398] object 3=
03 HDR_FILE_NAME len 24=0Ainfo: [@1114422] object 402 HDR_VMA len 72=0A	VMA=
_FILE vmaref 204 inoref 0=0Ainfo: [@1114494] object 403 HDR_PGARR len 16=0A=
info: [@1114510] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 204 inoref 0=
=0Ainfo: [@1114582] object 403 HDR_PGARR len 16=0Ainfo: [@1114598] object  =
 4 HDR_BUFFER len 4108=0Ainfo: [@1118706] object 403 HDR_PGARR len 16=0Ainf=
o: [@1118722] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 204 inoref 0=0Ai=
nfo: [@1118794] object 403 HDR_PGARR len 16=0Ainfo: [@1118810] object   4 H=
DR_BUFFER len 4108=0Ainfo: [@1122918] object 403 HDR_PGARR len 16=0Ainfo: [=
@1122934] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [=
@1123006] object 403 HDR_PGARR len 16=0Ainfo: [@1123022] object   4 HDR_BUF=
FER len 8208=0Ainfo: [@1131230] object 403 HDR_PGARR len 16=0Ainfo: [@11312=
46] object 404 HDR_MM_CONTEXT len 24=0Ainfo: [@1131270] object 202 HDR_MM_C=
ONTEXT_LDT len 8=0Ainfo: [@1131278] object   6 HDR_OBJREF len 16=0A	OBJ_SIG=
HAND ref 206=0Ainfo: [@1131294] object 451 HDR_FS len 16=0Ainfo: [@1131310]=
 object 303 HDR_FILE_NAME len 14=0Ainfo: [@1131324] object 303 HDR_FILE_NAM=
E len 10=0Ainfo: [@1131334] object   6 HDR_OBJREF len 16=0A	OBJ_SIGNAL ref =
207=0Ainfo: [@1131350] object 601 HDR_SIGHAND len 2056=0Ainfo: [@1133406] o=
bject 105 HDR_RESTART_BLOCK len 32=0Ainfo: [@1133438] object 602 HDR_SIGNAL=
 len 328=0Ainfo: [@1133766] object 604 HDR_SIGPENDING len 24=0Ainfo: [@1133=
790] object 604 HDR_SIGPENDING len 24=0Ainfo: [@1133814] object 603 HDR_SIG=
NAL_TASK len 16=0Ainfo: [@1133830] object 103 HDR_TASK_NS len 80=0Ainfo: [@=
1133910] object   5 HDR_STRING len 24=0Ainfo: [@1133934] object 107 HDR_CPU=
 len 48=0A	ax=3D0x00000000 bx=3D0x00000000 cx=3D0x00000000 dx=3D0xffffffff =
si=3D0xffffffff di=3D0xffffffff=0A	ip=3D0x00000400 bp=3D0x00000000 sp=3D0x0=
0010000 fs=3D0xffffffff(0xffff) gs=3D0xffffffff(0xffff)=0A	orig_ax=3D0x0000=
0400 flags=3D0x00010000 cs=3D0x0000 ds=3D0xffff es=3D0xffff ss=3D0x0000=0Ai=
nfo: [@1133982] object 106 HDR_THREAD len 56=0Ainfo: [@1134038] object 108 =
HDR_NS len 192=0Ainfo: [@1134230] object 201 HDR_CPU_FPU len 520=0Ainfo: [@=
1134750] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref 209=0Ainfo: [@1134766=
] object 115 HDR_USER len 96=0Ainfo: [@1134862] object 118 ---UNKNOWN--- le=
n 16=0Ainfo: [@1134878] object 104 HDR_TASK_OBJS len 16=0Ainfo: [@1134894] =
object   6 HDR_OBJREF len 16=0A	OBJ_FILE ref 211=0Ainfo: [@1134910] object =
301 HDR_FILE_TABLE len 16=0Ainfo: [@1134926] object 302 HDR_FILE_DESC len 2=
4=0Ainfo: [@1134950] object 302 HDR_FILE_DESC len 24=0Ainfo: [@1134974] obj=
ect 302 HDR_FILE_DESC len 24=0Ainfo: [@1134998] object   6 HDR_OBJREF len 1=
6=0A	OBJ_FS ref 212=0Ainfo: [@1135014] object   6 HDR_OBJREF len 16=0A	OBJ_=
MM ref 213=0Ainfo: [@1135030] object   6 HDR_OBJREF len 16=0A	OBJ_USER ref =
214=0Ainfo: [@1135046] object 115 HDR_USER len 96=0Ainfo: [@1135142] object=
 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@1135190] object 303 HDR_FILE=
_NAME len 19=0Ainfo: [@1135209] object 401 HDR_MM len 120=0Ainfo: [@1135329=
] object   4 HDR_BUFFER len 360=0Ainfo: [@1135689] object 402 HDR_VMA len 7=
2=0A	VMA_FILE vmaref 213 inoref 0=0Ainfo: [@1135761] object 403 HDR_PGARR l=
en 16=0Ainfo: [@1135777] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 213 i=
noref 0=0Ainfo: [@1135849] object 403 HDR_PGARR len 16=0Ainfo: [@1135865] o=
bject   4 HDR_BUFFER len 4108=0Ainfo: [@1139973] object 403 HDR_PGARR len 1=
6=0Ainfo: [@1139989] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 213 inore=
f 0=0Ainfo: [@1140061] object 403 HDR_PGARR len 16=0Ainfo: [@1140077] objec=
t   4 HDR_BUFFER len 4108=0Ainfo: [@1144185] object 403 HDR_PGARR len 16=0A=
info: [@1144201] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0A=
info: [@1144273] object 403 HDR_PGARR len 16=0Ainfo: [@1144289] object   4 =
HDR_BUFFER len 4108=0Ainfo: [@1148397] object 403 HDR_PGARR len 16=0Ainfo: =
[@1148413] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 217=0Ainfo: [@1148429=
] object 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@1148477] object 303 =
HDR_FILE_NAME len 39=0Ainfo: [@1148516] object 402 HDR_VMA len 72=0A	VMA_FI=
LE vmaref 217 inoref 0=0Ainfo: [@1148588] object 403 HDR_PGARR len 16=0Ainf=
o: [@1148604] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainf=
o: [@1148676] object 403 HDR_PGARR len 16=0Ainfo: [@1148692] object   4 HDR=
_BUFFER len 4108=0Ainfo: [@1152800] object 403 HDR_PGARR len 16=0Ainfo: [@1=
152816] object   6 HDR_OBJREF len 16=0A	OBJ_MM ref 219=0Ainfo: [@1152832] o=
bject 304 HDR_FILE len 48=0A	FILE_GENERIC=0Ainfo: [@1152880] object 303 HDR=
_FILE_NAME len 26=0Ainfo: [@1152906] object 402 HDR_VMA len 72=0A	VMA_FILE =
vmaref 219 inoref 0=0Ainfo: [@1152978] object 403 HDR_PGARR len 16=0Ainfo: =
[@1152994] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 219 inoref 0=0Ainfo=
: [@1153066] object 403 HDR_PGARR len 16=0Ainfo: [@1153082] object   4 HDR_=
BUFFER len 8208=0Ainfo: [@1161290] object 403 HDR_PGARR len 16=0Ainfo: [@11=
61306] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 219 inoref 0=0Ainfo: [@=
1161378] object 403 HDR_PGARR len 16=0Ainfo: [@1161394] object   4 HDR_BUFF=
ER len 4108=0Ainfo: [@1165502] object 403 HDR_PGARR len 16=0Ainfo: [@116551=
8] object 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@116559=
0] object 403 HDR_PGARR len 16=0Ainfo: [@1165606] object   4 HDR_BUFFER len=
 8208=0Ainfo: [@1173814] object 403 HDR_PGARR len 16=0Ainfo: [@1173830] obj=
ect 402 HDR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@1173902] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@1173918] object   4 HDR_BUFFER len 8208=
=0Ainfo: [@1182126] object 403 HDR_PGARR len 16=0Ainfo: [@1182142] object 4=
02 HDR_VMA len 72=0A	VMA_VDSO vmaref 0 inoref 0=0Ainfo: [@1182214] object  =
 6 HDR_OBJREF len 16=0A	OBJ_MM ref 221=0Ainfo: [@1182230] object 304 HDR_FI=
LE len 48=0A	FILE_GENERIC=0Ainfo: [@1182278] object 303 HDR_FILE_NAME len 2=
4=0Ainfo: [@1182302] object 402 HDR_VMA len 72=0A	VMA_FILE vmaref 221 inore=
f 0=0Ainfo: [@1182374] object 403 HDR_PGARR len 16=0Ainfo: [@1182390] objec=
t 402 HDR_VMA len 72=0A	VMA_FILE vmaref 221 inoref 0=0Ainfo: [@1182462] obj=
ect 403 HDR_PGARR len 16=0Ainfo: [@1182478] object   4 HDR_BUFFER len 4108=
=0Ainfo: [@1186586] object 403 HDR_PGARR len 16=0Ainfo: [@1186602] object 4=
02 HDR_VMA len 72=0A	VMA_FILE vmaref 221 inoref 0=0Ainfo: [@1186674] object=
 403 HDR_PGARR len 16=0Ainfo: [@1186690] object   4 HDR_BUFFER len 4108=0Ai=
nfo: [@1190798] object 403 HDR_PGARR len 16=0Ainfo: [@1190814] object 402 H=
DR_VMA len 72=0A	VMA_ANON vmaref 0 inoref 0=0Ainfo: [@1190886] object 403 H=
DR_PGARR len 16=0Ainfo: [@1190902] object   4 HDR_BUFFER len 8208=0Ainfo: [=
@1199110] object 403 HDR_PGARR len 16=0Ainfo: [@1199126] object 404 HDR_MM_=
CONTEXT len 24=0Ainfo: [@1199150] object 202 HDR_MM_CONTEXT_LDT len 8=0Ainf=
o: [@1199158] object   6 HDR_OBJREF len 16=0A	OBJ_SIGHAND ref 223=0Ainfo: [=
@1199174] object 451 HDR_FS len 16=0Ainfo: [@1199190] object 303 HDR_FILE_N=
AME len 14=0Ainfo: [@1199204] object 303 HDR_FILE_NAME len 10=0Ainfo: [@119=
9214] object   6 HDR_OBJREF len 16=0A	OBJ_SIGNAL ref 224=0Ainfo: [@1199230]=
 object 601 HDR_SIGHAND len 2056=0Ainfo: [@1201286] object 105 HDR_RESTART_=
BLOCK len 32=0Ainfo: [@1201318] object 602 HDR_SIGNAL len 328=0Ainfo: [@120=
1646] object 604 HDR_SIGPENDING len 24=0Ainfo: [@1201670] object 604 HDR_SI=
GPENDING len 24=0Ainfo: [@1201694] object 603 HDR_SIGNAL_TASK len 16=0Ainfo=
: [@1201710] object 9001 HDR_TAIL len 16=0A
--rS8CxjVDS/+yyDmU
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--rS8CxjVDS/+yyDmU--

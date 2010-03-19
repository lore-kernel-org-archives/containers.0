From: Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Fri, 19 Mar 2010 22:14:07 +0900
Message-ID: <EF179F3A-4FBA-4776-B7A4-48F5EF73DC9C__16125.9097898894$1269004612$gmane$org@dependable-os.net>
References: <4B83106C.7040203@cs.columbia.edu>
	<a1c54a921003150155q4a0c7fc1vb02ba0464b07f452@mail.gmail.com>
	<4B9EBAF2.1060304@cs.columbia.edu>
	<0B4E8136-FFC6-490D-B04A-23A6E1A924FF@dependable-os.net>
	<20100317205556.GA20750@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: multipart/mixed; boundary=Apple-Mail-9-786954914
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100317205556.GA20750-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


--Apple-Mail-9-786954914
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,
On 2010/03/18, at 5:55, Serge E. Hallyn wrote:

> Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
>> Hi,
>>=20
>> Thank you for prompt reply!
>> Sorry that I didn't post to containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cuFJUID1Z7QI@public.gmane.org
>>=20
>> On 2010/03/16, at 7:55, Oren Laadan wrote:
>>=20
>>> Hi,
>>>=20
>>> Thanks for taking the time to evaluate c/r. You may want to also
>>> try the latest, which is (as of now) ckpt-v20-rc2.
>>=20
>> Yeah, I'll eventually try to keep up with the latest,
>> but I just want to try the one  you think it's stable first anyway.
>>=20
>>> In the future, please CC the containers mailing list for issues
>>> related to c/r, at "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org".
>>>=20
>>> Jiro SEKIBA wrote:
>>>> Hi,
>>>> I'm trying to evaluate external checkpoint/restart with cr-v19 =
kernel.
>>>> However, when I restart, I got "Killed" message in stdout.
>>>> Do you have any tips or clue that are not in
>>>> Documentation/checkpoint/usage.txt ?
>>>> I'm using kernel pulled from
>>>> git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git .
>>>> checkout tag named "ckpt-v19". Base distro is ubuntu 9.10.
>>>> I ran self checkpioint/restart sample program in =
Documentation/checkpint.
>>>> It works as written in usage.txt.
>>>> However, I can not make external checkpint/restart work properly.
>>>> I made a simple test program bellow and create checkpoint =
externally using
>>>> the program in Documentation/checkpoint/, it looks checkpoint file =
is
>>>> created properly.
>>>> However, when I ran self_restart < ckpt.image, I got "Killed" =
message.
>>>=20
>>> If you take an external checkpoint, then you need to match it
>>> with an external restart, as opposed to self_restart.
>>>=20
>>> Otherwise, restarting with self_restart from a checkpoint that is
>>> not a self-checkpoint can yield unexpected results.
>>>=20
>>> Since you don't mention in your post, I don't know if you are using
>>> the tools from user-cr. If not, then you should use 'checkpoint' and
>>> 'restart' tools from there. It is available from:
>>> 	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git
>>> (use the same branch as the one you used to linux-cr).
>>>=20
>>> Once you have the tools compiled, and you checkpoint with the
>>> 'checkpoint' utility from there, you can restart with:
>>> 	restart -v < ckpt.image
>>>=20
>>=20
>> Thank you for the information.
>> Actually I was trying to create checkpoint in Document/checkpints.
>>=20
>> Now, I tried with user-cr, compiled binary in the same tag =
(ckpt-v19).
>> Creating checkpoint  looks OK and restart -v shows it Success.  nice!
>> However, the contents in /tmp/test.out never get further,
>> it remains same as when created checkpoint.
>>=20
>> I tried  "./restart -F /cgroup/0 -v --no-pidns < ckpt.image", got =
Success.
>> cat /cgroup/0/tasks tells that there is a process.
>> ps shows ./test.  So, it looks restarting.
>>=20
>> # ps axuww |grep $(cat /cgroup/0/tasks )
>> root      7231  0.1  0.0   1588    64 pts/0    D    16:57   0:00 =
./test
>> root      7238  0.0  0.1   2716   660 pts/1    R+   16:57   0:00 grep =
7231
>>=20
>> under the /proc, one file descriptor opened, and it is /tmp/test.out
>>=20
>> #  ls -l /proc/$(cat /cgroup/0/tasks)/fd
>> total 0
>> lrwx------ 1 root root 64 Mar 16 16:58 0 -> /tmp/test.out
>>=20
>> Nhh, it's close..
>>=20
>> I found that when I mount cgroup with -o freezer, self_checkpoint =
won't work.
>> It worked even I didn't mount the cgroup.
>> Is it what you expect?
>=20
> No, it is not.  Can you tell us more about exactly how it fails?
>=20

OK, I've checked differences of dmesg when self_restart does well and =
doesn't.
When it goes well, the filename is /tmp/cr-self.out

[  401.522556] [2307:2307:c/r:ckpt_read_fname:571] read filename =
'/tmp/cr-self.out'
[  401.522558] [2307:2307:c/r:restore_open_fname:594] fname =
'/tmp/cr-self.out' flags 0x2

However, when the contents of file remains, filename is =
/tmp/cr-self.out.org,
which is , of course, the one of original file binding to the original =
process.

[ 1088.414250] [2951:2951:c/r:ckpt_read_fname:571] read filename =
'/tmp/cr-self.out.orig'
[ 1088.414253] [2951:2951:c/r:restore_open_fname:594] fname =
'/tmp/cr-self.out.orig' flags 0x2

I can not reproduce yet, but at least cgroup freezer option won't affect =
like I mentioned.
Sorry that it might confuse you.

I still can not restart of external checkpoint.
I'll try to v20 next time.

> Maybe get the cr_tests (either from Oren's tree or from
> git clone git://git.sr71.net/~hallyn/cr_tests.git), cd cr_test,
> make, cd simple, run ./ckpt and send us the contents of
> /tmp/log, dmesg, and ckptinfo -ve /tmp/out ?

I think it runs OK, but send it in case.
/tmp/log was empty by the way.

thanks

>> Thank you again for the help!
>> I'm feeling better to use the latest ..
>=20
> -serge

--Apple-Mail-9-786954914
Content-Disposition: attachment;
	filename=ckptinfo-ve.log
Content-Type: application/octet-stream;
	name="ckptinfo-ve.log"
Content-Transfer-Encoding: 7bit

info: [@8] object HDR_HEADER len 72
info: [@80] object HDR_BUFFER len 73
info: [@153] object HDR_BUFFER len 73
info: [@226] object HDR_BUFFER len 73
info: [@299] object HDR_HEADER_ARCH len 16
info: [@315] object HDR_CONTAINER len 8
info: [@323] object HDR_BUFFER len 19
info: [@342] object HDR_LSM_INFO len 13
info: [@355] object HDR_TREE len 16
info: [@371] object HDR_BUFFER len 32
info: [@403] object HDR_TASK len 64
info: [@467] object HDR_STRING len 24
info: [@491] object HDR_THREAD len 40
info: [@531] object HDR_RESTART_BLOCK len 56
info: [@587] object HDR_CPU len 192
	ax=0x00000000 bx=0x00000cfe cx=0x00000005 dx=0x00000001 si=0x00000003 di=0xb77fff5f
	ip=0xb77f5430 bp=0xb7811000 sp=0xbfb8c0fc fs=0x00000000(0x0000) gs=0x00000000(0x4000)
	orig_ax=0x00000153 flags=0x00000246 cs=0x0001 ds=0x0002 es=0x0002 ss=0x0002
info: [@779] object HDR_OBJREF len 16
	OBJ_CRED ref 1
info: [@795] object HDR_OBJREF len 16
	OBJ_GROUPINFO ref 2
info: [@811] object HDR_GROUPINFO len 20
info: [@831] object HDR_OBJREF len 16
	OBJ_USER ref 3
info: [@847] object HDR_OBJREF len 16
	OBJ_USER_NS ref 4
info: [@863] object HDR_USER_NS len 16
info: [@879] object HDR_USER len 16
info: [@895] object HDR_CRED len 96
info: [@991] object HDR_TASK_CREDS len 16
info: [@1007] object HDR_OBJREF len 16
	OBJ_NS ref 5
info: [@1023] object HDR_OBJREF len 16
	OBJ_UTS_NS ref 6
info: [@1039] object HDR_UTS_NS len 400
info: [@1439] object HDR_OBJREF len 16
	OBJ_IPC_NS ref 7
info: [@1455] object HDR_IPC_NS len 56
info: [@1511] object HDR_IPC len 16
info: [@1527] object HDR_IPC_SHM len 120
info: [@1647] object HDR_PGARR len 16
info: [@1663] object HDR_BUFFER len 196808
info: [@198471] object HDR_PGARR len 16
info: [@198487] object HDR_IPC_SHM len 120
info: [@198607] object HDR_PGARR len 16
info: [@198623] object HDR_BUFFER len 82008
info: [@280631] object HDR_PGARR len 16
info: [@280647] object HDR_IPC_SHM len 120
info: [@280767] object HDR_PGARR len 16
info: [@280783] object HDR_BUFFER len 94308
info: [@375091] object HDR_PGARR len 16
info: [@375107] object HDR_IPC_SHM len 120
info: [@375227] object HDR_PGARR len 16
info: [@375243] object HDR_BUFFER len 393608
info: [@768851] object HDR_PGARR len 16
info: [@768867] object HDR_IPC_SHM len 120
info: [@768987] object HDR_PGARR len 16
info: [@769003] object HDR_BUFFER len 196808
info: [@965811] object HDR_PGARR len 16
info: [@965827] object HDR_IPC_SHM len 120
info: [@965947] object HDR_PGARR len 16
info: [@965963] object HDR_BUFFER len 90208
info: [@1056171] object HDR_PGARR len 16
info: [@1056187] object HDR_IPC_SHM len 120
info: [@1056307] object HDR_PGARR len 16
info: [@1056323] object HDR_BUFFER len 90208
info: [@1146531] object HDR_PGARR len 16
info: [@1146547] object HDR_IPC_SHM len 120
info: [@1146667] object HDR_PGARR len 16
info: [@1146683] object HDR_BUFFER len 90208
info: [@1236891] object HDR_PGARR len 16
info: [@1236907] object HDR_IPC_SHM len 120
info: [@1237027] object HDR_PGARR len 16
info: [@1237043] object HDR_BUFFER len 196808
info: [@1433851] object HDR_PGARR len 16
info: [@1433867] object HDR_IPC_SHM len 120
info: [@1433987] object HDR_PGARR len 16
info: [@1434003] object HDR_BUFFER len 196808
info: [@1630811] object HDR_PGARR len 16
info: [@1630827] object HDR_IPC_SHM len 120
info: [@1630947] object HDR_PGARR len 16
info: [@1630963] object HDR_BUFFER len 90208
info: [@1721171] object HDR_PGARR len 16
info: [@1721187] object HDR_IPC_SHM len 120
info: [@1721307] object HDR_PGARR len 16
info: [@1721323] object HDR_BUFFER len 65608
info: [@1786931] object HDR_PGARR len 16
info: [@1786947] object HDR_IPC_SHM len 120
info: [@1787067] object HDR_PGARR len 16
info: [@1787083] object HDR_BUFFER len 98408
info: [@1885491] object HDR_PGARR len 16
info: [@1885507] object HDR_IPC_SHM len 120
info: [@1885627] object HDR_PGARR len 16
info: [@1885643] object HDR_BUFFER len 98408
info: [@1984051] object HDR_PGARR len 16
info: [@1984067] object HDR_IPC_SHM len 120
info: [@1984187] object HDR_PGARR len 16
info: [@1984203] object HDR_BUFFER len 90208
info: [@2074411] object HDR_PGARR len 16
info: [@2074427] object HDR_IPC_SHM len 120
info: [@2074547] object HDR_PGARR len 16
info: [@2074563] object HDR_BUFFER len 369008
info: [@2443571] object HDR_PGARR len 16
info: [@2443587] object HDR_IPC_SHM len 120
info: [@2443707] object HDR_PGARR len 16
info: [@2443723] object HDR_BUFFER len 393608
info: [@2837331] object HDR_PGARR len 16
info: [@2837347] object HDR_IPC_SHM len 120
info: [@2837467] object HDR_PGARR len 16
info: [@2837483] object HDR_BUFFER len 65608
info: [@2903091] object HDR_PGARR len 16
info: [@2903107] object HDR_IPC len 16
info: [@2903123] object HDR_IPC len 16
info: [@2903139] object HDR_IPC_SEM len 88
info: [@2903227] object HDR_BUFFER len 24
info: [@2903251] object HDR_IPC_SEM len 88
info: [@2903339] object HDR_BUFFER len 1656
info: [@2904995] object HDR_IPC_SEM len 88
info: [@2905083] object HDR_BUFFER len 152
info: [@2905235] object HDR_IPC_SEM len 88
info: [@2905323] object HDR_BUFFER len 24
info: [@2905347] object HDR_NS len 16
info: [@2905363] object HDR_TASK_NS len 16
info: [@2905379] object HDR_OBJREF len 16
	OBJ_FILE_TABLE ref 26
info: [@2905395] object HDR_FILE_TABLE len 16
info: [@2905411] object HDR_OBJREF len 16
	OBJ_FILE ref 27
info: [@2905427] object HDR_FILE len 48
	FILE_GENERIC
info: [@2905475] object HDR_FILE_NAME len 25
info: [@2905500] object HDR_FILE_DESC len 24
info: [@2905524] object HDR_FILE_DESC len 24
info: [@2905548] object HDR_OBJREF len 16
	OBJ_FILE ref 28
info: [@2905564] object HDR_FILE len 48
	FILE_GENERIC
info: [@2905612] object HDR_FILE_NAME len 17
info: [@2905629] object HDR_FILE_DESC len 24
info: [@2905653] object HDR_FILE_DESC len 24
info: [@2905677] object HDR_OBJREF len 16
	OBJ_FILE ref 29
info: [@2905693] object HDR_FILE len 48
	FILE_GENERIC
info: [@2905741] object HDR_FILE_NAME len 17
info: [@2905758] object HDR_FILE_DESC len 24
info: [@2905782] object HDR_OBJREF len 16
	OBJ_MM ref 30
info: [@2905798] object HDR_OBJREF len 16
	OBJ_FILE ref 31
info: [@2905814] object HDR_OBJREF len 16
	OBJ_CRED ref 32
info: [@2905830] object HDR_CRED len 96
info: [@2905926] object HDR_FILE len 48
	FILE_GENERIC
info: [@2905974] object HDR_FILE_NAME len 53
info: [@2906027] object HDR_MM len 120
info: [@2906147] object HDR_BUFFER len 360
info: [@2906507] object HDR_VMA len 72
	VMA_FILE vmaref 31 inoref 0
info: [@2906579] object HDR_PGARR len 16
info: [@2906595] object HDR_VMA len 72
	VMA_FILE vmaref 31 inoref 0
info: [@2906667] object HDR_PGARR len 16
info: [@2906683] object HDR_BUFFER len 4108
info: [@2910791] object HDR_PGARR len 16
info: [@2910807] object HDR_VMA len 72
	VMA_FILE vmaref 31 inoref 0
info: [@2910879] object HDR_PGARR len 16
info: [@2910895] object HDR_BUFFER len 4108
info: [@2915003] object HDR_PGARR len 16
info: [@2915019] object HDR_VMA len 72
	VMA_ANON vmaref 0 inoref 0
info: [@2915091] object HDR_PGARR len 16
info: [@2915107] object HDR_BUFFER len 4108
info: [@2919215] object HDR_PGARR len 16
info: [@2919231] object HDR_VMA len 72
	VMA_ANON vmaref 0 inoref 0
info: [@2919303] object HDR_PGARR len 16
info: [@2919319] object HDR_BUFFER len 4108
info: [@2923427] object HDR_PGARR len 16
info: [@2923443] object HDR_OBJREF len 16
	OBJ_FILE ref 33
info: [@2923459] object HDR_FILE len 48
	FILE_GENERIC
info: [@2923507] object HDR_FILE_NAME len 42
info: [@2923549] object HDR_VMA len 72
	VMA_FILE vmaref 33 inoref 0
info: [@2923621] object HDR_PGARR len 16
info: [@2923637] object HDR_VMA len 72
	VMA_FILE vmaref 33 inoref 0
info: [@2923709] object HDR_PGARR len 16
info: [@2923725] object HDR_VMA len 72
	VMA_FILE vmaref 33 inoref 0
info: [@2923797] object HDR_PGARR len 16
info: [@2923813] object HDR_BUFFER len 8208
info: [@2932021] object HDR_PGARR len 16
info: [@2932037] object HDR_VMA len 72
	VMA_FILE vmaref 33 inoref 0
info: [@2932109] object HDR_PGARR len 16
info: [@2932125] object HDR_BUFFER len 4108
info: [@2936233] object HDR_PGARR len 16
info: [@2936249] object HDR_VMA len 72
	VMA_ANON vmaref 0 inoref 0
info: [@2936321] object HDR_PGARR len 16
info: [@2936337] object HDR_BUFFER len 8208
info: [@2944545] object HDR_PGARR len 16
info: [@2944561] object HDR_VMA len 72
	VMA_ANON vmaref 0 inoref 0
info: [@2944633] object HDR_PGARR len 16
info: [@2944649] object HDR_BUFFER len 12308
info: [@2956957] object HDR_PGARR len 16
info: [@2956973] object HDR_VMA len 72
	VMA_VDSO vmaref 0 inoref 0
info: [@2957045] object HDR_OBJREF len 16
	OBJ_FILE ref 34
info: [@2957061] object HDR_FILE len 48
	FILE_GENERIC
info: [@2957109] object HDR_FILE_NAME len 26
info: [@2957135] object HDR_VMA len 72
	VMA_FILE vmaref 34 inoref 0
info: [@2957207] object HDR_PGARR len 16
info: [@2957223] object HDR_VMA len 72
	VMA_FILE vmaref 34 inoref 0
info: [@2957295] object HDR_PGARR len 16
info: [@2957311] object HDR_BUFFER len 4108
info: [@2961419] object HDR_PGARR len 16
info: [@2961435] object HDR_VMA len 72
	VMA_FILE vmaref 34 inoref 0
info: [@2961507] object HDR_PGARR len 16
info: [@2961523] object HDR_BUFFER len 4108
info: [@2965631] object HDR_PGARR len 16
info: [@2965647] object HDR_VMA len 72
	VMA_ANON vmaref 0 inoref 0
info: [@2965719] object HDR_PGARR len 16
info: [@2965735] object HDR_BUFFER len 12308
info: [@2978043] object HDR_PGARR len 16
info: [@2978059] object HDR_MM_CONTEXT len 24
info: [@2978083] object ---UNKNOWN--- len 8
info: [@2978091] object HDR_OBJREF len 16
	OBJ_FS ref 35
info: [@2978107] object HDR_FS len 8
info: [@2978115] object HDR_FILE_NAME len 48
info: [@2978163] object HDR_FILE_NAME len 10
info: [@2978173] object HDR_OBJREF len 16
	OBJ_SIGHAND ref 36
info: [@2978189] object HDR_SIGHAND len 2056
info: [@2980245] object HDR_TASK_OBJS len 32
info: [@2980277] object HDR_SIGNAL len 328
info: [@2980605] object HDR_SIGPENDING len 24
info: [@2980629] object HDR_SIGPENDING len 24
info: [@2980653] object HDR_SIGNAL_TASK len 16
info: [@2980669] object HDR_TAIL len 16
info: reached end of file

--Apple-Mail-9-786954914
Content-Disposition: attachment;
	filename=dmesg
Content-Type: application/octet-stream;
	name="dmesg"
Content-Transfer-Encoding: 7bit

+++ dmesg.1	2010-03-19 22:02:06.349101828 +0900
+325] got page 0xd
+[ 1774.609506] [3326:3326:c/r:may_checkpoint_task:242] check 3326
+[ 1774.609512] [3326:3326:c/r:walk_task_subtree:623] total 1 ret 1
+[ 1774.609515] [3326:3326:c/r:may_checkpoint_task:242] check 3326
+[ 1774.609517] [3326:3326:c/r:walk_task_subtree:623] total 1 ret 1
+[ 1774.609520] [3326:3326:c/r:ckpt_write_obj:41] type 1 len 72
+[ 1774.609566] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 73
+[ 1774.609572] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 73
+[ 1774.609577] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 73
+[ 1774.609582] [3326:3326:c/r:ckpt_write_obj:41] type 2 len 16
+[ 1774.609586] [3326:3326:c/r:ckpt_write_obj:41] type 3 len 8
+[ 1774.609590] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 19
+[ 1774.609596] [3326:3326:c/r:ckpt_write_obj_type:66] type 7 len 13
+[ 1774.609600] [3326:3326:c/r:ckpt_write_obj:41] type 101 len 16
+[ 1774.609604] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 32
+[ 1774.609611] [3326:3326:c/r:checkpoint_pids:338] task[0]: vpid 3326 vtgid 3326 parent 3049
+[ 1774.609615] [3326:3326:c/r:checkpoint_all_tasks:227] dumping task #0
+[ 1774.609618] [3326:3326:c/r:ckpt_write_obj:41] type 102 len 64
+[ 1774.609622] [3326:3326:c/r:ckpt_write_obj_type:66] type 5 len 24
+[ 1774.609627] [3326:3326:c/r:checkpoint_task:445] task 0
+[ 1774.609629] [3326:3326:c/r:ckpt_write_obj:41] type 106 len 40
+[ 1774.609633] [3326:3326:c/r:checkpoint_task:454] thread 0
+[ 1774.609635] [3326:3326:c/r:checkpoint_restart_block:349] restart_block: non
+[ 1774.609638] [3326:3326:c/r:checkpoint_restart_block:428] restart_block: args 0x0 0x0 0x0 0x0 0x0
+[ 1774.609641] [3326:3326:c/r:ckpt_write_obj:41] type 105 len 56
+[ 1774.609644] [3326:3326:c/r:checkpoint_restart_block:433] restart_block ret 0
+[ 1774.609646] [3326:3326:c/r:checkpoint_task:458] restart-blocks 0
+[ 1774.609650] [3326:3326:c/r:checkpoint_cpu:179] math 0
+[ 1774.609652] [3326:3326:c/r:ckpt_write_obj:41] type 107 len 192
+[ 1774.609655] [3326:3326:c/r:checkpoint_task:462] cpu 0
+[ 1774.609658] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.609663] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.609667] [3326:3326:c/r:ckpt_write_obj:41] type 116 len 20
+[ 1774.609671] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.609676] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.609680] [3326:3326:c/r:ckpt_write_obj:41] type 113 len 16
+[ 1774.609684] [3326:3326:c/r:ckpt_write_obj:41] type 115 len 16
+[ 1774.609689] [3326:3326:c/r:do_checkpoint_cred:1046] cred uid 0 fsuid 0 gid 0 secref 0
+[ 1774.609691] [3326:3326:c/r:ckpt_write_obj:41] type 114 len 96
+[ 1774.609695] [3326:3326:c/r:ckpt_write_obj:41] type 117 len 16
+[ 1774.609699] [3326:3326:c/r:checkpoint_task_objs:249] cred: objref 0
+[ 1774.609702] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.609707] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.609711] [3326:3326:c/r:ckpt_write_obj:41] type 109 len 400
+[ 1774.609715] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.609720] [3326:3326:c/r:ckpt_write_obj:41] type 110 len 56
+[ 1774.609724] [3326:3326:c/r:checkpoint_ipc_any:76] ipc-shm count 18
+[ 1774.609727] [3326:3326:c/r:ckpt_write_obj:41] type 501 len 16
+[ 1774.609732] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 8 first 1
+[ 1774.609736] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 1784 lprid 1752 segsz 393216 mlock -1
+[ 1774.609739] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 8
+[ 1774.609741] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.609748] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.609750] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.609753] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.609755] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.609757] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.609759] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.609761] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.609763] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.609765] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.609767] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.609769] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.609771] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.609964] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.609966] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.609968] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.609970] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.609972] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.609974] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.609976] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.609978] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.609980] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.609982] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.609984] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.609986] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.609988] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x24
+[ 1774.609990] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x25
+[ 1774.609992] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x27
+[ 1774.609994] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x28
+[ 1774.609997] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2a
+[ 1774.609998] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2b
+[ 1774.610001] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2d
+[ 1774.610003] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2e
+[ 1774.610005] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x30
+[ 1774.610007] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x31
+[ 1774.610009] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x33
+[ 1774.610011] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x34
+[ 1774.610013] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x36
+[ 1774.610015] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x37
+[ 1774.610017] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x39
+[ 1774.610019] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3a
+[ 1774.610021] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3c
+[ 1774.610023] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3d
+[ 1774.610025] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3f
+[ 1774.610027] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x40
+[ 1774.610029] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x42
+[ 1774.610031] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x43
+[ 1774.610033] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x45
+[ 1774.610035] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x46
+[ 1774.610041] [3326:3326:c/r:checkpoint_memory_contents:458] collected 48 pages
+[ 1774.610043] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.610049] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 196808
+[ 1774.610636] [3326:3326:c/r:pgarr_release_pages:102] total pages 48
+[ 1774.610640] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.610645] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 9 first 1
+[ 1774.610649] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 1784 lprid 1752 segsz 393216 mlock -1
+[ 1774.610651] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 9
+[ 1774.610653] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.610658] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.610660] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.610662] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.610664] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.610666] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.610668] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.610670] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.610672] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.610674] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.610676] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.610678] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.610680] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.610683] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.610685] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.610687] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.610689] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.610691] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.610693] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.610695] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.610697] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.610707] [3326:3326:c/r:checkpoint_memory_contents:458] collected 20 pages
+[ 1774.610710] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.610714] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 82008
+[ 1774.610874] [3326:3326:c/r:pgarr_release_pages:102] total pages 20
+[ 1774.610877] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.610882] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 10 first 1
+[ 1774.610886] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2049 lprid 1795 segsz 393216 mlock -1
+[ 1774.610888] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 10
+[ 1774.610891] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.610895] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.610897] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.610900] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.610902] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.610904] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.610906] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.610908] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.610910] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.610912] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.610914] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.610916] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.610918] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.610920] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.610922] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.610924] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.610926] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.610929] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.610931] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.610933] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.610935] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.610937] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.610939] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.610941] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.610951] [3326:3326:c/r:checkpoint_memory_contents:458] collected 23 pages
+[ 1774.610953] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.610957] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 94308
+[ 1774.611685] [3326:3326:c/r:pgarr_release_pages:102] total pages 23
+[ 1774.611688] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.611694] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 11 first 1
+[ 1774.611697] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2035 lprid 2125 segsz 393216 mlock -1
+[ 1774.611700] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 11
+[ 1774.611702] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.611707] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.611709] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.611711] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2
+[ 1774.611713] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.611715] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.611717] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5
+[ 1774.611719] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.611721] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.611723] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x8
+[ 1774.611725] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.611727] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.611729] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb
+[ 1774.611731] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.611733] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.611735] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xe
+[ 1774.611737] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.611739] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.611741] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x11
+[ 1774.611743] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.611745] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.611747] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x14
+[ 1774.611749] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.611751] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.611753] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x17
+[ 1774.611755] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.611757] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.611759] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1a
+[ 1774.611761] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.611763] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.611765] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1d
+[ 1774.611766] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.611769] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.611770] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x20
+[ 1774.611772] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.611774] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.611776] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x23
+[ 1774.611778] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x24
+[ 1774.611780] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x25
+[ 1774.611782] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x26
+[ 1774.611784] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x27
+[ 1774.611786] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x28
+[ 1774.611788] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x29
+[ 1774.611790] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2a
+[ 1774.611792] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2b
+[ 1774.611794] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2c
+[ 1774.611796] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2d
+[ 1774.611798] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2e
+[ 1774.611800] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2f
+[ 1774.611802] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x30
+[ 1774.611804] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x31
+[ 1774.611806] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x32
+[ 1774.611808] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x33
+[ 1774.611810] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x34
+[ 1774.611812] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x35
+[ 1774.611814] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x36
+[ 1774.611816] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x37
+[ 1774.611817] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x38
+[ 1774.611820] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x39
+[ 1774.611821] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3a
+[ 1774.611823] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3b
+[ 1774.611825] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3c
+[ 1774.611827] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3d
+[ 1774.611829] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3e
+[ 1774.611831] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3f
+[ 1774.611833] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x40
+[ 1774.611835] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x41
+[ 1774.611837] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x42
+[ 1774.611839] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x43
+[ 1774.611841] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x44
+[ 1774.611843] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x45
+[ 1774.611845] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x46
+[ 1774.611847] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x47
+[ 1774.611849] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x48
+[ 1774.611851] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x49
+[ 1774.611853] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4a
+[ 1774.611855] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4b
+[ 1774.611856] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4c
+[ 1774.611858] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4d
+[ 1774.611860] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4e
+[ 1774.611862] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4f
+[ 1774.611864] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x50
+[ 1774.611866] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x51
+[ 1774.611868] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x52
+[ 1774.611870] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x53
+[ 1774.611872] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x54
+[ 1774.611874] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x55
+[ 1774.611876] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x56
+[ 1774.611878] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x57
+[ 1774.611880] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x58
+[ 1774.611882] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x59
+[ 1774.611884] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5a
+[ 1774.611885] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5b
+[ 1774.611887] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5c
+[ 1774.611889] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5d
+[ 1774.611891] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5e
+[ 1774.611893] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5f
+[ 1774.611895] [3326:3326:c/r:checkpoint_memory_contents:458] collected 96 pages
+[ 1774.611897] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.611902] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 393608
+[ 1774.621228] [3326:3326:c/r:pgarr_release_pages:102] total pages 96
+[ 1774.621235] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.621244] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 12 first 1
+[ 1774.621249] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 1898 lprid 1795 segsz 393216 mlock -1
+[ 1774.621251] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 12
+[ 1774.621253] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.621259] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.621261] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.621264] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.621266] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.621269] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.621270] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.621273] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.621275] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.621277] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.621279] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.621281] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.621283] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.621286] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.621288] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.621290] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.621292] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.621294] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.621296] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.621298] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.621300] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.621302] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.621304] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.621306] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.621308] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.621311] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x24
+[ 1774.621312] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x25
+[ 1774.621315] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x27
+[ 1774.621317] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x28
+[ 1774.621319] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2a
+[ 1774.621321] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2b
+[ 1774.621323] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2d
+[ 1774.621325] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2e
+[ 1774.621327] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x30
+[ 1774.621329] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x31
+[ 1774.621331] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x33
+[ 1774.621333] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x34
+[ 1774.621335] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x36
+[ 1774.621337] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x37
+[ 1774.621339] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x39
+[ 1774.621341] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3a
+[ 1774.621343] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3c
+[ 1774.621345] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3d
+[ 1774.621347] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3f
+[ 1774.621349] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x40
+[ 1774.621352] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x42
+[ 1774.621353] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x43
+[ 1774.621356] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x45
+[ 1774.621358] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x46
+[ 1774.621363] [3326:3326:c/r:checkpoint_memory_contents:458] collected 48 pages
+[ 1774.621365] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.621370] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 196808
+[ 1774.623005] [3326:3326:c/r:pgarr_release_pages:102] total pages 48
+[ 1774.623009] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.623015] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 13 first 1
+[ 1774.623019] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 1938 lprid 1795 segsz 393216 mlock -1
+[ 1774.623021] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 13
+[ 1774.623024] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.623028] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.623031] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.623033] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.623035] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.623037] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.623040] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.623042] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.623044] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.623046] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.623048] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.623050] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.623053] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.623056] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.623058] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.623060] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.623062] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.623064] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.623067] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.623069] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.623071] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.623073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.623075] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.623085] [3326:3326:c/r:checkpoint_memory_contents:458] collected 22 pages
+[ 1774.623088] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.623092] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 90208
+[ 1774.623453] [3326:3326:c/r:pgarr_release_pages:102] total pages 22
+[ 1774.623456] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.623462] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 14 first 1
+[ 1774.623465] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 1988 lprid 2007 segsz 393216 mlock -1
+[ 1774.623467] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 14
+[ 1774.623470] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.623474] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.623476] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.623479] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.623481] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.623483] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.623485] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.623487] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.623489] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.623491] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.623493] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.623495] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.623497] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.623499] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.623501] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.623504] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.623506] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.623508] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.623510] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.623512] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.623514] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.623516] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.623518] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.623528] [3326:3326:c/r:checkpoint_memory_contents:458] collected 22 pages
+[ 1774.623530] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.623534] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 90208
+[ 1774.623790] [3326:3326:c/r:pgarr_release_pages:102] total pages 22
+[ 1774.623793] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.623798] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 15 first 1
+[ 1774.623802] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2034 lprid 2186 segsz 393216 mlock -1
+[ 1774.623804] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 15
+[ 1774.623806] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.623811] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.623813] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.623815] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.623817] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.623820] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.623822] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.623824] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.623826] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.623828] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.623830] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.623832] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.623834] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.623837] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.623839] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.623841] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.623843] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.623845] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.623847] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.623849] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.623851] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.623853] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.623855] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.623867] [3326:3326:c/r:checkpoint_memory_contents:458] collected 22 pages
+[ 1774.623869] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.623873] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 90208
+[ 1774.624199] [3326:3326:c/r:pgarr_release_pages:102] total pages 22
+[ 1774.624202] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.624208] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 16 first 1
+[ 1774.624212] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2034 lprid 2186 segsz 393216 mlock -1
+[ 1774.624214] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 16
+[ 1774.624216] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.624228] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.624230] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.624233] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.624235] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.624237] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.624239] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.624241] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.624243] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.624245] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.624247] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.624249] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.624251] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.624254] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.624256] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.624258] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.624260] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.624262] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.624264] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.624266] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.624268] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.624270] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.624272] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.624274] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.624276] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.624279] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x24
+[ 1774.624281] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x25
+[ 1774.624283] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x27
+[ 1774.624285] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x28
+[ 1774.624287] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2a
+[ 1774.624289] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2b
+[ 1774.624291] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2d
+[ 1774.624293] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2e
+[ 1774.624295] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x30
+[ 1774.624297] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x31
+[ 1774.624299] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x33
+[ 1774.624301] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x34
+[ 1774.624304] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x36
+[ 1774.624305] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x37
+[ 1774.624308] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x39
+[ 1774.624309] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3a
+[ 1774.624312] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3c
+[ 1774.624314] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3d
+[ 1774.624316] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3f
+[ 1774.624318] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x40
+[ 1774.624320] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x42
+[ 1774.624322] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x43
+[ 1774.624324] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x45
+[ 1774.624326] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x46
+[ 1774.624331] [3326:3326:c/r:checkpoint_memory_contents:458] collected 48 pages
+[ 1774.624334] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.624338] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 196808
+[ 1774.624984] [3326:3326:c/r:pgarr_release_pages:102] total pages 48
+[ 1774.624987] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.624993] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 17 first 1
+[ 1774.624996] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2035 lprid 1795 segsz 393216 mlock -1
+[ 1774.624998] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 17
+[ 1774.625001] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.625005] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.625008] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.625010] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.625012] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.625014] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.625016] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.625018] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.625020] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.625022] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.625024] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.625026] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.625028] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.625031] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.625033] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.625035] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.625037] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.625039] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.625041] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.625043] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.625046] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.625048] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.625050] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.625052] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.625054] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.625056] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x24
+[ 1774.625058] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x25
+[ 1774.625060] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x27
+[ 1774.625062] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x28
+[ 1774.625064] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2a
+[ 1774.625066] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2b
+[ 1774.625068] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2d
+[ 1774.625070] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2e
+[ 1774.625072] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x30
+[ 1774.625074] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x31
+[ 1774.625076] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x33
+[ 1774.625078] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x34
+[ 1774.625080] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x36
+[ 1774.625082] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x37
+[ 1774.625084] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x39
+[ 1774.625086] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3a
+[ 1774.625088] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3c
+[ 1774.625090] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3d
+[ 1774.625092] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3f
+[ 1774.625095] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x40
+[ 1774.625097] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x42
+[ 1774.625099] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x43
+[ 1774.625101] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x45
+[ 1774.625103] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x46
+[ 1774.625108] [3326:3326:c/r:checkpoint_memory_contents:458] collected 48 pages
+[ 1774.625111] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.625115] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 196808
+[ 1774.625701] [3326:3326:c/r:pgarr_release_pages:102] total pages 48
+[ 1774.625704] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.625710] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 18 first 1
+[ 1774.625713] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2121 lprid 1795 segsz 393216 mlock -1
+[ 1774.625715] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 18
+[ 1774.625717] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.625722] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.625724] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.625727] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.625729] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.625731] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.625733] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.625735] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.625737] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.625739] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.625741] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.625743] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.625745] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.625748] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.625749] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.625752] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.625754] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.625756] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.625758] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.625760] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.625762] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.625764] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.625766] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.625775] [3326:3326:c/r:checkpoint_memory_contents:458] collected 22 pages
+[ 1774.625778] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.625782] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 90208
+[ 1774.625979] [3326:3326:c/r:pgarr_release_pages:102] total pages 22
+[ 1774.625982] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.625988] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 19 first 1
+[ 1774.625991] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2123 lprid 1795 segsz 393216 mlock -1
+[ 1774.625993] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 19
+[ 1774.625995] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.626000] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.626002] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.626004] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.626006] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.626008] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.626010] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.626012] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.626014] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.626016] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.626018] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.626021] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.626022] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.626025] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.626027] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.626029] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.626031] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.626042] [3326:3326:c/r:checkpoint_memory_contents:458] collected 16 pages
+[ 1774.626045] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.626049] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 65608
+[ 1774.626533] [3326:3326:c/r:pgarr_release_pages:102] total pages 16
+[ 1774.626536] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.626541] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 20 first 1
+[ 1774.626545] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2047 lprid 1795 segsz 393216 mlock -1
+[ 1774.626547] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 20
+[ 1774.626549] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.626554] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.626556] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.626558] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.626560] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.626562] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.626564] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.626566] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.626568] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.626570] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.626572] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.626574] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.626576] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.626579] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.626581] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.626583] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.626585] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.626587] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.626589] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.626591] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.626593] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.626595] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.626597] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.626599] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.626601] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.626611] [3326:3326:c/r:checkpoint_memory_contents:458] collected 24 pages
+[ 1774.626613] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.626617] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 98408
+[ 1774.626900] [3326:3326:c/r:pgarr_release_pages:102] total pages 24
+[ 1774.626900] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.626900] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 21 first 1
+[ 1774.626901] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2051 lprid 1795 segsz 393216 mlock -1
+[ 1774.626901] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 21
+[ 1774.626901] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.626901] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.626905] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.626907] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.626909] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.626911] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.626913] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.626915] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.626917] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.626920] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.626922] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.626924] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.626926] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.626928] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.626930] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.626932] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.626934] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.626943] [3326:3326:c/r:checkpoint_memory_contents:458] collected 24 pages
+[ 1774.626946] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.626951] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 98408
+[ 1774.627166] [3326:3326:c/r:pgarr_release_pages:102] total pages 24
+[ 1774.627169] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.627174] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 22 first 1
+[ 1774.627178] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2186 lprid 3019 segsz 393216 mlock -1
+[ 1774.627180] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 22
+[ 1774.627182] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.627187] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.627189] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.627191] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.627193] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.627195] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.627197] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.627199] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.627201] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.627203] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.627205] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.627207] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.627209] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.627212] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.627214] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.627216] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.627218] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.627220] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.627222] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.627224] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.627226] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.627228] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.627230] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.627240] [3326:3326:c/r:checkpoint_memory_contents:458] collected 22 pages
+[ 1774.627243] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.627247] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 90208
+[ 1774.627494] [3326:3326:c/r:pgarr_release_pages:102] total pages 22
+[ 1774.627497] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.627503] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 23 first 1
+[ 1774.627506] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2008 lprid 1795 segsz 393216 mlock -1
+[ 1774.627508] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 23
+[ 1774.627511] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.627515] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.627518] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.627520] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2
+[ 1774.627522] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.627524] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.627526] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5
+[ 1774.627528] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.627530] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.627532] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x8
+[ 1774.627534] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.627536] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.627538] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb
+[ 1774.627540] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.627542] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.627544] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xe
+[ 1774.627546] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.627548] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.627550] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x11
+[ 1774.627552] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.627554] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.627556] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x14
+[ 1774.627558] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.627560] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.627562] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x17
+[ 1774.627564] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.627566] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.627568] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1a
+[ 1774.627570] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.627572] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.627574] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1d
+[ 1774.627575] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.627577] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.627579] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x20
+[ 1774.627581] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.627583] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.627585] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x23
+[ 1774.627587] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x24
+[ 1774.627589] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x25
+[ 1774.627591] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x26
+[ 1774.627593] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x27
+[ 1774.627595] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x28
+[ 1774.627597] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x29
+[ 1774.627599] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2a
+[ 1774.627601] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2b
+[ 1774.627603] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2c
+[ 1774.627605] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2d
+[ 1774.627607] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2e
+[ 1774.627609] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2f
+[ 1774.627611] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x30
+[ 1774.627613] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x31
+[ 1774.627615] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x32
+[ 1774.627617] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x33
+[ 1774.627619] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x34
+[ 1774.627621] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x35
+[ 1774.627623] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x36
+[ 1774.627625] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x37
+[ 1774.627627] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x38
+[ 1774.627629] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x39
+[ 1774.627631] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3a
+[ 1774.627633] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3b
+[ 1774.627635] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3c
+[ 1774.627637] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3d
+[ 1774.627639] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3e
+[ 1774.627641] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3f
+[ 1774.627643] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x40
+[ 1774.627645] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x41
+[ 1774.627647] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x42
+[ 1774.627649] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x43
+[ 1774.627651] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x44
+[ 1774.627653] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x45
+[ 1774.627655] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x46
+[ 1774.627657] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x47
+[ 1774.627659] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x48
+[ 1774.627661] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x49
+[ 1774.627663] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4a
+[ 1774.627665] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4b
+[ 1774.627667] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4c
+[ 1774.627669] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4d
+[ 1774.627671] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4e
+[ 1774.627673] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4f
+[ 1774.627675] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x50
+[ 1774.627677] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x51
+[ 1774.627679] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x52
+[ 1774.627681] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x53
+[ 1774.627683] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x54
+[ 1774.627685] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x55
+[ 1774.627687] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x56
+[ 1774.627689] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x57
+[ 1774.627691] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x58
+[ 1774.627693] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x59
+[ 1774.627696] [3326:3326:c/r:checkpoint_memory_contents:458] collected 90 pages
+[ 1774.627699] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.627703] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 369008
+[ 1774.628083] [3326:3326:c/r:pgarr_release_pages:102] total pages 90
+[ 1774.628083] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.628083] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 24 first 1
+[ 1774.628083] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2008 lprid 1795 segsz 393216 mlock -1
+[ 1774.628083] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 24
+[ 1774.628083] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x8
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xe
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x11
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x14
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x17
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x18
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x19
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1a
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1b
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1c
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1d
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1e
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1f
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x20
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x21
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x22
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x23
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x24
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x25
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x26
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x27
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x28
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x29
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2a
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2b
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2c
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2d
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2e
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x2f
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x30
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x31
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x32
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x33
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x34
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x35
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x36
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x37
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x38
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x39
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3a
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3b
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3c
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3d
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3e
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3f
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x40
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x41
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x42
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x43
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x44
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x45
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x46
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x47
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x48
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x49
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4a
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4b
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4c
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4d
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4e
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4f
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x50
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x51
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x52
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x53
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x54
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x55
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x56
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x57
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x58
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x59
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5a
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5b
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5c
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5d
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5e
+[ 1774.628083] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x5f
+[ 1774.628083] [3326:3326:c/r:checkpoint_memory_contents:458] collected 96 pages
+[ 1774.628083] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.628083] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 393608
+[ 1774.639776] [3326:3326:c/r:pgarr_release_pages:102] total pages 96
+[ 1774.639784] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.639792] [3326:3326:c/r:ckpt_obj_lookup_add:803] INODE objref 25 first 1
+[ 1774.639798] [3326:3326:c/r:fill_ipc_shm_hdr:73] shm: cprid 2186 lprid 1795 segsz 393216 mlock -1
+[ 1774.639800] [3326:3326:c/r:checkpoint_ipc_shm:109] shm: objref 25
+[ 1774.639803] [3326:3326:c/r:ckpt_write_obj:41] type 502 len 120
+[ 1774.639808] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x0
+[ 1774.639810] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x1
+[ 1774.639814] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x3
+[ 1774.639816] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x4
+[ 1774.639818] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x6
+[ 1774.639820] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x7
+[ 1774.639822] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9
+[ 1774.639824] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xa
+[ 1774.639827] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xc
+[ 1774.639829] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xd
+[ 1774.639831] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xf
+[ 1774.639833] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x10
+[ 1774.639836] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x12
+[ 1774.639838] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x13
+[ 1774.639840] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x15
+[ 1774.639842] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x16
+[ 1774.639853] [3326:3326:c/r:checkpoint_memory_contents:458] collected 16 pages
+[ 1774.639856] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.639860] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 65608
+[ 1774.640011] [3326:3326:c/r:pgarr_release_pages:102] total pages 16
+[ 1774.640014] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640019] [3326:3326:c/r:checkpoint_ipc_any:84] ipc-shm ret 0
+[ 1774.640022] [3326:3326:c/r:checkpoint_ipc_any:76] ipc-msg count 0
+[ 1774.640024] [3326:3326:c/r:ckpt_write_obj:41] type 501 len 16
+[ 1774.640028] [3326:3326:c/r:checkpoint_ipc_any:84] ipc-msg ret 0
+[ 1774.640030] [3326:3326:c/r:checkpoint_ipc_any:76] ipc-sem count 4
+[ 1774.640033] [3326:3326:c/r:ckpt_write_obj:41] type 501 len 16
+[ 1774.640038] [3326:3326:c/r:fill_ipc_sem_hdr:50] sem: nsems 1
+[ 1774.640040] [3326:3326:c/r:ckpt_write_obj:41] type 505 len 88
+[ 1774.640044] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 24
+[ 1774.640049] [3326:3326:c/r:fill_ipc_sem_hdr:50] sem: nsems 103
+[ 1774.640052] [3326:3326:c/r:ckpt_write_obj:41] type 505 len 88
+[ 1774.640055] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 1656
+[ 1774.640067] [3326:3326:c/r:fill_ipc_sem_hdr:50] sem: nsems 9
+[ 1774.640069] [3326:3326:c/r:ckpt_write_obj:41] type 505 len 88
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 152
+[ 1774.640073] [3326:3326:c/r:fill_ipc_sem_hdr:50] sem: nsems 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 505 len 88
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 24
+[ 1774.640073] [3326:3326:c/r:checkpoint_ipc_any:84] ipc-sem ret 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 108 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_task_ns:177] nsproxy: objref 5
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 103 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_task_objs:256] ns: objref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 301 len 16
+[ 1774.640073] [3326:3326:c/r:do_checkpoint_file_table:362] nfds 5
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_common:188] file cr-test.out credref 1 secref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 304 len 48
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 25
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_desc:320] fd 1 objref 27 file d0c2cd00 coe 0)
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 302 len 24
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_desc:320] fd 2 objref 27 file d0c2cd00 coe 0)
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 302 len 24
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_common:188] file log credref 1 secref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 304 len 48
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 17
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_desc:320] fd 3 objref 28 file d0c45480 coe 0)
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 302 len 24
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_desc:320] fd 4 objref 27 file d0c2cd00 coe 0)
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 302 len 24
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_common:188] file out credref 1 secref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 304 len 48
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 17
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_desc:320] fd 5 objref 29 file d5cacd80 coe 0)
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 302 len 24
+[ 1774.640073] [3326:3326:c/r:do_checkpoint_file_table:370] files_deferq ran 0 entries
+[ 1774.640073] [3326:3326:c/r:checkpoint_task_objs:263] files: objref 26
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:do_checkpoint_cred:1046] cred uid 0 fsuid 0 gid 0 secref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 114 len 96
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_common:188] file ckpt credref 32 secref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 304 len 48
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 53
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 401 len 120
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 360
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0x8048000-0x8049000 flags 0x8001875
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0x8048000-0x8049000 flags 0x8001875 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0x8049000-0x804a000 flags 0x8101871
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0x8049000-0x804a000 flags 0x8101871 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x8049000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 1 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 4108
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0x804a000-0x804b000 flags 0x8101873
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0x804a000-0x804b000 flags 0x8101873 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x804a000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 1 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 4108
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0x9b97000-0x9bb8000 flags 0x100073
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0x9b97000-0x9bb8000 flags 0x100073 type 2
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0x9b97000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 1 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 4108
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb769d000-0xb769e000 flags 0x100073
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb769d000-0xb769e000 flags 0x100073 type 2
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb769d000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 1 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 4108
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb769e000-0xb77dc000 flags 0x8000075
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_common:188] file libc-2.10.1.so credref 1 secref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 304 len 48
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 42
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb769e000-0xb77dc000 flags 0x8000075 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb77dc000-0xb77dd000 flags 0x8000070
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb77dc000-0xb77dd000 flags 0x8000070 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb77dd000-0xb77df000 flags 0x8100071
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb77dd000-0xb77df000 flags 0x8100071 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77dd000
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77de000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 2 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 8208
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 2
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb77df000-0xb77e0000 flags 0x8100073
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb77df000-0xb77e0000 flags 0x8100073 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77df000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 1 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 4108
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb77e0000-0xb77e3000 flags 0x100073
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb77e0000-0xb77e3000 flags 0x100073 type 2
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77e0000
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77e2000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 2 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 8208
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 2
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb77f2000-0xb77f5000 flags 0x100073
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb77f2000-0xb77f5000 flags 0x100073 type 2
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77f2000
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77f3000
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb77f4000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 3 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 12308
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb77f5000-0xb77f6000 flags 0x4040075
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb77f5000-0xb77f6000 flags 0x4040075 type 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb77f6000-0xb7811000 flags 0x8000875
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_file_common:188] file ld-2.10.1.so credref 32 secref 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 304 len 48
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 26
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb77f6000-0xb7811000 flags 0x8000875 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb7811000-0xb7812000 flags 0x8100871
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb7811000-0xb7812000 flags 0x8100871 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb7811000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 1 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 4108
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xb7812000-0xb7813000 flags 0x8100873
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xb7812000-0xb7813000 flags 0x8100873 type 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xb7812000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 1 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 4108
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 1
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_vmas:626] vma 0xbfb8b000-0xbfb8e000 flags 0x100173
+[ 1774.640073] [3326:3326:c/r:generic_vma_checkpoint:502] vma 0xbfb8b000-0xbfb8e000 flags 0x100173 type 2
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 402 len 72
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xbfb8b000
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xbfb8c000
+[ 1774.640073] [3326:3326:c/r:vma_fill_pgarr:325] got page 0xbfb8d000
+[ 1774.640073] [3326:3326:c/r:checkpoint_memory_contents:458] collected 3 pages
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 4 len 12308
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 3
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 403 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_mm_context:228] nldt 0 vdso 0xb77f5000
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 404 len 24
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 202 len 8
+[ 1774.640073] [3326:3326:c/r:checkpoint_task_objs:270] mm: objref 30
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 451 len 8
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 48
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj_type:66] type 303 len 10
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 6 len 16
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 601 len 2056
+[ 1774.640073] [3326:3326:c/r:checkpoint_task_objs:284] sighand: objref 36
+[ 1774.640073] [3326:3326:c/r:ckpt_obj_lookup_add:803] SIGNAL objref 37 first 1
+[ 1774.640073] [3326:3326:c/r:checkpoint_task_objs:299] signal: objref 37
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 104 len 32
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 602 len 328
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 604 len 24
+[ 1774.640073] [3326:3326:c/r:checkpoint_task:466] objs 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 604 len 24
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 603 len 16
+[ 1774.640073] [3326:3326:c/r:checkpoint_task:470] task-signal 0
+[ 1774.640073] [3326:3326:c/r:ckpt_write_obj:41] type 9001 len 16
+[ 1774.640073] [3326:3326:c/r:pgarr_release_pages:102] total pages 0

--Apple-Mail-9-786954914
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--Apple-Mail-9-786954914--

From: Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Mon, 29 Mar 2010 17:52:13 +0900
Message-ID: <BC2CC354-59BA-465A-A863-0CDCD921A99A@dependable-os.net>
References: <4B83106C.7040203@cs.columbia.edu>
	<a1c54a921003150155q4a0c7fc1vb02ba0464b07f452@mail.gmail.com>
	<4B9EBAF2.1060304@cs.columbia.edu>
	<0B4E8136-FFC6-490D-B04A-23A6E1A924FF@dependable-os.net>
	<20100317205556.GA20750@us.ibm.com>
	<EF179F3A-4FBA-4776-B7A4-48F5EF73DC9C@dependable-os.net>
	<4BA39971.2080402@cs.columbia.edu>
	<FF5CB8EA-436D-4685-B7A2-946A83DF3F78@dependable-os.net>
	<20100324164758.GA21021@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: multipart/mixed; boundary=Apple-Mail-15--512242783
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100324164758.GA21021-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--Apple-Mail-15--512242783
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi

On 2010/03/25, at 1:47, Serge E. Hallyn wrote:

> Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
>>> If it doesn't work, can you please describe again the exact order of
>>> commands that you use and the reported error(s) ?
>>>=20
>> I'll let you know in any cases.
>>=20
>> Thank you very much for the advice
>=20
> Hi Jiro,
>=20
> Can you fetch the latest cr_tests
> 	(git clone git://git.sr71.net/~hallyn/cr_tests)
>=20
> and
> 	cd cr_tests; make; cd simple
> 	sh runtests.sh
>=20
> and tell me whether the second (restart --self) test succeeds?
> If it fails, can you send me the cr_*/log2 contents?
>=20

I've tried on ckpt-v20 and the above test looks OK.
And looks like self_checkpointing is working fine so far.

However, I'm still not able to restart external checkpoint correctly.

Here are the program and scripts I used for the test.
I used user-cr ckpt-v20 branch for checkpoint/restart program.

This time I disconnect the program from tty completely.

=
----------8<----------8<----------test.c----------8<----------8<----------=

#include <stdio.h>
#include <unistd.h>

int main(void)
{
  FILE *fp;
  int i;
  pid_t pid;
  int st;

  if(fork()) {
    return 0;
  } else {
    waitpid(getppid(), &st, NULL);

    close(0);
    close(1);
    close(2);
    setsid();

    if(fork()) {
      return 0;
    } else=20
      waitpid(getppid(), &st, NULL);
  }

  //unlink("/tmp/test.out");
  fp =3D fopen("/tmp/test.out","w");

  for(i=3D0;i<10;i++) {
    fprintf(fp,"%d\n",i);
    fflush(fp);
    sleep(1);
  }

  fclose(fp);
  return 0;
}
=
----------8<----------8<----------test.c----------8<----------8<----------=


=
----------8<----------8<----------checkpoint.sh----------8<----------8<---=
-------
#!/bin/sh

CLOG=3Dcheckpoint.log
RLOG=3Drestart.log
rm -f $CLOG $RLOG

./test &
sleep 1
PID=3D$(ps x | grep test | grep -v grep |cut -f 2 -d' ')

sleep 2
echo $PID > /cgroup/0/tasks

echo FROZEN > /cgroup/0/freezer.state
./checkpoint -l $CLOG -v $PID > ckpt.image

mv /tmp/test.out /tmp/test.out.orig
cp /tmp/test.out.orig /tmp/test.out

echo THAWED > /cgroup/0/freezer.state

./restart --pidns -l $RLOG -v -i ckpt.image;
=
----------8<----------8<----------checkpoint.sh----------8<----------8<---=
-------

When I run the above script, I got following:

# mount -t cgroup -o freezer cgroup /cgroup
# mkdir /cgroup/0
# sh checkpoint.sh
checkpoint id 8
Success

Then, I'm expecting to see number 0 to 9 in /tmp/test.out, but
I only got 0 to 3, which is the state I froze and checkpointed the =
process.

checkpoint.log and restart.log are empty.
I guess it means the programs worked fine.

I attached the dmesg I got by the single session of the script.
It looks the restart tries to reopen /tmp/test.out.

Could you give me any clues that I should check with?

My environment is Virtualbox VM.
I tried both with VT and without VT.
No virtualbox guest module is installed.


--Apple-Mail-15--512242783
Content-Disposition: attachment;
	filename=dmesg.log
Content-Type: application/octet-stream;
	name="dmesg.log"
Content-Transfer-Encoding: 7bit

++ /var/log/kern.log	2010-03-29 17:46:28.000000000 +0900
Mar 29 17:46:25 etdemo kernel: [  221.618929] [2163:2163:c/r:may_checkpoint_task:246] check 2156
Mar 29 17:46:25 etdemo kernel: [  221.618936] [2163:2163:c/r:walk_task_subtree:625] total 1 ret 1
Mar 29 17:46:25 etdemo kernel: [  221.618939] [2163:2163:c/r:may_checkpoint_task:246] check 2156
Mar 29 17:46:25 etdemo kernel: [  221.618942] [2163:2163:c/r:walk_task_subtree:625] total 1 ret 1
Mar 29 17:46:25 etdemo kernel: [  221.618947] [2163:2163:c/r:ckpt_write_obj:41] type 1 len 72
Mar 29 17:46:25 etdemo kernel: [  221.618976] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 73
Mar 29 17:46:25 etdemo kernel: [  221.618984] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 73
Mar 29 17:46:25 etdemo kernel: [  221.618990] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 73
Mar 29 17:46:25 etdemo kernel: [  221.618996] [2163:2163:c/r:ckpt_write_obj:41] type 2 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619001] [2163:2163:c/r:ckpt_write_obj:41] type 3 len 8
Mar 29 17:46:25 etdemo kernel: [  221.619006] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 19
Mar 29 17:46:25 etdemo kernel: [  221.619012] [2163:2163:c/r:ckpt_write_obj_type:67] type 7 len 13
Mar 29 17:46:25 etdemo kernel: [  221.619018] [2163:2163:c/r:ckpt_write_obj:41] type 101 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619023] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 32
Mar 29 17:46:25 etdemo kernel: [  221.619031] [2163:2163:c/r:checkpoint_pids:342] task[0]: vpid 2156 vtgid 2156 parent 1
Mar 29 17:46:25 etdemo kernel: [  221.619036] [2163:2163:c/r:checkpoint_all_tasks:231] dumping task #0
Mar 29 17:46:25 etdemo kernel: [  221.619039] [2163:2163:c/r:ckpt_write_obj:41] type 102 len 64
Mar 29 17:46:25 etdemo kernel: [  221.619044] [2163:2163:c/r:ckpt_write_obj_type:67] type 5 len 24
Mar 29 17:46:25 etdemo kernel: [  221.619050] [2163:2163:c/r:checkpoint_task:445] task 0
Mar 29 17:46:25 etdemo kernel: [  221.619054] [2163:2163:c/r:ckpt_write_obj:41] type 106 len 40
Mar 29 17:46:25 etdemo kernel: [  221.619058] [2163:2163:c/r:checkpoint_task:454] thread 0
Mar 29 17:46:25 etdemo kernel: [  221.619062] [2163:2163:c/r:checkpoint_restart_block:358] restart_block: hrtimer expire 222539287679 now 221618902755
Mar 29 17:46:25 etdemo kernel: [  221.619066] [2163:2163:c/r:checkpoint_restart_block:428] restart_block: args 0x1 0xbff6a104 0x0 0x0 0x36dbf59c
Mar 29 17:46:25 etdemo kernel: [  221.619069] [2163:2163:c/r:ckpt_write_obj:41] type 105 len 56
Mar 29 17:46:25 etdemo kernel: [  221.619074] [2163:2163:c/r:checkpoint_restart_block:433] restart_block ret 0
Mar 29 17:46:25 etdemo kernel: [  221.619076] [2163:2163:c/r:checkpoint_task:458] restart-blocks 0
Mar 29 17:46:25 etdemo kernel: [  221.619080] [2163:2163:c/r:checkpoint_cpu:179] math 0
Mar 29 17:46:25 etdemo kernel: [  221.619083] [2163:2163:c/r:ckpt_write_obj:41] type 107 len 192
Mar 29 17:46:25 etdemo kernel: [  221.619088] [2163:2163:c/r:checkpoint_task:462] cpu 0
Mar 29 17:46:25 etdemo kernel: [  221.619091] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619096] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619101] [2163:2163:c/r:ckpt_write_obj:41] type 116 len 20
Mar 29 17:46:25 etdemo kernel: [  221.619106] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619112] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619117] [2163:2163:c/r:ckpt_write_obj:41] type 113 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619122] [2163:2163:c/r:ckpt_write_obj:41] type 115 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619128] [2163:2163:c/r:do_checkpoint_cred:1046] cred uid 0 fsuid 0 gid 0 secref 0
Mar 29 17:46:25 etdemo kernel: [  221.619131] [2163:2163:c/r:ckpt_write_obj:41] type 114 len 96
Mar 29 17:46:25 etdemo kernel: [  221.619136] [2163:2163:c/r:ckpt_write_obj:41] type 117 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619140] [2163:2163:c/r:checkpoint_task_objs:249] cred: objref 0
Mar 29 17:46:25 etdemo kernel: [  221.619144] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619149] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619154] [2163:2163:c/r:ckpt_write_obj:41] type 109 len 400
Mar 29 17:46:25 etdemo kernel: [  221.619159] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619165] [2163:2163:c/r:ckpt_write_obj:41] type 110 len 56
Mar 29 17:46:25 etdemo kernel: [  221.619170] [2163:2163:c/r:checkpoint_ipc_any:91] ipc-shm count 17
Mar 29 17:46:25 etdemo kernel: [  221.619173] [2163:2163:c/r:ckpt_write_obj:41] type 501 len 16
Mar 29 17:46:25 etdemo kernel: [  221.619183] [2163:2163:c/r:ckpt_obj_lookup_add:804] INODE objref 8 first 1
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:fill_ipc_shm_hdr:74] shm: cprid 1735 lprid 1410 segsz 393216 mlock -1
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:checkpoint_ipc_shm:111] shm: objref 8
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:ckpt_write_obj:41] type 502 len 120
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x0
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x6
Mar 29 17:46:25 etdemo kernel: [  221.626473] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x7
Mar 29 17:46:25 etdemo kernel: [  221.626474] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x9
Mar 29 17:46:25 etdemo kernel: [  221.626474] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xa
Mar 29 17:46:25 etdemo kernel: [  221.626474] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xc
Mar 29 17:46:25 etdemo kernel: [  221.626474] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xd
Mar 29 17:46:25 etdemo kernel: [  221.626475] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xf
Mar 29 17:46:25 etdemo kernel: [  221.626481] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x10
Mar 29 17:46:25 etdemo kernel: [  221.626498] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x12
Mar 29 17:46:25 etdemo kernel: [  221.626501] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x13
Mar 29 17:46:25 etdemo kernel: [  221.626504] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x15
Mar 29 17:46:25 etdemo kernel: [  221.626507] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x16
Mar 29 17:46:25 etdemo kernel: [  221.626510] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x18
Mar 29 17:46:25 etdemo kernel: [  221.626512] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x19
Mar 29 17:46:25 etdemo kernel: [  221.626515] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1b
Mar 29 17:46:25 etdemo kernel: [  221.626518] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1c
Mar 29 17:46:25 etdemo kernel: [  221.626520] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1e
Mar 29 17:46:25 etdemo kernel: [  221.626523] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1f
Mar 29 17:46:25 etdemo kernel: [  221.626526] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x21
Mar 29 17:46:25 etdemo kernel: [  221.626529] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x22
Mar 29 17:46:25 etdemo kernel: [  221.626531] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x24
Mar 29 17:46:25 etdemo kernel: [  221.626534] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x25
Mar 29 17:46:25 etdemo kernel: [  221.626537] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x27
Mar 29 17:46:25 etdemo kernel: [  221.626539] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x28
Mar 29 17:46:25 etdemo kernel: [  221.626542] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2a
Mar 29 17:46:25 etdemo kernel: [  221.626544] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2b
Mar 29 17:46:25 etdemo kernel: [  221.626547] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2d
Mar 29 17:46:25 etdemo kernel: [  221.626550] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2e
Mar 29 17:46:25 etdemo kernel: [  221.626552] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x30
Mar 29 17:46:25 etdemo kernel: [  221.626555] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x31
Mar 29 17:46:25 etdemo kernel: [  221.626558] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x33
Mar 29 17:46:25 etdemo kernel: [  221.626560] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x34
Mar 29 17:46:25 etdemo kernel: [  221.626563] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x36
Mar 29 17:46:25 etdemo kernel: [  221.626565] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x37
Mar 29 17:46:25 etdemo kernel: [  221.626568] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x39
Mar 29 17:46:25 etdemo kernel: [  221.626571] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3a
Mar 29 17:46:25 etdemo kernel: [  221.626573] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3c
Mar 29 17:46:25 etdemo kernel: [  221.626576] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3d
Mar 29 17:46:25 etdemo kernel: [  221.626579] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3f
Mar 29 17:46:25 etdemo kernel: [  221.626582] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x40
Mar 29 17:46:25 etdemo kernel: [  221.626584] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x42
Mar 29 17:46:25 etdemo kernel: [  221.626587] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x43
Mar 29 17:46:25 etdemo kernel: [  221.626590] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x45
Mar 29 17:46:25 etdemo kernel: [  221.626592] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x46
Mar 29 17:46:25 etdemo kernel: [  221.626599] [2163:2163:c/r:checkpoint_memory_contents:458] collected 48 pages
Mar 29 17:46:25 etdemo kernel: [  221.626602] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:25 etdemo kernel: [  221.626610] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 196808
Mar 29 17:46:25 etdemo kernel: [  221.627030] [2163:2163:c/r:pgarr_release_pages:102] total pages 48
Mar 29 17:46:25 etdemo kernel: [  221.627034] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:25 etdemo kernel: [  221.627044] [2163:2163:c/r:ckpt_obj_lookup_add:804] INODE objref 9 first 1
Mar 29 17:46:25 etdemo kernel: [  221.627048] [2163:2163:c/r:fill_ipc_shm_hdr:74] shm: cprid 1735 lprid 1410 segsz 393216 mlock -1
Mar 29 17:46:25 etdemo kernel: [  221.627050] [2163:2163:c/r:checkpoint_ipc_shm:111] shm: objref 9
Mar 29 17:46:25 etdemo kernel: [  221.627052] [2163:2163:c/r:ckpt_write_obj:41] type 502 len 120
Mar 29 17:46:25 etdemo kernel: [  221.627063] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x0
Mar 29 17:46:25 etdemo kernel: [  221.627065] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1
Mar 29 17:46:25 etdemo kernel: [  221.627069] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3
Mar 29 17:46:25 etdemo kernel: [  221.627071] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4
Mar 29 17:46:25 etdemo kernel: [  221.627074] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x6
Mar 29 17:46:25 etdemo kernel: [  221.627076] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x7
Mar 29 17:46:26 etdemo kernel: [  221.627079] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x9
Mar 29 17:46:26 etdemo kernel: [  221.627081] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xa
Mar 29 17:46:26 etdemo kernel: [  221.627084] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xc
Mar 29 17:46:26 etdemo kernel: [  221.627087] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xd
Mar 29 17:46:26 etdemo kernel: [  221.627089] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xf
Mar 29 17:46:26 etdemo kernel: [  221.627092] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x10
Mar 29 17:46:26 etdemo kernel: [  221.627101] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x12
Mar 29 17:46:26 etdemo kernel: [  221.627104] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x13
Mar 29 17:46:26 etdemo kernel: [  221.627106] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x15
Mar 29 17:46:26 etdemo kernel: [  221.627109] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x16
Mar 29 17:46:26 etdemo kernel: [  221.627112] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x18
Mar 29 17:46:26 etdemo kernel: [  221.627114] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x19
Mar 29 17:46:26 etdemo kernel: [  221.627117] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1b
Mar 29 17:46:26 etdemo kernel: [  221.627119] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1c
Mar 29 17:46:26 etdemo kernel: [  221.627133] [2163:2163:c/r:checkpoint_memory_contents:458] collected 20 pages
Mar 29 17:46:26 etdemo kernel: [  221.627136] [2163:2163:c/r:ckpt_write_obj:41] typ
Mar 29 17:46:26 etdemo kernel: 0 2<0 idrr:ml_r: ag7  62]3::cvilg32got pagagx727]  1.2 2.6
Mar 29 17:46:26 etdemo kernel: priitgarr:25t 07>270211r:fga25t 0<7 621]116/ralrr5]te e[ 166 [21631c/vmf_prr2gop 01
Mar 29 17:46:26 etdemo kernel: >222] _f_r:]   0
Mar 29 17:46:26 etdemo kernel: <.602121cmallar2otge5>[161:cmalr: ag9
Mar 29 17:46:26 etdemo kernel: 63]3:3:vfip:3 gp0x< 2 p160es 26
Mar 29 17:46:26 etdemo kernel: < prc/c:vila5] 7163r:__pr: 2811] [216l_pgarr:325] got page 0x31
Mar 29 17:46:26 etdemo kernel: [  221.640802] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x33
Mar 29 17:46:26 etdemo kernel: [  221.640804] [2162163:c/got page 0x12
Mar 29 17:46:26 etdemo kernel: [  2
Mar 29 17:46:26 etdemo kernel: [  221.641472] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 369008
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:pgarr_r5] got page 0x4
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x5
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x6
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x7
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x8
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x9
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xa
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xc
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xd
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xe
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xf
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x10
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x11
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x12
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x13
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x14
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x15
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x16
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x17
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x18
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x19
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1a
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1b
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1c
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1d
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1e
Mar 29 17:46:26 etdemo kernel: [  221.652042] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x1f
Mar 29 17:46:26 etdemo kernel: [  221.652926] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x20
Mar 29 17:46:26 etdemo kernel: [  221.652929] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x21
Mar 29 17:46:26 etdemo kernel: [  221.652932] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x22
Mar 29 17:46:26 etdemo kernel: [  221.652934] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x23
Mar 29 17:46:26 etdemo kernel: [  221.652937] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x24
Mar 29 17:46:26 etdemo kernel: [  221.652939] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x25
Mar 29 17:46:26 etdemo kernel: [  221.652942] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x26
Mar 29 17:46:26 etdemo kernel: [  221.652944] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x27
Mar 29 17:46:26 etdemo kernel: [  221.652946] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x28
Mar 29 17:46:26 etdemo kernel: [  221.652949] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x29
Mar 29 17:46:26 etdemo kernel: [  221.652951] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2a
Mar 29 17:46:26 etdemo kernel: [  221.652954] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2b
Mar 29 17:46:26 etdemo kernel: [  221.652956] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2c
Mar 29 17:46:26 etdemo kernel: [  221.652959] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2d
Mar 29 17:46:26 etdemo kernel: [  221.652961] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2e
Mar 29 17:46:26 etdemo kernel: [  221.652963] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x2f
Mar 29 17:46:26 etdemo kernel: [  221.652966] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x30
Mar 29 17:46:26 etdemo kernel: [  221.652968] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x31
Mar 29 17:46:26 etdemo kernel: [  221.652971] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x32
Mar 29 17:46:26 etdemo kernel: [  221.652973] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x33
Mar 29 17:46:26 etdemo kernel: [  221.652975] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x34
Mar 29 17:46:26 etdemo kernel: [  221.652978] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x35
Mar 29 17:46:26 etdemo kernel: [  221.652980] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x36
Mar 29 17:46:26 etdemo kernel: [  221.652983] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x37
Mar 29 17:46:26 etdemo kernel: [  221.652985] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x38
Mar 29 17:46:26 etdemo kernel: [  221.652988] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x39
Mar 29 17:46:26 etdemo kernel: [  221.652990] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3a
Mar 29 17:46:26 etdemo kernel: [  221.652992] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3b
Mar 29 17:46:26 etdemo kernel: [  221.652995] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3c
Mar 29 17:46:26 etdemo kernel: [  221.652997] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3d
Mar 29 17:46:26 etdemo kernel: [  221.653000] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3e
Mar 29 17:46:26 etdemo kernel: [  221.653002] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x3f
Mar 29 17:46:26 etdemo kernel: [  221.653005] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x40
Mar 29 17:46:26 etdemo kernel: [  221.653007] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x41
Mar 29 17:46:26 etdemo kernel: [  221.653010] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x42
Mar 29 17:46:26 etdemo kernel: [  221.653012] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x43
Mar 29 17:46:26 etdemo kernel: [  221.653014] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x44
Mar 29 17:46:26 etdemo kernel: [  221.653017] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x45
Mar 29 17:46:26 etdemo kernel: [  221.653019] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x46
Mar 29 17:46:26 etdemo kernel: [  221.653022] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x47
Mar 29 17:46:26 etdemo kernel: [  221.653024] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x48
Mar 29 17:46:26 etdemo kernel: [  221.653027] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x49
Mar 29 17:46:26 etdemo kernel: [  221.653029] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4a
Mar 29 17:46:26 etdemo kernel: [  221.653031] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4b
Mar 29 17:46:26 etdemo kernel: [  221.653034] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4c
Mar 29 17:46:26 etdemo kernel: [  221.653036] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4d
Mar 29 17:46:26 etdemo kernel: [  221.653039] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4e
Mar 29 17:46:26 etdemo kernel: [  221.653041] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x4f
Mar 29 17:46:26 etdemo kernel: [  221.653044] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x50
Mar 29 17:46:26 etdemo kernel: [  221.653046] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x51
Mar 29 17:46:26 etdemo kernel: [  221.653049] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x52
Mar 29 17:46:26 etdemo kernel: [  221.653051] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x53
Mar 29 17:46:26 etdemo kernel: [  221.653053] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x54
Mar 29 17:46:26 etdemo kernel: [  221.653056] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x55
Mar 29 17:46:26 etdemo kernel: [  221.653058] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x56
Mar 29 17:46:26 etdemo kernel: [  221.653061] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x57
Mar 29 17:46:26 etdemo kernel: [  221.653063] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x58
Mar 29 17:46:26 etdemo kernel: [  221.653066] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x59
Mar 29 17:46:26 etdemo kernel: [  221.653068] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x5a
Mar 29 17:46:26 etdemo kernel: [  221.653071] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x5b
Mar 29 17:46:26 etdemo kernel: [  221.653073] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x5c
Mar 29 17:46:26 etdemo kernel: [  221.653075] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x5d
Mar 29 17:46:26 etdemo kernel: [  221.653075] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x5e
Mar 29 17:46:26 etdemo kernel: [  221.653075] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x5f
Mar 29 17:46:26 etdemo kernel: [  221.653075] [2163:2163:c/r:checkpoint_memory_contents:458] collected 96 pages
Mar 29 17:46:26 etdemo kernel: [  221.653078] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.653090] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 393608
Mar 29 17:46:26 etdemo kernel: [  221.654247] [2163:2163:c/r:pgarr_release_pages:102] total pages 96
Mar 29 17:46:26 etdemo kernel: [  221.654258] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654268] [2163:2163:c/r:checkpoint_ipc_any:99] ipc-shm ret 0
Mar 29 17:46:26 etdemo kernel: [  221.654271] [2163:2163:c/r:checkpoint_ipc_any:91] ipc-msg count 0
Mar 29 17:46:26 etdemo kernel: [  221.654274] [2163:2163:c/r:ckpt_write_obj:41] type 501 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654279] [2163:2163:c/r:checkpoint_ipc_any:99] ipc-msg ret 0
Mar 29 17:46:26 etdemo kernel: [  221.654282] [2163:2163:c/r:checkpoint_ipc_any:91] ipc-sem count 4
Mar 29 17:46:26 etdemo kernel: [  221.654285] [2163:2163:c/r:ckpt_write_obj:41] type 501 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654292] [2163:2163:c/r:fill_ipc_sem_hdr:49] sem: nsems 1
Mar 29 17:46:26 etdemo kernel: [  221.654298] [2163:2163:c/r:ckpt_write_obj:41] type 505 len 88
Mar 29 17:46:26 etdemo kernel: [  221.654305] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 24
Mar 29 17:46:26 etdemo kernel: [  221.654316] [2163:2163:c/r:fill_ipc_sem_hdr:49] sem: nsems 103
Mar 29 17:46:26 etdemo kernel: [  221.654319] [2163:2163:c/r:ckpt_write_obj:41] type 505 len 88
Mar 29 17:46:26 etdemo kernel: [  221.654325] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 1656
Mar 29 17:46:26 etdemo kernel: [  221.654341] [2163:2163:c/r:fill_ipc_sem_hdr:49] sem: nsems 9
Mar 29 17:46:26 etdemo kernel: [  221.654344] [2163:2163:c/r:ckpt_write_obj:41] type 505 len 88
Mar 29 17:46:26 etdemo kernel: [  221.654349] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 152
Mar 29 17:46:26 etdemo kernel: [  221.654355] [2163:2163:c/r:fill_ipc_sem_hdr:49] sem: nsems 1
Mar 29 17:46:26 etdemo kernel: [  221.654358] [2163:2163:c/r:ckpt_write_obj:41] type 505 len 88
Mar 29 17:46:26 etdemo kernel: [  221.654363] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 24
Mar 29 17:46:26 etdemo kernel: [  221.654369] [2163:2163:c/r:checkpoint_ipc_any:99] ipc-sem ret 0
Mar 29 17:46:26 etdemo kernel: [  221.654373] [2163:2163:c/r:ckpt_write_obj:41] type 108 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654378] [2163:2163:c/r:checkpoint_task_ns:177] nsproxy: objref 5
Mar 29 17:46:26 etdemo kernel: [  221.654381] [2163:2163:c/r:ckpt_write_obj:41] type 103 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654385] [2163:2163:c/r:checkpoint_task_objs:256] ns: objref 0
Mar 29 17:46:26 etdemo kernel: [  221.654390] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654396] [2163:2163:c/r:ckpt_write_obj:41] type 301 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654401] [2163:2163:c/r:do_checkpoint_file_table:362] nfds 1
Mar 29 17:46:26 etdemo kernel: [  221.654407] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654413] [2163:2163:c/r:checkpoint_file_common:188] file test.out credref 1 secref 0
Mar 29 17:46:26 etdemo kernel: [  221.654417] [2163:2163:c/r:ckpt_write_obj:41] type 304 len 48
Mar 29 17:46:26 etdemo kernel: [  221.654425] [2163:2163:c/r:ckpt_write_obj_type:67] type 303 len 22
Mar 29 17:46:26 etdemo kernel: [  221.654432] [2163:2163:c/r:checkpoint_file_desc:320] fd 0 objref 26 file d0a66700 coe 0)
Mar 29 17:46:26 etdemo kernel: [  221.654435] [2163:2163:c/r:ckpt_write_obj:41] type 302 len 24
Mar 29 17:46:26 etdemo kernel: [  221.654441] [2163:2163:c/r:do_checkpoint_file_table:370] files_deferq ran 0 entries
Mar 29 17:46:26 etdemo kernel: [  221.654444] [2163:2163:c/r:checkpoint_task_objs:263] files: objref 25
Mar 29 17:46:26 etdemo kernel: [  221.654448] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654455] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654461] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654467] [2163:2163:c/r:do_checkpoint_cred:1046] cred uid 0 fsuid 0 gid 0 secref 0
Mar 29 17:46:26 etdemo kernel: [  221.654470] [2163:2163:c/r:ckpt_write_obj:41] type 114 len 96
Mar 29 17:46:26 etdemo kernel: [  221.654475] [2163:2163:c/r:checkpoint_file_common:188] file test credref 29 secref 0
Mar 29 17:46:26 etdemo kernel: [  221.654478] [2163:2163:c/r:ckpt_write_obj:41] type 304 len 48
Mar 29 17:46:26 etdemo kernel: [  221.654484] [2163:2163:c/r:ckpt_write_obj_type:67] type 303 len 35
Mar 29 17:46:26 etdemo kernel: [  221.654490] [2163:2163:c/r:ckpt_write_obj:41] type 401 len 120
Mar 29 17:46:26 etdemo kernel: [  221.654496] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 360
Mar 29 17:46:26 etdemo kernel: [  221.654503] [2163:2163:c/r:checkpoint_vmas:626] vma 0x8048000-0x8049000 flags 0x8001875
Mar 29 17:46:26 etdemo kernel: [  221.654508] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0x8048000-0x8049000 flags 0x8001875 type 3
Mar 29 17:46:26 etdemo kernel: [  221.654511] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654518] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654520] [2163:2163:c/r:checkpoint_vmas:626] vma 0x8049000-0x804a000 flags 0x8101871
Mar 29 17:46:26 etdemo kernel: [  221.654520] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0x8049000-0x804a000 flags 0x8101871 type 3
Mar 29 17:46:26 etdemo kernel: [  221.654520] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654520] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x8049000
Mar 29 17:46:26 etdemo kernel: [  221.654520] [2163:2163:c/r:checkpoint_memory_contents:458] collected 1 pages
Mar 29 17:46:26 etdemo kernel: [  221.654526] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654533] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 4108
Mar 29 17:46:26 etdemo kernel: [  221.654549] [2163:2163:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:26 etdemo kernel: [  221.654553] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654558] [2163:2163:c/r:checkpoint_vmas:626] vma 0x804a000-0x804b000 flags 0x8101873
Mar 29 17:46:26 etdemo kernel: [  221.654561] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0x804a000-0x804b000 flags 0x8101873 type 3
Mar 29 17:46:26 etdemo kernel: [  221.654565] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654570] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x804a000
Mar 29 17:46:26 etdemo kernel: [  221.654573] [2163:2163:c/r:checkpoint_memory_contents:458] collected 1 pages
Mar 29 17:46:26 etdemo kernel: [  221.654576] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654580] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 4108
Mar 29 17:46:26 etdemo kernel: [  221.654599] [2163:2163:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:26 etdemo kernel: [  221.654605] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654613] [2163:2163:c/r:checkpoint_vmas:626] vma 0x9ede000-0x9eff000 flags 0x100073
Mar 29 17:46:26 etdemo kernel: [  221.654616] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0x9ede000-0x9eff000 flags 0x100073 type 2
Mar 29 17:46:26 etdemo kernel: [  221.654619] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654625] [2163:2163:c/r:vma_fill_pgarr:325] got page 0x9ede000
Mar 29 17:46:26 etdemo kernel: [  221.654630] [2163:2163:c/r:checkpoint_memory_contents:458] collected 1 pages
Mar 29 17:46:26 etdemo kernel: [  221.654633] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654638] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 4108
Mar 29 17:46:26 etdemo kernel: [  221.654654] [2163:2163:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:26 etdemo kernel: [  221.654657] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654662] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7701000-0xb7702000 flags 0x100073
Mar 29 17:46:26 etdemo kernel: [  221.654666] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7701000-0xb7702000 flags 0x100073 type 2
Mar 29 17:46:26 etdemo kernel: [  221.654669] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654675] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7701000
Mar 29 17:46:26 etdemo kernel: [  221.654677] [2163:2163:c/r:checkpoint_memory_contents:458] collected 1 pages
Mar 29 17:46:26 etdemo kernel: [  221.654680] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654685] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 4108
Mar 29 17:46:26 etdemo kernel: [  221.654701] [2163:2163:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:26 etdemo kernel: [  221.654704] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654710] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7702000-0xb7840000 flags 0x8000075
Mar 29 17:46:26 etdemo kernel: [  221.654714] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654720] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654725] [2163:2163:c/r:do_checkpoint_cred:1046] cred uid 0 fsuid 0 gid 0 secref 0
Mar 29 17:46:26 etdemo kernel: [  221.654728] [2163:2163:c/r:ckpt_write_obj:41] type 114 len 96
Mar 29 17:46:26 etdemo kernel: [  221.654733] [2163:2163:c/r:checkpoint_file_common:188] file libc-2.10.1.so credref 31 secref 0
Mar 29 17:46:26 etdemo kernel: [  221.654736] [2163:2163:c/r:ckpt_write_obj:41] type 304 len 48
Mar 29 17:46:26 etdemo kernel: [  221.654741] [2163:2163:c/r:ckpt_write_obj_type:67] type 303 len 42
Mar 29 17:46:26 etdemo kernel: [  221.654748] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7702000-0xb7840000 flags 0x8000075 type 3
Mar 29 17:46:26 etdemo kernel: [  221.654752] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654786] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654792] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7840000-0xb7841000 flags 0x8000070
Mar 29 17:46:26 etdemo kernel: [  221.654795] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7840000-0xb7841000 flags 0x8000070 type 3
Mar 29 17:46:26 etdemo kernel: [  221.654798] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654804] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654809] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7841000-0xb7843000 flags 0x8100071
Mar 29 17:46:26 etdemo kernel: [  221.654811] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7841000-0xb7843000 flags 0x8100071 type 3
Mar 29 17:46:26 etdemo kernel: [  221.654811] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654811] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7841000
Mar 29 17:46:26 etdemo kernel: [  221.654811] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7842000
Mar 29 17:46:26 etdemo kernel: [  221.654811] [2163:2163:c/r:checkpoint_memory_contents:458] collected 2 pages
Mar 29 17:46:26 etdemo kernel: [  221.654813] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654823] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 8208
Mar 29 17:46:26 etdemo kernel: [  221.654871] [2163:2163:c/r:pgarr_release_pages:102] total pages 2
Mar 29 17:46:26 etdemo kernel: [  221.654874] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654880] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7843000-0xb7844000 flags 0x8100073
Mar 29 17:46:26 etdemo kernel: [  221.654883] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7843000-0xb7844000 flags 0x8100073 type 3
Mar 29 17:46:26 etdemo kernel: [  221.654887] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654892] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7843000
Mar 29 17:46:26 etdemo kernel: [  221.654895] [2163:2163:c/r:checkpoint_memory_contents:458] collected 1 pages
Mar 29 17:46:26 etdemo kernel: [  221.654898] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654903] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 4108
Mar 29 17:46:26 etdemo kernel: [  221.654920] [2163:2163:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:26 etdemo kernel: [  221.654923] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654929] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7844000-0xb7847000 flags 0x100073
Mar 29 17:46:26 etdemo kernel: [  221.654932] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7844000-0xb7847000 flags 0x100073 type 2
Mar 29 17:46:26 etdemo kernel: [  221.654935] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.654941] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7844000
Mar 29 17:46:26 etdemo kernel: [  221.654944] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7845000
Mar 29 17:46:26 etdemo kernel: [  221.654947] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7846000
Mar 29 17:46:26 etdemo kernel: [  221.654949] [2163:2163:c/r:checkpoint_memory_contents:458] collected 3 pages
Mar 29 17:46:26 etdemo kernel: [  221.654952] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.654957] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 12308
Mar 29 17:46:26 etdemo kernel: [  221.654999] [2163:2163:c/r:pgarr_release_pages:102] total pages 3
Mar 29 17:46:26 etdemo kernel: [  221.655002] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655007] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7856000-0xb7859000 flags 0x100073
Mar 29 17:46:26 etdemo kernel: [  221.655011] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7856000-0xb7859000 flags 0x100073 type 2
Mar 29 17:46:26 etdemo kernel: [  221.655014] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.655019] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7856000
Mar 29 17:46:26 etdemo kernel: [  221.655022] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7857000
Mar 29 17:46:26 etdemo kernel: [  221.655024] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7858000
Mar 29 17:46:26 etdemo kernel: [  221.655027] [2163:2163:c/r:checkpoint_memory_contents:458] collected 3 pages
Mar 29 17:46:26 etdemo kernel: [  221.655030] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655035] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 12308
Mar 29 17:46:26 etdemo kernel: [  221.655075] [2163:2163:c/r:pgarr_release_pages:102] total pages 3
Mar 29 17:46:26 etdemo kernel: [  221.655078] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655084] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7859000-0xb785a000 flags 0x4040075
Mar 29 17:46:26 etdemo kernel: [  221.655088] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7859000-0xb785a000 flags 0x4040075 type 1
Mar 29 17:46:26 etdemo kernel: [  221.655091] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.655097] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb785a000-0xb7875000 flags 0x8000875
Mar 29 17:46:26 etdemo kernel: [  221.655100] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655106] [2163:2163:c/r:checkpoint_file_common:188] file ld-2.10.1.so credref 29 secref 0
Mar 29 17:46:26 etdemo kernel: [  221.655109] [2163:2163:c/r:ckpt_write_obj:41] type 304 len 48
Mar 29 17:46:26 etdemo kernel: [  221.655115] [2163:2163:c/r:ckpt_write_obj_type:67] type 303 len 26
Mar 29 17:46:26 etdemo kernel: [  221.655121] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb785a000-0xb7875000 flags 0x8000875 type 3
Mar 29 17:46:26 etdemo kernel: [  221.655125] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.655133] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655139] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7875000-0xb7876000 flags 0x8100871
Mar 29 17:46:26 etdemo kernel: [  221.655141] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7875000-0xb7876000 flags 0x8100871 type 3
Mar 29 17:46:26 etdemo kernel: [  221.655141] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.655141] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7875000
Mar 29 17:46:26 etdemo kernel: [  221.655141] [2163:2163:c/r:checkpoint_memory_contents:458] collected 1 pages
Mar 29 17:46:26 etdemo kernel: [  221.655141] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655141] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 4108
Mar 29 17:46:26 etdemo kernel: [  221.655173] [2163:2163:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:26 etdemo kernel: [  221.655176] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655182] [2163:2163:c/r:checkpoint_vmas:626] vma 0xb7876000-0xb7877000 flags 0x8100873
Mar 29 17:46:26 etdemo kernel: [  221.655186] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xb7876000-0xb7877000 flags 0x8100873 type 3
Mar 29 17:46:26 etdemo kernel: [  221.655189] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.655194] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xb7876000
Mar 29 17:46:26 etdemo kernel: [  221.655197] [2163:2163:c/r:checkpoint_memory_contents:458] collected 1 pages
Mar 29 17:46:26 etdemo kernel: [  221.655200] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655205] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 4108
Mar 29 17:46:26 etdemo kernel: [  221.655221] [2163:2163:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:26 etdemo kernel: [  221.655224] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655229] [2163:2163:c/r:checkpoint_vmas:626] vma 0xbff57000-0xbff6c000 flags 0x100173
Mar 29 17:46:26 etdemo kernel: [  221.655233] [2163:2163:c/r:generic_vma_checkpoint:502] vma 0xbff57000-0xbff6c000 flags 0x100173 type 2
Mar 29 17:46:26 etdemo kernel: [  221.655236] [2163:2163:c/r:ckpt_write_obj:41] type 402 len 72
Mar 29 17:46:26 etdemo kernel: [  221.655243] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xbff69000
Mar 29 17:46:26 etdemo kernel: [  221.655246] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xbff6a000
Mar 29 17:46:26 etdemo kernel: [  221.655249] [2163:2163:c/r:vma_fill_pgarr:325] got page 0xbff6b000
Mar 29 17:46:26 etdemo kernel: [  221.655251] [2163:2163:c/r:checkpoint_memory_contents:458] collected 3 pages
Mar 29 17:46:26 etdemo kernel: [  221.655254] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655259] [2163:2163:c/r:ckpt_write_obj_type:67] type 4 len 12308
Mar 29 17:46:26 etdemo kernel: [  221.655293] [2163:2163:c/r:pgarr_release_pages:102] total pages 3
Mar 29 17:46:26 etdemo kernel: [  221.655297] [2163:2163:c/r:ckpt_write_obj:41] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655303] [2163:2163:c/r:checkpoint_mm_context:228] nldt 0 vdso 0xb7859000
Mar 29 17:46:26 etdemo kernel: [  221.655306] [2163:2163:c/r:ckpt_write_obj:41] type 404 len 24
Mar 29 17:46:26 etdemo kernel: [  221.655310] [2163:2163:c/r:ckpt_write_obj_type:67] type 202 len 8
Mar 29 17:46:26 etdemo kernel: [  221.655315] [2163:2163:c/r:checkpoint_task_objs:270] mm: objref 27
Mar 29 17:46:26 etdemo kernel: [  221.655319] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655324] [2163:2163:c/r:ckpt_write_obj:41] type 451 len 8
Mar 29 17:46:26 etdemo kernel: [  221.655330] [2163:2163:c/r:ckpt_write_obj_type:67] type 303 len 30
Mar 29 17:46:26 etdemo kernel: [  221.655336] [2163:2163:c/r:ckpt_write_obj_type:67] type 303 len 10
Mar 29 17:46:26 etdemo kernel: [  221.655345] [2163:2163:c/r:ckpt_write_obj:41] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655352] [2163:2163:c/r:ckpt_write_obj:41] type 601 len 2056
Mar 29 17:46:26 etdemo kernel: [  221.655363] [2163:2163:c/r:checkpoint_task_objs:284] sighand: objref 34
Mar 29 17:46:26 etdemo kernel: [  221.655367] [2163:2163:c/r:ckpt_obj_lookup_add:804] SIGNAL objref 35 first 1
Mar 29 17:46:26 etdemo kernel: [  221.655369] [2163:2163:c/r:checkpoint_task_objs:299] signal: objref 35
Mar 29 17:46:26 etdemo kernel: [  221.655372] [2163:2163:c/r:ckpt_write_obj:41] type 104 len 32
Mar 29 17:46:26 etdemo kernel: [  221.655379] [2163:2163:c/r:ckpt_write_obj:41] type 602 len 328
Mar 29 17:46:26 etdemo kernel: [  221.655384] [2163:2163:c/r:ckpt_write_obj:41] type 604 len 24
Mar 29 17:46:26 etdemo kernel: [  221.655389] [2163:2163:c/r:checkpoint_task:466] objs 0
Mar 29 17:46:26 etdemo kernel: [  221.655392] [2163:2163:c/r:ckpt_write_obj:41] type 604 len 24
Mar 29 17:46:26 etdemo kernel: [  221.655397] [2163:2163:c/r:ckpt_write_obj:41] type 603 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655402] [2163:2163:c/r:checkpoint_task:470] task-signal 0
Mar 29 17:46:26 etdemo kernel: [  221.655406] [2163:2163:c/r:ckpt_write_obj:41] type 9001 len 16
Mar 29 17:46:26 etdemo kernel: [  221.655423] [2163:2163:c/r:pgarr_release_pages:102] total pages 0
Mar 29 17:46:26 etdemo kernel: [  221.811447] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 1 len 72
Mar 29 17:46:26 etdemo kernel: [  221.811453] [2168:1:c/r:ckpt_read_obj:386] type 1 len 72(72,72)
Mar 29 17:46:26 etdemo kernel: [  221.811459] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 4 len 73
Mar 29 17:46:26 etdemo kernel: [  221.811462] [2168:1:c/r:_ckpt_read_obj:290] type 4 len 73(73,73)
Mar 29 17:46:26 etdemo kernel: [  221.811469] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 4 len 73
Mar 29 17:46:26 etdemo kernel: [  221.811472] [2168:1:c/r:_ckpt_read_obj:290] type 4 len 73(73,73)
Mar 29 17:46:26 etdemo kernel: [  221.811475] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 4 len 73
Mar 29 17:46:26 etdemo kernel: [  221.811478] [2168:1:c/r:_ckpt_read_obj:290] type 4 len 73(73,73)
Mar 29 17:46:26 etdemo kernel: [  221.811482] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 2 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811485] [2168:1:c/r:ckpt_read_obj:386] type 2 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.811490] [2168:1:c/r:do_restore_coord:1228] restore header: 0
Mar 29 17:46:26 etdemo kernel: [  221.811493] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 3 len 8
Mar 29 17:46:26 etdemo kernel: [  221.811496] [2168:1:c/r:ckpt_read_obj:386] type 3 len 8(8,8)
Mar 29 17:46:26 etdemo kernel: [  221.811499] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 4 len 19
Mar 29 17:46:26 etdemo kernel: [  221.811502] [2168:1:c/r:_ckpt_read_obj:290] type 4 len 19(19,19)
Mar 29 17:46:26 etdemo kernel: [  221.811506] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 7 len 13
Mar 29 17:46:26 etdemo kernel: [  221.811509] [2168:1:c/r:ckpt_read_obj:386] type 7 len 13(0,208)
Mar 29 17:46:26 etdemo kernel: [  221.811512] [2168:1:c/r:do_restore_coord:1232] restore container: 0
Mar 29 17:46:26 etdemo kernel: [  221.811515] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 101 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811518] [2168:1:c/r:ckpt_read_obj:386] type 101 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.811522] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 4 len 32
Mar 29 17:46:26 etdemo kernel: [  221.811524] [2168:1:c/r:_ckpt_read_obj:290] type 4 len 32(32,32)
Mar 29 17:46:26 etdemo kernel: [  221.811529] [2168:1:c/r:do_restore_coord:1236] restore tree: 24
Mar 29 17:46:26 etdemo kernel: [  221.811532] [2168:1:c/r:__prepare_descendants:1074] consider task 2156
Mar 29 17:46:26 etdemo kernel: [  221.811535] [2168:1:c/r:__prepare_descendants:1099] prepare task 2156
Mar 29 17:46:26 etdemo kernel: [  221.811539] [2168:1:c/r:walk_task_subtree:625] total 1 ret 1
Mar 29 17:46:26 etdemo kernel: [  221.811542] [2168:1:c/r:prepare_descendants:1120] nr 1/1
Mar 29 17:46:26 etdemo kernel: [  221.811544] [2168:1:c/r:do_restore_coord:1280] restore prepare: 1
Mar 29 17:46:26 etdemo kernel: [  221.811572] [2169:2156:c/r:wait_task_active:876] pid 2156 waiting
Mar 29 17:46:26 etdemo kernel: [  221.811576] [2169:2156:c/r:wait_task_active:881] active 0 < 1 (ret 0, errno 0)
Mar 29 17:46:26 etdemo kernel: [  221.811581] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 102 len 64
Mar 29 17:46:26 etdemo kernel: [  221.811584] [2169:2156:c/r:ckpt_read_obj:386] type 102 len 64(64,64)
Mar 29 17:46:26 etdemo kernel: [  221.811588] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 5 len 24
Mar 29 17:46:26 etdemo kernel: [  221.811591] [2169:2156:c/r:_ckpt_read_obj:290] type 5 len 24(24,24)
Mar 29 17:46:26 etdemo kernel: [  221.811594] [2169:2156:c/r:restore_task:893] task 0
Mar 29 17:46:26 etdemo kernel: [  221.811597] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 106 len 40
Mar 29 17:46:26 etdemo kernel: [  221.811600] [2169:2156:c/r:ckpt_read_obj:386] type 106 len 40(40,40)
Mar 29 17:46:26 etdemo kernel: [  221.811604] [2169:2156:c/r:restore_task:905] thread 0
Mar 29 17:46:26 etdemo kernel: [  221.811607] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 105 len 56
Mar 29 17:46:26 etdemo kernel: [  221.811610] [2169:2156:c/r:ckpt_read_obj:386] type 105 len 56(56,56)
Mar 29 17:46:26 etdemo kernel: [  221.811614] [2169:2156:c/r:restore_restart_block:721] restart_block: expire 222724011379 begin 221803626455
Mar 29 17:46:26 etdemo kernel: [  221.811618] [2169:2156:c/r:restore_restart_block:723] restart_block: args 0x1 0xbff6a104 0x0 0x0 0x36dbf59c
Mar 29 17:46:26 etdemo kernel: [  221.811621] [2169:2156:c/r:restore_task:909] restart-blocks 0
Mar 29 17:46:26 etdemo kernel: [  221.811624] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 107 len 192
Mar 29 17:46:26 etdemo kernel: [  221.811627] [2169:2156:c/r:ckpt_read_obj:386] type 107 len 192(192,192)
Mar 29 17:46:26 etdemo kernel: [  221.811631] [2169:2156:c/r:restore_cpu:425] math 0
Mar 29 17:46:26 etdemo kernel: [  221.811634] [2169:2156:c/r:restore_task:913] cpu 0
Mar 29 17:46:26 etdemo kernel: [  221.811636] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811639] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:26 etdemo kernel: [  221.811643] [2169:2156:c/r:restore_obj:1053] len 16 ref 1 type 13
Mar 29 17:46:26 etdemo kernel: [  221.811647] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811650] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:26 etdemo kernel: [  221.811653] [2169:2156:c/r:restore_obj:1053] len 16 ref 2 type 15
Mar 29 17:46:26 etdemo kernel: [  221.811656] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 116 len 20
Mar 29 17:46:26 etdemo kernel: [  221.811659] [2169:2156:c/r:ckpt_read_obj:386] type 116 len 20(0,262168)
Mar 29 17:46:26 etdemo kernel: [  221.811664] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811667] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:26 etdemo kernel: [  221.811671] [2169:2156:c/r:restore_obj:1053] len 16 ref 3 type 14
Mar 29 17:46:26 etdemo kernel: [  221.811674] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811677] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:26 etdemo kernel: [  221.811679] [2169:2156:c/r:restore_obj:1053] len 16 ref 4 type 12
Mar 29 17:46:26 etdemo kernel: [  221.811679] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 113 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811680] [2169:2156:c/r:ckpt_read_obj:386] type 113 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.811687] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 115 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811690] [2169:2156:c/r:ckpt_read_obj:386] type 115 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.811694] [2169:2156:c/r:ckpt_obj_try_fetch:1132] USER_NS ref 4
Mar 29 17:46:26 etdemo kernel: [  221.811698] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 114 len 96
Mar 29 17:46:26 etdemo kernel: [  221.811701] [2169:2156:c/r:ckpt_read_obj:386] type 114 len 96(96,96)
Mar 29 17:46:26 etdemo kernel: [  221.811706] [2169:2156:c/r:ckpt_obj_try_fetch:1132] GROUPINFO ref 2
Mar 29 17:46:26 etdemo kernel: [  221.811708] [2169:2156:c/r:ckpt_obj_try_fetch:1132] USER ref 3
Mar 29 17:46:26 etdemo kernel: [  221.811714] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 117 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811717] [2169:2156:c/r:ckpt_read_obj:386] type 117 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.811721] [2169:2156:c/r:ckpt_obj_try_fetch:1132] CRED ref 1
Mar 29 17:46:26 etdemo kernel: [  221.811723] [2169:2156:c/r:ckpt_obj_try_fetch:1132] CRED ref 1
Mar 29 17:46:26 etdemo kernel: [  221.811726] [2169:2156:c/r:restore_task_creds:618] Returning 0
Mar 29 17:46:26 etdemo kernel: [  221.811729] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811731] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:26 etdemo kernel: [  221.811734] [2169:2156:c/r:restore_obj:1053] len 16 ref 5 type 8
Mar 29 17:46:26 etdemo kernel: [  221.811738] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811741] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:26 etdemo kernel: [  221.811744] [2169:2156:c/r:restore_obj:1053] len 16 ref 6 type 9
Mar 29 17:46:26 etdemo kernel: [  221.811747] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 109 len 400
Mar 29 17:46:26 etdemo kernel: [  221.811750] [2169:2156:c/r:ckpt_read_obj:386] type 109 len 400(400,400)
Mar 29 17:46:26 etdemo kernel: [  221.811755] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811758] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:26 etdemo kernel: [  221.811761] [2169:2156:c/r:restore_obj:1053] len 16 ref 7 type 10
Mar 29 17:46:26 etdemo kernel: [  221.811765] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 110 len 56
Mar 29 17:46:26 etdemo kernel: [  221.811768] [2169:2156:c/r:ckpt_read_obj:386] type 110 len 56(56,56)
Mar 29 17:46:26 etdemo kernel: [  221.811885] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 501 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811888] [2169:2156:c/r:ckpt_read_obj:386] type 501 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.811892] [2169:2156:c/r:restore_ipc_any:257] ipc-shm: count 17
Mar 29 17:46:26 etdemo kernel: [  221.811896] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:26 etdemo kernel: [  221.811899] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:26 etdemo kernel: [  221.811903] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 131072
Mar 29 17:46:26 etdemo kernel: [  221.811916] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 131072
Mar 29 17:46:26 etdemo kernel: [  221.811920] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1735 lprid 1410 segsz 393216 mlock -1
Mar 29 17:46:26 etdemo kernel: [  221.811924] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 8
Mar 29 17:46:26 etdemo kernel: [  221.811927] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.811930] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.811934] [2169:2156:c/r:restore_memory_contents:962] total pages 48
Mar 29 17:46:26 etdemo kernel: [  221.811937] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 196808
Mar 29 17:46:26 etdemo kernel: [  221.811941] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 196808(196808,196808)
Mar 29 17:46:26 etdemo kernel: [  221.811945] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:26 etdemo kernel: [  221.811958] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:26 etdemo kernel: [  221.811965] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:26 etdemo kernel: [  221.811972] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:26 etdemo kernel: [  221.811978] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:26 etdemo kernel: [  221.811984] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:26 etdemo kernel: [  221.811991] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:26 etdemo kernel: [  221.811997] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:26 etdemo kernel: [  221.812005] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:26 etdemo kernel: [  221.812012] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:26 etdemo kernel: [  221.812018] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:26 etdemo kernel: [  221.812024] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:26 etdemo kernel: [  221.812032] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:26 etdemo kernel: [  221.812038] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:26 etdemo kernel: [  221.812045] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:26 etdemo kernel: [  221.812051] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:26 etdemo kernel: [  221.812256] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:26 etdemo kernel: [  221.812272] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:26 etdemo kernel: [  221.812279] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:26 etdemo kernel: [  221.812286] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:26 etdemo kernel: [  221.812293] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:26 etdemo kernel: [  221.812303] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:26 etdemo kernel: [  221.812310] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:26 etdemo kernel: [  221.812317] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:26 etdemo kernel: [  221.812323] [2169:2156:c/r:read_pages_contents:919] got page 0x24
Mar 29 17:46:26 etdemo kernel: [  221.812329] [2169:2156:c/r:read_pages_contents:919] got page 0x25
Mar 29 17:46:26 etdemo kernel: [  221.812336] [2169:2156:c/r:read_pages_contents:919] got page 0x27
Mar 29 17:46:26 etdemo kernel: [  221.812343] [2169:2156:c/r:read_pages_contents:919] got page 0x28
Mar 29 17:46:26 etdemo kernel: [  221.812350] [2169:2156:c/r:read_pages_contents:919] got page 0x2a
Mar 29 17:46:26 etdemo kernel: [  221.812356] [2169:2156:c/r:read_pages_contents:919] got page 0x2b
Mar 29 17:46:26 etdemo kernel: [  221.812363] [2169:2156:c/r:read_pages_contents:919] got page 0x2d
Mar 29 17:46:26 etdemo kernel: [  221.812369] [2169:2156:c/r:read_pages_contents:919] got page 0x2e
Mar 29 17:46:26 etdemo kernel: [  221.812713] [2169:2156:c/r:read_pages_contents:919] got page 0x30
Mar 29 17:46:26 etdemo kernel: [  221.812721] [2169:2156:c/r:read_pages_contents:919] got page 0x31
Mar 29 17:46:26 etdemo kernel: [  221.812728] [2169:2156:c/r:read_pages_contents:919] got page 0x33
Mar 29 17:46:26 etdemo kernel: [  221.812734] [2169:2156:c/r:read_pages_contents:919] got page 0x34
Mar 29 17:46:26 etdemo kernel: [  221.812742] [2169:2156:c/r:read_pages_contents:919] got page 0x36
Mar 29 17:46:26 etdemo kernel: [  221.812748] [2169:2156:c/r:read_pages_contents:919] got page 0x37
Mar 29 17:46:26 etdemo kernel: [  221.812755] [2169:2156:c/r:read_pages_contents:919] got page 0x39
Mar 29 17:46:26 etdemo kernel: [  221.812761] [2169:2156:c/r:read_pages_contents:919] got page 0x3a
Mar 29 17:46:26 etdemo kernel: [  221.812767] [2169:2156:c/r:read_pages_contents:919] got page 0x3c
Mar 29 17:46:26 etdemo kernel: [  221.812774] [2169:2156:c/r:read_pages_contents:919] got page 0x3d
Mar 29 17:46:26 etdemo kernel: [  221.812780] [2169:2156:c/r:read_pages_contents:919] got page 0x3f
Mar 29 17:46:26 etdemo kernel: [  221.812787] [2169:2156:c/r:read_pages_contents:919] got page 0x40
Mar 29 17:46:26 etdemo kernel: [  221.812793] [2169:2156:c/r:read_pages_contents:919] got page 0x42
Mar 29 17:46:26 etdemo kernel: [  221.812800] [2169:2156:c/r:read_pages_contents:919] got page 0x43
Mar 29 17:46:26 etdemo kernel: [  221.812807] [2169:2156:c/r:read_pages_contents:919] got page 0x45
Mar 29 17:46:26 etdemo kernel: [  221.812813] [2169:2156:c/r:read_pages_contents:919] got page 0x46
Mar 29 17:46:26 etdemo kernel: [  221.813207] [2169:2156:c/r:pgarr_release_pages:102] total pages 48
Mar 29 17:46:26 etdemo kernel: [  221.813213] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.813216] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.813220] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:26 etdemo kernel: [  221.813226] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:26 etdemo kernel: [  221.813229] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:26 etdemo kernel: [  221.813233] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 163841
Mar 29 17:46:26 etdemo kernel: [  221.813246] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 163841
Mar 29 17:46:26 etdemo kernel: [  221.813250] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1735 lprid 1410 segsz 393216 mlock -1
Mar 29 17:46:26 etdemo kernel: [  221.813254] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 9
Mar 29 17:46:26 etdemo kernel: [  221.813257] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.813260] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.813264] [2169:2156:c/r:restore_memory_contents:962] total pages 20
Mar 29 17:46:26 etdemo kernel: [  221.813267] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 82008
Mar 29 17:46:26 etdemo kernel: [  221.813270] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 82008(82008,82008)
Mar 29 17:46:26 etdemo kernel: [  221.813273] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:26 etdemo kernel: [  221.813283] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:26 etdemo kernel: [  221.813292] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:26 etdemo kernel: [  221.813299] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:26 etdemo kernel: [  221.813309] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:26 etdemo kernel: [  221.813309] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:26 etdemo kernel: [  221.813317] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:26 etdemo kernel: [  221.813327] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:26 etdemo kernel: [  221.813334] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:26 etdemo kernel: [  221.813341] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:26 etdemo kernel: [  221.813347] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:26 etdemo kernel: [  221.813353] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:26 etdemo kernel: [  221.813361] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:26 etdemo kernel: [  221.813368] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:26 etdemo kernel: [  221.813374] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:26 etdemo kernel: [  221.813380] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:26 etdemo kernel: [  221.813795] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:26 etdemo kernel: [  221.813804] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:26 etdemo kernel: [  221.813811] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:26 etdemo kernel: [  221.813818] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:26 etdemo kernel: [  221.813824] [2169:2156:c/r:pgarr_release_pages:102] total pages 20
Mar 29 17:46:26 etdemo kernel: [  221.813827] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.813830] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.813834] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:26 etdemo kernel: [  221.813838] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:26 etdemo kernel: [  221.813841] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:26 etdemo kernel: [  221.813845] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 393218
Mar 29 17:46:26 etdemo kernel: [  221.813852] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 393218
Mar 29 17:46:26 etdemo kernel: [  221.813855] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1958 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:26 etdemo kernel: [  221.813859] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 10
Mar 29 17:46:26 etdemo kernel: [  221.813862] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.813865] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.813868] [2169:2156:c/r:restore_memory_contents:962] total pages 23
Mar 29 17:46:26 etdemo kernel: [  221.813872] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 94308
Mar 29 17:46:26 etdemo kernel: [  221.813875] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 94308(94308,94308)
Mar 29 17:46:26 etdemo kernel: [  221.813878] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:26 etdemo kernel: [  221.813884] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:26 etdemo kernel: [  221.813891] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:26 etdemo kernel: [  221.813897] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:26 etdemo kernel: [  221.813903] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:26 etdemo kernel: [  221.813909] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:26 etdemo kernel: [  221.813915] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:26 etdemo kernel: [  221.813921] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:26 etdemo kernel: [  221.813927] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:26 etdemo kernel: [  221.813932] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:26 etdemo kernel: [  221.813940] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:26 etdemo kernel: [  221.813946] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:26 etdemo kernel: [  221.814399] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:26 etdemo kernel: [  221.814408] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:26 etdemo kernel: [  221.814414] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:26 etdemo kernel: [  221.814422] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:26 etdemo kernel: [  221.814428] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:26 etdemo kernel: [  221.814434] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:26 etdemo kernel: [  221.814440] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:26 etdemo kernel: [  221.814446] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:26 etdemo kernel: [  221.814452] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:26 etdemo kernel: [  221.814458] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:26 etdemo kernel: [  221.814464] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:26 etdemo kernel: [  221.814470] [2169:2156:c/r:pgarr_release_pages:102] total pages 23
Mar 29 17:46:26 etdemo kernel: [  221.814474] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.814476] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.814477] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:26 etdemo kernel: [  221.814484] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:26 etdemo kernel: [  221.814487] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:26 etdemo kernel: [  221.814491] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 425987
Mar 29 17:46:26 etdemo kernel: [  221.814499] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 425987
Mar 29 17:46:26 etdemo kernel: [  221.814502] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1945 lprid 2000 segsz 393216 mlock -1
Mar 29 17:46:26 etdemo kernel: [  221.814506] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 11
Mar 29 17:46:26 etdemo kernel: [  221.814509] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:26 etdemo kernel: [  221.814512] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:26 etdemo kernel: [  221.814516] [2169:2156:c/r:restore_memory_contents:962] total pages 96
Mar 29 17:46:26 etdemo kernel: [  221.814519] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 393608
Mar 29 17:46:26 etdemo kernel: [  221.814522] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 393608(393608,393608)
Mar 29 17:46:26 etdemo kernel: [  221.814525] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:26 etdemo kernel: [  221.814534] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:26 etdemo kernel: [  221.814541] [2169:2156:c/r:read_pages_contents:919] got page 0x2
Mar 29 17:46:26 etdemo kernel: [  221.814550] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:26 etdemo kernel: [  221.814555] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:26 etdemo kernel: [  221.814988] [2169:2156:c/r:read_pages_contents:919] got page 0x5
Mar 29 17:46:26 etdemo kernel: [  221.815031] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:26 etdemo kernel: [  221.815094] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:26 etdemo kernel: [  221.815170] [2169:2156:c/r:read_pages_contents:919] got page 0x8
Mar 29 17:46:26 etdemo kernel: [  221.815288] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:26 etdemo kernel: [  221.815480] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:26 etdemo kernel: [  221.815524] [2169:2156:c/r:read_pages_contents:919] got page 0xb
Mar 29 17:46:26 etdemo kernel: [  221.815807] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:26 etdemo kernel: [  221.815833] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.815869] [2169:2156:c/r:read_pages_contents:919] got page 0xe
Mar 29 17:46:27 etdemo kernel: [  221.815896] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.815920] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.815947] [2169:2156:c/r:read_pages_contents:919] got page 0x11
Mar 29 17:46:27 etdemo kernel: [  221.816089] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.816175] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.816237] [2169:2156:c/r:read_pages_contents:919] got page 0x14
Mar 29 17:46:27 etdemo kernel: [  221.816281] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.816352] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.816416] [2169:2156:c/r:read_pages_contents:919] got page 0x17
Mar 29 17:46:27 etdemo kernel: [  221.816459] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.816521] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.816591] [2169:2156:c/r:read_pages_contents:919] got page 0x1a
Mar 29 17:46:27 etdemo kernel: [  221.816653] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.816715] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.816779] [2169:2156:c/r:read_pages_contents:919] got page 0x1d
Mar 29 17:46:27 etdemo kernel: [  221.817003] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.817066] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.817110] [2169:2156:c/r:read_pages_contents:919] got page 0x20
Mar 29 17:46:27 etdemo kernel: [  221.817173] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:27 etdemo kernel: [  221.817245] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:27 etdemo kernel: [  221.817307] [2169:2156:c/r:read_pages_contents:919] got page 0x23
Mar 29 17:46:27 etdemo kernel: [  221.817501] [2169:2156:c/r:read_pages_contents:919] got page 0x24
Mar 29 17:46:27 etdemo kernel: [  221.817525] [2169:2156:c/r:read_pages_contents:919] got page 0x25
Mar 29 17:46:27 etdemo kernel: [  221.817599] [2169:2156:c/r:read_pages_contents:919] got page 0x26
Mar 29 17:46:27 etdemo kernel: [  221.817662] [2169:2156:c/r:read_pages_contents:919] got page 0x27
Mar 29 17:46:27 etdemo kernel: [  221.817724] [2169:2156:c/r:read_pages_contents:919] got page 0x28
Mar 29 17:46:27 etdemo kernel: [  221.817767] [2169:2156:c/r:read_pages_contents:919] got page 0x29
Mar 29 17:46:27 etdemo kernel: [  221.817868] [2169:2156:c/r:read_pages_contents:919] got page 0x2a
Mar 29 17:46:27 etdemo kernel: [  221.817932] [2169:2156:c/r:read_pages_contents:919] got page 0x2b
Mar 29 17:46:27 etdemo kernel: [  221.817975] [2169:2156:c/r:read_pages_contents:919] got page 0x2c
Mar 29 17:46:27 etdemo kernel: [  221.818036] [2169:2156:c/r:read_pages_contents:919] got page 0x2d
Mar 29 17:46:27 etdemo kernel: [  221.818107] [2169:2156:c/r:read_pages_contents:919] got page 0x2e
Mar 29 17:46:27 etdemo kernel: [  221.818150] [2169:2156:c/r:read_pages_contents:919] got page 0x2f
Mar 29 17:46:27 etdemo kernel: [  221.818211] [2169:2156:c/r:read_pages_contents:919] got page 0x30
Mar 29 17:46:27 etdemo kernel: [  221.818352] [2169:2156:c/r:read_pages_contents:919] got page 0x31
Mar 29 17:46:27 etdemo kernel: [  221.818388] [2169:2156:c/r:read_pages_contents:919] got page 0x32
Mar 29 17:46:27 etdemo kernel: [  221.818412] [2169:2156:c/r:read_pages_contents:919] got page 0x33
Mar 29 17:46:27 etdemo kernel: [  221.818475] [2169:2156:c/r:read_pages_contents:919] got page 0x34
Mar 29 17:46:27 etdemo kernel: [  221.818522] [2169:2156:c/r:read_pages_contents:919] got page 0x35
Mar 29 17:46:27 etdemo kernel: [  221.818593] [2169:2156:c/r:read_pages_contents:919] got page 0x36
Mar 29 17:46:27 etdemo kernel: [  221.818655] [2169:2156:c/r:read_pages_contents:919] got page 0x37
Mar 29 17:46:27 etdemo kernel: [  221.818698] [2169:2156:c/r:read_pages_contents:919] got page 0x38
Mar 29 17:46:27 etdemo kernel: [  221.818762] [2169:2156:c/r:read_pages_contents:919] got page 0x39
Mar 29 17:46:27 etdemo kernel: [  221.818833] [2169:2156:c/r:read_pages_contents:919] got page 0x3a
Mar 29 17:46:27 etdemo kernel: [  221.818894] [2169:2156:c/r:read_pages_contents:919] got page 0x3b
Mar 29 17:46:27 etdemo kernel: [  221.818937] [2169:2156:c/r:read_pages_contents:919] got page 0x3c
Mar 29 17:46:27 etdemo kernel: [  221.818998] [2169:2156:c/r:read_pages_contents:919] got page 0x3d
Mar 29 17:46:27 etdemo kernel: [  221.819068] [2169:2156:c/r:read_pages_contents:919] got page 0x3e
Mar 29 17:46:27 etdemo kernel: [  221.819111] [2169:2156:c/r:read_pages_contents:919] got page 0x3f
Mar 29 17:46:27 etdemo kernel: [  221.819172] [2169:2156:c/r:read_pages_contents:919] got page 0x40
Mar 29 17:46:27 etdemo kernel: [  221.819216] [2169:2156:c/r:read_pages_contents:919] got page 0x41
Mar 29 17:46:27 etdemo kernel: [  221.819287] [2169:2156:c/r:read_pages_contents:919] got page 0x42
Mar 29 17:46:27 etdemo kernel: [  221.819348] [2169:2156:c/r:read_pages_contents:919] got page 0x43
Mar 29 17:46:27 etdemo kernel: [  221.819391] [2169:2156:c/r:read_pages_contents:919] got page 0x44
Mar 29 17:46:27 etdemo kernel: [  221.819452] [2169:2156:c/r:read_pages_contents:919] got page 0x45
Mar 29 17:46:27 etdemo kernel: [  221.819521] [2169:2156:c/r:read_pages_contents:919] got page 0x46
Mar 29 17:46:27 etdemo kernel: [  221.819566] [2169:2156:c/r:read_pages_contents:919] got page 0x47
Mar 29 17:46:27 etdemo kernel: [  221.819627] [2169:2156:c/r:read_pages_contents:919] got page 0x48
Mar 29 17:46:27 etdemo kernel: [  221.819688] [2169:2156:c/r:read_pages_contents:919] got page 0x49
Mar 29 17:46:27 etdemo kernel: [  221.819739] [2169:2156:c/r:read_pages_contents:919] got page 0x4a
Mar 29 17:46:27 etdemo kernel: [  221.819800] [2169:2156:c/r:read_pages_contents:919] got page 0x4b
Mar 29 17:46:27 etdemo kernel: [  221.819843] [2169:2156:c/r:read_pages_contents:919] got page 0x4c
Mar 29 17:46:27 etdemo kernel: [  221.819904] [2169:2156:c/r:read_pages_contents:919] got page 0x4d
Mar 29 17:46:27 etdemo kernel: [  221.820087] [2169:2156:c/r:read_pages_contents:919] got page 0x4e
Mar 29 17:46:27 etdemo kernel: [  221.820254] [2169:2156:c/r:read_pages_contents:919] got page 0x4f
Mar 29 17:46:27 etdemo kernel: [  221.820297] [2169:2156:c/r:read_pages_contents:919] got page 0x50
Mar 29 17:46:27 etdemo kernel: [  221.820360] [2169:2156:c/r:read_pages_contents:919] got page 0x51
Mar 29 17:46:27 etdemo kernel: [  221.820456] [2169:2156:c/r:read_pages_contents:919] got page 0x52
Mar 29 17:46:27 etdemo kernel: [  221.820500] [2169:2156:c/r:read_pages_contents:919] got page 0x53
Mar 29 17:46:27 etdemo kernel: [  221.820565] [2169:2156:c/r:read_pages_contents:919] got page 0x54
Mar 29 17:46:27 etdemo kernel: [  221.820629] [2169:2156:c/r:read_pages_contents:919] got page 0x55
Mar 29 17:46:27 etdemo kernel: [  221.820701] [2169:2156:c/r:read_pages_contents:919] got page 0x56
Mar 29 17:46:27 etdemo kernel: [  221.820744] [2169:2156:c/r:read_pages_contents:919] got page 0x57
Mar 29 17:46:27 etdemo kernel: [  221.820806] [2169:2156:c/r:read_pages_contents:919] got page 0x58
Mar 29 17:46:27 etdemo kernel: [  221.820869] [2169:2156:c/r:read_pages_contents:919] got page 0x59
Mar 29 17:46:27 etdemo kernel: [  221.820921] [2169:2156:c/r:read_pages_contents:919] got page 0x5a
Mar 29 17:46:27 etdemo kernel: [  221.820983] [2169:2156:c/r:read_pages_contents:919] got page 0x5b
Mar 29 17:46:27 etdemo kernel: [  221.821046] [2169:2156:c/r:read_pages_contents:919] got page 0x5c
Mar 29 17:46:27 etdemo kernel: [  221.821090] [2169:2156:c/r:read_pages_contents:919] got page 0x5d
Mar 29 17:46:27 etdemo kernel: [  221.821174] [2169:2156:c/r:read_pages_contents:919] got page 0x5e
Mar 29 17:46:27 etdemo kernel: [  221.821237] [2169:2156:c/r:read_pages_contents:919] got page 0x5f
Mar 29 17:46:27 etdemo kernel: [  221.821281] [2169:2156:c/r:pgarr_release_pages:102] total pages 96
Mar 29 17:46:27 etdemo kernel: [  221.821339] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.821342] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.821355] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.821361] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.821364] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.821369] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 262148
Mar 29 17:46:27 etdemo kernel: [  221.821385] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 262148
Mar 29 17:46:27 etdemo kernel: [  221.821390] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1850 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.821395] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 12
Mar 29 17:46:27 etdemo kernel: [  221.821398] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.821401] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.821404] [2169:2156:c/r:restore_memory_contents:962] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.821408] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 90208
Mar 29 17:46:27 etdemo kernel: [  221.821411] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 90208(90208,90208)
Mar 29 17:46:27 etdemo kernel: [  221.821414] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.821424] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.821620] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.821685] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.821747] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.821791] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.821865] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.821928] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.821972] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.822034] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.822106] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.822149] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.822436] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.823137] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.823230] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.823300] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.823818] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.823886] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.823961] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.824085] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.824147] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.824190] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.824261] [2169:2156:c/r:pgarr_release_pages:102] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.824318] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.824322] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.824326] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.824331] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.824334] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.824339] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 294917
Mar 29 17:46:27 etdemo kernel: [  221.824353] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 294917
Mar 29 17:46:27 etdemo kernel: [  221.824357] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1820 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.824362] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 13
Mar 29 17:46:27 etdemo kernel: [  221.824365] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.824368] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.824371] [2169:2156:c/r:restore_memory_contents:962] total pages 48
Mar 29 17:46:27 etdemo kernel: [  221.824375] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 196808
Mar 29 17:46:27 etdemo kernel: [  221.824378] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 196808(196808,196808)
Mar 29 17:46:27 etdemo kernel: [  221.824381] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.824390] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.824566] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.824629] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.824682] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.824773] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.824835] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.824880] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.824952] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.825015] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.825058] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.825127] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.825323] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.825390] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.825469] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.825513] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.825584] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.825646] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.825688] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.825750] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.825820] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.825862] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.825924] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:27 etdemo kernel: [  221.825969] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:27 etdemo kernel: [  221.826038] [2169:2156:c/r:read_pages_contents:919] got page 0x24
Mar 29 17:46:27 etdemo kernel: [  221.826100] [2169:2156:c/r:read_pages_contents:919] got page 0x25
Mar 29 17:46:27 etdemo kernel: [  221.826143] [2169:2156:c/r:read_pages_contents:919] got page 0x27
Mar 29 17:46:27 etdemo kernel: [  221.826204] [2169:2156:c/r:read_pages_contents:919] got page 0x28
Mar 29 17:46:27 etdemo kernel: [  221.826276] [2169:2156:c/r:read_pages_contents:919] got page 0x2a
Mar 29 17:46:27 etdemo kernel: [  221.826319] [2169:2156:c/r:read_pages_contents:919] got page 0x2b
Mar 29 17:46:27 etdemo kernel: [  221.826380] [2169:2156:c/r:read_pages_contents:919] got page 0x2d
Mar 29 17:46:27 etdemo kernel: [  221.826441] [2169:2156:c/r:read_pages_contents:919] got page 0x2e
Mar 29 17:46:27 etdemo kernel: [  221.826493] [2169:2156:c/r:read_pages_contents:919] got page 0x30
Mar 29 17:46:27 etdemo kernel: [  221.826554] [2169:2156:c/r:read_pages_contents:919] got page 0x31
Mar 29 17:46:27 etdemo kernel: [  221.826597] [2169:2156:c/r:read_pages_contents:919] got page 0x33
Mar 29 17:46:27 etdemo kernel: [  221.826680] [2169:2156:c/r:read_pages_contents:919] got page 0x34
Mar 29 17:46:27 etdemo kernel: [  221.826752] [2169:2156:c/r:read_pages_contents:919] got page 0x36
Mar 29 17:46:27 etdemo kernel: [  221.826797] [2169:2156:c/r:read_pages_contents:919] got page 0x37
Mar 29 17:46:27 etdemo kernel: [  221.826858] [2169:2156:c/r:read_pages_contents:919] got page 0x39
Mar 29 17:46:27 etdemo kernel: [  221.826919] [2169:2156:c/r:read_pages_contents:919] got page 0x3a
Mar 29 17:46:27 etdemo kernel: [  221.826971] [2169:2156:c/r:read_pages_contents:919] got page 0x3c
Mar 29 17:46:27 etdemo kernel: [  221.827032] [2169:2156:c/r:read_pages_contents:919] got page 0x3d
Mar 29 17:46:27 etdemo kernel: [  221.827075] [2169:2156:c/r:read_pages_contents:919] got page 0x3f
Mar 29 17:46:27 etdemo kernel: [  221.827138] [2169:2156:c/r:read_pages_contents:919] got page 0x40
Mar 29 17:46:27 etdemo kernel: [  221.827191] [2169:2156:c/r:read_pages_contents:919] got page 0x42
Mar 29 17:46:27 etdemo kernel: [  221.827235] [2169:2156:c/r:read_pages_contents:919] got page 0x43
Mar 29 17:46:27 etdemo kernel: [  221.827296] [2169:2156:c/r:read_pages_contents:919] got page 0x45
Mar 29 17:46:27 etdemo kernel: [  221.827358] [2169:2156:c/r:read_pages_contents:919] got page 0x46
Mar 29 17:46:27 etdemo kernel: [  221.827409] [2169:2156:c/r:pgarr_release_pages:102] total pages 48
Mar 29 17:46:27 etdemo kernel: [  221.827519] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.827523] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.827527] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.827531] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.827534] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.827538] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 327686
Mar 29 17:46:27 etdemo kernel: [  221.827548] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 327686
Mar 29 17:46:27 etdemo kernel: [  221.827553] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1901 lprid 1911 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.827557] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 14
Mar 29 17:46:27 etdemo kernel: [  221.827560] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.827564] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.827567] [2169:2156:c/r:restore_memory_contents:962] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.827573] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 90208
Mar 29 17:46:27 etdemo kernel: [  221.827577] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 90208(90208,90208)
Mar 29 17:46:27 etdemo kernel: [  221.827580] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.827590] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.827746] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.827879] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.827932] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.828069] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.828093] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.828116] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.828188] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.828230] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.828292] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.828337] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.828409] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.828471] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.828532] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.828575] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.828663] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.828726] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.828769] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.828830] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.828900] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.828943] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.829005] [2169:2156:c/r:pgarr_release_pages:102] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.829042] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.829046] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.829049] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.829053] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.829056] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.829060] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 360455
Mar 29 17:46:27 etdemo kernel: [  221.829066] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 360455
Mar 29 17:46:27 etdemo kernel: [  221.829070] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1944 lprid 2054 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.829073] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 15
Mar 29 17:46:27 etdemo kernel: [  221.829077] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.829080] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.829083] [2169:2156:c/r:restore_memory_contents:962] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.829086] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 90208
Mar 29 17:46:27 etdemo kernel: [  221.829089] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 90208(90208,90208)
Mar 29 17:46:27 etdemo kernel: [  221.829092] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.829101] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.829257] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.829318] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.829361] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.829422] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.829473] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.829534] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.829595] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.829639] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.829709] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.829771] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.829817] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.829877] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.829947] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.829990] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.830059] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.830120] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.830190] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.830232] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.830349] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.830566] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.830637] [2169:2156:c/r:pgarr_release_pages:102] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.830694] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.830697] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.830701] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.830704] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.830707] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.830711] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 458760
Mar 29 17:46:27 etdemo kernel: [  221.830719] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 458760
Mar 29 17:46:27 etdemo kernel: [  221.830723] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1944 lprid 2054 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.830727] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 16
Mar 29 17:46:27 etdemo kernel: [  221.830730] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.830733] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.830736] [2169:2156:c/r:restore_memory_contents:962] total pages 48
Mar 29 17:46:27 etdemo kernel: [  221.830739] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 196808
Mar 29 17:46:27 etdemo kernel: [  221.830742] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 196808(196808,196808)
Mar 29 17:46:27 etdemo kernel: [  221.830746] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.830756] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.830902] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.830964] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.831034] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.831077] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.831156] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.831180] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.831251] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.831294] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.831355] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.831398] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.831471] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.831532] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.831593] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.831638] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.831708] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.831770] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.831814] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.831876] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.832056] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.832251] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.832314] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:27 etdemo kernel: [  221.832358] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:27 etdemo kernel: [  221.832432] [2169:2156:c/r:read_pages_contents:919] got page 0x24
Mar 29 17:46:27 etdemo kernel: [  221.832494] [2169:2156:c/r:read_pages_contents:919] got page 0x25
Mar 29 17:46:27 etdemo kernel: [  221.832538] [2169:2156:c/r:read_pages_contents:919] got page 0x27
Mar 29 17:46:27 etdemo kernel: [  221.832601] [2169:2156:c/r:read_pages_contents:919] got page 0x28
Mar 29 17:46:27 etdemo kernel: [  221.832801] [2169:2156:c/r:read_pages_contents:919] got page 0x2a
Mar 29 17:46:27 etdemo kernel: [  221.832892] [2169:2156:c/r:read_pages_contents:919] got page 0x2b
Mar 29 17:46:27 etdemo kernel: [  221.832954] [2169:2156:c/r:read_pages_contents:919] got page 0x2d
Mar 29 17:46:27 etdemo kernel: [  221.833017] [2169:2156:c/r:read_pages_contents:919] got page 0x2e
Mar 29 17:46:27 etdemo kernel: [  221.833093] [2169:2156:c/r:read_pages_contents:919] got page 0x30
Mar 29 17:46:27 etdemo kernel: [  221.833158] [2169:2156:c/r:read_pages_contents:919] got page 0x31
Mar 29 17:46:27 etdemo kernel: [  221.833253] [2169:2156:c/r:read_pages_contents:919] got page 0x33
Mar 29 17:46:27 etdemo kernel: [  221.833300] [2169:2156:c/r:read_pages_contents:919] got page 0x34
Mar 29 17:46:27 etdemo kernel: [  221.833392] [2169:2156:c/r:read_pages_contents:919] got page 0x36
Mar 29 17:46:27 etdemo kernel: [  221.833540] [2169:2156:c/r:read_pages_contents:919] got page 0x37
Mar 29 17:46:27 etdemo kernel: [  221.833566] [2169:2156:c/r:read_pages_contents:919] got page 0x39
Mar 29 17:46:27 etdemo kernel: [  221.833592] [2169:2156:c/r:read_pages_contents:919] got page 0x3a
Mar 29 17:46:27 etdemo kernel: [  221.833626] [2169:2156:c/r:read_pages_contents:919] got page 0x3c
Mar 29 17:46:27 etdemo kernel: [  221.833652] [2169:2156:c/r:read_pages_contents:919] got page 0x3d
Mar 29 17:46:27 etdemo kernel: [  221.833708] [2169:2156:c/r:read_pages_contents:919] got page 0x3f
Mar 29 17:46:27 etdemo kernel: [  221.833777] [2169:2156:c/r:read_pages_contents:919] got page 0x40
Mar 29 17:46:27 etdemo kernel: [  221.833811] [2169:2156:c/r:read_pages_contents:919] got page 0x42
Mar 29 17:46:27 etdemo kernel: [  221.833876] [2169:2156:c/r:read_pages_contents:919] got page 0x43
Mar 29 17:46:27 etdemo kernel: [  221.833941] [2169:2156:c/r:read_pages_contents:919] got page 0x45
Mar 29 17:46:27 etdemo kernel: [  221.834002] [2169:2156:c/r:read_pages_contents:919] got page 0x46
Mar 29 17:46:27 etdemo kernel: [  221.834056] [2169:2156:c/r:pgarr_release_pages:102] total pages 48
Mar 29 17:46:27 etdemo kernel: [  221.834113] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.834117] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.834121] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.834127] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.834130] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.834135] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 491529
Mar 29 17:46:27 etdemo kernel: [  221.834149] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 491529
Mar 29 17:46:27 etdemo kernel: [  221.834154] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1945 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.834158] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 17
Mar 29 17:46:27 etdemo kernel: [  221.834162] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.834165] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.834170] [2169:2156:c/r:restore_memory_contents:962] total pages 48
Mar 29 17:46:27 etdemo kernel: [  221.834311] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 196808
Mar 29 17:46:27 etdemo kernel: [  221.834315] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 196808(196808,196808)
Mar 29 17:46:27 etdemo kernel: [  221.834318] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.834328] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.834391] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.834461] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.834529] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.834572] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.834633] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.834684] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.834745] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.834807] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.834850] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.834919] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.834986] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.835046] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.835089] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.835159] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.835220] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.835262] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.835324] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.835509] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.835574] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.835637] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.835681] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:27 etdemo kernel: [  221.835756] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:27 etdemo kernel: [  221.835818] [2169:2156:c/r:read_pages_contents:919] got page 0x24
Mar 29 17:46:27 etdemo kernel: [  221.835880] [2169:2156:c/r:read_pages_contents:919] got page 0x25
Mar 29 17:46:27 etdemo kernel: [  221.835954] [2169:2156:c/r:read_pages_contents:919] got page 0x27
Mar 29 17:46:27 etdemo kernel: [  221.836068] [2169:2156:c/r:read_pages_contents:919] got page 0x28
Mar 29 17:46:27 etdemo kernel: [  221.836217] [2169:2156:c/r:read_pages_contents:919] got page 0x2a
Mar 29 17:46:27 etdemo kernel: [  221.836242] [2169:2156:c/r:read_pages_contents:919] got page 0x2b
Mar 29 17:46:27 etdemo kernel: [  221.836267] [2169:2156:c/r:read_pages_contents:919] got page 0x2d
Mar 29 17:46:27 etdemo kernel: [  221.836322] [2169:2156:c/r:read_pages_contents:919] got page 0x2e
Mar 29 17:46:27 etdemo kernel: [  221.836366] [2169:2156:c/r:read_pages_contents:919] got page 0x30
Mar 29 17:46:27 etdemo kernel: [  221.836427] [2169:2156:c/r:read_pages_contents:919] got page 0x31
Mar 29 17:46:27 etdemo kernel: [  221.836490] [2169:2156:c/r:read_pages_contents:919] got page 0x33
Mar 29 17:46:27 etdemo kernel: [  221.836542] [2169:2156:c/r:read_pages_contents:919] got page 0x34
Mar 29 17:46:27 etdemo kernel: [  221.836603] [2169:2156:c/r:read_pages_contents:919] got page 0x36
Mar 29 17:46:27 etdemo kernel: [  221.836666] [2169:2156:c/r:read_pages_contents:919] got page 0x37
Mar 29 17:46:27 etdemo kernel: [  221.836709] [2169:2156:c/r:read_pages_contents:919] got page 0x39
Mar 29 17:46:27 etdemo kernel: [  221.836779] [2169:2156:c/r:read_pages_contents:919] got page 0x3a
Mar 29 17:46:27 etdemo kernel: [  221.836841] [2169:2156:c/r:read_pages_contents:919] got page 0x3c
Mar 29 17:46:27 etdemo kernel: [  221.836884] [2169:2156:c/r:read_pages_contents:919] got page 0x3d
Mar 29 17:46:27 etdemo kernel: [  221.836945] [2169:2156:c/r:read_pages_contents:919] got page 0x3f
Mar 29 17:46:27 etdemo kernel: [  221.837017] [2169:2156:c/r:read_pages_contents:919] got page 0x40
Mar 29 17:46:27 etdemo kernel: [  221.837060] [2169:2156:c/r:read_pages_contents:919] got page 0x42
Mar 29 17:46:27 etdemo kernel: [  221.837125] [2169:2156:c/r:read_pages_contents:919] got page 0x43
Mar 29 17:46:27 etdemo kernel: [  221.837186] [2169:2156:c/r:read_pages_contents:919] got page 0x45
Mar 29 17:46:27 etdemo kernel: [  221.837257] [2169:2156:c/r:read_pages_contents:919] got page 0x46
Mar 29 17:46:27 etdemo kernel: [  221.837300] [2169:2156:c/r:pgarr_release_pages:102] total pages 48
Mar 29 17:46:27 etdemo kernel: [  221.837357] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.837360] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.837365] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.837371] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.837373] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.837378] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 524298
Mar 29 17:46:27 etdemo kernel: [  221.837391] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 524298
Mar 29 17:46:27 etdemo kernel: [  221.837395] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1998 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.837400] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 18
Mar 29 17:46:27 etdemo kernel: [  221.837403] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.837406] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.837409] [2169:2156:c/r:restore_memory_contents:962] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.837412] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 90208
Mar 29 17:46:27 etdemo kernel: [  221.837415] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 90208(90208,90208)
Mar 29 17:46:27 etdemo kernel: [  221.837419] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.837428] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.837591] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.837663] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.837724] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.837766] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.837827] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.837897] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.837940] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.838001] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.838043] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.838231] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.838277] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.838338] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.838381] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.838451] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.838512] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.838556] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.838645] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.838696] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.838757] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.838800] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.838861] [2169:2156:c/r:pgarr_release_pages:102] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.838925] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.838929] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.838932] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.838936] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.838939] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.838943] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 557067
Mar 29 17:46:27 etdemo kernel: [  221.838949] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 557067
Mar 29 17:46:27 etdemo kernel: [  221.838953] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1997 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.838956] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 19
Mar 29 17:46:27 etdemo kernel: [  221.838959] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.838962] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.838965] [2169:2156:c/r:restore_memory_contents:962] total pages 16
Mar 29 17:46:27 etdemo kernel: [  221.838968] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 65608
Mar 29 17:46:27 etdemo kernel: [  221.838971] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 65608(65608,65608)
Mar 29 17:46:27 etdemo kernel: [  221.838975] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.838983] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.839131] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.839174] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.839266] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.839390] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.839470] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.839587] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.839648] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.839720] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.839762] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.839824] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.839869] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.839939] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.840051] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.840075] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.840098] [2169:2156:c/r:pgarr_release_pages:102] total pages 16
Mar 29 17:46:27 etdemo kernel: [  221.840125] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.840129] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.840132] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.840136] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.840139] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.840142] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 589836
Mar 29 17:46:27 etdemo kernel: [  221.840150] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 589836
Mar 29 17:46:27 etdemo kernel: [  221.840153] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1953 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.840157] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 20
Mar 29 17:46:27 etdemo kernel: [  221.840160] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.840163] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.840166] [2169:2156:c/r:restore_memory_contents:962] total pages 24
Mar 29 17:46:27 etdemo kernel: [  221.840170] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 98408
Mar 29 17:46:27 etdemo kernel: [  221.840173] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 98408(98408,98408)
Mar 29 17:46:27 etdemo kernel: [  221.840176] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.840185] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.840315] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.840358] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.840419] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.840471] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.840532] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.840701] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.840837] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.840889] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.840950] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.841011] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.841057] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.841127] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.841189] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.841232] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.841292] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.841362] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.841405] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.841468] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.841510] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.841581] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.841642] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:27 etdemo kernel: [  221.841685] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:27 etdemo kernel: [  221.841746] [2169:2156:c/r:pgarr_release_pages:102] total pages 24
Mar 29 17:46:27 etdemo kernel: [  221.841810] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.841814] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.841817] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.841821] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.841824] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.841828] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 622605
Mar 29 17:46:27 etdemo kernel: [  221.841835] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 622605
Mar 29 17:46:27 etdemo kernel: [  221.841838] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1959 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.841842] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 21
Mar 29 17:46:27 etdemo kernel: [  221.841845] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.841848] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.841851] [2169:2156:c/r:restore_memory_contents:962] total pages 24
Mar 29 17:46:27 etdemo kernel: [  221.841855] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 98408
Mar 29 17:46:27 etdemo kernel: [  221.841858] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 98408(98408,98408)
Mar 29 17:46:27 etdemo kernel: [  221.841861] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.841870] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.842016] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.842060] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.842159] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.842232] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.842275] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.842338] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.842418] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.842548] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.842611] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.842831] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.842878] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.842970] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.843014] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.843076] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.843119] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.843190] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.843251] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.843294] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.843356] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.843559] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.843583] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:27 etdemo kernel: [  221.843607] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:27 etdemo kernel: [  221.843631] [2169:2156:c/r:pgarr_release_pages:102] total pages 24
Mar 29 17:46:27 etdemo kernel: [  221.843659] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.843662] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.843666] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.843671] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.843674] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.843679] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 655374
Mar 29 17:46:27 etdemo kernel: [  221.843691] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 655374
Mar 29 17:46:27 etdemo kernel: [  221.843695] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 2054 lprid 2056 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.843699] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 22
Mar 29 17:46:27 etdemo kernel: [  221.843703] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.843706] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.843709] [2169:2156:c/r:restore_memory_contents:962] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.843712] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 90208
Mar 29 17:46:27 etdemo kernel: [  221.843715] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 90208(90208,90208)
Mar 29 17:46:27 etdemo kernel: [  221.843718] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:27 etdemo kernel: [  221.843729] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:27 etdemo kernel: [  221.843767] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:27 etdemo kernel: [  221.843828] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:27 etdemo kernel: [  221.843889] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:27 etdemo kernel: [  221.843941] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:27 etdemo kernel: [  221.844063] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:27 etdemo kernel: [  221.844087] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:27 etdemo kernel: [  221.844110] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:27 etdemo kernel: [  221.844143] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:27 etdemo kernel: [  221.844167] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:27 etdemo kernel: [  221.844209] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:27 etdemo kernel: [  221.844396] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:27 etdemo kernel: [  221.844468] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:27 etdemo kernel: [  221.844530] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:27 etdemo kernel: [  221.844575] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:27 etdemo kernel: [  221.844636] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:27 etdemo kernel: [  221.844706] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:27 etdemo kernel: [  221.844749] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:27 etdemo kernel: [  221.844810] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:27 etdemo kernel: [  221.844854] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:27 etdemo kernel: [  221.844923] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:27 etdemo kernel: [  221.844985] [2169:2156:c/r:pgarr_release_pages:102] total pages 22
Mar 29 17:46:27 etdemo kernel: [  221.845023] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:27 etdemo kernel: [  221.845026] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:27 etdemo kernel: [  221.845030] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:27 etdemo kernel: [  221.845034] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:27 etdemo kernel: [  221.845037] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:27 etdemo kernel: [  221.845040] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 688143
Mar 29 17:46:27 etdemo kernel: [  221.845050] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 688143
Mar 29 17:46:27 etdemo kernel: [  221.845053] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1918 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:27 etdemo kernel: [  221.845057] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 23
Mar 29 17:46:28 etdemo kernel: [  221.845060] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.845063] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.845066] [2169:2156:c/r:restore_memory_contents:962] total pages 90
Mar 29 17:46:28 etdemo kernel: [  221.845070] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 369008
Mar 29 17:46:28 etdemo kernel: [  221.845073] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 369008(369008,369008)
Mar 29 17:46:28 etdemo kernel: [  221.845076] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:28 etdemo kernel: [  221.845085] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:28 etdemo kernel: [  221.845219] [2169:2156:c/r:read_pages_contents:919] got page 0x2
Mar 29 17:46:28 etdemo kernel: [  221.845290] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:28 etdemo kernel: [  221.845353] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:28 etdemo kernel: [  221.845414] [2169:2156:c/r:read_pages_contents:919] got page 0x5
Mar 29 17:46:28 etdemo kernel: [  221.845456] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:28 etdemo kernel: [  221.845528] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:28 etdemo kernel: [  221.845590] [2169:2156:c/r:read_pages_contents:919] got page 0x8
Mar 29 17:46:28 etdemo kernel: [  221.845632] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:28 etdemo kernel: [  221.845694] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:28 etdemo kernel: [  221.845747] [2169:2156:c/r:read_pages_contents:919] got page 0xb
Mar 29 17:46:28 etdemo kernel: [  221.845808] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:28 etdemo kernel: [  221.845870] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:28 etdemo kernel: [  221.845913] [2169:2156:c/r:read_pages_contents:919] got page 0xe
Mar 29 17:46:28 etdemo kernel: [  221.845982] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:28 etdemo kernel: [  221.846044] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:28 etdemo kernel: [  221.846098] [2169:2156:c/r:read_pages_contents:919] got page 0x11
Mar 29 17:46:28 etdemo kernel: [  221.846179] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:28 etdemo kernel: [  221.846230] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:28 etdemo kernel: [  221.846297] [2169:2156:c/r:read_pages_contents:919] got page 0x14
Mar 29 17:46:28 etdemo kernel: [  221.846397] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:28 etdemo kernel: [  221.846441] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:28 etdemo kernel: [  221.846511] [2169:2156:c/r:read_pages_contents:919] got page 0x17
Mar 29 17:46:28 etdemo kernel: [  221.846554] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:28 etdemo kernel: [  221.846615] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:28 etdemo kernel: [  221.846676] [2169:2156:c/r:read_pages_contents:919] got page 0x1a
Mar 29 17:46:28 etdemo kernel: [  221.846728] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:28 etdemo kernel: [  221.846789] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:28 etdemo kernel: [  221.846832] [2169:2156:c/r:read_pages_contents:919] got page 0x1d
Mar 29 17:46:28 etdemo kernel: [  221.846893] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:28 etdemo kernel: [  221.846963] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:28 etdemo kernel: [  221.847006] [2169:2156:c/r:read_pages_contents:919] got page 0x20
Mar 29 17:46:28 etdemo kernel: [  221.847067] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:28 etdemo kernel: [  221.847110] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:28 etdemo kernel: [  221.847181] [2169:2156:c/r:read_pages_contents:919] got page 0x23
Mar 29 17:46:28 etdemo kernel: [  221.847242] [2169:2156:c/r:read_pages_contents:919] got page 0x24
Mar 29 17:46:28 etdemo kernel: [  221.847285] [2169:2156:c/r:read_pages_contents:919] got page 0x25
Mar 29 17:46:28 etdemo kernel: [  221.847346] [2169:2156:c/r:read_pages_contents:919] got page 0x26
Mar 29 17:46:28 etdemo kernel: [  221.847416] [2169:2156:c/r:read_pages_contents:919] got page 0x27
Mar 29 17:46:28 etdemo kernel: [  221.847459] [2169:2156:c/r:read_pages_contents:919] got page 0x28
Mar 29 17:46:28 etdemo kernel: [  221.847520] [2169:2156:c/r:read_pages_contents:919] got page 0x29
Mar 29 17:46:28 etdemo kernel: [  221.847566] [2169:2156:c/r:read_pages_contents:919] got page 0x2a
Mar 29 17:46:28 etdemo kernel: [  221.847685] [2169:2156:c/r:read_pages_contents:919] got page 0x2b
Mar 29 17:46:28 etdemo kernel: [  221.847841] [2169:2156:c/r:read_pages_contents:919] got page 0x2c
Mar 29 17:46:28 etdemo kernel: [  221.847904] [2169:2156:c/r:read_pages_contents:919] got page 0x2d
Mar 29 17:46:28 etdemo kernel: [  221.847947] [2169:2156:c/r:read_pages_contents:919] got page 0x2e
Mar 29 17:46:28 etdemo kernel: [  221.848068] [2169:2156:c/r:read_pages_contents:919] got page 0x2f
Mar 29 17:46:28 etdemo kernel: [  221.848092] [2169:2156:c/r:read_pages_contents:919] got page 0x30
Mar 29 17:46:28 etdemo kernel: [  221.848155] [2169:2156:c/r:read_pages_contents:919] got page 0x31
Mar 29 17:46:28 etdemo kernel: [  221.848217] [2169:2156:c/r:read_pages_contents:919] got page 0x32
Mar 29 17:46:28 etdemo kernel: [  221.848268] [2169:2156:c/r:read_pages_contents:919] got page 0x33
Mar 29 17:46:28 etdemo kernel: [  221.848330] [2169:2156:c/r:read_pages_contents:919] got page 0x34
Mar 29 17:46:28 etdemo kernel: [  221.848372] [2169:2156:c/r:read_pages_contents:919] got page 0x35
Mar 29 17:46:28 etdemo kernel: [  221.848433] [2169:2156:c/r:read_pages_contents:919] got page 0x36
Mar 29 17:46:28 etdemo kernel: [  221.848503] [2169:2156:c/r:read_pages_contents:919] got page 0x37
Mar 29 17:46:28 etdemo kernel: [  221.848635] [2169:2156:c/r:read_pages_contents:919] got page 0x38
Mar 29 17:46:28 etdemo kernel: [  221.848699] [2169:2156:c/r:read_pages_contents:919] got page 0x39
Mar 29 17:46:28 etdemo kernel: [  221.848742] [2169:2156:c/r:read_pages_contents:919] got page 0x3a
Mar 29 17:46:28 etdemo kernel: [  221.848847] [2169:2156:c/r:read_pages_contents:919] got page 0x3b
Mar 29 17:46:28 etdemo kernel: [  221.848967] [2169:2156:c/r:read_pages_contents:919] got page 0x3c
Mar 29 17:46:28 etdemo kernel: [  221.849028] [2169:2156:c/r:read_pages_contents:919] got page 0x3d
Mar 29 17:46:28 etdemo kernel: [  221.849071] [2169:2156:c/r:read_pages_contents:919] got page 0x3e
Mar 29 17:46:28 etdemo kernel: [  221.849142] [2169:2156:c/r:read_pages_contents:919] got page 0x3f
Mar 29 17:46:28 etdemo kernel: [  221.849203] [2169:2156:c/r:read_pages_contents:919] got page 0x40
Mar 29 17:46:28 etdemo kernel: [  221.849247] [2169:2156:c/r:read_pages_contents:919] got page 0x41
Mar 29 17:46:28 etdemo kernel: [  221.849309] [2169:2156:c/r:read_pages_contents:919] got page 0x42
Mar 29 17:46:28 etdemo kernel: [  221.849379] [2169:2156:c/r:read_pages_contents:919] got page 0x43
Mar 29 17:46:28 etdemo kernel: [  221.849422] [2169:2156:c/r:read_pages_contents:919] got page 0x44
Mar 29 17:46:28 etdemo kernel: [  221.849483] [2169:2156:c/r:read_pages_contents:919] got page 0x45
Mar 29 17:46:28 etdemo kernel: [  221.849525] [2169:2156:c/r:read_pages_contents:919] got page 0x46
Mar 29 17:46:28 etdemo kernel: [  221.849595] [2169:2156:c/r:read_pages_contents:919] got page 0x47
Mar 29 17:46:28 etdemo kernel: [  221.849656] [2169:2156:c/r:read_pages_contents:919] got page 0x48
Mar 29 17:46:28 etdemo kernel: [  221.849701] [2169:2156:c/r:read_pages_contents:919] got page 0x49
Mar 29 17:46:28 etdemo kernel: [  221.849762] [2169:2156:c/r:read_pages_contents:919] got page 0x4a
Mar 29 17:46:28 etdemo kernel: [  221.849832] [2169:2156:c/r:read_pages_contents:919] got page 0x4b
Mar 29 17:46:28 etdemo kernel: [  221.849875] [2169:2156:c/r:read_pages_contents:919] got page 0x4c
Mar 29 17:46:28 etdemo kernel: [  221.849937] [2169:2156:c/r:read_pages_contents:919] got page 0x4d
Mar 29 17:46:28 etdemo kernel: [  221.849999] [2169:2156:c/r:read_pages_contents:919] got page 0x4e
Mar 29 17:46:28 etdemo kernel: [  221.850050] [2169:2156:c/r:read_pages_contents:919] got page 0x4f
Mar 29 17:46:28 etdemo kernel: [  221.850111] [2169:2156:c/r:read_pages_contents:919] got page 0x50
Mar 29 17:46:28 etdemo kernel: [  221.850201] [2169:2156:c/r:read_pages_contents:919] got page 0x51
Mar 29 17:46:28 etdemo kernel: [  221.850245] [2169:2156:c/r:read_pages_contents:919] got page 0x52
Mar 29 17:46:28 etdemo kernel: [  221.850296] [2169:2156:c/r:read_pages_contents:919] got page 0x53
Mar 29 17:46:28 etdemo kernel: [  221.850358] [2169:2156:c/r:read_pages_contents:919] got page 0x54
Mar 29 17:46:28 etdemo kernel: [  221.850419] [2169:2156:c/r:read_pages_contents:919] got page 0x55
Mar 29 17:46:28 etdemo kernel: [  221.850461] [2169:2156:c/r:read_pages_contents:919] got page 0x56
Mar 29 17:46:28 etdemo kernel: [  221.850579] [2169:2156:c/r:read_pages_contents:919] got page 0x57
Mar 29 17:46:28 etdemo kernel: [  221.850622] [2169:2156:c/r:read_pages_contents:919] got page 0x58
Mar 29 17:46:28 etdemo kernel: [  221.850684] [2169:2156:c/r:read_pages_contents:919] got page 0x59
Mar 29 17:46:28 etdemo kernel: [  221.850727] [2169:2156:c/r:pgarr_release_pages:102] total pages 90
Mar 29 17:46:28 etdemo kernel: [  221.850793] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.850796] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.850800] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.850804] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
Mar 29 17:46:28 etdemo kernel: [  221.850807] [2169:2156:c/r:ckpt_read_obj:386] type 502 len 120(120,120)
Mar 29 17:46:28 etdemo kernel: [  221.850811] [2169:2156:c/r:restore_ipc_shm:229] shm: do_shmget size 393216 flag 0x780 id 720912
Mar 29 17:46:28 etdemo kernel: [  221.850827] [2169:2156:c/r:restore_ipc_shm:231] shm: do_shmget ret 720912
Mar 29 17:46:28 etdemo kernel: [  221.850831] [2169:2156:c/r:load_ipc_shm_hdr:185] shm: cprid 1918 lprid 1745 segsz 393216 mlock -1
Mar 29 17:46:28 etdemo kernel: [  221.850835] [2169:2156:c/r:ckpt_obj_insert:1109] FILE objref 24
Mar 29 17:46:28 etdemo kernel: [  221.850838] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.850841] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.850844] [2169:2156:c/r:restore_memory_contents:962] total pages 96
Mar 29 17:46:28 etdemo kernel: [  221.850848] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 393608
Mar 29 17:46:28 etdemo kernel: [  221.850851] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 393608(393608,393608)
Mar 29 17:46:28 etdemo kernel: [  221.850854] [2169:2156:c/r:read_pages_contents:919] got page 0x0
Mar 29 17:46:28 etdemo kernel: [  221.850864] [2169:2156:c/r:read_pages_contents:919] got page 0x1
Mar 29 17:46:28 etdemo kernel: [  221.851001] [2169:2156:c/r:read_pages_contents:919] got page 0x2
Mar 29 17:46:28 etdemo kernel: [  221.851063] [2169:2156:c/r:read_pages_contents:919] got page 0x3
Mar 29 17:46:28 etdemo kernel: [  221.851106] [2169:2156:c/r:read_pages_contents:919] got page 0x4
Mar 29 17:46:28 etdemo kernel: [  221.851176] [2169:2156:c/r:read_pages_contents:919] got page 0x5
Mar 29 17:46:28 etdemo kernel: [  221.851237] [2169:2156:c/r:read_pages_contents:919] got page 0x6
Mar 29 17:46:28 etdemo kernel: [  221.851280] [2169:2156:c/r:read_pages_contents:919] got page 0x7
Mar 29 17:46:28 etdemo kernel: [  221.851341] [2169:2156:c/r:read_pages_contents:919] got page 0x8
Mar 29 17:46:28 etdemo kernel: [  221.851410] [2169:2156:c/r:read_pages_contents:919] got page 0x9
Mar 29 17:46:28 etdemo kernel: [  221.851453] [2169:2156:c/r:read_pages_contents:919] got page 0xa
Mar 29 17:46:28 etdemo kernel: [  221.851514] [2169:2156:c/r:read_pages_contents:919] got page 0xb
Mar 29 17:46:28 etdemo kernel: [  221.851557] [2169:2156:c/r:read_pages_contents:919] got page 0xc
Mar 29 17:46:28 etdemo kernel: [  221.851626] [2169:2156:c/r:read_pages_contents:919] got page 0xd
Mar 29 17:46:28 etdemo kernel: [  221.851756] [2169:2156:c/r:read_pages_contents:919] got page 0xe
Mar 29 17:46:28 etdemo kernel: [  221.851802] [2169:2156:c/r:read_pages_contents:919] got page 0xf
Mar 29 17:46:28 etdemo kernel: [  221.851864] [2169:2156:c/r:read_pages_contents:919] got page 0x10
Mar 29 17:46:28 etdemo kernel: [  221.851933] [2169:2156:c/r:read_pages_contents:919] got page 0x11
Mar 29 17:46:28 etdemo kernel: [  221.852058] [2169:2156:c/r:read_pages_contents:919] got page 0x12
Mar 29 17:46:28 etdemo kernel: [  221.852082] [2169:2156:c/r:read_pages_contents:919] got page 0x13
Mar 29 17:46:28 etdemo kernel: [  221.852106] [2169:2156:c/r:read_pages_contents:919] got page 0x14
Mar 29 17:46:28 etdemo kernel: [  221.852139] [2169:2156:c/r:read_pages_contents:919] got page 0x15
Mar 29 17:46:28 etdemo kernel: [  221.852201] [2169:2156:c/r:read_pages_contents:919] got page 0x16
Mar 29 17:46:28 etdemo kernel: [  221.852243] [2169:2156:c/r:read_pages_contents:919] got page 0x17
Mar 29 17:46:28 etdemo kernel: [  221.852304] [2169:2156:c/r:read_pages_contents:919] got page 0x18
Mar 29 17:46:28 etdemo kernel: [  221.852374] [2169:2156:c/r:read_pages_contents:919] got page 0x19
Mar 29 17:46:28 etdemo kernel: [  221.852417] [2169:2156:c/r:read_pages_contents:919] got page 0x1a
Mar 29 17:46:28 etdemo kernel: [  221.852478] [2169:2156:c/r:read_pages_contents:919] got page 0x1b
Mar 29 17:46:28 etdemo kernel: [  221.852610] [2169:2156:c/r:read_pages_contents:919] got page 0x1c
Mar 29 17:46:28 etdemo kernel: [  221.852645] [2169:2156:c/r:read_pages_contents:919] got page 0x1d
Mar 29 17:46:28 etdemo kernel: [  221.852706] [2169:2156:c/r:read_pages_contents:919] got page 0x1e
Mar 29 17:46:28 etdemo kernel: [  221.852749] [2169:2156:c/r:read_pages_contents:919] got page 0x1f
Mar 29 17:46:28 etdemo kernel: [  221.852810] [2169:2156:c/r:read_pages_contents:919] got page 0x20
Mar 29 17:46:28 etdemo kernel: [  221.852880] [2169:2156:c/r:read_pages_contents:919] got page 0x21
Mar 29 17:46:28 etdemo kernel: [  221.852923] [2169:2156:c/r:read_pages_contents:919] got page 0x22
Mar 29 17:46:28 etdemo kernel: [  221.852992] [2169:2156:c/r:read_pages_contents:919] got page 0x23
Mar 29 17:46:28 etdemo kernel: [  221.853054] [2169:2156:c/r:read_pages_contents:919] got page 0x24
Mar 29 17:46:28 etdemo kernel: [  221.853123] [2169:2156:c/r:read_pages_contents:919] got page 0x25
Mar 29 17:46:28 etdemo kernel: [  221.853166] [2169:2156:c/r:read_pages_contents:919] got page 0x26
Mar 29 17:46:28 etdemo kernel: [  221.853228] [2169:2156:c/r:read_pages_contents:919] got page 0x27
Mar 29 17:46:28 etdemo kernel: [  221.853289] [2169:2156:c/r:read_pages_contents:919] got page 0x28
Mar 29 17:46:28 etdemo kernel: [  221.853340] [2169:2156:c/r:read_pages_contents:919] got page 0x29
Mar 29 17:46:28 etdemo kernel: [  221.853512] [2169:2156:c/r:read_pages_contents:919] got page 0x2a
Mar 29 17:46:28 etdemo kernel: [  221.853537] [2169:2156:c/r:read_pages_contents:919] got page 0x2b
Mar 29 17:46:28 etdemo kernel: [  221.853560] [2169:2156:c/r:read_pages_contents:919] got page 0x2c
Mar 29 17:46:28 etdemo kernel: [  221.853595] [2169:2156:c/r:read_pages_contents:919] got page 0x2d
Mar 29 17:46:28 etdemo kernel: [  221.853618] [2169:2156:c/r:read_pages_contents:919] got page 0x2e
Mar 29 17:46:28 etdemo kernel: [  221.853641] [2169:2156:c/r:read_pages_contents:919] got page 0x2f
Mar 29 17:46:28 etdemo kernel: [  221.853665] [2169:2156:c/r:read_pages_contents:919] got page 0x30
Mar 29 17:46:28 etdemo kernel: [  221.853697] [2169:2156:c/r:read_pages_contents:919] got page 0x31
Mar 29 17:46:28 etdemo kernel: [  221.853758] [2169:2156:c/r:read_pages_contents:919] got page 0x32
Mar 29 17:46:28 etdemo kernel: [  221.853801] [2169:2156:c/r:read_pages_contents:919] got page 0x33
Mar 29 17:46:28 etdemo kernel: [  221.853862] [2169:2156:c/r:read_pages_contents:919] got page 0x34
Mar 29 17:46:28 etdemo kernel: [  221.853931] [2169:2156:c/r:read_pages_contents:919] got page 0x35
Mar 29 17:46:28 etdemo kernel: [  221.853974] [2169:2156:c/r:read_pages_contents:919] got page 0x36
Mar 29 17:46:28 etdemo kernel: [  221.854035] [2169:2156:c/r:read_pages_contents:919] got page 0x37
Mar 29 17:46:28 etdemo kernel: [  221.854078] [2169:2156:c/r:read_pages_contents:919] got page 0x38
Mar 29 17:46:28 etdemo kernel: [  221.854149] [2169:2156:c/r:read_pages_contents:919] got page 0x39
Mar 29 17:46:28 etdemo kernel: [  221.854259] [2169:2156:c/r:read_pages_contents:919] got page 0x3a
Mar 29 17:46:28 etdemo kernel: [  221.854304] [2169:2156:c/r:read_pages_contents:919] got page 0x3b
Mar 29 17:46:28 etdemo kernel: [  221.854365] [2169:2156:c/r:read_pages_contents:919] got page 0x3c
Mar 29 17:46:28 etdemo kernel: [  221.854417] [2169:2156:c/r:read_pages_contents:919] got page 0x3d
Mar 29 17:46:28 etdemo kernel: [  221.854478] [2169:2156:c/r:read_pages_contents:919] got page 0x3e
Mar 29 17:46:28 etdemo kernel: [  221.854522] [2169:2156:c/r:read_pages_contents:919] got page 0x3f
Mar 29 17:46:28 etdemo kernel: [  221.854583] [2169:2156:c/r:read_pages_contents:919] got page 0x40
Mar 29 17:46:28 etdemo kernel: [  221.854653] [2169:2156:c/r:read_pages_contents:919] got page 0x41
Mar 29 17:46:28 etdemo kernel: [  221.854697] [2169:2156:c/r:read_pages_contents:919] got page 0x42
Mar 29 17:46:28 etdemo kernel: [  221.854758] [2169:2156:c/r:read_pages_contents:919] got page 0x43
Mar 29 17:46:28 etdemo kernel: [  221.854819] [2169:2156:c/r:read_pages_contents:919] got page 0x44
Mar 29 17:46:28 etdemo kernel: [  221.854871] [2169:2156:c/r:read_pages_contents:919] got page 0x45
Mar 29 17:46:28 etdemo kernel: [  221.854932] [2169:2156:c/r:read_pages_contents:919] got page 0x46
Mar 29 17:46:28 etdemo kernel: [  221.854977] [2169:2156:c/r:read_pages_contents:919] got page 0x47
Mar 29 17:46:28 etdemo kernel: [  221.855038] [2169:2156:c/r:read_pages_contents:919] got page 0x48
Mar 29 17:46:28 etdemo kernel: [  221.855108] [2169:2156:c/r:read_pages_contents:919] got page 0x49
Mar 29 17:46:28 etdemo kernel: [  221.855169] [2169:2156:c/r:read_pages_contents:919] got page 0x4a
Mar 29 17:46:28 etdemo kernel: [  221.855234] [2169:2156:c/r:read_pages_contents:919] got page 0x4b
Mar 29 17:46:28 etdemo kernel: [  221.855344] [2169:2156:c/r:read_pages_contents:919] got page 0x4c
Mar 29 17:46:28 etdemo kernel: [  221.855488] [2169:2156:c/r:read_pages_contents:919] got page 0x4d
Mar 29 17:46:28 etdemo kernel: [  221.855532] [2169:2156:c/r:read_pages_contents:919] got page 0x4e
Mar 29 17:46:28 etdemo kernel: [  221.855594] [2169:2156:c/r:read_pages_contents:919] got page 0x4f
Mar 29 17:46:28 etdemo kernel: [  221.855656] [2169:2156:c/r:read_pages_contents:919] got page 0x50
Mar 29 17:46:28 etdemo kernel: [  221.855710] [2169:2156:c/r:read_pages_contents:919] got page 0x51
Mar 29 17:46:28 etdemo kernel: [  221.855772] [2169:2156:c/r:read_pages_contents:919] got page 0x52
Mar 29 17:46:28 etdemo kernel: [  221.855835] [2169:2156:c/r:read_pages_contents:919] got page 0x53
Mar 29 17:46:28 etdemo kernel: [  221.855878] [2169:2156:c/r:read_pages_contents:919] got page 0x54
Mar 29 17:46:28 etdemo kernel: [  221.855953] [2169:2156:c/r:read_pages_contents:919] got page 0x55
Mar 29 17:46:28 etdemo kernel: [  221.856064] [2169:2156:c/r:read_pages_contents:919] got page 0x56
Mar 29 17:46:28 etdemo kernel: [  221.856089] [2169:2156:c/r:read_pages_contents:919] got page 0x57
Mar 29 17:46:28 etdemo kernel: [  221.856113] [2169:2156:c/r:read_pages_contents:919] got page 0x58
Mar 29 17:46:28 etdemo kernel: [  221.856149] [2169:2156:c/r:read_pages_contents:919] got page 0x59
Mar 29 17:46:28 etdemo kernel: [  221.856193] [2169:2156:c/r:read_pages_contents:919] got page 0x5a
Mar 29 17:46:28 etdemo kernel: [  221.856237] [2169:2156:c/r:read_pages_contents:919] got page 0x5b
Mar 29 17:46:28 etdemo kernel: [  221.856299] [2169:2156:c/r:read_pages_contents:919] got page 0x5c
Mar 29 17:46:28 etdemo kernel: [  221.856370] [2169:2156:c/r:read_pages_contents:919] got page 0x5d
Mar 29 17:46:28 etdemo kernel: [  221.856414] [2169:2156:c/r:read_pages_contents:919] got page 0x5e
Mar 29 17:46:28 etdemo kernel: [  221.856475] [2169:2156:c/r:read_pages_contents:919] got page 0x5f
Mar 29 17:46:28 etdemo kernel: [  221.856537] [2169:2156:c/r:pgarr_release_pages:102] total pages 96
Mar 29 17:46:28 etdemo kernel: [  221.856583] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856587] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.856592] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.856597] [2169:2156:c/r:restore_ipc_any:270] ipc-shm: ret 0
Mar 29 17:46:28 etdemo kernel: [  221.856600] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 501 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856603] [2169:2156:c/r:ckpt_read_obj:386] type 501 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.856607] [2169:2156:c/r:restore_ipc_any:257] ipc-msg: count 0
Mar 29 17:46:28 etdemo kernel: [  221.856609] [2169:2156:c/r:restore_ipc_any:270] ipc-msg: ret 0
Mar 29 17:46:28 etdemo kernel: [  221.856612] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 501 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856615] [2169:2156:c/r:ckpt_read_obj:386] type 501 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.856619] [2169:2156:c/r:restore_ipc_any:257] ipc-sem: count 4
Mar 29 17:46:28 etdemo kernel: [  221.856622] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 505 len 88
Mar 29 17:46:28 etdemo kernel: [  221.856625] [2169:2156:c/r:ckpt_read_obj:386] type 505 len 88(88,88)
Mar 29 17:46:28 etdemo kernel: [  221.856630] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 24
Mar 29 17:46:28 etdemo kernel: [  221.856633] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 24(24,24)
Mar 29 17:46:28 etdemo kernel: [  221.856636] [2169:2156:c/r:restore_ipc_sem:197] sem: do_semget key 1275144238 flag 0x780 id 0
Mar 29 17:46:28 etdemo kernel: [  221.856645] [2169:2156:c/r:restore_ipc_sem:199] sem: do_semget ret 0
Mar 29 17:46:28 etdemo kernel: [  221.856651] [2169:2156:c/r:load_ipc_sem_hdr:121] sem: nsems 1
Mar 29 17:46:28 etdemo kernel: [  221.856655] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 505 len 88
Mar 29 17:46:28 etdemo kernel: [  221.856658] [2169:2156:c/r:ckpt_read_obj:386] type 505 len 88(88,88)
Mar 29 17:46:28 etdemo kernel: [  221.856662] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 1656
Mar 29 17:46:28 etdemo kernel: [  221.856665] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 1656(1656,1656)
Mar 29 17:46:28 etdemo kernel: [  221.856671] [2169:2156:c/r:restore_ipc_sem:197] sem: do_semget key 1392584750 flag 0x780 id 32769
Mar 29 17:46:28 etdemo kernel: [  221.856877] [2169:2156:c/r:restore_ipc_sem:199] sem: do_semget ret 32769
Mar 29 17:46:28 etdemo kernel: [  221.856880] [2169:2156:c/r:load_ipc_sem_hdr:121] sem: nsems 103
Mar 29 17:46:28 etdemo kernel: [  221.856885] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 505 len 88
Mar 29 17:46:28 etdemo kernel: [  221.856888] [2169:2156:c/r:ckpt_read_obj:386] type 505 len 88(88,88)
Mar 29 17:46:28 etdemo kernel: [  221.856892] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 152
Mar 29 17:46:28 etdemo kernel: [  221.856895] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 152(152,152)
Mar 29 17:46:28 etdemo kernel: [  221.856898] [2169:2156:c/r:restore_ipc_sem:197] sem: do_semget key 1208035374 flag 0x780 id 65538
Mar 29 17:46:28 etdemo kernel: [  221.856902] [2169:2156:c/r:restore_ipc_sem:199] sem: do_semget ret 65538
Mar 29 17:46:28 etdemo kernel: [  221.856904] [2169:2156:c/r:load_ipc_sem_hdr:121] sem: nsems 9
Mar 29 17:46:28 etdemo kernel: [  221.856908] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 505 len 88
Mar 29 17:46:28 etdemo kernel: [  221.856911] [2169:2156:c/r:ckpt_read_obj:386] type 505 len 88(88,88)
Mar 29 17:46:28 etdemo kernel: [  221.856914] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 24
Mar 29 17:46:28 etdemo kernel: [  221.856917] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 24(24,24)
Mar 29 17:46:28 etdemo kernel: [  221.856920] [2169:2156:c/r:restore_ipc_sem:197] sem: do_semget key 1459693614 flag 0x780 id 98307
Mar 29 17:46:28 etdemo kernel: [  221.856924] [2169:2156:c/r:restore_ipc_sem:199] sem: do_semget ret 98307
Mar 29 17:46:28 etdemo kernel: [  221.856927] [2169:2156:c/r:load_ipc_sem_hdr:121] sem: nsems 1
Mar 29 17:46:28 etdemo kernel: [  221.856930] [2169:2156:c/r:restore_ipc_any:270] ipc-sem: ret 0
Mar 29 17:46:28 etdemo kernel: [  221.856934] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 108 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856937] [2169:2156:c/r:ckpt_read_obj:386] type 108 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.856942] [2169:2156:c/r:ckpt_obj_try_fetch:1132] UTS_NS ref 6
Mar 29 17:46:28 etdemo kernel: [  221.856945] [2169:2156:c/r:ckpt_obj_try_fetch:1132] IPC_NS ref 7
Mar 29 17:46:28 etdemo kernel: [  221.856950] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 103 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856953] [2169:2156:c/r:ckpt_read_obj:386] type 103 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.856957] [2169:2156:c/r:ckpt_obj_try_fetch:1132] NSPROXY ref 5
Mar 29 17:46:28 etdemo kernel: [  221.856961] [2169:2156:c/r:restore_task_ns:585] nsproxy: ret 0 (db414018)
Mar 29 17:46:28 etdemo kernel: [  221.856964] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856967] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.856970] [2169:2156:c/r:restore_obj:1053] len 16 ref 25 type 2
Mar 29 17:46:28 etdemo kernel: [  221.856973] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 301 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856976] [2169:2156:c/r:ckpt_read_obj:386] type 301 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.856980] [2169:2156:c/r:do_restore_file_table:871] nfds 1
Mar 29 17:46:28 etdemo kernel: [  221.856988] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.856991] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.856994] [2169:2156:c/r:restore_obj:1053] len 16 ref 26 type 3
Mar 29 17:46:28 etdemo kernel: [  221.856997] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 304 len 48
Mar 29 17:46:28 etdemo kernel: [  221.857000] [2169:2156:c/r:ckpt_read_obj:386] type 304 len 48(0,4104)
Mar 29 17:46:28 etdemo kernel: [  221.857004] [2169:2156:c/r:do_restore_file:786] flags 0x1 mode 0x1e type 1
Mar 29 17:46:28 etdemo kernel: [  221.857008] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 303 len 22
Mar 29 17:46:28 etdemo kernel: [  221.857011] [2169:2156:c/r:_ckpt_read_obj:290] type 303 len 22(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.857014] [2169:2156:c/r:ckpt_read_fname:571] read filename '/tmp/test.out'
Mar 29 17:46:28 etdemo kernel: [  221.857017] [2169:2156:c/r:restore_open_fname:594] fname '/tmp/test.out' flags 0x1
Mar 29 17:46:28 etdemo kernel: [  221.857031] [2169:2156:c/r:ckpt_obj_try_fetch:1132] CRED ref 1
Mar 29 17:46:28 etdemo kernel: [  221.857036] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 302 len 24
Mar 29 17:46:28 etdemo kernel: [  221.857039] [2169:2156:c/r:ckpt_read_obj:386] type 302 len 24(24,24)
Mar 29 17:46:28 etdemo kernel: [  221.857043] [2169:2156:c/r:restore_file_desc:825] ref 26 fd 0 c.o.e 0
Mar 29 17:46:28 etdemo kernel: [  221.857046] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 26
Mar 29 17:46:28 etdemo kernel: [  221.857049] [2169:2156:c/r:restore_file_desc:843] newfd got 0 wanted 0
Mar 29 17:46:28 etdemo kernel: [  221.857053] [2169:2156:c/r:do_restore_file_table:896] files_deferq ran 0 entries
Mar 29 17:46:28 etdemo kernel: [  221.857057] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.857059] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.857063] [2169:2156:c/r:restore_obj:1053] len 16 ref 27 type 4
Mar 29 17:46:28 etdemo kernel: [  221.857066] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.857069] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.857072] [2169:2156:c/r:restore_obj:1053] len 16 ref 28 type 3
Mar 29 17:46:28 etdemo kernel: [  221.857075] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.857078] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.857081] [2169:2156:c/r:restore_obj:1053] len 16 ref 29 type 13
Mar 29 17:46:28 etdemo kernel: [  221.857084] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 114 len 96
Mar 29 17:46:28 etdemo kernel: [  221.857088] [2169:2156:c/r:ckpt_read_obj:386] type 114 len 96(96,96)
Mar 29 17:46:28 etdemo kernel: [  221.857092] [2169:2156:c/r:ckpt_obj_try_fetch:1132] GROUPINFO ref 2
Mar 29 17:46:28 etdemo kernel: [  221.857095] [2169:2156:c/r:ckpt_obj_try_fetch:1132] USER ref 3
Mar 29 17:46:28 etdemo kernel: [  221.857101] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 304 len 48
Mar 29 17:46:28 etdemo kernel: [  221.857104] [2169:2156:c/r:ckpt_read_obj:386] type 304 len 48(0,4104)
Mar 29 17:46:28 etdemo kernel: [  221.857108] [2169:2156:c/r:do_restore_file:786] flags 0x8020 mode 0x1d type 1
Mar 29 17:46:28 etdemo kernel: [  221.857111] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 303 len 35
Mar 29 17:46:28 etdemo kernel: [  221.857114] [2169:2156:c/r:_ckpt_read_obj:290] type 303 len 35(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.857117] [2169:2156:c/r:ckpt_read_fname:571] read filename '/home/jir/cp/external/test'
Mar 29 17:46:28 etdemo kernel: [  221.857120] [2169:2156:c/r:restore_open_fname:594] fname '/home/jir/cp/external/test' flags 0x8020
Mar 29 17:46:28 etdemo kernel: [  221.857125] [2169:2156:c/r:ckpt_obj_try_fetch:1132] CRED ref 29
Mar 29 17:46:28 etdemo kernel: [  221.857128] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 401 len 120
Mar 29 17:46:28 etdemo kernel: [  221.857134] [2169:2156:c/r:ckpt_read_obj:386] type 401 len 120(120,120)
Mar 29 17:46:28 etdemo kernel: [  221.857138] [2169:2156:c/r:do_restore_mm:1266] map_count 16
Mar 29 17:46:28 etdemo kernel: [  221.857940] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 28
Mar 29 17:46:28 etdemo kernel: [  221.857948] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 360
Mar 29 17:46:28 etdemo kernel: [  221.857951] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 360(360,360)
Mar 29 17:46:28 etdemo kernel: [  221.857955] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.857958] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.857963] [2169:2156:c/r:restore_vma:1198] vma 0x8048000-0x8049000 flags 0x8001875 type 3 vmaref 28 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.857966] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.857969] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 28
Mar 29 17:46:28 etdemo kernel: [  221.857978] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x5 flag 0x1812 pgoff 0x0 => 0x8048000
Mar 29 17:46:28 etdemo kernel: [  221.857982] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.857985] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.857988] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.857992] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.857995] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.857999] [2169:2156:c/r:restore_vma:1198] vma 0x8049000-0x804a000 flags 0x8101871 type 3 vmaref 28 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.858002] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.858004] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 28
Mar 29 17:46:28 etdemo kernel: [  221.858009] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x1 flag 0x1812 pgoff 0x0 => 0x8049000
Mar 29 17:46:28 etdemo kernel: [  221.858012] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.858015] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.858019] [2169:2156:c/r:restore_memory_contents:962] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.858022] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 4108
Mar 29 17:46:28 etdemo kernel: [  221.858025] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 4108(4108,4108)
Mar 29 17:46:28 etdemo kernel: [  221.858028] [2169:2156:c/r:read_pages_contents:919] got page 0x8049000
Mar 29 17:46:28 etdemo kernel: [  221.858191] [2169:2156:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.861188] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.861193] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.861198] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.861203] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.861207] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.861212] [2169:2156:c/r:restore_vma:1198] vma 0x804a000-0x804b000 flags 0x8101873 type 3 vmaref 28 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.861215] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.861219] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 28
Mar 29 17:46:28 etdemo kernel: [  221.861231] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x3 flag 0x1812 pgoff 0x1 => 0x804a000
Mar 29 17:46:28 etdemo kernel: [  221.861235] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.861238] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.861241] [2169:2156:c/r:restore_memory_contents:962] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.861244] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 4108
Mar 29 17:46:28 etdemo kernel: [  221.861247] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 4108(4108,4108)
Mar 29 17:46:28 etdemo kernel: [  221.861251] [2169:2156:c/r:read_pages_contents:919] got page 0x804a000
Mar 29 17:46:28 etdemo kernel: [  221.861273] [2169:2156:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.861414] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.861418] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.861421] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.861425] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.861428] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.861432] [2169:2156:c/r:restore_vma:1198] vma 0x9ede000-0x9eff000 flags 0x100073 type 2 vmaref 0 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.861435] [2169:2156:c/r:restore_vma:1216] vma type ANON PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.861440] [2169:2156:c/r:generic_vma_restore:1059] size 0x21000 prot 0x3 flag 0x12 pgoff 0x0 => 0x9ede000
Mar 29 17:46:28 etdemo kernel: [  221.861443] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.861446] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.861449] [2169:2156:c/r:restore_memory_contents:962] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.861452] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 4108
Mar 29 17:46:28 etdemo kernel: [  221.861455] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 4108(4108,4108)
Mar 29 17:46:28 etdemo kernel: [  221.861459] [2169:2156:c/r:read_pages_contents:919] got page 0x9ede000
Mar 29 17:46:28 etdemo kernel: [  221.861611] [2169:2156:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.862173] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862177] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.862180] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.862184] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.862187] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.862191] [2169:2156:c/r:restore_vma:1198] vma 0xb7701000-0xb7702000 flags 0x100073 type 2 vmaref 0 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.862195] [2169:2156:c/r:restore_vma:1216] vma type ANON PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.862201] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x3 flag 0x12 pgoff 0x0 => 0xb7701000
Mar 29 17:46:28 etdemo kernel: [  221.862204] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862207] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.862210] [2169:2156:c/r:restore_memory_contents:962] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.862214] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 4108
Mar 29 17:46:28 etdemo kernel: [  221.862217] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 4108(4108,4108)
Mar 29 17:46:28 etdemo kernel: [  221.862220] [2169:2156:c/r:read_pages_contents:919] got page 0xb7701000
Mar 29 17:46:28 etdemo kernel: [  221.862315] [2169:2156:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.862703] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862707] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.862711] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.862714] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862717] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.862721] [2169:2156:c/r:restore_obj:1053] len 16 ref 30 type 3
Mar 29 17:46:28 etdemo kernel: [  221.862724] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862727] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.862730] [2169:2156:c/r:restore_obj:1053] len 16 ref 31 type 13
Mar 29 17:46:28 etdemo kernel: [  221.862734] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 114 len 96
Mar 29 17:46:28 etdemo kernel: [  221.862736] [2169:2156:c/r:ckpt_read_obj:386] type 114 len 96(96,96)
Mar 29 17:46:28 etdemo kernel: [  221.862741] [2169:2156:c/r:ckpt_obj_try_fetch:1132] GROUPINFO ref 2
Mar 29 17:46:28 etdemo kernel: [  221.862744] [2169:2156:c/r:ckpt_obj_try_fetch:1132] USER ref 3
Mar 29 17:46:28 etdemo kernel: [  221.862751] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 304 len 48
Mar 29 17:46:28 etdemo kernel: [  221.862754] [2169:2156:c/r:ckpt_read_obj:386] type 304 len 48(0,4104)
Mar 29 17:46:28 etdemo kernel: [  221.862759] [2169:2156:c/r:do_restore_file:786] flags 0x0 mode 0x1d type 1
Mar 29 17:46:28 etdemo kernel: [  221.862762] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 303 len 42
Mar 29 17:46:28 etdemo kernel: [  221.862765] [2169:2156:c/r:_ckpt_read_obj:290] type 303 len 42(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.862768] [2169:2156:c/r:ckpt_read_fname:571] read filename '/lib/tls/i686/cmov/libc-2.10.1.so'
Mar 29 17:46:28 etdemo kernel: [  221.862771] [2169:2156:c/r:restore_open_fname:594] fname '/lib/tls/i686/cmov/libc-2.10.1.so' flags 0x0
Mar 29 17:46:28 etdemo kernel: [  221.862779] [2169:2156:c/r:ckpt_obj_try_fetch:1132] CRED ref 31
Mar 29 17:46:28 etdemo kernel: [  221.862787] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.862792] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.862797] [2169:2156:c/r:restore_vma:1198] vma 0xb7702000-0xb7840000 flags 0x8000075 type 3 vmaref 30 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.862800] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.862803] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 30
Mar 29 17:46:28 etdemo kernel: [  221.862809] [2169:2156:c/r:generic_vma_restore:1059] size 0x13e000 prot 0x5 flag 0x12 pgoff 0x0 => 0xb7702000
Mar 29 17:46:28 etdemo kernel: [  221.862813] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862816] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.862819] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.862822] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.862825] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.862829] [2169:2156:c/r:restore_vma:1198] vma 0xb7840000-0xb7841000 flags 0x8000070 type 3 vmaref 30 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.862832] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.862834] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 30
Mar 29 17:46:28 etdemo kernel: [  221.862839] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x0 flag 0x12 pgoff 0x13e => 0xb7840000
Mar 29 17:46:28 etdemo kernel: [  221.862843] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862846] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.862849] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.862852] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.862855] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.862859] [2169:2156:c/r:restore_vma:1198] vma 0xb7841000-0xb7843000 flags 0x8100071 type 3 vmaref 30 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.862862] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.862865] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 30
Mar 29 17:46:28 etdemo kernel: [  221.862869] [2169:2156:c/r:generic_vma_restore:1059] size 0x2000 prot 0x1 flag 0x12 pgoff 0x13e => 0xb7841000
Mar 29 17:46:28 etdemo kernel: [  221.862872] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862875] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.862879] [2169:2156:c/r:restore_memory_contents:962] total pages 2
Mar 29 17:46:28 etdemo kernel: [  221.862882] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 8208
Mar 29 17:46:28 etdemo kernel: [  221.862885] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 8208(8208,8208)
Mar 29 17:46:28 etdemo kernel: [  221.862888] [2169:2156:c/r:read_pages_contents:919] got page 0xb7841000
Mar 29 17:46:28 etdemo kernel: [  221.862972] [2169:2156:c/r:read_pages_contents:919] got page 0xb7842000
Mar 29 17:46:28 etdemo kernel: [  221.862983] [2169:2156:c/r:pgarr_release_pages:102] total pages 2
Mar 29 17:46:28 etdemo kernel: [  221.862987] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.862990] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.862993] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.862997] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863000] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863004] [2169:2156:c/r:restore_vma:1198] vma 0xb7843000-0xb7844000 flags 0x8100073 type 3 vmaref 30 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863007] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.863010] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 30
Mar 29 17:46:28 etdemo kernel: [  221.863015] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x3 flag 0x12 pgoff 0x140 => 0xb7843000
Mar 29 17:46:28 etdemo kernel: [  221.863018] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863021] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863025] [2169:2156:c/r:restore_memory_contents:962] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.863028] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 4108
Mar 29 17:46:28 etdemo kernel: [  221.863031] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 4108(4108,4108)
Mar 29 17:46:28 etdemo kernel: [  221.863034] [2169:2156:c/r:read_pages_contents:919] got page 0xb7843000
Mar 29 17:46:28 etdemo kernel: [  221.863044] [2169:2156:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.863047] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863050] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863053] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.863056] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863060] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863064] [2169:2156:c/r:restore_vma:1198] vma 0xb7844000-0xb7847000 flags 0x100073 type 2 vmaref 0 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863067] [2169:2156:c/r:restore_vma:1216] vma type ANON PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.863071] [2169:2156:c/r:generic_vma_restore:1059] size 0x3000 prot 0x3 flag 0x12 pgoff 0x0 => 0xb7844000
Mar 29 17:46:28 etdemo kernel: [  221.863074] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863077] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863080] [2169:2156:c/r:restore_memory_contents:962] total pages 3
Mar 29 17:46:28 etdemo kernel: [  221.863084] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 12308
Mar 29 17:46:28 etdemo kernel: [  221.863087] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 12308(12308,12308)
Mar 29 17:46:28 etdemo kernel: [  221.863090] [2169:2156:c/r:read_pages_contents:919] got page 0xb7844000
Mar 29 17:46:28 etdemo kernel: [  221.863098] [2169:2156:c/r:read_pages_contents:919] got page 0xb7845000
Mar 29 17:46:28 etdemo kernel: [  221.863105] [2169:2156:c/r:read_pages_contents:919] got page 0xb7846000
Mar 29 17:46:28 etdemo kernel: [  221.863113] [2169:2156:c/r:pgarr_release_pages:102] total pages 3
Mar 29 17:46:28 etdemo kernel: [  221.863116] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863119] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863122] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.863126] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863129] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863133] [2169:2156:c/r:restore_vma:1198] vma 0xb7856000-0xb7859000 flags 0x100073 type 2 vmaref 0 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863136] [2169:2156:c/r:restore_vma:1216] vma type ANON PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.863140] [2169:2156:c/r:generic_vma_restore:1059] size 0x3000 prot 0x3 flag 0x12 pgoff 0x0 => 0xb7856000
Mar 29 17:46:28 etdemo kernel: [  221.863143] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863146] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863149] [2169:2156:c/r:restore_memory_contents:962] total pages 3
Mar 29 17:46:28 etdemo kernel: [  221.863153] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 12308
Mar 29 17:46:28 etdemo kernel: [  221.863156] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 12308(12308,12308)
Mar 29 17:46:28 etdemo kernel: [  221.863159] [2169:2156:c/r:read_pages_contents:919] got page 0xb7856000
Mar 29 17:46:28 etdemo kernel: [  221.863166] [2169:2156:c/r:read_pages_contents:919] got page 0xb7857000
Mar 29 17:46:28 etdemo kernel: [  221.863173] [2169:2156:c/r:read_pages_contents:919] got page 0xb7858000
Mar 29 17:46:28 etdemo kernel: [  221.863180] [2169:2156:c/r:pgarr_release_pages:102] total pages 3
Mar 29 17:46:28 etdemo kernel: [  221.863183] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863186] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863189] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.863193] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863196] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863200] [2169:2156:c/r:restore_vma:1198] vma 0xb7859000-0xb785a000 flags 0x4040075 type 1 vmaref 0 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863203] [2169:2156:c/r:restore_vma:1216] vma type VDSO
Mar 29 17:46:28 etdemo kernel: [  221.863207] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863210] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.863214] [2169:2156:c/r:restore_obj:1053] len 16 ref 32 type 3
Mar 29 17:46:28 etdemo kernel: [  221.863217] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 304 len 48
Mar 29 17:46:28 etdemo kernel: [  221.863220] [2169:2156:c/r:ckpt_read_obj:386] type 304 len 48(0,4104)
Mar 29 17:46:28 etdemo kernel: [  221.863223] [2169:2156:c/r:do_restore_file:786] flags 0x8020 mode 0x1d type 1
Mar 29 17:46:28 etdemo kernel: [  221.863227] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 303 len 26
Mar 29 17:46:28 etdemo kernel: [  221.863230] [2169:2156:c/r:_ckpt_read_obj:290] type 303 len 26(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.863233] [2169:2156:c/r:ckpt_read_fname:571] read filename '/lib/ld-2.10.1.so'
Mar 29 17:46:28 etdemo kernel: [  221.863236] [2169:2156:c/r:restore_open_fname:594] fname '/lib/ld-2.10.1.so' flags 0x8020
Mar 29 17:46:28 etdemo kernel: [  221.863242] [2169:2156:c/r:ckpt_obj_try_fetch:1132] CRED ref 29
Mar 29 17:46:28 etdemo kernel: [  221.863246] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863249] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863253] [2169:2156:c/r:restore_vma:1198] vma 0xb785a000-0xb7875000 flags 0x8000875 type 3 vmaref 32 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863256] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.863259] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 32
Mar 29 17:46:28 etdemo kernel: [  221.863264] [2169:2156:c/r:generic_vma_restore:1059] size 0x1b000 prot 0x5 flag 0x812 pgoff 0x0 => 0xb785a000
Mar 29 17:46:28 etdemo kernel: [  221.863267] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863270] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863274] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.863277] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863280] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863284] [2169:2156:c/r:restore_vma:1198] vma 0xb7875000-0xb7876000 flags 0x8100871 type 3 vmaref 32 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863287] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.863289] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 32
Mar 29 17:46:28 etdemo kernel: [  221.863293] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x1 flag 0x812 pgoff 0x1a => 0xb7875000
Mar 29 17:46:28 etdemo kernel: [  221.863297] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863300] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863303] [2169:2156:c/r:restore_memory_contents:962] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.863306] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 4108
Mar 29 17:46:28 etdemo kernel: [  221.863309] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 4108(4108,4108)
Mar 29 17:46:28 etdemo kernel: [  221.863312] [2169:2156:c/r:read_pages_contents:919] got page 0xb7875000
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:restore_vma:1198] vma 0xb7876000-0xb7877000 flags 0x8100873 type 3 vmaref 32 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:restore_vma:1216] vma type FILE PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.863318] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE ref 32
Mar 29 17:46:28 etdemo kernel: [  221.863325] [2169:2156:c/r:generic_vma_restore:1059] size 0x1000 prot 0x3 flag 0x812 pgoff 0x1b => 0xb7876000
Mar 29 17:46:28 etdemo kernel: [  221.863329] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863332] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863336] [2169:2156:c/r:restore_memory_contents:962] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.863339] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 4108
Mar 29 17:46:28 etdemo kernel: [  221.863342] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 4108(4108,4108)
Mar 29 17:46:28 etdemo kernel: [  221.863345] [2169:2156:c/r:read_pages_contents:919] got page 0xb7876000
Mar 29 17:46:28 etdemo kernel: [  221.863355] [2169:2156:c/r:pgarr_release_pages:102] total pages 1
Mar 29 17:46:28 etdemo kernel: [  221.863358] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863361] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863365] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.863368] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 402 len 72
Mar 29 17:46:28 etdemo kernel: [  221.863371] [2169:2156:c/r:ckpt_read_obj:386] type 402 len 72(72,72)
Mar 29 17:46:28 etdemo kernel: [  221.863375] [2169:2156:c/r:restore_vma:1198] vma 0xbff57000-0xbff6c000 flags 0x100173 type 2 vmaref 0 inoref 0
Mar 29 17:46:28 etdemo kernel: [  221.863378] [2169:2156:c/r:restore_vma:1216] vma type ANON PRIVATE
Mar 29 17:46:28 etdemo kernel: [  221.863382] [2169:2156:c/r:generic_vma_restore:1059] size 0x15000 prot 0x3 flag 0x112 pgoff 0x0 => 0xbff57000
Mar 29 17:46:28 etdemo kernel: [  221.863386] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863389] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863392] [2169:2156:c/r:restore_memory_contents:962] total pages 3
Mar 29 17:46:28 etdemo kernel: [  221.863395] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 4 len 12308
Mar 29 17:46:28 etdemo kernel: [  221.863398] [2169:2156:c/r:_ckpt_read_obj:290] type 4 len 12308(12308,12308)
Mar 29 17:46:28 etdemo kernel: [  221.863401] [2169:2156:c/r:read_pages_contents:919] got page 0xbff69000
Mar 29 17:46:28 etdemo kernel: [  221.863522] [2169:2156:c/r:read_pages_contents:919] got page 0xbff6a000
Mar 29 17:46:28 etdemo kernel: [  221.863529] [2169:2156:c/r:read_pages_contents:919] got page 0xbff6b000
Mar 29 17:46:28 etdemo kernel: [  221.863536] [2169:2156:c/r:pgarr_release_pages:102] total pages 3
Mar 29 17:46:28 etdemo kernel: [  221.863539] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 403 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863542] [2169:2156:c/r:ckpt_read_obj:386] type 403 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863545] [2169:2156:c/r:restore_memory_contents:962] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.863549] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 404 len 24
Mar 29 17:46:28 etdemo kernel: [  221.863551] [2169:2156:c/r:ckpt_read_obj:386] type 404 len 24(24,24)
Mar 29 17:46:28 etdemo kernel: [  221.863556] [2169:2156:c/r:restore_mm_context:481] nldt 0 vdso 0xb7859000 (b7859000)
Mar 29 17:46:28 etdemo kernel: [  221.863559] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 202 len 8
Mar 29 17:46:28 etdemo kernel: [  221.863562] [2169:2156:c/r:_ckpt_read_obj:290] type 202 len 8(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.863566] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863569] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.863572] [2169:2156:c/r:restore_obj:1053] len 16 ref 33 type 5
Mar 29 17:46:28 etdemo kernel: [  221.863576] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 451 len 8
Mar 29 17:46:28 etdemo kernel: [  221.863578] [2169:2156:c/r:ckpt_read_obj:386] type 451 len 8(8,8)
Mar 29 17:46:28 etdemo kernel: [  221.863583] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 303 len 30
Mar 29 17:46:28 etdemo kernel: [  221.863586] [2169:2156:c/r:_ckpt_read_obj:290] type 303 len 30(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.863589] [2169:2156:c/r:ckpt_read_fname:571] read filename '/home/jir/cp/external'
Mar 29 17:46:28 etdemo kernel: [  221.863592] [2169:2156:c/r:restore_cwd:985] attempting chdir to /home/jir/cp/external
Mar 29 17:46:28 etdemo kernel: [  221.863599] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 303 len 10
Mar 29 17:46:28 etdemo kernel: [  221.863602] [2169:2156:c/r:_ckpt_read_obj:290] type 303 len 10(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.863605] [2169:2156:c/r:ckpt_read_fname:571] read filename '/'
Mar 29 17:46:28 etdemo kernel: [  221.863608] [2169:2156:c/r:restore_chroot:965] attempting chroot to /
Mar 29 17:46:28 etdemo kernel: [  221.863613] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 6 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863615] [2169:2156:c/r:_ckpt_read_objref:230] shared len 16 type 6
Mar 29 17:46:28 etdemo kernel: [  221.863619] [2169:2156:c/r:restore_obj:1053] len 16 ref 34 type 6
Mar 29 17:46:28 etdemo kernel: [  221.863622] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 601 len 2056
Mar 29 17:46:28 etdemo kernel: [  221.863625] [2169:2156:c/r:ckpt_read_obj:386] type 601 len 2056(2056,2056)
Mar 29 17:46:28 etdemo kernel: [  221.863633] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 104 len 32
Mar 29 17:46:28 etdemo kernel: [  221.863636] [2169:2156:c/r:ckpt_read_obj:386] type 104 len 32(32,32)
Mar 29 17:46:28 etdemo kernel: [  221.863640] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FILE_TABLE ref 25
Mar 29 17:46:28 etdemo kernel: [  221.863644] [2169:2156:c/r:restore_task_objs:651] file_table: ret 0 (d0a08e00)
Mar 29 17:46:28 etdemo kernel: [  221.863647] [2169:2156:c/r:ckpt_obj_try_fetch:1132] MM ref 27
Mar 29 17:46:28 etdemo kernel: [  221.863649] [2169:2156:c/r:restore_task_objs:656] mm: ret 0 (db789c40)
Mar 29 17:46:28 etdemo kernel: [  221.863652] [2169:2156:c/r:ckpt_obj_try_fetch:1132] FS ref 33
Mar 29 17:46:28 etdemo kernel: [  221.863655] [2169:2156:c/r:restore_task_objs:661] fs: ret 0 (d62d8a80)
Mar 29 17:46:28 etdemo kernel: [  221.863658] [2169:2156:c/r:ckpt_obj_try_fetch:1132] SIGHAND ref 34
Mar 29 17:46:28 etdemo kernel: [  221.863661] [2169:2156:c/r:restore_task_objs:666] sighand: ret 0 (d1fccfc0)
Mar 29 17:46:28 etdemo kernel: [  221.863664] [2169:2156:c/r:ckpt_obj_insert:1109] SIGNAL objref 35
Mar 29 17:46:28 etdemo kernel: [  221.863668] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 602 len 328
Mar 29 17:46:28 etdemo kernel: [  221.863671] [2169:2156:c/r:ckpt_read_obj:386] type 602 len 328(328,328)
Mar 29 17:46:28 etdemo kernel: [  221.863676] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 604 len 24
Mar 29 17:46:28 etdemo kernel: [  221.863679] [2169:2156:c/r:ckpt_read_obj:386] type 604 len 24(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.863686] [2169:2156:c/r:restore_task_objs:671] signal: ret 0 (d0fc1200)
Mar 29 17:46:28 etdemo kernel: [  221.863689] [2169:2156:c/r:restore_task:917] objs 0
Mar 29 17:46:28 etdemo kernel: [  221.863692] [2169:2156:c/r:restore_task:921] creds: ret 0
Mar 29 17:46:28 etdemo kernel: [  221.863695] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 604 len 24
Mar 29 17:46:28 etdemo kernel: [  221.863697] [2169:2156:c/r:ckpt_read_obj:386] type 604 len 24(0,0)
Mar 29 17:46:28 etdemo kernel: [  221.863701] [2169:2156:c/r:ckpt_read_obj_dispatch:254] type 603 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863704] [2169:2156:c/r:ckpt_read_obj:386] type 603 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863707] [2169:2156:c/r:restore_task:925] signal: ret 0
Mar 29 17:46:28 etdemo kernel: [  221.863714] [2169:2156:c/r:wait_task_sync:889] pid 2156 syncing
Mar 29 17:46:28 etdemo kernel: [  221.863719] [2168:1:c/r:wait_all_tasks_finish:1145] final sync kflags 0x2 (ret 0)
Mar 29 17:46:28 etdemo kernel: [  221.863719] [2168:1:c/r:do_restore_coord:1285] restore finish: 0
Mar 29 17:46:28 etdemo kernel: [  221.863719] [2168:1:c/r:do_restore_coord:1291] restore deferqueue: 0
Mar 29 17:46:28 etdemo kernel: [  221.863719] [2168:1:c/r:ckpt_read_obj_dispatch:254] type 9001 len 16
Mar 29 17:46:28 etdemo kernel: [  221.863719] [2168:1:c/r:ckpt_read_obj:386] type 9001 len 16(16,16)
Mar 29 17:46:28 etdemo kernel: [  221.863722] [2168:1:c/r:do_restore_coord:1296] restore tail: 0
Mar 29 17:46:28 etdemo kernel: [  221.863730] [2168:1:c/r:clear_task_ctx:826] task 1 clear checkpoint_ctx
Mar 29 17:46:28 etdemo kernel: [  221.863733] [2168:1:c/r:do_restart:1411] sys_restart returns 0
Mar 29 17:46:28 etdemo kernel: [  221.866590] [2169:2156:c/r:wait_task_sync:891] task sync done (errno 0)
Mar 29 17:46:28 etdemo kernel: [  221.866594] [2169:2156:c/r:clear_task_ctx:826] task 2156 clear checkpoint_ctx
Mar 29 17:46:28 etdemo kernel: [  221.866598] [2169:2156:c/r:restore_debug_free:141] 2 tasks registered, nr_tasks was 0 nr_total 0
Mar 29 17:46:28 etdemo kernel: [  221.866601] [2169:2156:c/r:restore_debug_free:144] active pid was 1, ctx->errno 0
Mar 29 17:46:28 etdemo kernel: [  221.866604] [2169:2156:c/r:restore_debug_free:146] kflags 6 uflags 0 oflags 1
Mar 29 17:46:28 etdemo kernel: [  221.866607] [2169:2156:c/r:restore_debug_free:148] task[0] to run 2156
Mar 29 17:46:28 etdemo kernel: [  221.866610] [2169:2156:c/r:restore_debug_free:173] pid 2168 type Coord state Success
Mar 29 17:46:28 etdemo kernel: [  221.866613] [2169:2156:c/r:restore_debug_free:173] pid 2169 type Root state Success
Mar 29 17:46:28 etdemo kernel: [  221.866628] [2169:2156:c/r:pgarr_release_pages:102] total pages 0
Mar 29 17:46:28 etdemo kernel: [  221.866632] [2169:2156:c/r:do_restart:1411] sys_restart returns -516
Mar 29 17:46:28 etdemo kernel: [  222.724188] test[2169] general protection ip:b773eb94 sp:bff69b6c error:0 in libc-2.10.1.so[b7702000+13e000]

--Apple-Mail-15--512242783
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii



--Apple-Mail-15--512242783
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--Apple-Mail-15--512242783--

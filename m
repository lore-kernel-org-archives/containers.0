From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: fix "scheduling in atomic" while restoring ipc shm
Date: Tue, 2 Mar 2010 17:17:16 -0600
Message-ID: <20100302231716.GA4594@us.ibm.com>
References: <201002241902.19623@zigzag.lvk.cs.msu.su>
	<1267054267-2819-1-git-send-email-orenl@cs.columbia.edu>
	<4B85E62B.90804@cs.columbia.edu>
	<201003021750.47123@zigzag.lvk.cs.msu.su>
	<4B8D8C7D.2050004@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B8D8C7D.2050004-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>, leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Nikita V. Youshchenko wrote:
> >> Hi Nikita,
> >>
> >> Thanks for the report and the analysis. It actually helped to
> >> pinpoint a couple of other minor issues in the code. This patch
> >> should fix all of these.
> >>
> >> Oren.
> > 
> > Hi Oren.
> > 
> > With ckpt-v19 plus this patch applied, we still are getting a kernel
> > crash, with BUG() fired at
> > +       ipc = idr_find(&msg_ids->ipcs_idr, h->perms.id);
> > +       BUG_ON(!ipc);
> > added by the patch.
> > 
> > By looking at the code, I can't understand how this idr_find() can at
> > all succeed, if the namespace it is looking in was just created and
> > is empty.
> > 
> > What code adds object in question into this idr?
> 
> As Serge pointed out, the call to do_msgget(), if succeeded, should
> have created the object, and if it didn't succeed then we would have
> returned with an error message.

Should have, but didn't :)  I get the same BUG_ON.

> You can see in your log, that we request id 32769 (h->prems.id) and
> that is what do_shmget() returned. So I'm quite confused...
> 
> Can you post your test program so I can try to reproduce it here ?

You can just

	cd cr_tests/ipc; sh test-sem.sh

to reliably reproduce.

> Also, can you add a debug output before and after the call to idr_find
> that prints the h->perms.id ?
> 
> Thanks,
> 
> Oren.
> 
> 
> > 
> > Any hints?
> > 
> 
> 
> > Nikita
> > 
> > ...
> > [   60.321860] [430:430:c/r:ckpt_read_obj_dispatch:254] type 502 len 120
> > [   60.322489] [430:430:c/r:ckpt_read_obj:383] type 502 len 120(120,120)
> > [   60.323140] [430:430:c/r:restore_ipc_shm:226] shm: do_shmget size 790528 flag 0x7a4 id 32769
> > [   60.324257] [430:430:c/r:restore_ipc_shm:228] shm: do_shmget ret 32769
> > [   60.325573] ------------[ cut here ]------------
> > [   60.326059] kernel BUG at ipc/checkpoint_shm.c:274!
> > [   60.326564] invalid opcode: 0000 [#1] PREEMPT SMP
> > [   60.327124] last sysfs file:
> > [   60.327480] Modules linked in:
> > [   60.327903]
> > [   60.328104] Pid: 430, comm: bash Not tainted 2.6.33-rc8 #2 /
> > [   60.328104] EIP: 0060:[<c10e0abe>] EFLAGS: 00000246 CPU: 0
> > [   60.328104] EIP is at restore_ipc_shm+0x1a0/0x35a
> > [   60.328104] EAX: 00000000 EBX: 00000000 ECX: 00000005 EDX: c789ba58
> > [   60.328104] ESI: 00008001 EDI: c793d640 EBP: c79ac000 ESP: c7991dbc
> > [   60.328104]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> > [   60.328104] Process bash (pid: 430, ti=c7990000 task=c7855b70 task.ti=c7990000)
> > [   60.328104] Stack:
> > [   60.328104]  c129da9c c79ac000 000c1000 00000000 c129db00 000001ae 000001b4 000c1000
> > [   60.328104] <0> 00000000 c124dde1 000001ae 00000001 00000000 c7940c00 c79ac000 c10e036d
> > [   60.328104] <0> 00000002 c129da9c ffffffef c129da9c c799ac60 c79ac000 c10e048a 000001f6
> > [   60.328104] Call Trace:
> > [   60.328104]  [<c10e036d>] ? restore_ipc_any+0xa5/0x119
> > [   60.328104]  [<c10e048a>] ? restore_ipc_ns+0xa9/0x112
> > [   60.328104]  [<c10e091e>] ? restore_ipc_shm+0x0/0x35a
> > [   60.328104]  [<c10feb48>] ? restore_obj+0x98/0x116
> > [   60.328104]  [<c11007ed>] ? ckpt_read_obj_dispatch+0x220/0x246
> > [   60.328104]  [<c1100829>] ? ckpt_read_obj+0x16/0xe8
> > [   60.328104]  [<c107b866>] ? fsnotify_access+0x5a/0x61
> > [   60.328104]  [<c110097d>] ? ckpt_read_obj_type+0x16/0x70
> > [   60.328104]  [<c1039ab8>] ? restore_ns+0x18/0x12b
> > [   60.328104]  [<c10feb48>] ? restore_obj+0x98/0x116
> > [   60.328104]  [<c11007ed>] ? ckpt_read_obj_dispatch+0x220/0x246
> > [   60.328104]  [<c1100829>] ? ckpt_read_obj+0x16/0xe8
> > [   60.328104]  [<c110097d>] ? ckpt_read_obj_type+0x16/0x70
> > [   60.328104]  [<c11033fb>] ? restore_task+0x512/0x9fc
> > [   60.328104]  [<c1101b59>] ? do_restart+0xff4/0x12f3
> > [   60.328104]  [<c10364f0>] ? autoremove_wake_function+0x0/0x2d
> > [   60.328104]  [<c10fdb21>] ? do_sys_restart+0x66/0x77
> > [   60.328104]  [<c10027d5>] ? ptregs_restart+0x15/0x1c
> > [   60.328104]  [<c10026d0>] ? sysenter_do_call+0x12/0x26
> > [   60.328104] Code: fe ff ff e9 c8 01 00 00 8b 04 24 83 c0 64 89 44 24 10 e8 dd 16 10 00 8b 57 10 8b 04 24 83 c0 
> > 74 e8 24 71 02 00 85 c0 89 c3 75 04 <0f> 0b eb fe 8b 68 2c 8d 45 18 3e ff 45 18 8b 44 24 04 8d 57 08
> > [   60.328104] EIP: [<c10e0abe>] restore_ipc_shm+0x1a0/0x35a SS:ESP 0068:c7991dbc
> > [   60.351332] ---[ end trace 9660dfa05be59307 ]---
> > 
> > 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

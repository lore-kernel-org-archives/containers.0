From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: fix "scheduling in atomic" while restoring ipc shm
Date: Tue, 2 Mar 2010 17:40:03 -0600
Message-ID: <20100302234003.GA5674@us.ibm.com>
References: <201002241902.19623@zigzag.lvk.cs.msu.su>
	<1267054267-2819-1-git-send-email-orenl@cs.columbia.edu>
	<4B85E62B.90804@cs.columbia.edu>
	<201003021750.47123@zigzag.lvk.cs.msu.su>
	<4B8D8C7D.2050004@cs.columbia.edu>
	<20100302231716.GA4594@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100302231716.GA4594-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > 
> > 
> > Nikita V. Youshchenko wrote:
> > >> Hi Nikita,
> > >>
> > >> Thanks for the report and the analysis. It actually helped to
> > >> pinpoint a couple of other minor issues in the code. This patch
> > >> should fix all of these.
> > >>
> > >> Oren.
> > > 
> > > Hi Oren.
> > > 
> > > With ckpt-v19 plus this patch applied, we still are getting a kernel
> > > crash, with BUG() fired at
> > > +       ipc = idr_find(&msg_ids->ipcs_idr, h->perms.id);
> > > +       BUG_ON(!ipc);
> > > added by the patch.
> > > 
> > > By looking at the code, I can't understand how this idr_find() can at
> > > all succeed, if the namespace it is looking in was just created and
> > > is empty.
> > > 
> > > What code adds object in question into this idr?
> > 
> > As Serge pointed out, the call to do_msgget(), if succeeded, should
> > have created the object, and if it didn't succeed then we would have
> > returned with an error message.
> 
> Should have, but didn't :)  I get the same BUG_ON.
> 
> > You can see in your log, that we request id 32769 (h->prems.id) and
> > that is what do_shmget() returned. So I'm quite confused...
> > 
> > Can you post your test program so I can try to reproduce it here ?
> 
> You can just
> 
> 	cd cr_tests/ipc; sh test-sem.sh
> 
> to reliably reproduce.
> 
> > Also, can you add a debug output before and after the call to idr_find
> > that prints the h->perms.id ?

[root@oracer4b linux-2.6]# git diff
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index f865471..1c53581 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -210,7 +210,11 @@ int restore_load_ipc_perms(struct ckpt_ctx *ctx,
perm->cuid = h->cuid;
perm->cgid = h->cgid;
perm->mode = h->mode;
-       perm->seq = h->seq;
+       if (perm->seq != h->seq) {
+               ckpt_err(ctx, -EINVAL, "bad kern_ipc_perm->seq (%d not %d)\n",
+                       perm->mode, h->mode);
+               return -EINVAL;
+       }

return security_restore_obj(ctx, (void *)perm,
CKPT_SECURITY_IPC,
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 78c1932..c4012c9 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -216,7 +216,10 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
* ipc-ns, we will need to re-examine this.
*/

+       printk(KERN_NOTICE "XXX h->perms.id before is %lx\n", h->perms.id);
ipc = idr_find(&sem_ids->ipcs_idr, h->perms.id);
+       printk(KERN_NOTICE "XXX h->perms.id after is %lx\n", h->perms.id);
+       printk(KERN_NOTICE "XXX and i got back %lx\n", ipc);
BUG_ON(!ipc);

sem = container_of(ipc, struct sem_array, sem_perm);

[root@oracer4b linux-2.6]# dmesg|grep XXX
XXX h->perms.id before is 0
XXX h->perms.id after is 0
XXX and i got back ffff88007e51b0d0
XXX h->perms.id before is 8001
XXX h->perms.id after is 8001
XXX and i got back 0

[root@oracer4b linux-2.6]# dmesg|grep sem
[2410:2410:c/r:checkpoint_ipc_any:76] ipc-sem count 2
[2410:2410:c/r:fill_ipc_sem_hdr:50] sem: nsems 1
[2410:2410:c/r:fill_ipc_sem_hdr:50] sem: nsems 1
[2410:2410:c/r:checkpoint_ipc_any:84] ipc-sem ret 0
[2410:2410:c/r:checkpoint_file_common:188] file create-sem credref 11 secref 0
[2417:2406:c/r:restore_ipc_any:236] ipc-sem: count 2
[2417:2406:c/r:restore_ipc_sem:196] sem: do_semget key 0 flag 0x780 id 0
[2417:2406:c/r:restore_ipc_sem:198] sem: do_semget ret 0
[2417:2406:c/r:load_ipc_sem_hdr:120] sem: nsems 1
[2417:2406:c/r:restore_ipc_sem:196] sem: do_semget key 180146447 flag 0x780 id 32769
[2417:2406:c/r:restore_ipc_sem:198] sem: do_semget ret 32769
kernel BUG at ipc/checkpoint_sem.c:223!


-serge

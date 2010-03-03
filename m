From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: selinux prevents msgrcv on restore message queues?
Date: Tue, 2 Mar 2010 19:19:41 -0600
Message-ID: <20100303011941.GA10429@us.ibm.com>
References: <1267565774.11828.15.camel@localhost.localdomain>
	<20100303004727.GA8272@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100303004727.GA8272-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > Hi,
> > 
> > With ckpt-v19-rc3 the test-mq.sh testcase in cr_tests fails when SELinux
> > is enabled on my test system (64-bit powerpc kernel).  The testcase
> > sleeps in do_msgrcv after restart and never wakes up.  When SELinux is
> > disabled, the messages are received and the testcase passes.
> > 
> > I've established that the messages are being restored during restart --
> > msgctl(IPC_STAT) shows one message in each queue before calling msgrcv.
> > Adding the IPC_NOWAIT flag to the msgrcv calls gets ENOMSG, however.
> > 
> > I managed to narrow this down to security_msg_queue_msgrcv ->
> > selinux_msg_queue_msgrcv.  avc_has_perm(SECCLASS_MSG, MSG__RECEIVE) gets
> > -EACCESS, so I guess something is going awry in selinux restore hooks?
> > 
> > Any ideas?
> 
> Hmm, wait.  security_msg_msg_alloc() is being called after
> security_msg_msg_restore.  That may not be what is causing
> your troubles, but it's certainly not right.

Can you try the following patch?

Also, to actually restore the LSM labels you need to add -k to your
restart flags, but without the -k you should get a sane default
security label.

From 6609b9d71312c6641bdceaaa97bbbf2f809b6ade Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 2 Mar 2010 13:13:36 -0600
Subject: [PATCH 1/1] always security_msg_alloc before security_msg_restore

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint_msg.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index 0155c20..594580f 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -231,6 +231,12 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	msg->next = NULL;
 	pseg = &msg->next;
 
+	/* set default MAC attributes */
+	ret = security_msg_msg_alloc(msg);
+	if (ret < 0)
+		goto out;
+
+	/* if requested and allowed, reset checkpointed MAC attributes */
 	ret = security_restore_obj(ctx, (void *) msg, CKPT_SECURITY_MSG_MSG,
 				   h->sec_ref);
 	if (ret < 0)
@@ -261,7 +267,6 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	msg->m_type = h->m_type;
 	msg->m_ts = h->m_ts;
 	*clen = h->m_ts;
-	ret = security_msg_msg_alloc(msg);
  out:
 	if (ret < 0 && msg) {
 		free_msg(msg);
-- 
1.6.0.6

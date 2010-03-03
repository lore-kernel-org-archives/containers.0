From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: selinux prevents msgrcv on restore message queues?
Date: Wed, 3 Mar 2010 17:44:48 -0600
Message-ID: <20100303234448.GA27869@us.ibm.com>
References: <1267565774.11828.15.camel@localhost.localdomain>
	<20100303004727.GA8272@us.ibm.com>
	<20100303011941.GA10429@us.ibm.com>
	<1267639445.11828.19.camel@localhost.localdomain>
	<20100303194910.GC12379@us.ibm.com>
	<1267653386.3559.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1267653386.3559.9.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Wed, 2010-03-03 at 13:49 -0600, Serge E. Hallyn wrote:
> > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > > On Tue, 2010-03-02 at 19:19 -0600, Serge E. Hallyn wrote:
> > > > Can you try the following patch?
> > > > 
> > > > Also, to actually restore the LSM labels you need to add -k to your
> > > > restart flags, but without the -k you should get a sane default
> > > > security label.
> > > 
> > > Thanks, the ipc/mq tests pass with this patch and restart -k.  Without
> > > -k the tests still fail in the same manner (msgrcv fails).  Is that the
> > > behavior you'd expect?
> > 
> > Not really - the test runs as unconfined_u right?
> 
> I added a ps -Z to test-mq.sh before thawing:
> 
> # PATH=/root/cr/user-cr.git:$PATH bash test-mq.sh 
> Using output dir ./cr_mq_6T8KIG6
> XXX Test 1: simple restart with SYSVIPC msq
> check-mq: no process killed
> ../common.sh: line 45:  5173 Killed                  ( sleep $1; kill -s USR1 $$ )
> LABEL                             PID TTY          TIME CMD
> unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 4358 pts/1 00:00:00 bash
> unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5151 pts/1 00:00:00 bash
> unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5172 pts/1 00:00:00 nsexec
> unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5175 pts/1 00:00:00 sleep
> unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5178 pts/1 00:00:00 check-
> unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5183 pts/1 00:00:00 ps
> PASS

Can you try the following patch?

(this is on top of the last one - I'd sent)

The problem is that selinux does not assign a label to a msg_msg
until you do msgsnd.  So it may be best to special-case the
msg_msg object type and always have it restore the msgtype.  One
reason *NOT* to do that woudl be that the restarter might not have
msg_msg:restore permission...  But pls let me know if this patch
fixes your problem.

thanks,
-serge

From d20ab718b6ebe21a034801c461772e588b92432a Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 3 Mar 2010 11:31:33 -0600
Subject: [PATCH 1/1] always restore msg_msg label

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 security/security.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/security/security.c b/security/security.c
index 28db976..2b147cf 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1524,7 +1524,9 @@ int security_restore_obj(struct ckpt_ctx *ctx, void *v, int sectype,
 
 	/* return if caller didn't want to restore checkpointed labels */
 	if (!(ctx->uflags & RESTART_KEEP_LSM))
-		return 0;
+		/* though msg_msg label must always be restored */
+		if (sectype != CKPT_SECURITY_MSG_MSG)
+			return 0;
 
 	l = ckpt_obj_fetch(ctx, secref, CKPT_OBJ_SECURITY);
 	if (IS_ERR(l))
-- 
1.6.0.6

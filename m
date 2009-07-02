From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] Disable CLONE_PARENT for init
Date: Wed, 1 Jul 2009 17:35:20 -0700
Message-ID: <20090702003520.GA26247__39352.452036883$1246495771$gmane$org@us.ibm.com>
References: <20090701073140.GA14284@us.ibm.com>
	<20090701074654.A6C6321D57@magilla.sf.frob.com>
	<20090701082452.GA3297@redhat.com>
	<20090701214805.GA25734@us.ibm.com>
	<20090701215833.876DA404FD@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090701215833.876DA404FD-nL1rrgvulkc2UH6IwYuUx0EOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Roland McGrath [roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
| Yeah, that's fine.  Since Oleg's pointed out that there is indeed no way to
| avoid the leak in some global-init uses, it is fine to have a comment that
| says that global init problems are part of the reason to outlaw this usage.
| I just objected to a change that was really for container init but said it
| was only to fix something different.

Ok. How about this comment:

---

Disable CLONE_PARENT for init.

When global or container-init processes use CLONE_PARENT, they create a
multi-rooted process tree. Besides siblings of global init remain as
zombies on exit since they are not reaped by their parent (swapper). So
prevent global and container-inits from creating siblings.

Changelog[v3]:
	- [Roland, Oleg] Simplify comment describing the change
Changelog[v2]:
	- Simplify patch description based on comments from Eric Biederman
	  and Oleg Nesterov.
	- [Oleg Nesterov] Use SIGNAL_UNKILLABLE instead of is_global_init()

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/fork.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-mmotm/kernel/fork.c
===================================================================
--- linux-mmotm.orig/kernel/fork.c	2009-06-30 23:01:06.000000000 -0700
+++ linux-mmotm/kernel/fork.c	2009-07-01 17:29:09.000000000 -0700
@@ -974,6 +974,16 @@ static struct task_struct *copy_process(
 	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
 		return ERR_PTR(-EINVAL);
 
+	/*
+	 * Siblings of global init remain as zombies on exit since they are
+	 * not reaped by their parent (swapper). To solve this and to avoid
+	 * multi-rooted process trees, prevent global and container-inits
+	 * from creating siblings.
+	 */
+	if ((clone_flags & CLONE_PARENT) &&
+				current->signal->flags & SIGNAL_UNKILLABLE)
+		return ERR_PTR(-EINVAL);
+
 	retval = security_task_create(clone_flags);
 	if (retval)
 		goto fork_out;

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Deny CLONE_PARENT|CLONE_NEWPID combination
Date: Tue, 28 Jul 2009 12:06:54 -0700
Message-ID: <20090728190654.GA5806__14779.828899964$1248807943$gmane$org@us.ibm.com>
References: <20090728164406.GA17275@us.ibm.com>
	<20090728180553.GB6427@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090728180553.GB6427-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| > 
| > Deny CLONE_PARENT|CLONE_NEWPID combination.
| > 
| > CLONE_PARENT was used to implement an older threading model.  For consistency
| > with the CLONE_THREAD check in copy_pid_ns(), disable CLONE_PARENT and
| > CLONE_SIGHAND with CLONE_NEWPID, at least until the required semantics of
| > the pid namespaces are clear.
| > 
| > Changelog[v3]:
| > 	Remove CLONE_SIGHAND and for now only fail CLONE_NEWPID|CLONE_PARENT.
| 
| (FWIW your patch description does not reflect this...)

You are right. Here is the patch with updated description.
---

Deny CLONE_PARENT|CLONE_NEWPID|CLONE_SIGHAND combination.

CLONE_PARENT was used to implement an older threading model.  For consistency
with the CLONE_THREAD check in copy_pid_ns(), disable CLONE_PARENT with
CLONE_NEWPID, at least until the required semantics of pid namespaces are
clear.

Changelog[v3]:
	Remove CLONE_SIGHAND and for now only fail CLONE_NEWPID|CLONE_PARENT.
Changelog[v2]:
	[Eric Biederman] Disable CLONE_SIGHAND also ?

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/pid_namespace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-mmotm/kernel/pid_namespace.c
===================================================================
--- linux-mmotm.orig/kernel/pid_namespace.c	2009-07-16 10:03:01.000000000 -0700
+++ linux-mmotm/kernel/pid_namespace.c	2009-07-16 11:37:24.000000000 -0700
@@ -118,7 +118,7 @@
 {
 	if (!(flags & CLONE_NEWPID))
 		return get_pid_ns(old_ns);
-	if (flags & CLONE_THREAD)
+	if (flags & (CLONE_THREAD|CLONE_PARENT))
 		return ERR_PTR(-EINVAL);
 	return create_pid_namespace(old_ns);
 }

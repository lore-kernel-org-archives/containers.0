From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 08/38] pidns 2/2: rewrite copy_pid_ns()
Date: Fri, 22 May 2009 08:55:02 +0400
Message-ID: <1242968132-1044-8-git-send-email-adobriyan__46726.3143430047$1242968848$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

copy_pid_ns() is a perfect example of a case where unwinding leads to more
code and makes it less clear. Watch the diffstat.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 kernel/pid_namespace.c |   18 +++---------------
 1 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 495d5de..821722a 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -116,23 +116,11 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 
 struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old_ns)
 {
-	struct pid_namespace *new_ns;
-
-	BUG_ON(!old_ns);
-	new_ns = get_pid_ns(old_ns);
 	if (!(flags & CLONE_NEWPID))
-		goto out;
-
-	new_ns = ERR_PTR(-EINVAL);
+		return get_pid_ns(old_ns);
 	if (flags & CLONE_THREAD)
-		goto out_put;
-
-	new_ns = create_pid_namespace(old_ns);
-
-out_put:
-	put_pid_ns(old_ns);
-out:
-	return new_ns;
+		return ERR_PTR(-EINVAL);
+	return create_pid_namespace(old_ns);
 }
 
 void free_pid_ns(struct kref *kref)
-- 
1.5.6.5

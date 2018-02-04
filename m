From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: [RFC 2/3] seccomp: hoist out filter resolving logic
Date: Sun,  4 Feb 2018 11:49:45 +0100
Message-ID: <20180204104946.25559-3-tycho__29723.9035521217$1517741358$gmane$org@tycho.ws>
References: <20180204104946.25559-1-tycho@tycho.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180204104946.25559-1-tycho-E0fblnxP3wo@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Hoist out the nth filter resolving logic that ptrace uses into a new
function. We'll use this in the next patch to implement the new
PTRACE_SECCOMP_GET_FILTER_FLAGS command. This is based on an older patch
that I had sent a while ago; it significantly revamps the get_nth_filter
logic based on previous suggestions from Oleg.

Signed-off-by: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
CC: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
CC: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
CC: Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
---
 kernel/seccomp.c | 77 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 45 insertions(+), 32 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 9541eb379e74..800db3f2866f 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -1179,49 +1179,68 @@ long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
 }
 
 #if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
-long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
-			void __user *data)
+static struct seccomp_filter *get_nth_filter(struct task_struct *task,
+					     unsigned long filter_off)
 {
-	struct seccomp_filter *filter;
-	struct sock_fprog_kern *fprog;
-	long ret;
-	unsigned long count = 0;
-
-	if (!capable(CAP_SYS_ADMIN) ||
-	    current->seccomp.mode != SECCOMP_MODE_DISABLED) {
-		return -EACCES;
-	}
+	struct seccomp_filter *orig, *filter;
+	unsigned long count;
 
+	/*
+	 * Note: this is only correct because the caller should be the (ptrace)
+	 * tracer of the task, otherwise lock_task_sighand is needed.
+	 */
 	spin_lock_irq(&task->sighand->siglock);
+
 	if (task->seccomp.mode != SECCOMP_MODE_FILTER) {
-		ret = -EINVAL;
-		goto out;
+		spin_unlock_irq(&task->sighand->siglock);
+		return ERR_PTR(-EINVAL);
 	}
 
-	filter = task->seccomp.filter;
-	while (filter) {
-		filter = filter->prev;
+	orig = task->seccomp.filter;
+	__get_seccomp_filter(orig);
+	spin_unlock_irq(&task->sighand->siglock);
+
+	count = 0;
+	for (filter = orig; filter; filter = filter->prev)
 		count++;
-	}
 
 	if (filter_off >= count) {
-		ret = -ENOENT;
+		filter = ERR_PTR(-ENOENT);
 		goto out;
 	}
-	count -= filter_off;
 
-	filter = task->seccomp.filter;
-	while (filter && count > 1) {
-		filter = filter->prev;
+	count -= filter_off;
+	for (filter = orig; filter && count > 1; filter = filter->prev)
 		count--;
-	}
 
 	if (WARN_ON(count != 1 || !filter)) {
-		/* The filter tree shouldn't shrink while we're using it. */
-		ret = -ENOENT;
+		filter = ERR_PTR(-ENOENT);
 		goto out;
 	}
 
+	__get_seccomp_filter(filter);
+
+out:
+	__put_seccomp_filter(orig);
+	return filter;
+}
+
+long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
+			void __user *data)
+{
+	struct seccomp_filter *filter;
+	struct sock_fprog_kern *fprog;
+	long ret;
+
+	if (!capable(CAP_SYS_ADMIN) ||
+	    current->seccomp.mode != SECCOMP_MODE_DISABLED) {
+		return -EACCES;
+	}
+
+	filter = get_nth_filter(task, filter_off);
+	if (IS_ERR(filter))
+		return PTR_ERR(filter);
+
 	fprog = filter->prog->orig_prog;
 	if (!fprog) {
 		/* This must be a new non-cBPF filter, since we save
@@ -1236,17 +1255,11 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
 	if (!data)
 		goto out;
 
-	__get_seccomp_filter(filter);
-	spin_unlock_irq(&task->sighand->siglock);
-
 	if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fprog)))
 		ret = -EFAULT;
 
-	__put_seccomp_filter(filter);
-	return ret;
-
 out:
-	spin_unlock_irq(&task->sighand->siglock);
+	__put_seccomp_filter(filter);
 	return ret;
 }
 #endif
-- 
2.14.1

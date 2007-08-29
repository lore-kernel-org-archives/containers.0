From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] Switch nfs/callback.c to using struct pid, not pid_t
Date: Wed, 29 Aug 2007 17:36:24 +0400
Message-ID: <46D57658.2040704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
List-Id: containers.vger.kernel.org

Pid namespaces make it dangerous to use pid and tgid values
when run in some namespace. The struct pid itself is going
to be the only way for working with task pids, so make the
nfs callback thread use it.

Since nfs_callback_info.pid is set to current's one and reset
on the thread exit, it is safe not to get the struct pid. 

Since this pid is used later under lock_kernel() w/o sleeping 
operations, checking for i to be not NULL and killing the 
thread with kill_pid() is safe.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a796be5..5b8e5fc 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -27,7 +27,7 @@
 struct nfs_callback_data {
 	unsigned int users;
 	struct svc_serv *serv;
-	pid_t pid;
+	struct pid *pid;
 	struct completion started;
 	struct completion stopped;
 };
@@ -64,7 +64,7 @@ static void nfs_callback_svc(struct svc_
 	__module_get(THIS_MODULE);
 	lock_kernel();
 
-	nfs_callback_info.pid = current->pid;
+	nfs_callback_info.pid = task_pid(current);
 	daemonize("nfsv4-svc");
 	/* Process request with signals blocked, but allow SIGKILL.  */
 	allow_signal(SIGKILL);
@@ -98,7 +98,7 @@ static void nfs_callback_svc(struct svc_
 	}
 
 	svc_exit_thread(rqstp);
-	nfs_callback_info.pid = 0;
+	nfs_callback_info.pid = NULL;
 	complete(&nfs_callback_info.stopped);
 	unlock_kernel();
 	module_put_and_exit(0);
@@ -114,7 +114,7 @@ int nfs_callback_up(void)
 
 	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
-	if (nfs_callback_info.users++ || nfs_callback_info.pid != 0)
+	if (nfs_callback_info.users++ || nfs_callback_info.pid != NULL)
 		goto out;
 	init_completion(&nfs_callback_info.started);
 	init_completion(&nfs_callback_info.stopped);
@@ -157,9 +157,9 @@ void nfs_callback_down(void)
 	mutex_lock(&nfs_callback_mutex);
 	nfs_callback_info.users--;
 	do {
-		if (nfs_callback_info.users != 0 || nfs_callback_info.pid == 0)
+		if (nfs_callback_info.users != 0 || nfs_callback_info.pid == NULL)
 			break;
-		if (kill_proc(nfs_callback_info.pid, SIGKILL, 1) < 0)
+		if (kill_pid(nfs_callback_info.pid, SIGKILL, 1) < 0)
 			break;
 	} while (wait_for_completion_timeout(&nfs_callback_info.stopped, 5*HZ) == 0);
 	mutex_unlock(&nfs_callback_mutex);

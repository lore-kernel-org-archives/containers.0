From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: [PATCH] sys_getsid: don't use ->nsproxy directly
Date: Thu, 6 Dec 2007 20:53:14 +0300
Message-ID: <20071206175314.GA11727@tv-sign.ru>
References: <m11wa0v31c.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m11wa0v31c.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

With the new semantics of find_vpid() we don't need to play with ->nsproxy
explicitely, _vxx() do the right things.

Also s/tasklist/rcu/.

Signed-off-by: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>

--- PT/kernel/sys.c~	2007-12-05 21:43:18.000000000 +0300
+++ PT/kernel/sys.c	2007-12-06 20:09:02.000000000 +0300
@@ -1025,19 +1025,16 @@ asmlinkage long sys_getsid(pid_t pid)
 	else {
 		int retval;
 		struct task_struct *p;
-		struct pid_namespace *ns;
 
-		ns = current->nsproxy->pid_ns;
-
-		read_lock(&tasklist_lock);
-		p = find_task_by_pid_ns(pid, ns);
+		rcu_read_lock();
+		p = find_task_by_vpid(pid);
 		retval = -ESRCH;
 		if (p) {
 			retval = security_task_getsid(p);
 			if (!retval)
-				retval = task_session_nr_ns(p, ns);
+				retval = task_session_vnr(p);
 		}
-		read_unlock(&tasklist_lock);
+		rcu_read_unlock();
 		return retval;
 	}
 }

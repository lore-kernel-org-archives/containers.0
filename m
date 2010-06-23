From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] pid_ns: move pid_ns_release_proc() from
	proc_flush_task() to zap_pid_ns_processes()
Date: Wed, 23 Jun 2010 22:37:35 +0200
Message-ID: <20100623203735.GB25298@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<20100617212003.GA4182@redhat.com>
	<20100618082033.GD16877@hawkmoon.kerlabs.com>
	<20100618111554.GA3252@redhat.com>
	<20100618160849.GA7404@redhat.com>
	<20100618173320.GG16877@hawkmoon.kerlabs.com>
	<20100618175541.GA13680@redhat.com>
	<20100618212355.GA29478@redhat.com>
	<20100619190840.GA3424@redhat.com>
	<20100623203652.GA25298@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100623203652.GA25298-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This is mostly cleanup and optimization, but also fixes the bug.

proc_flush_task() checks upid->nr == 1 to detect the case when
a sub-namespace exits. However, this doesn't work in case when
a multithreaded init execs and calls release_task(old_leader),
the old leader has the same pid 1.

Move pid_ns_release_proc() to zap_pid_ns_processes(), it is called
when we know for sure that init is exiting.

Note: with or without this change this mntput() can happen before the
EXIT_DEAD tasks not visible to do_wait() have passed proc_flush_task().
We need more fixes.

Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

 fs/proc/base.c         |    4 ----
 kernel/pid_namespace.c |    2 ++
 2 files changed, 2 insertions(+), 4 deletions(-)

--- 35-rc3/fs/proc/base.c~PNS_5_MOVE_MNTPUT_TO_ZAP	2010-06-23 22:06:01.000000000 +0200
+++ 35-rc3/fs/proc/base.c	2010-06-23 22:10:26.000000000 +0200
@@ -2745,10 +2745,6 @@ void proc_flush_task(struct task_struct 
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
 					tgid->numbers[i].nr);
 	}
-
-	upid = &pid->numbers[pid->level];
-	if (upid->nr == 1)
-		pid_ns_release_proc(upid->ns);
 }
 
 static struct dentry *proc_pid_instantiate(struct inode *dir,
--- 35-rc3/kernel/pid_namespace.c~PNS_5_MOVE_MNTPUT_TO_ZAP	2010-06-23 22:13:07.000000000 +0200
+++ 35-rc3/kernel/pid_namespace.c	2010-06-23 22:13:55.000000000 +0200
@@ -189,6 +189,8 @@ void zap_pid_ns_processes(struct pid_nam
 	} while (rc != -ECHILD);
 
 	acct_exit_ns(pid_ns);
+	pid_ns_release_proc(pid_ns);
+
 	return;
 }

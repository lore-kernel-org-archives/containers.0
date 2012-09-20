From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 15/27] userns: Teach trace to use from_kuid
Date: Wed, 19 Sep 2012 18:52:17 -0700
Message-ID: <1348105949-25454-15-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- When tracing capture the kuid.
- When displaying the data to user space convert the kuid into the
  user namespace of the process that opened the report file.

Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig         |    1 -
 kernel/trace/trace.c |    3 ++-
 kernel/trace/trace.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 6de46ef..2a388e5 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -927,7 +927,6 @@ config UIDGID_CONVERTED
 	# Features
 	depends on IMA = n
 	depends on EVM = n
-	depends on TRACING = n
 	depends on FS_POSIX_ACL = n
 	depends on QUOTA = n
 	depends on QUOTACTL = n
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 5c38c81..c9ace83 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2060,7 +2060,8 @@ print_trace_header(struct seq_file *m, struct trace_iterator *iter)
 	seq_puts(m, "#    -----------------\n");
 	seq_printf(m, "#    | task: %.16s-%d "
 		   "(uid:%d nice:%ld policy:%ld rt_prio:%ld)\n",
-		   data->comm, data->pid, data->uid, data->nice,
+		   data->comm, data->pid,
+		   from_kuid_munged(seq_user_ns(m), data->uid), data->nice,
 		   data->policy, data->rt_priority);
 	seq_puts(m, "#    -----------------\n");
 
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 55e1f7f..40a6f30 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -147,7 +147,7 @@ struct trace_array_cpu {
 	unsigned long		skipped_entries;
 	cycle_t			preempt_timestamp;
 	pid_t			pid;
-	uid_t			uid;
+	kuid_t			uid;
 	char			comm[TASK_COMM_LEN];
 };
 
-- 
1.7.5.4

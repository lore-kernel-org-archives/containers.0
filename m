From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V7 08/10] fork: audit on creation of new namespace(s) with
	clone and unshare
Date: Tue, 12 May 2015 16:02:45 -0400
Message-ID: <cc07dc56b3a760a9e4bd4edf030065ece205d1a0.1431451547.git.rgb@redhat.com>
References: <cover.1431451547.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

When clone(2) is called to fork a new process or unshare(2) creating one or
more namespaces, audit the event to tie the new pid with the namespace IDs.

Added the macro CLONE_NEW_MASK_ALL to refer to all CLONE_NEW* flags.

Cleaned up check_unshare_flags() to make it more readable using this new macro.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/uapi/linux/sched.h |    6 ++++++
 kernel/fork.c              |   13 +++++++++----
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/sched.h b/include/uapi/linux/sched.h
index cc89dde..5f03ce9 100644
--- a/include/uapi/linux/sched.h
+++ b/include/uapi/linux/sched.h
@@ -28,6 +28,12 @@
 #define CLONE_NEWUSER		0x10000000	/* New user namespace */
 #define CLONE_NEWPID		0x20000000	/* New pid namespace */
 #define CLONE_NEWNET		0x40000000	/* New network namespace */
+#define CLONE_NEW_MASK_ALL	 (CLONE_NEWNS \
+				| CLONE_NEWUTS \
+				| CLONE_NEWIPC \
+				| CLONE_NEWUSER \
+				| CLONE_NEWPID \
+				| CLONE_NEWNET)	/* mask of all namespace type flags */
 #define CLONE_IO		0x80000000	/* Clone io context */
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index cf65139..c09c5df 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1680,6 +1680,9 @@ long do_fork(unsigned long clone_flags,
 			get_task_struct(p);
 		}
 
+		if (unlikely(clone_flags & CLONE_NEW_MASK_ALL))
+			audit_log_ns_info(p);
+
 		wake_up_new_task(p);
 
 		/* forking complete and child started to run, tell ptracer */
@@ -1802,10 +1805,9 @@ void __init proc_caches_init(void)
  */
 static int check_unshare_flags(unsigned long unshare_flags)
 {
-	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
-				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|
-				CLONE_NEWUSER|CLONE_NEWPID))
+	if (unshare_flags & ~(CLONE_THREAD | CLONE_FS | CLONE_SIGHAND |
+				CLONE_VM | CLONE_FILES | CLONE_SYSVSEM |
+				CLONE_NEW_MASK_ALL))
 		return -EINVAL;
 	/*
 	 * Not implemented, but pretend it works if there is nothing to
@@ -1964,6 +1966,9 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 			commit_creds(new_cred);
 			new_cred = NULL;
 		}
+
+		if (unshare_flags & CLONE_NEW_MASK_ALL)
+			audit_log_ns_info(current);
 	}
 
 bad_unshare_cleanup_cred:
-- 
1.7.1

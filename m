From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 14/36] c/r of restart-blocks: export
	functionality used in next patch
Date: Tue,  7 Apr 2009 08:27:22 -0400
Message-ID: <1239107264-21775-15-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

To support c/r of restart-blocks (system call that need to be
restarted because they were interrupted but there was no userspace
visible side-effect), export restart-block callbacks for poll()
and futex() syscalls.

More details on c/r of restart-blocks and how it works in the
following patch.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/select.c                  |    2 +-
 include/linux/futex.h        |   10 ++++++++++
 include/linux/poll.h         |    3 +++
 include/linux/posix-timers.h |    2 ++
 kernel/futex.c               |   11 +----------
 kernel/posix-timers.c        |    2 +-
 6 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 0fe0e14..e64ddc6 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -833,7 +833,7 @@ out_fds:
 	return err;
 }
 
-static long do_restart_poll(struct restart_block *restart_block)
+long do_restart_poll(struct restart_block *restart_block)
 {
 	struct pollfd __user *ufds = restart_block->poll.ufds;
 	int nfds = restart_block->poll.nfds;
diff --git a/include/linux/futex.h b/include/linux/futex.h
index 3bf5bb5..dd0e06b 100644
--- a/include/linux/futex.h
+++ b/include/linux/futex.h
@@ -130,6 +130,16 @@ extern int
 handle_futex_death(u32 __user *uaddr, struct task_struct *curr, int pi);
 
 /*
+ * In case we must use restart_block to restart a futex_wait,
+ * we encode in the 'flags' shared capability
+ */
+#define FLAGS_SHARED		0x01
+#define FLAGS_CLOCKRT		0x02
+
+/* referenced by checkpoint/restart */
+extern long futex_wait_restart(struct restart_block *restart);
+
+/*
  * Futexes are matched on equal values of this key.
  * The key type depends on whether it's a shared or private mapping.
  * Don't rearrange members without looking at hash_futex().
diff --git a/include/linux/poll.h b/include/linux/poll.h
index 8c24ef8..97f95a7 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -131,6 +131,9 @@ extern int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 
 extern int poll_select_set_timeout(struct timespec *to, long sec, long nsec);
 
+/* used by checkpoint/restart */
+extern long do_restart_poll(struct restart_block *restart_block);
+
 #endif /* KERNEL */
 
 #endif /* _LINUX_POLL_H */
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 4f71bf4..3d0e946 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -119,4 +119,6 @@ long clock_nanosleep_restart(struct restart_block *restart_block);
 
 void update_rlimit_cpu(unsigned long rlim_new);
 
+int invalid_clockid(const clockid_t which_clock);
+
 #endif
diff --git a/kernel/futex.c b/kernel/futex.c
index 438701a..0c78ffe 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -1152,15 +1152,6 @@ handle_fault:
 	goto retry;
 }
 
-/*
- * In case we must use restart_block to restart a futex_wait,
- * we encode in the 'flags' shared capability
- */
-#define FLAGS_SHARED		0x01
-#define FLAGS_CLOCKRT		0x02
-
-static long futex_wait_restart(struct restart_block *restart);
-
 static int futex_wait(u32 __user *uaddr, int fshared,
 		      u32 val, ktime_t *abs_time, u32 bitset, int clockrt)
 {
@@ -1324,7 +1315,7 @@ out:
 }
 
 
-static long futex_wait_restart(struct restart_block *restart)
+long futex_wait_restart(struct restart_block *restart)
 {
 	u32 __user *uaddr = (u32 __user *)restart->futex.uaddr;
 	int fshared = 0;
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 052ec4d..a734f4e 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -205,7 +205,7 @@ static int no_timer_create(struct k_itimer *new_timer)
 /*
  * Return nonzero if we know a priori this clockid_t value is bogus.
  */
-static inline int invalid_clockid(const clockid_t which_clock)
+inline int invalid_clockid(const clockid_t which_clock)
 {
 	if (which_clock < 0)	/* CPU clock, posix_cpu_* will check it */
 		return 0;
-- 
1.5.4.3

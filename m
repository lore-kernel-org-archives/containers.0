From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: [PATCH v2 2/4] seccomp: make get_nth_filter available outside of
	CHECKPOINT_RESTORE
Date: Thu, 17 May 2018 09:12:16 -0600
Message-ID: <20180517151218.12850-3-tycho__18630.1753776663$1526569892$gmane$org@tycho.ws>
References: <20180517151218.12850-1-tycho@tycho.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180517151218.12850-1-tycho-E0fblnxP3wo@public.gmane.org>
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
Cc: "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

In the next commit we'll use this same mnemonic to get a listener for the
nth filter, so we need it available outside of CHECKPOINT_RESTORE. This is
slightly looser than necessary, because it really could be
CHECKPOINT_RESTORE || USER_NOTIFICATION, but it's declared static and this
complicates the code less, so hopefully it's ok.

Signed-off-by: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
CC: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
CC: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
CC: Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>

v2: new in v2
---
 kernel/seccomp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index a169a62cb78a..f136eca93f2f 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -1180,7 +1180,7 @@ long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
 	return do_seccomp(op, 0, uargs);
 }
 
-#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
+#if defined(CONFIG_SECCOMP_FILTER)
 static struct seccomp_filter *get_nth_filter(struct task_struct *task,
 					     unsigned long filter_off)
 {
@@ -1227,6 +1227,7 @@ static struct seccomp_filter *get_nth_filter(struct task_struct *task,
 	return filter;
 }
 
+#if defined(CONFIG_CHECKPOINT_RESTORE)
 long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
 			void __user *data)
 {
@@ -1299,7 +1300,8 @@ long seccomp_get_metadata(struct task_struct *task,
 	__put_seccomp_filter(filter);
 	return ret;
 }
-#endif
+#endif /* CONFIG_CHECKPOINT_RESTORE */
+#endif /* CONFIG_SECCOMP_FILTER */
 
 #ifdef CONFIG_SYSCTL
 
-- 
2.17.0

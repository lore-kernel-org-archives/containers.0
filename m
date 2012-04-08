From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 20/43] userns: Replace user_ns_map_uid and user_ns_map_gid
	with from_kuid and from_kgid
Date: Sat,  7 Apr 2012 22:15:16 -0700
Message-ID: <1333862139-31737-20-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

These function are no longer needed replace them with their more useful equivalents.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |   12 ------------
 ipc/mqueue.c                   |    3 +--
 kernel/signal.c                |    2 +-
 net/core/sock.c                |    4 ++--
 4 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index a2c6145..4e72922 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -69,16 +69,4 @@ static inline void put_user_ns(struct user_namespace *ns)
 
 #endif
 
-static inline uid_t user_ns_map_uid(struct user_namespace *to,
-	const struct cred *cred, kuid_t uid)
-{
-	return from_kuid_munged(to, uid);
-}
-
-static inline gid_t user_ns_map_gid(struct user_namespace *to,
-	const struct cred *cred, kgid_t gid)
-{
-	return from_kgid_munged(to, gid);
-}
-
 #endif /* _LINUX_USER_H */
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index b53cf34..b6a0d46 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -538,8 +538,7 @@ static void __do_notify(struct mqueue_inode_info *info)
 			rcu_read_lock();
 			sig_i.si_pid = task_tgid_nr_ns(current,
 						ns_of_pid(info->notify_owner));
-			sig_i.si_uid = user_ns_map_uid(info->notify_user_ns,
-						current_cred(), current_uid());
+			sig_i.si_uid = from_kuid_munged(info->notify_user_ns, current_uid());
 			rcu_read_unlock();
 
 			kill_pid_info(info->notify.sigev_signo,
diff --git a/kernel/signal.c b/kernel/signal.c
index 2734dc9..d630327 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1026,7 +1026,7 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 static inline uid_t map_cred_ns(const struct cred *cred,
 				struct user_namespace *ns)
 {
-	return user_ns_map_uid(ns, cred, cred->uid);
+	return from_kuid_munged(ns, cred->uid);
 }
 
 #ifdef CONFIG_USER_NS
diff --git a/net/core/sock.c b/net/core/sock.c
index b2e14c0..e1ec8ba 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -821,8 +821,8 @@ void cred_to_ucred(struct pid *pid, const struct cred *cred,
 	if (cred) {
 		struct user_namespace *current_ns = current_user_ns();
 
-		ucred->uid = user_ns_map_uid(current_ns, cred, cred->euid);
-		ucred->gid = user_ns_map_gid(current_ns, cred, cred->egid);
+		ucred->uid = from_kuid(current_ns, cred->euid);
+		ucred->gid = from_kgid(current_ns, cred->egid);
 	}
 }
 EXPORT_SYMBOL_GPL(cred_to_ucred);
-- 
1.7.2.5

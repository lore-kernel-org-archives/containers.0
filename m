From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/6] user namespace: clamp down users of cap_raised
Date: Fri,  4 Nov 2011 22:24:39 +0000
Message-ID: <1320445482-8459-4-git-send-email-serge@hallyn.com>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320445482-8459-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
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
Cc: richard-/L3Ra7n9ekc@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

A few modules are using cap_raised(current_cap(), cap) to authorize
actions.  This means that tasks which are privileged in non-initial
user namespaces will be deemed privileged.  The privilege should only
be granted if the task is in the initial user namespace.

Switching the calls to capable() would change the behavior - it would
cause the LSM capable hooks to be called, and set PF_SUPERPRIV if
the capability was used.  So instead, put in an explicit check and
refuse privilege if the caller is not in init_user_ns.

Changelog:
Oct 23: Use a nice macro to make the code shorter and easier to read,
	per advice from Andrew Morgan and David Howells.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/block/drbd/drbd_nl.c           |    2 +-
 drivers/md/dm-log-userspace-transfer.c |    2 +-
 drivers/staging/pohmelfs/config.c      |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 include/linux/cred.h                   |    2 ++
 5 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index af2a250..b7b19b8 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -2297,7 +2297,7 @@ static void drbd_connector_callback(struct cn_msg *req, struct netlink_skb_parms
 		return;
 	}
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
+	if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SYS_ADMIN)) {
 		retcode = ERR_PERM;
 		goto fail;
 	}
diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-userspace-transfer.c
index 1f23e04..126a79b 100644
--- a/drivers/md/dm-log-userspace-transfer.c
+++ b/drivers/md/dm-log-userspace-transfer.c
@@ -134,7 +134,7 @@ static void cn_ulog_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SYS_ADMIN))
 		return;
 
 	spin_lock(&receiving_list_lock);
diff --git a/drivers/staging/pohmelfs/config.c b/drivers/staging/pohmelfs/config.c
index b6c42cb..327c047 100644
--- a/drivers/staging/pohmelfs/config.c
+++ b/drivers/staging/pohmelfs/config.c
@@ -525,7 +525,7 @@ static void pohmelfs_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *n
 {
 	int err;
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SYS_ADMIN))
 		return;
 
 	switch (msg->flags) {
diff --git a/drivers/video/uvesafb.c b/drivers/video/uvesafb.c
index 7f8472c..94e0e9d 100644
--- a/drivers/video/uvesafb.c
+++ b/drivers/video/uvesafb.c
@@ -73,7 +73,7 @@ static void uvesafb_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *ns
 	struct uvesafb_task *utask;
 	struct uvesafb_ktask *task;
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SYS_ADMIN))
 		return;
 
 	if (msg->seq >= UVESAFB_TASKS_MAX)
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 4030896..2f75da7 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -359,9 +359,11 @@ static inline void put_cred(const struct cred *_cred)
 
 #ifdef CONFIG_USER_NS
 #define current_user_ns() (current_cred_xxx(user_ns))
+#define IN_ROOT_USER_NS() (current_user_ns() == &init_user_ns)
 #else
 extern struct user_namespace init_user_ns;
 #define current_user_ns() (&init_user_ns)
+#define IN_ROOT_USER_NS() (1)
 #endif
 
 
-- 
1.7.0.4

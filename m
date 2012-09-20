From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 11/27] userns: Convert the audit loginuid  to be a kuid
Date: Wed, 19 Sep 2012 18:52:13 -0700
Message-ID: <1348105949-25454-11-git-send-email-ebiederm@xmission.com>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Always store audit loginuids in type kuid_t.

Print loginuids by converting them into uids in the appropriate user
namespace, and then printing the resulting uid.

Modify audit_get_loginuid to return a kuid_t.

Modify audit_set_loginuid to take a kuid_t.

Modify /proc/<pid>/loginuid on read to convert the loginuid into the
user namespace of the opener of the file.

Modify /proc/<pid>/loginud on write to convert the loginuid
rom the user namespace of the opener of the file.

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org> ?
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/tty/tty_audit.c           |   14 ++++++++------
 fs/proc/base.c                    |   12 ++++++++++--
 include/linux/audit.h             |    6 +++---
 include/linux/init_task.h         |    2 +-
 include/linux/sched.h             |    2 +-
 include/linux/tty.h               |    4 ++--
 include/net/netlabel.h            |    2 +-
 include/net/xfrm.h                |   23 ++++++++++++-----------
 kernel/audit.c                    |   20 ++++++++++----------
 kernel/audit_watch.c              |    2 +-
 kernel/auditfilter.c              |    7 ++++---
 kernel/auditsc.c                  |   20 +++++++++++---------
 net/core/dev.c                    |    2 +-
 net/netlabel/netlabel_unlabeled.c |    2 +-
 net/netlabel/netlabel_user.c      |    2 +-
 net/xfrm/xfrm_policy.c            |    8 ++++----
 net/xfrm/xfrm_state.c             |    6 +++---
 net/xfrm/xfrm_user.c              |   12 ++++++------
 18 files changed, 80 insertions(+), 66 deletions(-)

diff --git a/drivers/tty/tty_audit.c b/drivers/tty/tty_audit.c
index 7c58669..5b59bd7 100644
--- a/drivers/tty/tty_audit.c
+++ b/drivers/tty/tty_audit.c
@@ -61,7 +61,7 @@ static void tty_audit_buf_put(struct tty_audit_buf *buf)
 }
 
 static void tty_audit_log(const char *description, struct task_struct *tsk,
-			  uid_t loginuid, unsigned sessionid, int major,
+			  kuid_t loginuid, unsigned sessionid, int major,
 			  int minor, unsigned char *data, size_t size)
 {
 	struct audit_buffer *ab;
@@ -73,7 +73,9 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
 
 		audit_log_format(ab, "%s pid=%u uid=%u auid=%u ses=%u "
 				 "major=%d minor=%d comm=", description,
-				 tsk->pid, uid, loginuid, sessionid,
+				 tsk->pid, uid,
+				 from_kuid(&init_user_ns, loginuid),
+				 sessionid,
 				 major, minor);
 		get_task_comm(name, tsk);
 		audit_log_untrustedstring(ab, name);
@@ -89,7 +91,7 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
  *	Generate an audit message from the contents of @buf, which is owned by
  *	@tsk with @loginuid.  @buf->mutex must be locked.
  */
-static void tty_audit_buf_push(struct task_struct *tsk, uid_t loginuid,
+static void tty_audit_buf_push(struct task_struct *tsk, kuid_t loginuid,
 			       unsigned int sessionid,
 			       struct tty_audit_buf *buf)
 {
@@ -112,7 +114,7 @@ static void tty_audit_buf_push(struct task_struct *tsk, uid_t loginuid,
  */
 static void tty_audit_buf_push_current(struct tty_audit_buf *buf)
 {
-	uid_t auid = audit_get_loginuid(current);
+	kuid_t auid = audit_get_loginuid(current);
 	unsigned int sessionid = audit_get_sessionid(current);
 	tty_audit_buf_push(current, auid, sessionid, buf);
 }
@@ -179,7 +181,7 @@ void tty_audit_tiocsti(struct tty_struct *tty, char ch)
 	}
 
 	if (should_audit && audit_enabled) {
-		uid_t auid;
+		kuid_t auid;
 		unsigned int sessionid;
 
 		auid = audit_get_loginuid(current);
@@ -199,7 +201,7 @@ void tty_audit_tiocsti(struct tty_struct *tty, char ch)
  * reference to the tty audit buffer if available.
  * Flush the buffer or return an appropriate error code.
  */
-int tty_audit_push_task(struct task_struct *tsk, uid_t loginuid, u32 sessionid)
+int tty_audit_push_task(struct task_struct *tsk, kuid_t loginuid, u32 sessionid)
 {
 	struct tty_audit_buf *buf = ERR_PTR(-EPERM);
 	unsigned long flags;
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1b6c84c..138cff4 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1089,7 +1089,8 @@ static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
 	if (!task)
 		return -ESRCH;
 	length = scnprintf(tmpbuf, TMPBUFLEN, "%u",
-				audit_get_loginuid(task));
+			   from_kuid(file->f_cred->user_ns,
+				     audit_get_loginuid(task)));
 	put_task_struct(task);
 	return simple_read_from_buffer(buf, count, ppos, tmpbuf, length);
 }
@@ -1101,6 +1102,7 @@ static ssize_t proc_loginuid_write(struct file * file, const char __user * buf,
 	char *page, *tmp;
 	ssize_t length;
 	uid_t loginuid;
+	kuid_t kloginuid;
 
 	rcu_read_lock();
 	if (current != pid_task(proc_pid(inode), PIDTYPE_PID)) {
@@ -1130,7 +1132,13 @@ static ssize_t proc_loginuid_write(struct file * file, const char __user * buf,
 		goto out_free_page;
 
 	}
-	length = audit_set_loginuid(loginuid);
+	kloginuid = make_kuid(file->f_cred->user_ns, loginuid);
+	if (!uid_valid(kloginuid)) {
+		length = -EINVAL;
+		goto out_free_page;
+	}
+
+	length = audit_set_loginuid(kloginuid);
 	if (likely(length == 0))
 		length = count;
 
diff --git a/include/linux/audit.h b/include/linux/audit.h
index ca019bb..12367cb 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -527,7 +527,7 @@ static inline void audit_ptrace(struct task_struct *t)
 extern unsigned int audit_serial(void);
 extern int auditsc_get_stamp(struct audit_context *ctx,
 			      struct timespec *t, unsigned int *serial);
-extern int  audit_set_loginuid(uid_t loginuid);
+extern int  audit_set_loginuid(kuid_t loginuid);
 #define audit_get_loginuid(t) ((t)->loginuid)
 #define audit_get_sessionid(t) ((t)->sessionid)
 extern void audit_log_task_context(struct audit_buffer *ab);
@@ -639,7 +639,7 @@ extern int audit_signals;
 #define audit_core_dumps(i) do { ; } while (0)
 #define audit_seccomp(i,s,c) do { ; } while (0)
 #define auditsc_get_stamp(c,t,s) (0)
-#define audit_get_loginuid(t) (-1)
+#define audit_get_loginuid(t) (INVALID_UID)
 #define audit_get_sessionid(t) (-1)
 #define audit_log_task_context(b) do { ; } while (0)
 #define audit_ipc_obj(i) ((void)0)
@@ -705,7 +705,7 @@ extern int		    audit_update_lsm_rules(void);
 extern int audit_filter_user(void);
 extern int audit_filter_type(int type);
 extern int  audit_receive_filter(int type, int pid, int seq,
-				void *data, size_t datasz, uid_t loginuid,
+				void *data, size_t datasz, kuid_t loginuid,
 				u32 sessionid, u32 sid);
 extern int audit_enabled;
 #else
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 89f1cb1..6d087c5 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -92,7 +92,7 @@ extern struct group_info init_groups;
 
 #ifdef CONFIG_AUDITSYSCALL
 #define INIT_IDS \
-	.loginuid = -1, \
+	.loginuid = INVALID_UID, \
 	.sessionid = -1,
 #else
 #define INIT_IDS
diff --git a/include/linux/sched.h b/include/linux/sched.h
index c147e70..f64d092 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1426,7 +1426,7 @@ struct task_struct {
 
 	struct audit_context *audit_context;
 #ifdef CONFIG_AUDITSYSCALL
-	uid_t loginuid;
+	kuid_t loginuid;
 	unsigned int sessionid;
 #endif
 	struct seccomp seccomp;
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 9f47ab5..7298385 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -553,7 +553,7 @@ extern void tty_audit_fork(struct signal_struct *sig);
 extern void tty_audit_tiocsti(struct tty_struct *tty, char ch);
 extern void tty_audit_push(struct tty_struct *tty);
 extern int tty_audit_push_task(struct task_struct *tsk,
-			       uid_t loginuid, u32 sessionid);
+			       kuid_t loginuid, u32 sessionid);
 #else
 static inline void tty_audit_add_data(struct tty_struct *tty,
 				      unsigned char *data, size_t size)
@@ -572,7 +572,7 @@ static inline void tty_audit_push(struct tty_struct *tty)
 {
 }
 static inline int tty_audit_push_task(struct task_struct *tsk,
-				      uid_t loginuid, u32 sessionid)
+				      kuid_t loginuid, u32 sessionid)
 {
 	return 0;
 }
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index f674409..2c95d55 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -110,7 +110,7 @@ struct cipso_v4_doi;
 /* NetLabel audit information */
 struct netlbl_audit {
 	u32 secid;
-	uid_t loginuid;
+	kuid_t loginuid;
 	u32 sessionid;
 };
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d9509eb..1f217e2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -662,7 +662,7 @@ struct xfrm_spi_skb_cb {
 /* Audit Information */
 struct xfrm_audit {
 	u32	secid;
-	uid_t	loginuid;
+	kuid_t	loginuid;
 	u32	sessionid;
 };
 
@@ -681,13 +681,14 @@ static inline struct audit_buffer *xfrm_audit_start(const char *op)
 	return audit_buf;
 }
 
-static inline void xfrm_audit_helper_usrinfo(uid_t auid, u32 ses, u32 secid,
+static inline void xfrm_audit_helper_usrinfo(kuid_t auid, u32 ses, u32 secid,
 					     struct audit_buffer *audit_buf)
 {
 	char *secctx;
 	u32 secctx_len;
 
-	audit_log_format(audit_buf, " auid=%u ses=%u", auid, ses);
+	audit_log_format(audit_buf, " auid=%u ses=%u",
+			 from_kuid(&init_user_ns, auid), ses);
 	if (secid != 0 &&
 	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0) {
 		audit_log_format(audit_buf, " subj=%s", secctx);
@@ -697,13 +698,13 @@ static inline void xfrm_audit_helper_usrinfo(uid_t auid, u32 ses, u32 secid,
 }
 
 extern void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid);
+				  kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid);
+				  kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 u32 auid, u32 ses, u32 secid);
+				 kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    u32 auid, u32 ses, u32 secid);
+				    kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 					     struct sk_buff *skb);
 extern void xfrm_audit_state_replay(struct xfrm_state *x,
@@ -716,22 +717,22 @@ extern void xfrm_audit_state_icvfail(struct xfrm_state *x,
 #else
 
 static inline void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid)
+				  kuid_t auid, u32 ses, u32 secid)
 {
 }
 
 static inline void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid)
+				  kuid_t auid, u32 ses, u32 secid)
 {
 }
 
 static inline void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 u32 auid, u32 ses, u32 secid)
+				 kuid_t auid, u32 ses, u32 secid)
 {
 }
 
 static inline void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    u32 auid, u32 ses, u32 secid)
+				    kuid_t auid, u32 ses, u32 secid)
 {
 }
 
diff --git a/kernel/audit.c b/kernel/audit.c
index 2e0dd5e..44a4b13 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -265,7 +265,7 @@ void audit_log_lost(const char *message)
 }
 
 static int audit_log_config_change(char *function_name, int new, int old,
-				   uid_t loginuid, u32 sessionid, u32 sid,
+				   kuid_t loginuid, u32 sessionid, u32 sid,
 				   int allow_changes)
 {
 	struct audit_buffer *ab;
@@ -273,7 +273,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	audit_log_format(ab, "%s=%d old=%d auid=%u ses=%u", function_name, new,
-			 old, loginuid, sessionid);
+			 old, from_kuid(&init_user_ns, loginuid), sessionid);
 	if (sid) {
 		char *ctx = NULL;
 		u32 len;
@@ -293,7 +293,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 }
 
 static int audit_do_config_change(char *function_name, int *to_change,
-				  int new, uid_t loginuid, u32 sessionid,
+				  int new, kuid_t loginuid, u32 sessionid,
 				  u32 sid)
 {
 	int allow_changes, rc = 0, old = *to_change;
@@ -320,21 +320,21 @@ static int audit_do_config_change(char *function_name, int *to_change,
 	return rc;
 }
 
-static int audit_set_rate_limit(int limit, uid_t loginuid, u32 sessionid,
+static int audit_set_rate_limit(int limit, kuid_t loginuid, u32 sessionid,
 				u32 sid)
 {
 	return audit_do_config_change("audit_rate_limit", &audit_rate_limit,
 				      limit, loginuid, sessionid, sid);
 }
 
-static int audit_set_backlog_limit(int limit, uid_t loginuid, u32 sessionid,
+static int audit_set_backlog_limit(int limit, kuid_t loginuid, u32 sessionid,
 				   u32 sid)
 {
 	return audit_do_config_change("audit_backlog_limit", &audit_backlog_limit,
 				      limit, loginuid, sessionid, sid);
 }
 
-static int audit_set_enabled(int state, uid_t loginuid, u32 sessionid, u32 sid)
+static int audit_set_enabled(int state, kuid_t loginuid, u32 sessionid, u32 sid)
 {
 	int rc;
 	if (state < AUDIT_OFF || state > AUDIT_LOCKED)
@@ -349,7 +349,7 @@ static int audit_set_enabled(int state, uid_t loginuid, u32 sessionid, u32 sid)
 	return rc;
 }
 
-static int audit_set_failure(int state, uid_t loginuid, u32 sessionid, u32 sid)
+static int audit_set_failure(int state, kuid_t loginuid, u32 sessionid, u32 sid)
 {
 	if (state != AUDIT_FAIL_SILENT
 	    && state != AUDIT_FAIL_PRINTK
@@ -607,7 +607,7 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 }
 
 static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
-				     uid_t auid, u32 ses, u32 sid)
+				     kuid_t auid, u32 ses, u32 sid)
 {
 	int rc = 0;
 	char *ctx = NULL;
@@ -622,7 +622,7 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
 	audit_log_format(*ab, "pid=%d uid=%u auid=%u ses=%u",
 			 task_tgid_vnr(current),
 			 from_kuid(&init_user_ns, current_uid()),
-			 auid, ses);
+			 from_kuid(&init_user_ns, auid), ses);
 	if (sid) {
 		rc = security_secid_to_secctx(sid, &ctx, &len);
 		if (rc)
@@ -644,7 +644,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int			err;
 	struct audit_buffer	*ab;
 	u16			msg_type = nlh->nlmsg_type;
-	uid_t			loginuid; /* loginuid of sender */
+	kuid_t			loginuid; /* loginuid of sender */
 	u32			sessionid;
 	struct audit_sig_info   *sig_data;
 	char			*ctx = NULL;
diff --git a/kernel/audit_watch.c b/kernel/audit_watch.c
index 3823281..1c22ec3 100644
--- a/kernel/audit_watch.c
+++ b/kernel/audit_watch.c
@@ -241,7 +241,7 @@ static void audit_watch_log_rule_change(struct audit_krule *r, struct audit_watc
 		struct audit_buffer *ab;
 		ab = audit_log_start(NULL, GFP_NOFS, AUDIT_CONFIG_CHANGE);
 		audit_log_format(ab, "auid=%u ses=%u op=",
-				 audit_get_loginuid(current),
+				 from_kuid(&init_user_ns, audit_get_loginuid(current)),
 				 audit_get_sessionid(current));
 		audit_log_string(ab, op);
 		audit_log_format(ab, " path=");
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index b30320c..c4bcdba 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1109,7 +1109,7 @@ static void audit_list_rules(int pid, int seq, struct sk_buff_head *q)
 }
 
 /* Log rule additions and removals */
-static void audit_log_rule_change(uid_t loginuid, u32 sessionid, u32 sid,
+static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 				  char *action, struct audit_krule *rule,
 				  int res)
 {
@@ -1121,7 +1121,8 @@ static void audit_log_rule_change(uid_t loginuid, u32 sessionid, u32 sid,
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (!ab)
 		return;
-	audit_log_format(ab, "auid=%u ses=%u", loginuid, sessionid);
+	audit_log_format(ab, "auid=%u ses=%u",
+			 from_kuid(&init_user_ns, loginuid), sessionid);
 	if (sid) {
 		char *ctx = NULL;
 		u32 len;
@@ -1152,7 +1153,7 @@ static void audit_log_rule_change(uid_t loginuid, u32 sessionid, u32 sid,
  * @sid: SE Linux Security ID of sender
  */
 int audit_receive_filter(int type, int pid, int seq, void *data,
-			 size_t datasz, uid_t loginuid, u32 sessionid, u32 sid)
+			 size_t datasz, kuid_t loginuid, u32 sessionid, u32 sid)
 {
 	struct task_struct *tsk;
 	struct audit_netlink_list *dest;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 0b5b8a2..26fdfc0 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -149,7 +149,7 @@ struct audit_aux_data_execve {
 struct audit_aux_data_pids {
 	struct audit_aux_data	d;
 	pid_t			target_pid[AUDIT_AUX_PIDS];
-	uid_t			target_auid[AUDIT_AUX_PIDS];
+	kuid_t			target_auid[AUDIT_AUX_PIDS];
 	uid_t			target_uid[AUDIT_AUX_PIDS];
 	unsigned int		target_sessionid[AUDIT_AUX_PIDS];
 	u32			target_sid[AUDIT_AUX_PIDS];
@@ -214,7 +214,7 @@ struct audit_context {
 	int		    arch;
 
 	pid_t		    target_pid;
-	uid_t		    target_auid;
+	kuid_t		    target_auid;
 	uid_t		    target_uid;
 	unsigned int	    target_sessionid;
 	u32		    target_sid;
@@ -1176,7 +1176,7 @@ static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk
 }
 
 static int audit_log_pid_context(struct audit_context *context, pid_t pid,
-				 uid_t auid, uid_t uid, unsigned int sessionid,
+				 kuid_t auid, uid_t uid, unsigned int sessionid,
 				 u32 sid, char *comm)
 {
 	struct audit_buffer *ab;
@@ -1188,7 +1188,8 @@ static int audit_log_pid_context(struct audit_context *context, pid_t pid,
 	if (!ab)
 		return rc;
 
-	audit_log_format(ab, "opid=%d oauid=%d ouid=%d oses=%d", pid, auid,
+	audit_log_format(ab, "opid=%d oauid=%d ouid=%d oses=%d", pid,
+			 from_kuid(&init_user_ns, auid),
 			 uid, sessionid);
 	if (security_secid_to_secctx(sid, &ctx, &len)) {
 		audit_log_format(ab, " obj=(none)");
@@ -1630,7 +1631,7 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 		  context->name_count,
 		  context->ppid,
 		  context->pid,
-		  tsk->loginuid,
+		  from_kuid(&init_user_ns, tsk->loginuid),
 		  context->uid,
 		  context->gid,
 		  context->euid, context->suid, context->fsuid,
@@ -2291,14 +2292,14 @@ static atomic_t session_id = ATOMIC_INIT(0);
  *
  * Called (set) from fs/proc/base.c::proc_loginuid_write().
  */
-int audit_set_loginuid(uid_t loginuid)
+int audit_set_loginuid(kuid_t loginuid)
 {
 	struct task_struct *task = current;
 	struct audit_context *context = task->audit_context;
 	unsigned int sessionid;
 
 #ifdef CONFIG_AUDIT_LOGINUID_IMMUTABLE
-	if (task->loginuid != -1)
+	if (uid_valid(task->loginuid))
 		return -EPERM;
 #else /* CONFIG_AUDIT_LOGINUID_IMMUTABLE */
 	if (!capable(CAP_AUDIT_CONTROL))
@@ -2315,7 +2316,8 @@ int audit_set_loginuid(uid_t loginuid)
 				"old auid=%u new auid=%u"
 				" old ses=%u new ses=%u",
 				task->pid, task_uid(task),
-				task->loginuid, loginuid,
+				from_kuid(&init_user_ns, task->loginuid),
+				from_kuid(&init_user_ns, loginuid),
 				task->sessionid, sessionid);
 			audit_log_end(ab);
 		}
@@ -2543,7 +2545,7 @@ int __audit_signal_info(int sig, struct task_struct *t)
 	if (audit_pid && t->tgid == audit_pid) {
 		if (sig == SIGTERM || sig == SIGHUP || sig == SIGUSR1 || sig == SIGUSR2) {
 			audit_sig_pid = tsk->pid;
-			if (tsk->loginuid != -1)
+			if (uid_valid(tsk->loginuid))
 				audit_sig_uid = tsk->loginuid;
 			else
 				audit_sig_uid = uid;
diff --git a/net/core/dev.c b/net/core/dev.c
index 026bb4a..1c0d082 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4524,7 +4524,7 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 				"dev=%s prom=%d old_prom=%d auid=%u uid=%u gid=%u ses=%u",
 				dev->name, (dev->flags & IFF_PROMISC),
 				(old_flags & IFF_PROMISC),
-				audit_get_loginuid(current),
+				from_kuid(&init_user_ns, audit_get_loginuid(current)),
 				from_kuid(&init_user_ns, uid),
 				from_kgid(&init_user_ns, gid),
 				audit_get_sessionid(current));
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index e7ff694..729a345 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1541,7 +1541,7 @@ int __init netlbl_unlabel_defconf(void)
 	 * it is called is at bootup before the audit subsystem is reporting
 	 * messages so don't worry to much about these values. */
 	security_task_getsecid(current, &audit_info.secid);
-	audit_info.loginuid = 0;
+	audit_info.loginuid = GLOBAL_ROOT_UID;
 	audit_info.sessionid = 0;
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 9fae63f..9650c4a 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -109,7 +109,7 @@ struct audit_buffer *netlbl_audit_start_common(int type,
 		return NULL;
 
 	audit_log_format(audit_buf, "netlabel: auid=%u ses=%u",
-			 audit_info->loginuid,
+			 from_kuid(&init_user_ns, audit_info->loginuid),
 			 audit_info->sessionid);
 
 	if (audit_info->secid != 0 &&
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c5a5165..2f47515 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2630,12 +2630,12 @@ static void xfrm_policy_fini(struct net *net)
 
 	flush_work(&net->xfrm.policy_hash_work);
 #ifdef CONFIG_XFRM_SUB_POLICY
-	audit_info.loginuid = -1;
+	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
 	xfrm_policy_flush(net, XFRM_POLICY_TYPE_SUB, &audit_info);
 #endif
-	audit_info.loginuid = -1;
+	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
 	xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
@@ -2742,7 +2742,7 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 }
 
 void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-			   uid_t auid, u32 sessionid, u32 secid)
+			   kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
@@ -2757,7 +2757,7 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
 void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-			      uid_t auid, u32 sessionid, u32 secid)
+			      kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5b228f9..fce6a49 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2045,7 +2045,7 @@ void xfrm_state_fini(struct net *net)
 	unsigned int sz;
 
 	flush_work(&net->xfrm.state_hash_work);
-	audit_info.loginuid = -1;
+	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
 	xfrm_state_flush(net, IPSEC_PROTO_ANY, &audit_info);
@@ -2112,7 +2112,7 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 }
 
 void xfrm_audit_state_add(struct xfrm_state *x, int result,
-			  uid_t auid, u32 sessionid, u32 secid)
+			  kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
@@ -2127,7 +2127,7 @@ void xfrm_audit_state_add(struct xfrm_state *x, int result,
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
 void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-			     uid_t auid, u32 sessionid, u32 secid)
+			     kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e75d8e4..9ea55db 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -575,7 +575,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
-	uid_t loginuid = audit_get_loginuid(current);
+	kuid_t loginuid = audit_get_loginuid(current);
 	u32 sessionid = audit_get_sessionid(current);
 	u32 sid;
 
@@ -654,7 +654,7 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
-	uid_t loginuid = audit_get_loginuid(current);
+	kuid_t loginuid = audit_get_loginuid(current);
 	u32 sessionid = audit_get_sessionid(current);
 	u32 sid;
 
@@ -1369,7 +1369,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	int err;
 	int excl;
-	uid_t loginuid = audit_get_loginuid(current);
+	kuid_t loginuid = audit_get_loginuid(current);
 	u32 sessionid = audit_get_sessionid(current);
 	u32 sid;
 
@@ -1624,7 +1624,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 					    NETLINK_CB(skb).pid);
 		}
 	} else {
-		uid_t loginuid = audit_get_loginuid(current);
+		kuid_t loginuid = audit_get_loginuid(current);
 		u32 sessionid = audit_get_sessionid(current);
 		u32 sid;
 
@@ -1918,7 +1918,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = 0;
 	if (up->hard) {
-		uid_t loginuid = audit_get_loginuid(current);
+		kuid_t loginuid = audit_get_loginuid(current);
 		u32 sessionid = audit_get_sessionid(current);
 		u32 sid;
 
@@ -1961,7 +1961,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	km_state_expired(x, ue->hard, current->pid);
 
 	if (ue->hard) {
-		uid_t loginuid = audit_get_loginuid(current);
+		kuid_t loginuid = audit_get_loginuid(current);
 		u32 sessionid = audit_get_sessionid(current);
 		u32 sid;
 
-- 
1.7.5.4

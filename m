From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 10/21] userns: Convert net/ax25 to use kuid_t where appropriate
Date: Mon, 13 Aug 2012 13:18:24 -0700
Message-ID: <1344889115-21610-10-git-send-email-ebiederm__23579.4739718132$1344889281$gmane$org@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/ax25.h  |    4 ++--
 init/Kconfig        |    1 -
 net/ax25/ax25_uid.c |   21 ++++++++++++++-------
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 5d23521..53539ac 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -157,7 +157,7 @@ enum {
 typedef struct ax25_uid_assoc {
 	struct hlist_node	uid_node;
 	atomic_t		refcount;
-	uid_t			uid;
+	kuid_t			uid;
 	ax25_address		call;
 } ax25_uid_assoc;
 
@@ -434,7 +434,7 @@ extern unsigned long ax25_display_timer(struct timer_list *);
 
 /* ax25_uid.c */
 extern int  ax25_uid_policy;
-extern ax25_uid_assoc *ax25_findbyuid(uid_t);
+extern ax25_uid_assoc *ax25_findbyuid(kuid_t);
 extern int __must_check ax25_uid_ioctl(int, struct sockaddr_ax25 *);
 extern const struct file_operations ax25_uid_fops;
 extern void ax25_uid_free(void);
diff --git a/init/Kconfig b/init/Kconfig
index 64ff9ce..8447e0c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -952,7 +952,6 @@ config UIDGID_CONVERTED
 	depends on NET_KEY = n
 	depends on INET_DIAG = n
 	depends on DNS_RESOLVER = n
-	depends on AX25 = n
 
 	# Filesystems
 	depends on USB_GADGETFS = n
diff --git a/net/ax25/ax25_uid.c b/net/ax25/ax25_uid.c
index e3c579b..957999e 100644
--- a/net/ax25/ax25_uid.c
+++ b/net/ax25/ax25_uid.c
@@ -51,14 +51,14 @@ int ax25_uid_policy;
 
 EXPORT_SYMBOL(ax25_uid_policy);
 
-ax25_uid_assoc *ax25_findbyuid(uid_t uid)
+ax25_uid_assoc *ax25_findbyuid(kuid_t uid)
 {
 	ax25_uid_assoc *ax25_uid, *res = NULL;
 	struct hlist_node *node;
 
 	read_lock(&ax25_uid_lock);
 	ax25_uid_for_each(ax25_uid, node, &ax25_uid_list) {
-		if (ax25_uid->uid == uid) {
+		if (uid_eq(ax25_uid->uid, uid)) {
 			ax25_uid_hold(ax25_uid);
 			res = ax25_uid;
 			break;
@@ -84,7 +84,7 @@ int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 		read_lock(&ax25_uid_lock);
 		ax25_uid_for_each(ax25_uid, node, &ax25_uid_list) {
 			if (ax25cmp(&sax->sax25_call, &ax25_uid->call) == 0) {
-				res = ax25_uid->uid;
+				res = from_kuid_munged(current_user_ns(), ax25_uid->uid);
 				break;
 			}
 		}
@@ -93,9 +93,14 @@ int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 		return res;
 
 	case SIOCAX25ADDUID:
+	{
+		kuid_t sax25_kuid;
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		user = ax25_findbyuid(sax->sax25_uid);
+		sax25_kuid = make_kuid(current_user_ns(), sax->sax25_uid);
+		if (!uid_valid(sax25_kuid))
+			return -EINVAL;
+		user = ax25_findbyuid(sax25_kuid);
 		if (user) {
 			ax25_uid_put(user);
 			return -EEXIST;
@@ -106,7 +111,7 @@ int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 			return -ENOMEM;
 
 		atomic_set(&ax25_uid->refcount, 1);
-		ax25_uid->uid  = sax->sax25_uid;
+		ax25_uid->uid  = sax25_kuid;
 		ax25_uid->call = sax->sax25_call;
 
 		write_lock(&ax25_uid_lock);
@@ -114,7 +119,7 @@ int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 		write_unlock(&ax25_uid_lock);
 
 		return 0;
-
+	}
 	case SIOCAX25DELUID:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
@@ -172,7 +177,9 @@ static int ax25_uid_seq_show(struct seq_file *seq, void *v)
 		struct ax25_uid_assoc *pt;
 
 		pt = hlist_entry(v, struct ax25_uid_assoc, uid_node);
-		seq_printf(seq, "%6d %s\n", pt->uid, ax2asc(buf, &pt->call));
+		seq_printf(seq, "%6d %s\n",
+			from_kuid_munged(seq_user_ns(seq), pt->uid),
+			ax2asc(buf, &pt->call));
 	}
 	return 0;
 }
-- 
1.7.5.4

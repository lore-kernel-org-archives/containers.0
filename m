From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 21/27] userns: Implement struct kqid
Date: Wed, 19 Sep 2012 18:52:23 -0700
Message-ID: <1348105949-25454-21-git-send-email-ebiederm__48539.8193276071$1348107106$gmane$org@xmission.com>
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

Add the data type struct kqid which holds the kernel internal form of
the owning identifier of a quota.  struct kqid is a replacement for
the implicit union of uid, gid and project id stored in an unsigned
int and the quota type field that is was used in the quota data
structures.  Making the data type explicit allows the kuid_t and
kgid_t type safety to propogate more thoroughly through the code,
revealing more places where uid/gid conversions need be made.

Along with the data type struct kqid comes the helper functions
qid_eq, qid_lt, from_kqid, from_kqid_munged, qid_valid, make_kqid,
make_kqid_invalid, make_kqid_uid, make_kqid_gid.

Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/quota/Makefile     |    2 +-
 fs/quota/kqid.c       |  132 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/quota.h |  125 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 258 insertions(+), 1 deletions(-)
 create mode 100644 fs/quota/kqid.c

diff --git a/fs/quota/Makefile b/fs/quota/Makefile
index 5f9e9e2..c66c37c 100644
--- a/fs/quota/Makefile
+++ b/fs/quota/Makefile
@@ -2,6 +2,6 @@ obj-$(CONFIG_QUOTA)		+= dquot.o
 obj-$(CONFIG_QFMT_V1)		+= quota_v1.o
 obj-$(CONFIG_QFMT_V2)		+= quota_v2.o
 obj-$(CONFIG_QUOTA_TREE)	+= quota_tree.o
-obj-$(CONFIG_QUOTACTL)		+= quota.o
+obj-$(CONFIG_QUOTACTL)		+= quota.o kqid.o
 obj-$(CONFIG_QUOTACTL_COMPAT)	+= compat.o
 obj-$(CONFIG_QUOTA_NETLINK_INTERFACE)	+= netlink.o
diff --git a/fs/quota/kqid.c b/fs/quota/kqid.c
new file mode 100644
index 0000000..2f97b0e
--- /dev/null
+++ b/fs/quota/kqid.c
@@ -0,0 +1,132 @@
+#include <linux/fs.h>
+#include <linux/quota.h>
+#include <linux/export.h>
+
+/**
+ *	qid_eq - Test to see if to kquid values are the same
+ *	@left: A qid value
+ *	@right: Another quid value
+ *
+ *	Return true if the two qid values are equal and false otherwise.
+ */
+bool qid_eq(struct kqid left, struct kqid right)
+{
+	if (left.type != right.type)
+		return false;
+	switch(left.type) {
+	case USRQUOTA:
+		return uid_eq(left.uid, right.uid);
+	case GRPQUOTA:
+		return gid_eq(left.gid, right.gid);
+	case PRJQUOTA:
+		return projid_eq(left.projid, right.projid);
+	default:
+		BUG();
+	}
+}
+EXPORT_SYMBOL(qid_eq);
+
+/**
+ *	qid_lt - Test to see if one qid value is less than another
+ *	@left: The possibly lesser qid value
+ *	@right: The possibly greater qid value
+ *
+ *	Return true if left is less than right and false otherwise.
+ */
+bool qid_lt(struct kqid left, struct kqid right)
+{
+	if (left.type < right.type)
+		return true;
+	if (left.type > right.type)
+		return false;
+	switch (left.type) {
+	case USRQUOTA:
+		return uid_lt(left.uid, right.uid);
+	case GRPQUOTA:
+		return gid_lt(left.gid, right.gid);
+	case PRJQUOTA:
+		return projid_lt(left.projid, right.projid);
+	default:
+		BUG();
+	}
+}
+EXPORT_SYMBOL(qid_lt);
+
+/**
+ *	from_kqid - Create a qid from a kqid user-namespace pair.
+ *	@targ: The user namespace we want a qid in.
+ *	@kuid: The kernel internal quota identifier to start with.
+ *
+ *	Map @kqid into the user-namespace specified by @targ and
+ *	return the resulting qid.
+ *
+ *	There is always a mapping into the initial user_namespace.
+ *
+ *	If @kqid has no mapping in @targ (qid_t)-1 is returned.
+ */
+qid_t from_kqid(struct user_namespace *targ, struct kqid kqid)
+{
+	switch (kqid.type) {
+	case USRQUOTA:
+		return from_kuid(targ, kqid.uid);
+	case GRPQUOTA:
+		return from_kgid(targ, kqid.gid);
+	case PRJQUOTA:
+		return from_kprojid(targ, kqid.projid);
+	default:
+		BUG();
+	}
+}
+EXPORT_SYMBOL(from_kqid);
+
+/**
+ *	from_kqid_munged - Create a qid from a kqid user-namespace pair.
+ *	@targ: The user namespace we want a qid in.
+ *	@kqid: The kernel internal quota identifier to start with.
+ *
+ *	Map @kqid into the user-namespace specified by @targ and
+ *	return the resulting qid.
+ *
+ *	There is always a mapping into the initial user_namespace.
+ *
+ *	Unlike from_kqid from_kqid_munged never fails and always
+ *	returns a valid projid.  This makes from_kqid_munged
+ *	appropriate for use in places where failing to provide
+ *	a qid_t is not a good option.
+ *
+ *	If @kqid has no mapping in @targ the kqid.type specific
+ *	overflow identifier is returned.
+ */
+qid_t from_kqid_munged(struct user_namespace *targ, struct kqid kqid)
+{
+	switch (kqid.type) {
+	case USRQUOTA:
+		return from_kuid_munged(targ, kqid.uid);
+	case GRPQUOTA:
+		return from_kgid_munged(targ, kqid.gid);
+	case PRJQUOTA:
+		return from_kprojid_munged(targ, kqid.projid);
+	default:
+		BUG();
+	}
+}
+EXPORT_SYMBOL(from_kqid_munged);
+
+/**
+ *	qid_valid - Report if a valid value is stored in a kqid.
+ *	@qid: The kernel internal quota identifier to test.
+ */
+bool qid_valid(struct kqid qid)
+{
+	switch (qid.type) {
+	case USRQUOTA:
+		return uid_valid(qid.uid);
+	case GRPQUOTA:
+		return gid_valid(qid.gid);
+	case PRJQUOTA:
+		return projid_valid(qid.projid);
+	default:
+		BUG();
+	}
+}
+EXPORT_SYMBOL(qid_valid);
diff --git a/include/linux/quota.h b/include/linux/quota.h
index 524ede8..00ac8d8 100644
--- a/include/linux/quota.h
+++ b/include/linux/quota.h
@@ -181,10 +181,135 @@ enum {
 #include <linux/dqblk_v2.h>
 
 #include <linux/atomic.h>
+#include <linux/uidgid.h>
+#include <linux/projid.h>
+
+#undef USRQUOTA
+#undef GRPQUOTA
+enum quota_type {
+	USRQUOTA = 0,		/* element used for user quotas */
+	GRPQUOTA = 1,		/* element used for group quotas */
+	PRJQUOTA = 2,		/* element used for project quotas */
+};
 
 typedef __kernel_uid32_t qid_t; /* Type in which we store ids in memory */
 typedef long long qsize_t;	/* Type in which we store sizes */
 
+struct kqid {			/* Type in which we store the quota identifier */
+	union {
+		kuid_t uid;
+		kgid_t gid;
+		kprojid_t projid;
+	};
+	enum quota_type type;  /* USRQUOTA (uid) or GRPQUOTA (gid) or PRJQUOTA (projid) */
+};
+
+extern bool qid_eq(struct kqid left, struct kqid right);
+extern bool qid_lt(struct kqid left, struct kqid right);
+extern qid_t from_kqid(struct user_namespace *to, struct kqid qid);
+extern qid_t from_kqid_munged(struct user_namespace *to, struct kqid qid);
+extern bool qid_valid(struct kqid qid);
+
+/**
+ *	make_kqid - Map a user-namespace, type, qid tuple into a kqid.
+ *	@from: User namespace that the qid is in
+ *	@type: The type of quota
+ *	@qid: Quota identifier
+ *
+ *	Maps a user-namespace, type qid tuple into a kernel internal
+ *	kqid, and returns that kqid.
+ *
+ *	When there is no mapping defined for the user-namespace, type,
+ *	qid tuple an invalid kqid is returned.  Callers are expected to
+ *	test for and handle handle invalid kqids being returned.
+ *	Invalid kqids may be tested for using qid_valid().
+ */
+static inline struct kqid make_kqid(struct user_namespace *from,
+				    enum quota_type type, qid_t qid)
+{
+	struct kqid kqid;
+
+	kqid.type = type;
+	switch (type) {
+	case USRQUOTA:
+		kqid.uid = make_kuid(from, qid);
+		break;
+	case GRPQUOTA:
+		kqid.gid = make_kgid(from, qid);
+		break;
+	case PRJQUOTA:
+		kqid.projid = make_kprojid(from, qid);
+		break;
+	default:
+		BUG();
+	}
+	return kqid;
+}
+
+/**
+ *	make_kqid_invalid - Explicitly make an invalid kqid
+ *	@type: The type of quota identifier
+ *
+ *	Returns an invalid kqid with the specified type.
+ */
+static inline struct kqid make_kqid_invalid(enum quota_type type)
+{
+	struct kqid kqid;
+
+	kqid.type = type;
+	switch (type) {
+	case USRQUOTA:
+		kqid.uid = INVALID_UID;
+		break;
+	case GRPQUOTA:
+		kqid.gid = INVALID_GID;
+		break;
+	case PRJQUOTA:
+		kqid.projid = INVALID_PROJID;
+		break;
+	default:
+		BUG();
+	}
+	return kqid;
+}
+
+/**
+ *	make_kqid_uid - Make a kqid from a kuid
+ *	@uid: The kuid to make the quota identifier from
+ */
+static inline struct kqid make_kqid_uid(kuid_t uid)
+{
+	struct kqid kqid;
+	kqid.type = USRQUOTA;
+	kqid.uid = uid;
+	return kqid;
+}
+
+/**
+ *	make_kqid_gid - Make a kqid from a kgid
+ *	@gid: The kgid to make the quota identifier from
+ */
+static inline struct kqid make_kqid_gid(kgid_t gid)
+{
+	struct kqid kqid;
+	kqid.type = GRPQUOTA;
+	kqid.gid = gid;
+	return kqid;
+}
+
+/**
+ *	make_kqid_projid - Make a kqid from a projid
+ *	@projid: The kprojid to make the quota identifier from
+ */
+static inline struct kqid make_kqid_projid(kprojid_t projid)
+{
+	struct kqid kqid;
+	kqid.type = PRJQUOTA;
+	kqid.projid = projid;
+	return kqid;
+}
+
+
 extern spinlock_t dq_data_lock;
 
 /* Maximal numbers of writes for quota operation (insert/delete/update)
-- 
1.7.5.4

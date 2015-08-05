From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 7/6] vfs: Make mnt_escape_count 64bit
Date: Tue, 04 Aug 2015 22:14:25 -0500
Message-ID: <87y4hqwhny.fsf_-_@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tfkawu9.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Mon, 03 Aug 2015 16:25:18 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


The primary way that mnt_escape_count differs from a seqcount is that
it's value is cached across operations that sleep.  In emperical
testing mnt_escape_count can be made to rollover in 64 minutes on an
Intel 2.5Ghz Core i5 processor on ramfs.  Meanwhile a single pathname
lookup on an otherwise idle system has been measured at 2 minutes 9
seconds.  Those numbers are entirely too close for comfort, especially
given that nfs lookups can take indefinitely long.

Extend mnt_escape_count to 64bit to increase the expected time to
rollover from 1 hour to 489,957 years.  Even if the efficiency of
rename is increased to be able to rename 2^31 entries in 1 second
(instead of the 1 hour that I measured) it will still take 136 years
before the escape count rolls over, making it essentially never.

On 32bit the low 32bit word of the 64bit count is treated as a
sequence count such that if you read the low 32bit value, read the
high 32bit value, and then read the low 32bit value again and the low
32bit value remains unchanged the high 32bit value is guaranteed to be
stable when the low 32bit value does not equal -1UL.  Thankfully in
the unlikely event that the low 32bit value is -1UL the code does not
care about the high 32bit value so the code does not need to reread
the values in that case.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/mount.h     | 32 ++++++++++++++++++++++++++++----
 fs/namei.c     |  6 +++---
 fs/namespace.c | 13 ++++++++++++-
 3 files changed, 43 insertions(+), 8 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index d32d074cc0d4..cd89e786efa7 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -38,7 +38,10 @@ struct mount {
 	struct mount *mnt_parent;
 	struct dentry *mnt_mountpoint;
 	struct vfsmount mnt;
-	unsigned mnt_escape_count;
+	unsigned long mnt_escape_count;
+#if BITS_PER_LONG < 64
+	unsigned long mnt_escape_count_high;
+#endif
 	union {
 		struct rcu_head mnt_rcu;
 		struct llist_node mnt_llist;
@@ -111,15 +114,36 @@ static inline void detach_mounts(struct dentry *dentry)
 extern const struct dentry *lock_namespace_rename(struct dentry *, struct dentry *, bool);
 extern void unlock_namespace_rename(const struct dentry *, struct dentry *, struct dentry *, bool);
 
-static inline unsigned read_mnt_escape_count(struct vfsmount *vfsmount)
+static inline u64 read_mnt_escape_count(struct vfsmount *vfsmount)
 {
 	struct mount *mnt = real_mount(vfsmount);
-	unsigned ret = READ_ONCE(mnt->mnt_escape_count);
+#if BITS_PER_LONG >= 64
+	u64 ret = READ_ONCE(mnt->mnt_escape_count);
+#else
+	u64 ret;
+	unsigned long low0, low, high;
+	/* In the unlikely event that low0 == low and low == -1
+	 * mnt_escape_count_high may or not be incremented yet.  In
+	 * that event the odd value of low will not match the anything
+	 * cached, will signal that the validity of is_subdir is in
+	 * flux and will not be cached.  Therefore when low == -1 the
+	 * value of high does not matter.
+	 */
+	low0 = READ_ONCE(mnt->mnt_escape_count);
+	do {
+		low = low0;
+		smp_rmb();
+		high = READ_ONCE(mnt->mnt_escape_count_high);
+		smp_rmb();
+		low0 = READ_ONCE(mnt->mnt_escape_count);
+	} while (low != low0);
+	ret = (((u64)high) << 32) | low;
+#endif
 	smp_rmb();
 	return ret;
 }
 
-static inline void cache_mnt_escape_count(unsigned *cache, unsigned escape_count)
+static inline void cache_mnt_escape_count(u64 *cache, u64 escape_count)
 {
 	if (likely(escape_count & 1) == 0)
 		*cache = escape_count;
diff --git a/fs/namei.c b/fs/namei.c
index 79a5dca073f5..ef1463c0b96a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -514,7 +514,7 @@ struct nameidata {
 	struct nameidata *saved;
 	unsigned	root_seq;
 	int		dfd;
-	unsigned	mnt_escape_count;
+	u64		mnt_escape_count;
 };
 
 static void set_nameidata(struct nameidata *p, int dfd, struct filename *name)
@@ -571,7 +571,7 @@ static int __nd_alloc_stack(struct nameidata *nd)
 static bool path_connected(struct nameidata *nd)
 {
 	struct vfsmount *mnt = nd->path.mnt;
-	unsigned escape_count = read_mnt_escape_count(mnt);
+	u64 escape_count = read_mnt_escape_count(mnt);
 
 	if (likely(escape_count == nd->mnt_escape_count))
 		return true;
@@ -3041,7 +3041,7 @@ static int do_last(struct nameidata *nd,
 	unsigned seq;
 	struct inode *inode;
 	struct path save_parent = { .dentry = NULL, .mnt = NULL };
-	unsigned save_parent_escape_count = 0;
+	u64 save_parent_escape_count = 0;
 	struct path path;
 	bool retried = false;
 	int error;
diff --git a/fs/namespace.c b/fs/namespace.c
index 9faec24f3f23..98596c4b992a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1692,10 +1692,21 @@ static void lock_escaped_mounts_begin(struct dentry *root)
 		 */
 		hlist_for_each_entry(mnt, &mr->r_list, mnt_mr_list) {
 			/* Don't return to 0 if the couunt wraps */
-			if (unlikely(mnt->mnt_escape_count == (0U - 2)))
+#if BITS_PER_LONG >= 64
+			if (unlikely(mnt->mnt_escape_count == (0UL - 2)))
 				mnt->mnt_escape_count = 1;
 			else
 				mnt->mnt_escape_count++;
+#else
+			if (unlikely(mnt->mnt_escape_count == (0UL - 2))) {
+				WRITE_ONCE(mnt->mnt_escape_count, (0UL - 1));
+				smp_wmb();
+				mnt->mnt_escape_count_high++;
+				smp_wmb();
+				WRITE_ONCE(mnt->mnt_escape_count, 1);
+			} else
+				mnt->mnt_escape_count++;
+#endif
 			smp_wmb();
 		}
 	}
-- 
2.2.1

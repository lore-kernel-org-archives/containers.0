From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v8 1/6] fs/posix_acl: Update the comments and support
	lightweight cache skipping
Date: Fri,  2 Mar 2018 15:59:14 -0600
Message-ID: <20180302215919.27207-1-ebiederm@xmission.com>
References: <87r2p287i8.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r2p287i8.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

The code has been missing a way for a ->get_acl method to not cache
a return value without risking invalidating a cached value
that was set while get_acl() was returning.

Add that support by implementing to_uncachable_acl, to_cachable_acl,
is_uncacheable_acl, and dealing with uncachable acls in get_acl().

Update the comments so that they are a little clearer about
what is going on in get_acl()

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/posix_acl.c            | 50 ++++++++++++++++++++++++++++++++---------------
 include/linux/posix_acl.h | 17 ++++++++++++++++
 2 files changed, 51 insertions(+), 16 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 2fd0fde16fe1..00281bc30854 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -96,12 +96,16 @@ struct posix_acl *get_acl(struct inode *inode, int type)
 {
 	void *sentinel;
 	struct posix_acl **p;
-	struct posix_acl *acl;
+	struct posix_acl *acl, *to_cache;
 
 	/*
 	 * The sentinel is used to detect when another operation like
 	 * set_cached_acl() or forget_cached_acl() races with get_acl().
 	 * It is guaranteed that is_uncached_acl(sentinel) is true.
+	 *
+	 * This is sufficient to prevent races between ->set_acl
+	 * calling set_cached_acl (outside of filesystem specific
+	 * locking) and get_acl() caching the returned acl.
 	 */
 
 	acl = get_cached_acl(inode, type);
@@ -126,12 +130,18 @@ struct posix_acl *get_acl(struct inode *inode, int type)
 		/* fall through */ ;
 
 	/*
-	 * Normally, the ACL returned by ->get_acl will be cached.
-	 * A filesystem can prevent that by calling
-	 * forget_cached_acl(inode, type) in ->get_acl.
+	 * Normally, the ACL returned by ->get_acl() will be cached.
+	 *
+	 * A filesystem can prevent the acl returned by ->get_acl()
+	 * from being cached by wrapping it with to_uncachable_acl().
 	 *
-	 * If the filesystem doesn't have a get_acl() function at all, we'll
-	 * just create the negative cache entry.
+	 * A filesystem can at anytime effect the cache directly and
+	 * cause in process calls of get_acl() not to update the cache
+	 * by calling forget_cache_acl(inode, type) or
+	 * set_cached_acl(inode, type, acl).
+	 *
+	 * If the filesystem doesn't have a ->get_acl() function at
+	 * all, we'll just create the negative cache entry.
 	 */
 	if (!inode->i_op->get_acl) {
 		set_cached_acl(inode, type, NULL);
@@ -140,20 +150,28 @@ struct posix_acl *get_acl(struct inode *inode, int type)
 	acl = inode->i_op->get_acl(inode, type);
 
 	if (IS_ERR(acl)) {
-		/*
-		 * Remove our sentinel so that we don't block future attempts
-		 * to cache the ACL.
-		 */
-		cmpxchg(p, sentinel, ACL_NOT_CACHED);
-		return acl;
+		/* Don't cache an acl just return an error. */
+		to_cache = ACL_NOT_CACHED;
+	}
+	else if (is_uncacheable_acl(acl)) {
+		/* Don't cache an acl, but return one. */
+		to_cache = ACL_NOT_CACHED;
+		acl = to_cacheable_acl(acl);
+	}
+	else {
+		/* Cache and return the acl. */
+		to_cache = posix_acl_dup(acl);
 	}
 
 	/*
-	 * Cache the result, but only if our sentinel is still in place.
+	 * Remove the sentinel and replace it with the value to
+	 * cache, but only if the sentinel is still in place.
 	 */
-	posix_acl_dup(acl);
-	if (unlikely(cmpxchg(p, sentinel, acl) != sentinel))
-		posix_acl_release(acl);
+	if (unlikely(cmpxchg(p, sentinel, to_cache) != sentinel)) {
+		if (!is_uncached_acl(to_cache))
+			posix_acl_release(to_cache);
+	}
+
 	return acl;
 }
 EXPORT_SYMBOL(get_acl);
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 540595a321a7..3be8929b9f48 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -56,6 +56,23 @@ posix_acl_release(struct posix_acl *acl)
 		kfree_rcu(acl, a_rcu);
 }
 
+/*
+ * Allow for acls returned from ->get_acl() to not be cached.
+ */
+static inline bool is_uncacheable_acl(struct posix_acl *acl)
+{
+	return ((unsigned long)acl) & 1UL;
+}
+
+static inline struct posix_acl *to_uncacheable_acl(struct posix_acl *acl)
+{
+	return (struct posix_acl *)(((unsigned long)acl) | 1UL);
+}
+
+static inline struct posix_acl *to_cacheable_acl(struct posix_acl *acl)
+{
+	return (struct posix_acl *)(((unsigned long)acl) & ~1UL);
+}
 
 /* posix_acl.c */
 
-- 
2.14.1

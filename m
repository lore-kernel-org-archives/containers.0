From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH] fs/posix_acl: Update the comments and support
	lightweight cache skipping
Date: Fri, 02 Mar 2018 13:53:45 -0600
Message-ID: <87r2p2b6eu.fsf_-___19596.9411907301$1520020375$gmane$org@xmission.com>
References: <87po4rz4ui.fsf_-_@xmission.com>
	<20180226235302.12708-3-ebiederm@xmission.com>
	<CA+55aFySgJyR6JLcS9HLC9wEpWU1isdyTkchHxZHbJWsh7HFpg@mail.gmail.com>
	<87r2p7rvn5.fsf@xmission.com> <87tvu3qg2b.fsf@xmission.com>
	<CA+55aFwPo7Pbq+3Oup-oo8MUFHeEpFXp7qr6z2PrzKp7S0ON+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+55aFwPo7Pbq+3Oup-oo8MUFHeEpFXp7qr6z2PrzKp7S0ON+A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Linus Torvalds's message of "Mon, 26 Feb 2018 19:41:21 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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

Linus my issue with the forget_cached_acl case was really that it was
too big of a hammer.  If you care about caching acls only somtimes
forget_cached_acl called from ->get_acl can stomp that acl you
explicitly cached with set_cached_acl.

With this change I can unify the legacy horrible fuse posix acl case
that requires not caching acls with a single if statement in the get_acl
method. AKA:

+	if (!IS_ERR(acl) && !fc->posix_acl)
+		acl = to_uncacheable_acl(acl);
 	return acl;

That code I know is locally correct even if later fuse decides to cache
negative acls when the underlying filesystem does not support xattrs.

 fs/posix_acl.c            | 56 ++++++++++++++++++++++++++++++++++-------------
 include/linux/posix_acl.h | 17 ++++++++++++++
 2 files changed, 58 insertions(+), 15 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 2fd0fde16fe1..e58a68e18603 100644
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
+	 *
+	 * A filesystem can at anytime effect the cache directly and
+	 * cause in process calls of get_acl() not to update the cache
+	 * by calling forget_cache_acl(inode, type) or
+	 * set_cached_acl(inode, type, acl).
 	 *
-	 * If the filesystem doesn't have a get_acl() function at all, we'll
-	 * just create the negative cache entry.
+	 * If the filesystem doesn't have a ->get_acl() function at
+	 * all, we'll just create the negative cache entry.
 	 */
 	if (!inode->i_op->get_acl) {
 		set_cached_acl(inode, type, NULL);
@@ -139,21 +149,37 @@ struct posix_acl *get_acl(struct inode *inode, int type)
 	}
 	acl = inode->i_op->get_acl(inode, type);
 
+
+	/* To keep the logic simple default to not caching an acl when
+	 * the sentinel is cleared.
+	 */
+	to_cache = ACL_NOT_CACHED;
 	if (IS_ERR(acl)) {
-		/*
-		 * Remove our sentinel so that we don't block future attempts
-		 * to cache the ACL.
+		/* Clears the sentinel so that we don't block future
+		 * attempts to cache the ACL, and return an error.
 		 */
-		cmpxchg(p, sentinel, ACL_NOT_CACHED);
-		return acl;
+	}
+	else if (is_uncacheable_acl(acl)) {
+		/* Clears the sentinel so that we don't block future
+		 * attempts to cache the ACL, and return a valid ACL.
+		 */
+		acl = to_cacheable_acl(acl);
+	}
+	else {
+		to_cache = acl;
+		posix_acl_dup(to_cache);
 	}
 
 	/*
-	 * Cache the result, but only if our sentinel is still in place.
+	 * Remove the sentinel and replace it with the value that
+	 * needs to be cached, but only if the sentinel is still in
+	 * place.
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

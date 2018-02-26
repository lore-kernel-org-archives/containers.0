From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v7 3/7] fs/posix_acl: Document that get_acl respects
	ACL_DONT_CACHE
Date: Mon, 26 Feb 2018 17:52:58 -0600
Message-ID: <20180226235302.12708-3-ebiederm__8164.95896219767$1519689180$gmane$org@xmission.com>
References: <87po4rz4ui.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87po4rz4ui.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Fuse is about to join overlayfs in relying on get_acl respecting
ACL_DONT_CACHE so update the documentation in get_acl to reflect that
fact.  The comment and this change description should give people a
clue that respecting ACL_DONT_CACHE in get_acl is important, and they
should audit the filesystems before removing that support.

Additionaly update the comment above the call to get_acl itself and
remove the wrong information that an implementation of get_acl can
prevent caching by calling forget_cached_acl.  Replace that with the
correct information that to prevent caching all that is necessary is
to set inode->i_acl = inode->i_default_acl = ACL_DONT_CACHE when the
inode is initialized.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/posix_acl.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 2fd0fde16fe1..3c24fc263401 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -121,14 +121,17 @@ struct posix_acl *get_acl(struct inode *inode, int type)
 	 * could wait for that other task to complete its job, but it's easier
 	 * to just call ->get_acl to fetch the ACL ourself.  (This is going to
 	 * be an unlikely race.)
+	 *
+	 * ACL_DONT_CACHE is treated as another task updating the acl and
+	 * remains set.
 	 */
 	if (cmpxchg(p, ACL_NOT_CACHED, sentinel) != ACL_NOT_CACHED)
 		/* fall through */ ;
 
 	/*
 	 * Normally, the ACL returned by ->get_acl will be cached.
-	 * A filesystem can prevent that by calling
-	 * forget_cached_acl(inode, type) in ->get_acl.
+	 * A filesystem can prevent that by calling setting
+	 * inode->i_acl = inode->i_default_acl = ACL_DONT_CACHE.
 	 *
 	 * If the filesystem doesn't have a get_acl() function at all, we'll
 	 * just create the negative cache entry.
-- 
2.14.1

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] userns: Allow hardlinks for 4.4
Date: Wed, 04 Nov 2015 12:52:22 -0600
Message-ID: <87fv0loavt.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: f2ca379642d7a843be972ea4167abdd3c8c9e5d1 namei: permit linking with CAP_FOWNER in userns

This round just contains a single patch.  There has been a lot of other
work this period but it is not quite ready yet, so I am pushing it until
4.5.

The remaining change by Dirk Steinmetz wich fixes both Gentoo and Ubuntu
containers allows hardlinks if we have the appropriate capabilities in
the user namespace.  Security wise it is really a gimme as the user
namespace root can already call setuid become that user and create the
hardlink.

Eric


Dirk Steinmetz (1):
      namei: permit linking with CAP_FOWNER in userns

 fs/namei.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 726d211db484..29fc6a657477 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -955,26 +955,23 @@ static bool safe_hardlink_source(struct inode *inode)
  *  - sysctl_protected_hardlinks enabled
  *  - fsuid does not match inode
  *  - hardlink source is unsafe (see safe_hardlink_source() above)
- *  - not CAP_FOWNER
+ *  - not CAP_FOWNER in a namespace with the inode owner uid mapped
  *
  * Returns 0 if successful, -ve on error.
  */
 static int may_linkat(struct path *link)
 {
-	const struct cred *cred;
 	struct inode *inode;
 
 	if (!sysctl_protected_hardlinks)
 		return 0;
 
-	cred = current_cred();
 	inode = link->dentry->d_inode;
 
 	/* Source inode owner (or CAP_FOWNER) can hardlink all they like,
 	 * otherwise, it must be a safe source.
 	 */
-	if (uid_eq(cred->fsuid, inode->i_uid) || safe_hardlink_source(inode) ||
-	    capable(CAP_FOWNER))
+	if (inode_owner_or_capable(inode) || safe_hardlink_source(inode))
 		return 0;
 
 	audit_log_link_denied("linkat", link);
-- 
2.2.1

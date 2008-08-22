From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/10] user namespaces: bad bad bad but test code
Date: Fri, 22 Aug 2008 14:46:33 -0500
Message-ID: <20080822194633.GG10360@us.ibm.com>
References: <20080822194513.GA10262@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822194513.GA10262-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Let uid 0 in a child namespace whose creator owns a file,
access that file.

This of course means that user hallyn (if he is allowed to
remount / for his userns, i.e. through
	capset cap_sys_admin=ep usernsremount
can create files owned by root.

So this is only so we can play.  This code will be removed
in favor of code doing "the right thing" using extended
attributes.  Then, when the above user creates a file,
the inode->iuid will be set to 500 (hallyn), and an
xattr named fs.userns=(<nsid>,0) will store the fact that
in the given nsid (might be 1 for instance) uid 0 owns
the file.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 lib/fsuserns.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/fsuserns.c b/lib/fsuserns.c
index 0a9f52d..c237d1d 100644
--- a/lib/fsuserns.c
+++ b/lib/fsuserns.c
@@ -185,6 +185,15 @@ int fsuserns_convert_uid_gid(struct user_namespace *ns, struct inode *inode,
 convert:
 	mutex_unlock(&fsuserns_table_mutex);
 
+	/* The following is BAD CODE.  IT's for testing only */
+	if (current->uid == 0) {
+		if (inode->i_uid == ns->creator->uid) {
+			*retuid = 0;
+			*retgid = 0;
+			return 1;
+		}
+	}
+
 	/*
 	 * ok now we would look through the xattrs for the
 	 * inode to find a stored uid in this namespace.
-- 
1.5.4.3

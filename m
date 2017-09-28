From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH] security: Make the selinux setxattr and removexattr
	hooks behave
Date: Thu, 28 Sep 2017 17:34:53 -0500
Message-ID: <87tvzmqwoi.fsf__31316.3031860769$1506638135$gmane$org@xmission.com>
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
To: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org


It looks like once upon a time a long time ago selinux copied code
from cap_inode_removexattr and cap_inode_setxattr into
selinux_inode_setotherxattr.  However the code has now diverged and
selinux is implementing a policy that is quite different than
cap_inode_setxattr and cap_inode_removexattr especially when it comes
to the security.capable xattr.

To keep things working and to make the comments in security/security.c
correct when the xattr is securit.capable, call cap_inode_setxattr
or cap_inode_removexattr as appropriate.

I suspect there is a larger conversation to be had here but this
is enough to keep selinux from implementing a non-sense hard coded
policy that breaks other parts of the kernel.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 security/selinux/hooks.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index f5d304736852..edf4bd292dc7 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3167,6 +3167,9 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 	u32 newsid, sid = current_sid();
 	int rc = 0;
 
+	if (strcmp(name, XATTR_NAME_CAPS) == 0)
+		return cap_inode_setxattr(dentry, name, value, size, flags);
+
 	if (strcmp(name, XATTR_NAME_SELINUX))
 		return selinux_inode_setotherxattr(dentry, name);
 
@@ -3282,6 +3285,9 @@ static int selinux_inode_listxattr(struct dentry *dentry)
 
 static int selinux_inode_removexattr(struct dentry *dentry, const char *name)
 {
+	if (strcmp(name, XATTR_NAME_CAPS) == 0)
+		return cap_inode_removexattr(dentry, name);
+
 	if (strcmp(name, XATTR_NAME_SELINUX))
 		return selinux_inode_setotherxattr(dentry, name);
 
-- 
2.14.1

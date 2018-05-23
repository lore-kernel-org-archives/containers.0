From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [REVIEW][PATCH 6/6] fs: Allow CAP_SYS_ADMIN in s_user_ns to freeze
	and thaw filesystems
Date: Wed, 23 May 2018 18:25:38 -0500
Message-ID: <20180523232538.4880-6-ebiederm__11248.7874845558$1527118092$gmane$org@xmission.com>
References: <87o9h6554f.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87o9h6554f.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

The user in control of a super block should be allowed to freeze
and thaw it. Relax the restrictions on the FIFREEZE and FITHAW
ioctls to require CAP_SYS_ADMIN in s_user_ns.

Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ioctl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/ioctl.c b/fs/ioctl.c
index 4823431d1c9d..b445b13fc59b 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -549,7 +549,7 @@ static int ioctl_fsfreeze(struct file *filp)
 {
 	struct super_block *sb = file_inode(filp)->i_sb;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(sb->s_user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	/* If filesystem doesn't support freeze feature, return. */
@@ -566,7 +566,7 @@ static int ioctl_fsthaw(struct file *filp)
 {
 	struct super_block *sb = file_inode(filp)->i_sb;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(sb->s_user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	/* Thaw */
-- 
2.14.1

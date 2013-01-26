From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 6/6] userns: Allow the userns root to mount tmpfs.
Date: Fri, 25 Jan 2013 18:26:48 -0800
Message-ID: <87d2wshe6v.fsf@xmission.com>
References: <87ehh8it9s.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ehh8it9s.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 25 Jan 2013 18:15:43 -0800")
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


There is no backing store to tmpfs and file creation rules are the
same as for any other filesystem so it is semantically safe to allow
unprivileged users to mount it.  ramfs is safe for the same reasons so
allow either flavor of tmpfs to be mounted by a user namespace root
user.

The memory control group successfully limits how much memory tmpfs can
consume on any system that cares about a user namespace root using
tmpfs to exhaust memory the memory control group can be deployed.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 mm/shmem.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 5c90d84..197ca5e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2766,6 +2766,7 @@ static struct file_system_type shmem_fs_type = {
 	.name		= "tmpfs",
 	.mount		= shmem_mount,
 	.kill_sb	= kill_litter_super,
+	.fs_flags	= FS_USERNS_MOUNT,
 };
 
 int __init shmem_init(void)
@@ -2823,6 +2824,7 @@ static struct file_system_type shmem_fs_type = {
 	.name		= "tmpfs",
 	.mount		= ramfs_mount,
 	.kill_sb	= kill_litter_super,
+	.fs_flags	= FS_USERNS_MOUNT,
 };
 
 int __init shmem_init(void)
-- 
1.7.5.4

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 01/14] userns: Convert loop to use kuid_t instead of uid_t
Date: Thu, 20 Sep 2012 17:28:37 -0700
Message-ID: <1348187330-6616-1-git-send-email-ebiederm@xmission.com>
References: <87k3vote43.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3vote43.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: "Signed-off-by: Jens Axboe" <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Signed-off-by: Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/block/loop.c |    4 ++--
 include/linux/loop.h |    2 +-
 init/Kconfig         |    1 -
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 3bba655..e9d594f 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -1038,10 +1038,10 @@ loop_set_status(struct loop_device *lo, const struct loop_info64 *info)
 {
 	int err;
 	struct loop_func_table *xfer;
-	uid_t uid = current_uid();
+	kuid_t uid = current_uid();
 
 	if (lo->lo_encrypt_key_size &&
-	    lo->lo_key_owner != uid &&
+	    !uid_eq(lo->lo_key_owner, uid) &&
 	    !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 	if (lo->lo_state != Lo_bound)
diff --git a/include/linux/loop.h b/include/linux/loop.h
index 11a41a8..9635116 100644
--- a/include/linux/loop.h
+++ b/include/linux/loop.h
@@ -44,7 +44,7 @@ struct loop_device {
 	int		lo_encrypt_key_size;
 	struct loop_func_table *lo_encryption;
 	__u32           lo_init[2];
-	uid_t		lo_key_owner;	/* Who set the key */
+	kuid_t		lo_key_owner;	/* Who set the key */
 	int		(*ioctl)(struct loop_device *, int cmd, 
 				 unsigned long arg); 
 
diff --git a/init/Kconfig b/init/Kconfig
index f0371a6..f315997 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -960,7 +960,6 @@ config UIDGID_CONVERTED
 	depends on !UML || HOSTFS = n
 
 	# The rare drivers that won't build
-	depends on BLK_DEV_LOOP = n
 	depends on ANDROID_BINDER_IPC = n
 
 	# Security modules
-- 
1.7.5.4

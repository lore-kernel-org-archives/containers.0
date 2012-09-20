From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 03/25] userns: Convert usb functionfs to use kuid/kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:41:44 -0700
Message-ID: <1348141326-23355-3-git-send-email-ebiederm@xmission.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348141326-23355-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/usb/gadget/f_fs.c |   23 ++++++++++++++++-------
 init/Kconfig              |    1 -
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/usb/gadget/f_fs.c b/drivers/usb/gadget/f_fs.c
index 8adc79d..f9ee4e0 100644
--- a/drivers/usb/gadget/f_fs.c
+++ b/drivers/usb/gadget/f_fs.c
@@ -220,8 +220,8 @@ struct ffs_data {
 	/* File permissions, written once when fs is mounted */
 	struct ffs_file_perms {
 		umode_t				mode;
-		uid_t				uid;
-		gid_t				gid;
+		kuid_t				uid;
+		kgid_t				gid;
 	}				file_perms;
 
 	/*
@@ -1143,10 +1143,19 @@ static int ffs_fs_parse_opts(struct ffs_sb_fill_data *data, char *opts)
 			break;
 
 		case 3:
-			if (!memcmp(opts, "uid", 3))
-				data->perms.uid = value;
+			if (!memcmp(opts, "uid", 3)) {
+				data->perms.uid = make_kuid(current_user_ns(), value);
+				if (!uid_valid(data->perms.uid)) {
+					pr_err("%s: unmapped value: %lu\n", opts, value);
+					return -EINVAL;
+				}
+			}
 			else if (!memcmp(opts, "gid", 3))
-				data->perms.gid = value;
+				data->perms.gid = make_kgid(current_user_ns(), value);
+				if (!gid_valid(data->perms.gid)) {
+					pr_err("%s: unmapped value: %lu\n", opts, value);
+					return -EINVAL;
+				}
 			else
 				goto invalid;
 			break;
@@ -1175,8 +1184,8 @@ ffs_fs_mount(struct file_system_type *t, int flags,
 	struct ffs_sb_fill_data data = {
 		.perms = {
 			.mode = S_IFREG | 0600,
-			.uid = 0,
-			.gid = 0
+			.uid = GLOBAL_ROOT_UID,
+			.gid = GLOBAL_ROOT_GID,
 		},
 		.root_mode = S_IFDIR | 0500,
 	};
diff --git a/init/Kconfig b/init/Kconfig
index 633bde2..e7e0cc1 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -932,7 +932,6 @@ config UIDGID_CONVERTED
 	depends on NET_9P = n
 
 	# Filesystems
-	depends on USB_FUNCTIONFS = n
 	depends on DEVTMPFS = n
 	depends on XENFS = n
 
-- 
1.7.5.4

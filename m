From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 4/9][cr][v2]: Restore file_owner info
Date: Tue, 18 May 2010 20:07:27 -0700
Message-ID: <1274238452-15382-5-git-send-email-sukadev__22498.0214181871$1274238161$gmane$org@linux.vnet.ibm.com>
References: <1274238452-15382-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274238452-15382-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

Restore the file-owner information for each 'struct file'.  This is
essentially is like a new fcntl(F_SETOWN) and fcntl(F_SETSIG) calls,
except that the pid, uid, euid and signum values are read from the
checkpoint image.

Changelog[v2]:
	- [Matt Helsley, Serge Hallyn]: Don't trust uids in checkpoint image.
	  (added CAP_KILL check)
	- Check that signal number read from the checkpoint image is valid.
	  (not sure it is required, since its an incomplete check for tampering)

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c |   55 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 0fa4ce8..e82f4f1 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -615,6 +615,57 @@ static int attach_file(struct file *file)
 	return fd;
 }
 
+static int restore_file_owner(struct ckpt_ctx *ctx, struct ckpt_hdr_file *h,
+		struct file *file)
+{
+	int ret;
+	struct pid *pid;
+	uid_t uid, euid;
+
+	uid = h->f_owner_uid;
+	euid = h->f_owner_euid;
+
+	ckpt_debug("restore_file_owner(): uid %u, euid %u, pid %d, type %d\n",
+			uid, euid, h->f_owner_pid, h->f_owner_pid_type);
+	/*
+	 * We can't trust the uids in the checkpoint image and normally need
+	 * CAP_KILL. But if the uids match our ids, should be fine since we
+	 * have access to the file.
+	 *
+	 * TODO: Move this check to __f_setown() ?
+	 */
+	ret = -EACCES;
+	if (!capable(CAP_KILL) &&
+			(uid != current_uid() || euid != current_euid())) {
+		ckpt_err(ctx, ret, "image uids [%d, %d] don't match current "
+				"process uids [%d, %d] and no CAP_KILL\n",
+				uid, euid, current_uid(), current_euid());
+		return ret;
+	}
+
+	ret = -EINVAL;
+	if (!valid_signal(h->f_owner_signum)) {
+		ckpt_err(ctx, ret, "Invalid signum %d\n", h->f_owner_signum);
+		return ret;
+	}
+	file->f_owner.signum = h->f_owner_signum;
+
+	rcu_read_lock();
+	pid = find_vpid(h->f_owner_pid);
+	/*
+	 * TODO: Do we need to force==1 or can it be 0 ? 'force' is used to
+	 * 	 modify the owner, if one is already set. Can it be set when
+	 * 	 we restart an application ?
+	 */
+	ret = __f_setown(file, pid, h->f_owner_pid_type, uid, euid, 1);
+	rcu_read_unlock();
+
+	if (ret < 0)
+		ckpt_err(ctx, ret, "__fsetown_uid() failed\n");
+
+	return ret;
+}
+
 #define CKPT_SETFL_MASK  \
 	(O_APPEND | O_NONBLOCK | O_NDELAY | FASYNC | O_DIRECT | O_NOATIME)
 
@@ -648,6 +699,10 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	if (ret < 0)
 		return ret;
 
+	ret = restore_file_owner(ctx, h, file);
+	if (ret < 0)
+		return ret;
+
 	/*
 	 * Normally f_mode is set by open, and modified only via
 	 * fcntl(), so its value now should match that at checkpoint.
-- 
1.6.0.4

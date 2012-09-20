From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 26/27] userns: Convert struct dquot_warn
Date: Wed, 19 Sep 2012 18:52:28 -0700
Message-ID: <1348105949-25454-26-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Convert w_dq_id to be a struct kquid and remove the now unncessary
w_dq_type.

This is a simple conversion and enough other places have already
been converted that this actually reduces the code complexity
by a little bit, when removing now unnecessary type conversions.

Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/quota/dquot.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index efaeed3..f3db845 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -1132,8 +1132,7 @@ static void dquot_decr_space(struct dquot *dquot, qsize_t number)
 
 struct dquot_warn {
 	struct super_block *w_sb;
-	qid_t w_dq_id;
-	short w_dq_type;
+	struct kqid w_dq_id;
 	short w_type;
 };
 
@@ -1157,11 +1156,11 @@ static int need_print_warning(struct dquot_warn *warn)
 	if (!flag_print_warnings)
 		return 0;
 
-	switch (warn->w_dq_type) {
+	switch (warn->w_dq_id.type) {
 		case USRQUOTA:
-			return current_fsuid() == warn->w_dq_id;
+			return current_fsuid() == warn->w_dq_id.uid;
 		case GRPQUOTA:
-			return in_group_p(warn->w_dq_id);
+			return in_group_p(warn->w_dq_id.gid);
 	}
 	return 0;
 }
@@ -1187,7 +1186,7 @@ static void print_warning(struct dquot_warn *warn)
 		tty_write_message(tty, ": warning, ");
 	else
 		tty_write_message(tty, ": write failed, ");
-	tty_write_message(tty, quotatypes[warn->w_dq_type]);
+	tty_write_message(tty, quotatypes[warn->w_dq_id.type]);
 	switch (warntype) {
 		case QUOTA_NL_IHARDWARN:
 			msg = " file limit reached.\r\n";
@@ -1220,8 +1219,7 @@ static void prepare_warning(struct dquot_warn *warn, struct dquot *dquot,
 		return;
 	warn->w_type = warntype;
 	warn->w_sb = dquot->dq_sb;
-	warn->w_dq_id = from_kqid(&init_user_ns, dquot->dq_id);
-	warn->w_dq_type = dquot->dq_id.type;
+	warn->w_dq_id = dquot->dq_id;
 }
 
 /*
@@ -1239,7 +1237,7 @@ static void flush_warnings(struct dquot_warn *warn)
 #ifdef CONFIG_PRINT_QUOTA_WARNING
 		print_warning(&warn[i]);
 #endif
-		quota_send_warning(make_kqid(&init_user_ns, warn[i].w_dq_type, warn[i].w_dq_id),
+		quota_send_warning(warn[i].w_dq_id,
 				   warn[i].w_sb->s_dev, warn[i].w_type);
 	}
 }
-- 
1.7.5.4

From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [PATCHv5] locks: Filter /proc/locks output on proc pid ns
Date: Fri,  5 Aug 2016 10:30:04 +0300
Message-ID: <1470382204-21480-1-git-send-email-kernel@kyup.com>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1470148943-21835-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On busy container servers reading /proc/locks shows all the locks
created by all clients. This can cause large latency spikes. In my
case I observed lsof taking up to 5-10 seconds while processing around
50k locks. Fix this by limiting the locks shown only to those created
in the same pidns as the one the proc fs was mounted in. When reading
/proc/locks from the init_pid_ns proc instance then perform no
filtering

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/locks.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ee1b15f6fc13..484b7e106076 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2574,9 +2574,19 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 	struct inode *inode = NULL;
 	unsigned int fl_pid;
 
-	if (fl->fl_nspid)
-		fl_pid = pid_vnr(fl->fl_nspid);
-	else
+	if (fl->fl_nspid) {
+		struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
+
+		/* Don't let fl_pid change depending on who is reading the file */
+		fl_pid = pid_nr_ns(fl->fl_nspid, proc_pidns);
+
+		/* If there isn't a fl_pid don't display who is waiting on the lock
+		 * if we are called from locks_show, or if we are called from
+		 * __show_fd_info - skip lock entirely
+		 */
+		if (fl_pid == 0)
+			return;
+	} else
 		fl_pid = fl->fl_pid;
 
 	if (fl->fl_file != NULL)
@@ -2648,9 +2658,13 @@ static int locks_show(struct seq_file *f, void *v)
 {
 	struct locks_iterator *iter = f->private;
 	struct file_lock *fl, *bfl;
+	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
 
 	fl = hlist_entry(v, struct file_lock, fl_link);
 
+	if (fl->fl_nspid && !pid_nr_ns(fl->fl_nspid, proc_pidns))
+		return 0;
+
 	lock_get_status(f, fl, iter->li_pos, "");
 
 	list_for_each_entry(bfl, &fl->fl_block, fl_block)
-- 
2.5.0

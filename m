From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [PATCHv4] locks: Filter /proc/locks output on proc pid ns
Date: Thu,  4 Aug 2016 10:26:28 +0300
Message-ID: <1470295588-9803-1-git-send-email-kernel@kyup.com>
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
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org
Cc: bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
List-Id: containers.vger.kernel.org

On busy container servers reading /proc/locks shows all the locks
created by all clients. This can cause large latency spikes. In my
case I observed lsof taking up to 5-10 seconds while processing around
50k locks. Fix this by limiting the locks shown only to those created
in the same pidns as the one the proc fs was mounted in. When reading
/proc/locks from the init_pid_ns proc instance then perform no
filtering

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 fs/locks.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index ee1b15f6fc13..df038c27b19f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2648,9 +2648,13 @@ static int locks_show(struct seq_file *f, void *v)
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

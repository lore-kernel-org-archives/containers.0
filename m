From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [CRIU] BUG: Dentry ffff9f795a08fe60{i=af565f,
	n=lo} still in use (1) [unmount of proc proc]
Date: Thu, 06 Jul 2017 08:41:00 -0500
Message-ID: <87van54r9v.fsf__17262.1386046105$1499348948$gmane$org@xmission.com>
References: <CANaxB-yneyRrUhJp1uwvHcaC88n3yyF5Jjr=1A869hWQsXfNEg@mail.gmail.com>
	<8737ai4ns6.fsf@xmission.com>
	<CANaxB-z-K=A2_OfMsXqROttsef0SXSeACX8Wj9ik2NJ1Dkz_Fw@mail.gmail.com>
	<87vane1cao.fsf@xmission.com>
	<20170630191106.GB8899@outlook.office365.com>
	<20170703163646.GA9346@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170703163646.GA9346-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Andrei Vagin's message of
	"Mon, 3 Jul 2017 09:36:48 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>, Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> I did a few experiments and found that the bug is reproduced for 6-12
> hours on the our test server. Then I reverted two patches and the server
> is working normally for more than 24 hours already, so the bug is
> probably in one of these patches.
>
> commit e3d0065ab8535cbeee69a4c46a59f4d7360803ae
> Author: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Date:   Sun Jul 2 07:41:25 2017 +0200
>
>     Revert "proc/sysctl: prune stale dentries during unregistering"
>     
>     This reverts commit d6cffbbe9a7e51eb705182965a189457c17ba8a3.
>
> commit 2d3c50dac81011c1da4d2f7a63b84bd75287e320
> Author: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Date:   Sun Jul 2 07:40:08 2017 +0200
>
>     Revert "proc/sysctl: Don't grab i_lock under sysctl_lock."
>     
>     This reverts commit ace0c791e6c3cf5ef37cad2df69f0d90ccc40ffb.
>
>
> FYI: This bug has been reproduced on 4.11.7

Instead of the revert could you test the patch below?

This should fix the issue by grabbing a s_active reference
to the proc super block for every inode we flush.

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c5ae09b6c726..18694598bebf 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -67,7 +67,7 @@ struct proc_inode {
 	struct proc_dir_entry *pde;
 	struct ctl_table_header *sysctl;
 	struct ctl_table *sysctl_entry;
-	struct list_head sysctl_inodes;
+	struct hlist_node sysctl_inodes;
 	const struct proc_ns_operations *ns_ops;
 	struct inode vfs_inode;
 };
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 67985a7233c2..9bf06e2b1284 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -191,7 +191,7 @@ static void init_header(struct ctl_table_header *head,
 	head->set = set;
 	head->parent = NULL;
 	head->node = node;
-	INIT_LIST_HEAD(&head->inodes);
+	INIT_HLIST_HEAD(&head->inodes);
 	if (node) {
 		struct ctl_table *entry;
 		for (entry = table; entry->procname; entry++, node++)
@@ -261,25 +261,42 @@ static void unuse_table(struct ctl_table_header *p)
 			complete(p->unregistering);
 }
 
-/* called under sysctl_lock */
 static void proc_sys_prune_dcache(struct ctl_table_header *head)
 {
-	struct inode *inode, *prev = NULL;
+	struct inode *inode;
 	struct proc_inode *ei;
+	struct hlist_node *node;
+	struct super_block *sb;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(ei, &head->inodes, sysctl_inodes) {
-		inode = igrab(&ei->vfs_inode);
-		if (inode) {
-			rcu_read_unlock();
-			iput(prev);
-			prev = inode;
-			d_prune_aliases(inode);
+	for (;;) {
+		node = hlist_first_rcu(&head->inodes);
+		if (!node)
+			break;
+		ei = hlist_entry(node, struct proc_inode, sysctl_inodes);
+		spin_lock(&sysctl_lock);
+		hlist_del_init_rcu(&ei->sysctl_inodes);
+		spin_unlock(&sysctl_lock);
+
+		inode = &ei->vfs_inode;
+		sb = inode->i_sb;
+		if (!atomic_inc_not_zero(&sb->s_active))
+			continue;
+		inode = igrab(inode);
+		rcu_read_unlock();
+		if (unlikely(!inode)) {
+			deactivate_super(sb);
 			rcu_read_lock();
+			continue;
 		}
+
+		d_prune_aliases(inode);
+		iput(inode);
+		deactivate_super(sb);
+
+		rcu_read_lock();
 	}
 	rcu_read_unlock();
-	iput(prev);
 }
 
 /* called under sysctl_lock, will reacquire if has to wait */
@@ -461,7 +478,7 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 	}
 	ei->sysctl = head;
 	ei->sysctl_entry = table;
-	list_add_rcu(&ei->sysctl_inodes, &head->inodes);
+	hlist_add_head_rcu(&ei->sysctl_inodes, &head->inodes);
 	head->count++;
 	spin_unlock(&sysctl_lock);
 
@@ -489,7 +506,7 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 void proc_sys_evict_inode(struct inode *inode, struct ctl_table_header *head)
 {
 	spin_lock(&sysctl_lock);
-	list_del_rcu(&PROC_I(inode)->sysctl_inodes);
+	hlist_del_init_rcu(&PROC_I(inode)->sysctl_inodes);
 	if (!--head->count)
 		kfree_rcu(head, rcu);
 	spin_unlock(&sysctl_lock);
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 80d07816def0..1c04a26bfd2f 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -143,7 +143,7 @@ struct ctl_table_header
 	struct ctl_table_set *set;
 	struct ctl_dir *parent;
 	struct ctl_node *node;
-	struct list_head inodes; /* head for proc_inode->sysctl_inodes */
+	struct hlist_head inodes; /* head for proc_inode->sysctl_inodes */
 };
 
 struct ctl_dir {

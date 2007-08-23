From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Remove unused variables from fs/proc/base.c
Date: Thu, 23 Aug 2007 19:43:19 +0400
Message-ID: <46CDAB17.4040105@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764685AbXHWPsK@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Sukadev Bhattiprolu <sukadev@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

When removing the explicit task_struct->pid usage I found that
proc_readfd_common() and proc_pident_readdir() get this field,
but do not use it at all. So this cleanup is a cheap help with
the task_struct->pid isolation.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 fs/proc/base.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 2fb3dfc..79e1918 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1434,7 +1434,7 @@ static int proc_readfd_common(struct fil
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 	struct task_struct *p = get_proc_task(inode);
-	unsigned int fd, tid, ino;
+	unsigned int fd, ino;
 	int retval;
 	struct files_struct * files;
 	struct fdtable *fdt;
@@ -1443,7 +1443,6 @@ static int proc_readfd_common(struct fil
 	if (!p)
 		goto out_no_task;
 	retval = 0;
-	tid = p->pid;
 
 	fd = filp->f_pos;
 	switch (fd) {
@@ -1678,7 +1677,6 @@ static int proc_pident_readdir(struct fi
 		const struct pid_entry *ents, unsigned int nents)
 {
 	int i;
-	int pid;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 	struct task_struct *task = get_proc_task(inode);
@@ -1691,7 +1689,6 @@ static int proc_pident_readdir(struct fi
 		goto out_no_task;
 
 	ret = 0;
-	pid = task->pid;
 	i = filp->f_pos;
 	switch (i) {
 	case 0:

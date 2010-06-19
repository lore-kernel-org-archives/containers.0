From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/4] procfs: proc_get_sb: consolidate/cleanup
	root_inode->pid logic
Date: Sat, 19 Jun 2010 21:09:26 +0200
Message-ID: <20100619190926.GB3424@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100619190840.GA3424@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Depending on whether it is called by the init_pid_ns or not, proc_get_sb()
does different things to initialize PROC_I(s_root->d_inode)->pid, and both
look ugly, imho.

- init_pid_ns tries to initialize ->pid every time proc_get_sb() is
  called, and we check the global proc_mnt != NULL to ensure proc_get_sb()
  was already called in the past and thus it is safe to use sb->s_root.

- sub-namespaces set ->pid at MS_KERNMOUNT stage and thus proc_get_sb()
  can'be called before the first alloc_pid() in copy_process(), ugly.

Consolidate this code, and initialize PROC_I(s_root->d_inode)->pid when
the proc fs is actually mounted (MS_KERNMOUNT is not set). This also
allows us to do more cleanups.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/proc/root.c |   23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

--- 35-rc3/fs/proc/root.c~PNS_1_PROC_GET_SB_ROOT_PID	2010-06-19 19:20:23.000000000 +0200
+++ 35-rc3/fs/proc/root.c	2010-06-19 19:21:38.000000000 +0200
@@ -41,18 +41,6 @@ static int proc_get_sb(struct file_syste
 	int err;
 	struct super_block *sb;
 	struct pid_namespace *ns;
-	struct proc_inode *ei;
-
-	if (proc_mnt) {
-		/* Seed the root directory with a pid so it doesn't need
-		 * to be special in base.c.  I would do this earlier but
-		 * the only task alive when /proc is mounted the first time
-		 * is the init_task and it doesn't have any pids.
-		 */
-		ei = PROC_I(proc_mnt->mnt_sb->s_root->d_inode);
-		if (!ei->pid)
-			ei->pid = find_get_pid(1);
-	}
 
 	if (flags & MS_KERNMOUNT)
 		ns = (struct pid_namespace *)data;
@@ -71,15 +59,18 @@ static int proc_get_sb(struct file_syste
 			return err;
 		}
 
-		ei = PROC_I(sb->s_root->d_inode);
+		sb->s_flags |= MS_ACTIVE;
+		ns->proc_mnt = mnt;
+	}
+
+	/* MS_KERNMOUNT is called before ns has any pids */
+	if (!(flags & MS_KERNMOUNT)) {
+		struct proc_inode *ei = PROC_I(sb->s_root->d_inode);
 		if (!ei->pid) {
 			rcu_read_lock();
 			ei->pid = get_pid(find_pid_ns(1, ns));
 			rcu_read_unlock();
 		}
-
-		sb->s_flags |= MS_ACTIVE;
-		ns->proc_mnt = mnt;
 	}
 
 	simple_set_mnt(mnt, sb);

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 13/14] userns: On ia64 deal with current_uid and current_gid
	being kuid and kgid
Date: Thu, 20 Sep 2012 17:28:49 -0700
Message-ID: <1348187330-6616-13-git-send-email-ebiederm@xmission.com>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348187330-6616-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

These ia64 uses of current_uid and current_gid slipped through the
cracks when I was converting everything to kuids and kgids convert
them now.

Cc: Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 arch/ia64/kernel/mca_drv.c |    3 ++-
 arch/ia64/kernel/perfmon.c |   32 ++++++++++++++++----------------
 arch/ia64/kernel/signal.c  |    4 ++--
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 1c2e894..9392e02 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -158,7 +158,8 @@ mca_handler_bh(unsigned long paddr, void *iip, unsigned long ipsr)
 	ia64_mlogbuf_dump();
 	printk(KERN_ERR "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
 		"iip: %p, psr: 0x%lx,paddr: 0x%lx](%s) encounters MCA.\n",
-	       raw_smp_processor_id(), current->pid, current_uid(),
+	       raw_smp_processor_id(), current->pid,
+		from_kuid(&init_user_ns, current_uid()),
 		iip, ipsr, paddr, current->comm);
 
 	spin_lock(&mca_bh_lock);
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 3fa4bc5..5a5c222 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2380,8 +2380,8 @@ static int
 pfm_bad_permissions(struct task_struct *task)
 {
 	const struct cred *tcred;
-	uid_t uid = current_uid();
-	gid_t gid = current_gid();
+	kuid_t uid = current_uid();
+	kgid_t gid = current_gid();
 	int ret;
 
 	rcu_read_lock();
@@ -2389,20 +2389,20 @@ pfm_bad_permissions(struct task_struct *task)
 
 	/* inspired by ptrace_attach() */
 	DPRINT(("cur: uid=%d gid=%d task: euid=%d suid=%d uid=%d egid=%d sgid=%d\n",
-		uid,
-		gid,
-		tcred->euid,
-		tcred->suid,
-		tcred->uid,
-		tcred->egid,
-		tcred->sgid));
-
-	ret = ((uid != tcred->euid)
-	       || (uid != tcred->suid)
-	       || (uid != tcred->uid)
-	       || (gid != tcred->egid)
-	       || (gid != tcred->sgid)
-	       || (gid != tcred->gid)) && !capable(CAP_SYS_PTRACE);
+		from_kuid(&init_user_ns, uid),
+		from_kgid(&init_user_ns, gid),
+		from_kuid(&init_user_ns, tcred->euid),
+		from_kuid(&init_user_ns, tcred->suid),
+		from_kuid(&init_user_ns, tcred->uid),
+		from_kgid(&init_user_ns, tcred->egid),
+		from_kgid(&init_user_ns, tcred->sgid)));
+
+	ret = ((!uid_eq(uid, tcred->euid))
+	       || (!uid_eq(uid, tcred->suid))
+	       || (!uid_eq(uid, tcred->uid))
+	       || (!gid_eq(gid, tcred->egid))
+	       || (!gid_eq(gid, tcred->sgid))
+	       || (!gid_eq(gid, tcred->gid))) && !capable(CAP_SYS_PTRACE);
 
 	rcu_read_unlock();
 	return ret;
diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index a199be1..37dd795 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -220,7 +220,7 @@ ia64_rt_sigreturn (struct sigscratch *scr)
 	si.si_errno = 0;
 	si.si_code = SI_KERNEL;
 	si.si_pid = task_pid_vnr(current);
-	si.si_uid = current_uid();
+	si.si_uid = from_kuid_munged(current_user_ns(), current_uid());
 	si.si_addr = sc;
 	force_sig_info(SIGSEGV, &si, current);
 	return retval;
@@ -317,7 +317,7 @@ force_sigsegv_info (int sig, void __user *addr)
 	si.si_errno = 0;
 	si.si_code = SI_KERNEL;
 	si.si_pid = task_pid_vnr(current);
-	si.si_uid = current_uid();
+	si.si_uid = from_kuid_munged(current_user_ns(), current_uid());
 	si.si_addr = addr;
 	force_sig_info(SIGSEGV, &si, current);
 	return 0;
-- 
1.7.5.4

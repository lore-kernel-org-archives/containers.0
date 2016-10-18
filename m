From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH] exec: Don't exec files the userns root can not read.
Date: Tue, 18 Oct 2016 16:15:20 -0500
Message-ID: <87k2d5nytz.fsf_-___15578.2842812643$1476825479$gmane$org@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r37dnz74.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 18 Oct 2016 16:07:27 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


When the user namespace support was merged the need to prevent
ptracing an executable that is not readable was overlooked.

Correct this oversight by not letting exec succeed if during exec an
executable is not readable and the current user namespace capabilities
do not apply to the executable's file.

While it happens that distros install some files setuid and
non-readable I have not found any executable files just installed
non-readalbe.  Executables that are setuid to a user not mapped in a
user namespace are worthless, so I don't expect this to introduce
any problems in practice.

There may be a way to allow this execution to happen by setting
mm->user_ns to a more privileged user namespace and watching out for
the possibility of using dynamic linkers or other shared libraries
that the kernel loads into the mm to bypass the read-only
restriction.  But the analysis is more difficult and it would
require more code churn so I don't think the effort is worth it.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Fixes: 9e4a36ece652 ("userns: Fail exec for suid and sgid binaries with ids outside our user namespace.")
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

Tossing this out for review in case I missed something silly but this
patch seems pretty trivial.

 arch/x86/ia32/ia32_aout.c |  4 +++-
 fs/binfmt_aout.c          |  4 +++-
 fs/binfmt_elf.c           |  4 +++-
 fs/binfmt_elf_fdpic.c     |  4 +++-
 fs/binfmt_flat.c          |  4 +++-
 fs/exec.c                 | 19 ++++++++++++++++---
 include/linux/binfmts.h   |  6 +++++-
 7 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index cb26f18d43af..7ad20dedd929 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -294,7 +294,9 @@ static int load_aout_binary(struct linux_binprm *bprm)
 	set_personality(PER_LINUX);
 	set_personality_ia32(false);
 
-	setup_new_exec(bprm);
+	retval = setup_new_exec(bprm);
+	if (retval)
+		return retval;
 
 	regs->cs = __USER32_CS;
 	regs->r8 = regs->r9 = regs->r10 = regs->r11 = regs->r12 =
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index ae1b5404fced..b7b8aa03ccd0 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -242,7 +242,9 @@ static int load_aout_binary(struct linux_binprm * bprm)
 #else
 	set_personality(PER_LINUX);
 #endif
-	setup_new_exec(bprm);
+	retval = setup_new_exec(bprm);
+	if (retval)
+		return retval;
 
 	current->mm->end_code = ex.a_text +
 		(current->mm->start_code = N_TXTADDR(ex));
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 2472af2798c7..423fece0b8c4 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -852,7 +852,9 @@ static int load_elf_binary(struct linux_binprm *bprm)
 	if (!(current->personality & ADDR_NO_RANDOMIZE) && randomize_va_space)
 		current->flags |= PF_RANDOMIZE;
 
-	setup_new_exec(bprm);
+	retval = setup_new_exec(bprm);
+	if (retval)
+		goto out_free_dentry;
 	install_exec_creds(bprm);
 
 	/* Do this so that we can load the interpreter, if need be.  We will
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 464a972e88c1..d3099caff96d 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -352,7 +352,9 @@ static int load_elf_fdpic_binary(struct linux_binprm *bprm)
 	if (elf_read_implies_exec(&exec_params.hdr, executable_stack))
 		current->personality |= READ_IMPLIES_EXEC;
 
-	setup_new_exec(bprm);
+	retval = setup_new_exec(bprm);
+	if (retval)
+		goto error;
 
 	set_binfmt(&elf_fdpic_format);
 
diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
index 9b2917a30294..25ca68940ad4 100644
--- a/fs/binfmt_flat.c
+++ b/fs/binfmt_flat.c
@@ -524,7 +524,9 @@ static int load_flat_file(struct linux_binprm *bprm,
 
 		/* OK, This is the point of no return */
 		set_personality(PER_LINUX_32BIT);
-		setup_new_exec(bprm);
+		ret = setup_new_exec(bprm);
+		if (ret)
+			goto err;
 	}
 
 	/*
diff --git a/fs/exec.c b/fs/exec.c
index 6fcfb3f7b137..f724ed94ba7a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1270,12 +1270,21 @@ EXPORT_SYMBOL(flush_old_exec);
 
 void would_dump(struct linux_binprm *bprm, struct file *file)
 {
-	if (inode_permission(file_inode(file), MAY_READ) < 0)
+	struct inode *inode = file_inode(file);
+	if (inode_permission(inode, MAY_READ) < 0) {
+		struct user_namespace *user_ns = current->mm->user_ns;
 		bprm->interp_flags |= BINPRM_FLAGS_ENFORCE_NONDUMP;
+
+		/* May the user_ns root read the executable? */
+		if (!kuid_has_mapping(user_ns, inode->i_uid) ||
+		    !kgid_has_mapping(user_ns, inode->i_gid)) {
+			bprm->interp_flags |= BINPRM_FLAGS_EXEC_INACCESSIBLE;
+		}
+	}
 }
 EXPORT_SYMBOL(would_dump);
 
-void setup_new_exec(struct linux_binprm * bprm)
+int setup_new_exec(struct linux_binprm * bprm)
 {
 	arch_pick_mmap_layout(current->mm);
 
@@ -1296,12 +1305,15 @@ void setup_new_exec(struct linux_binprm * bprm)
 	 */
 	current->mm->task_size = TASK_SIZE;
 
+	would_dump(bprm, bprm->file);
+	if (bprm->interp_flags & BINPRM_FLAGS_EXEC_INACCESSIBLE)
+		return -EPERM;
+
 	/* install the new credentials */
 	if (!uid_eq(bprm->cred->uid, current_euid()) ||
 	    !gid_eq(bprm->cred->gid, current_egid())) {
 		current->pdeath_signal = 0;
 	} else {
-		would_dump(bprm, bprm->file);
 		if (bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP)
 			set_dumpable(current->mm, suid_dumpable);
 	}
@@ -1311,6 +1323,7 @@ void setup_new_exec(struct linux_binprm * bprm)
 	current->self_exec_id++;
 	flush_signal_handlers(current, 0);
 	do_close_on_exec(current->files);
+	return 0;
 }
 EXPORT_SYMBOL(setup_new_exec);
 
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index 1303b570b18c..8e5fb9eca2ee 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -57,6 +57,10 @@ struct linux_binprm {
 #define BINPRM_FLAGS_PATH_INACCESSIBLE_BIT 2
 #define BINPRM_FLAGS_PATH_INACCESSIBLE (1 << BINPRM_FLAGS_PATH_INACCESSIBLE_BIT)
 
+/* executable is inaccessible for performing exec */
+#define BINPRM_FLAGS_EXEC_INACCESSIBLE_BIT 3
+#define BINPRM_FLAGS_EXEC_INACCESSIBLE (1 << BINPRM_FLAGS_EXEC_INACCESSIBLE_BIT)
+
 /* Function parameter for binfmt->coredump */
 struct coredump_params {
 	const siginfo_t *siginfo;
@@ -100,7 +104,7 @@ extern int prepare_binprm(struct linux_binprm *);
 extern int __must_check remove_arg_zero(struct linux_binprm *);
 extern int search_binary_handler(struct linux_binprm *);
 extern int flush_old_exec(struct linux_binprm * bprm);
-extern void setup_new_exec(struct linux_binprm * bprm);
+extern int setup_new_exec(struct linux_binprm * bprm);
 extern void would_dump(struct linux_binprm *, struct file *);
 
 extern int suid_dumpable;
-- 
2.8.3

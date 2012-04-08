From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 33/43] userns: Convert binary formats to use kuid/kgid where
	appropriate
Date: Sat,  7 Apr 2012 22:15:29 -0700
Message-ID: <1333862139-31737-33-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/binfmt_elf.c       |   12 ++++++------
 fs/binfmt_elf_fdpic.c |   12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 48ffb3d..efc6731 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -228,10 +228,10 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	NEW_AUX_ENT(AT_BASE, interp_load_addr);
 	NEW_AUX_ENT(AT_FLAGS, 0);
 	NEW_AUX_ENT(AT_ENTRY, exec->e_entry);
-	NEW_AUX_ENT(AT_UID, cred->uid);
-	NEW_AUX_ENT(AT_EUID, cred->euid);
-	NEW_AUX_ENT(AT_GID, cred->gid);
-	NEW_AUX_ENT(AT_EGID, cred->egid);
+	NEW_AUX_ENT(AT_UID, from_kuid_munged(cred->user_ns, cred->uid));
+	NEW_AUX_ENT(AT_EUID, from_kuid_munged(cred->user_ns, cred->euid));
+	NEW_AUX_ENT(AT_GID, from_kgid_munged(cred->user_ns, cred->gid));
+	NEW_AUX_ENT(AT_EGID, from_kgid_munged(cred->user_ns, cred->egid));
  	NEW_AUX_ENT(AT_SECURE, security_bprm_secureexec(bprm));
 	NEW_AUX_ENT(AT_RANDOM, (elf_addr_t)(unsigned long)u_rand_bytes);
 	NEW_AUX_ENT(AT_EXECFN, bprm->exec);
@@ -1367,8 +1367,8 @@ static int fill_psinfo(struct elf_prpsinfo *psinfo, struct task_struct *p,
 	psinfo->pr_flag = p->flags;
 	rcu_read_lock();
 	cred = __task_cred(p);
-	SET_UID(psinfo->pr_uid, cred->uid);
-	SET_GID(psinfo->pr_gid, cred->gid);
+	SET_UID(psinfo->pr_uid, from_kuid_munged(cred->user_ns, cred->uid));
+	SET_GID(psinfo->pr_gid, from_kgid_munged(cred->user_ns, cred->gid));
 	rcu_read_unlock();
 	strncpy(psinfo->pr_fname, p->comm, sizeof(psinfo->pr_fname));
 	
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 9bd5612..82bf0ed 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -631,10 +631,10 @@ static int create_elf_fdpic_tables(struct linux_binprm *bprm,
 	NEW_AUX_ENT(AT_BASE,	interp_params->elfhdr_addr);
 	NEW_AUX_ENT(AT_FLAGS,	0);
 	NEW_AUX_ENT(AT_ENTRY,	exec_params->entry_addr);
-	NEW_AUX_ENT(AT_UID,	(elf_addr_t) cred->uid);
-	NEW_AUX_ENT(AT_EUID,	(elf_addr_t) cred->euid);
-	NEW_AUX_ENT(AT_GID,	(elf_addr_t) cred->gid);
-	NEW_AUX_ENT(AT_EGID,	(elf_addr_t) cred->egid);
+	NEW_AUX_ENT(AT_UID,	(elf_addr_t) from_kuid_munged(cred->user_ns, cred->uid));
+	NEW_AUX_ENT(AT_EUID,	(elf_addr_t) from_kuid_munged(cred->user_ns, cred->euid));
+	NEW_AUX_ENT(AT_GID,	(elf_addr_t) from_kgid_munged(cred->user_ns, cred->gid));
+	NEW_AUX_ENT(AT_EGID,	(elf_addr_t) from_kgid_munged(cred->user_ns, cred->egid));
 	NEW_AUX_ENT(AT_SECURE,	security_bprm_secureexec(bprm));
 	NEW_AUX_ENT(AT_EXECFN,	bprm->exec);
 
@@ -1431,8 +1431,8 @@ static int fill_psinfo(struct elf_prpsinfo *psinfo, struct task_struct *p,
 	psinfo->pr_flag = p->flags;
 	rcu_read_lock();
 	cred = __task_cred(p);
-	SET_UID(psinfo->pr_uid, cred->uid);
-	SET_GID(psinfo->pr_gid, cred->gid);
+	SET_UID(psinfo->pr_uid, from_kuid_munged(cred->user_ns, cred->uid));
+	SET_GID(psinfo->pr_gid, from_kgid_munged(cred->user_ns, cred->gid));
 	rcu_read_unlock();
 	strncpy(psinfo->pr_fname, p->comm, sizeof(psinfo->pr_fname));
 
-- 
1.7.2.5

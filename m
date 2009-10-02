From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/3] cr: add selinux support (v4)
Date: Fri, 2 Oct 2009 16:55:44 -0500
Message-ID: <20091002215544.GA7446@us.ibm.com>
References: <20091002034916.GA16871@us.ibm.com> <20091002035250.GC16920@us.ibm.com> <1254488381.30591.316.camel@moss-pluto.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1254488381.30591.316.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-security-module-owner@vger.kernel.org
To: Stephen Smalley <sds@epoch.ncsc.mil>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

Quoting Stephen Smalley (sds@epoch.ncsc.mil):
> On Thu, 2009-10-01 at 22:52 -0500, Serge E. Hallyn wrote:
> > Documentation/checkpoint/readme.txt begins:
> > """
> > Application checkpoint/restart is the ability to save the state
> > of a running application so that it can later resume its execution
> > from the time at which it was checkpointed.
> > """
> > 
> > This patch adds the ability to checkpoint and restore selinux
> > contexts for tasks, open files, and sysvipc objects.  Contexts
> > are checkpointed as strings.  For tasks and files, where a security
> > struct actually points to several contexts, all contexts are
> > written out in one string, separated by ':::'.
> 
> > diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> > index 8d8b69c..4fb8b5d 100644
> > --- a/security/selinux/hooks.c
> > +++ b/security/selinux/hooks.c
> > @@ -2961,6 +2962,108 @@ static int selinux_file_permission(struct file *file, int mask)
> >  	return selinux_revalidate_file_permission(file, mask);
> >  }
> >  
> > +/*
> > + * for file context, we print both the fsec->sid and fsec->fown_sid
> > + * as string representations, separated by ':::'
> > + * We don't touch isid - if you wanted that set you shoulda set up the
> > + * fs correctly.
> > + */
> > +static inline char *selinux_file_checkpoint(void *security)

Thanks for looking it over again, Stephen.

> Why are these functions declared inline?  In any event, just let the
> compiler figure out when to make them inline if appropriate.

Yikes, I don't know.  Must have cut-n-pasted the prototypes from
include/linux/security.h.  Fixed below.

> > +static inline int selinux_file_restore(struct file *file, char *ctx)
> > +{
> > +	char *s1, *s2;
> > +	__u32 sid1 = 0, sid2 = 0;
> > +	int ret = -EINVAL;
> > +	struct file_security_struct *fsec = file->f_security;
> > +
> > +	/*
> > +	 * Objhash made sure the string is null-terminated.
> > +	 * We make a copy so we can mangle it.
> > +	 */
> > +	s1 = kstrdup(ctx, GFP_KERNEL);
> > +	if (!s1)
> > +		return -ENOMEM;
> > +	s2 = strstr(s1, ":::");
> > +	if (!s2)
> > +		goto out;
> > +
> > +	*s2 = '\0';
> > +	s2 += 3;
> > +	if (*s2 == '\0')
> > +		goto out;
> > +
> > +	/* SECSID_NULL is not valid for file sids */
> > +	if (strlen(s1) == 0 || strlen(s2) == 0)
> > +		goto out;
> > +
> > +	ret = security_context_to_sid(s1, strlen(s1), &sid1);
> > +	if (ret)
> > +		goto out;
> > +	ret = security_context_to_sid(s2, strlen(s2), &sid2);
> > +	if (ret)
> > +		goto out;
> > +
> > +	if (sid1 && fsec->sid != sid1) {
> > +		ret = avc_has_perm(current_sid(), sid1, SECCLASS_FILE,
> > +					FILE__RESTORE, NULL);
> > +		if (ret)
> > +			goto out;
> > +		fsec->sid = sid1;
> > +	}
> > +
> > +#if 0
> > +	/* The following must wait - bc we don't yet support
> > +	 * c/r of fowners. */
> > +	if (sid2 && fsec->fown_sid != sid2) {
> > +		ret = avc_has_perm(current_sid(), sid2, SECCLASS_FILE,
> > +				FILE__FOWN_RESTORE, NULL);
> > +		if (ret)
> > +			goto out;
> > +	       fsec->fown_sid = sid2;
> > +	}
> > +#endif
> 
> I'm not sure why you can't enable this code yet.  From your comment, it
> sounds like c/r doesn't yet handle the uid/euid in the fown_struct, but
> that doesn't mean you can't manage the fown_sid that we store in the
> file.  We just leveraged the fact that a fown_struct is never outside
> the context of a containing struct file (at least from a send_sigio
> context) to avoid introducing a separate security field with its own
> lifecycle there.

Ok, I enabled it (with no resulting problems).

> > @@ -3219,6 +3322,187 @@ static int selinux_task_create(unsigned long clone_flags)
> >  	return current_has_perm(current, PROCESS__FORK);
> >  }
> >  
> > +#define NUMTASKSIDS 6
> > +/*
> > + * for cred context, we print:
> > + *   osid, sid, exec_sid, create_sid, keycreate_sid, sockcreate_sid;
> > + * as string representations, separated by ':::'
> > + */
> > +static inline char *selinux_cred_checkpoint(void *security)
> > +{
> > +	struct task_security_struct *tsec = security;
> > +	char *stmp, *sfull = NULL;
> > +	__u32 slen, runlen;
> > +	int i, ret;
> > +	__u32 sids[NUMTASKSIDS] = { tsec->osid, tsec->sid, tsec->exec_sid,
> > +		tsec->create_sid, tsec->keycreate_sid, tsec->sockcreate_sid };
> 
> Why are you using __u32 rather than just u32?  I think the former is
> only necessary in certain headers that might be shared with userspace?

Changed below

> > +static inline int selinux_cred_restore(struct file *file, struct cred *cred,
> > +					char *ctx)
> > +{
> > +	char *s, *s1, *s2 = NULL;
> > +	int ret = -EINVAL;
> > +	struct task_security_struct *tsec = cred->security;
> > +	int i;
> > +	__u32 sids[NUMTASKSIDS];
> > +	struct inode *ctx_inode = file->f_dentry->d_inode;
> > +	struct avc_audit_data ad;
> 
> audit code was refactored in mainline to share common data structures
> and code among security modules, so e.g. this became common_audit_data.
> Not sure what your baseline is, but this happened in July.

It was merged by Linus on Sep 11, though, which is 2 days after our
latest c/r port to his tree :)

> 
> > +	/*
> > +	 * Check that these transitions are allowed, and effect them.
> > +	 * XXX: Do these checks suffice?
> > +	 */
> > +	if (tsec->osid != sids[0]) {
> > +		/*
> > +		 * Are any security decisions made based on osid?
> > +		 * Is it worth adding a PROCESS_RESTORE_OSID permission
> > +		 * for this?
> > +		 */
> > +		 tsec->osid = sids[0];
> 
> osid is only used in kernel permission checks upon a SID transition, and
> then it has been updated to ->sid prior to the transition.  Userspace
> however may use it in a permission check (obtained via getprevcon) on
> the caller when the program runs in its own domain, e.g. passwd(1).  I
> suppose there should be a check for it, although possibly it could be
> the same as for the ->sid (i.e. PROCESS__RESTORE).

Ok, done.

> > diff --git a/security/selinux/include/av_perm_to_string.h b/security/selinux/include/av_perm_to_string.h
> > index 31df1d7..78945e7 100644
> > --- a/security/selinux/include/av_perm_to_string.h
> > +++ b/security/selinux/include/av_perm_to_string.h
> <snip>
> 
> Just FYI, this file goes away with the dynamic class/perm discovery
> patch that I've been posting to selinux list.
> 
> > diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
> > index d645192..8e066ac 100644
> > --- a/security/selinux/include/av_permissions.h
> > +++ b/security/selinux/include/av_permissions.h
> <snip>
> 
> Likewise, this file goes away and is replaced by an automatically
> generated one from the new classmap.h file, which is the only kernel
> file you'll need to modify to add new permissions.

Ok, that's nice actually.

So I have some work to do when we re-base to Linus' tree, but in the
meantime, here is a version addressing the rest of the comments.  Or
would you prefer I wait and resend after a re-base?

thanks,
-serge

From 77a3a47895fd43e1593752a79b0b09d40744fb41 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue@us.ibm.com>
Date: Thu, 27 Aug 2009 08:19:36 -0700
Subject: [PATCH 1/1] cr: add selinux support (v5)

Documentation/checkpoint/readme.txt begins:
"""
Application checkpoint/restart is the ability to save the state
of a running application so that it can later resume its execution
from the time at which it was checkpointed.
"""

This patch adds the ability to checkpoint and restore selinux
contexts for tasks, open files, and sysvipc objects.  Contexts
are checkpointed as strings.  For tasks and files, where a security
struct actually points to several contexts, all contexts are
written out in one string, separated by ':::'.

The default behaviors are to checkpoint contexts, but not to
restore them.  To attempt to restore them, sys_restart() must
be given the RESTART_KEEP_LSM flag.  If this is given then
the caller of sys_restart() must have the new 'restore' permission
to the target objclass, or for instance PROCESS__SETFSCREATE to
itself to specify a create_sid.

There are some tests under cr_tests/selinux at
git://git.sr71.net/~hallyn/cr_tests.git.

A corresponding simple refpolicy (and /usr/share/selinux/devel/include)
patch is needed.

The programs to checkpoint and restart (called 'checkpoint' and
'restart') come from git://git.ncl.cs.columbia.edu/pub/git/user-cr.git.
This patch applies against the checkpoint/restart-enabled kernel
tree at git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git/.

Changelog:
	oct 02: (Stephen Smalley suggestions):
		1. s/__u32/u32/
		2. enable the fown sid restoration
		3. use process_restore to authorize resetting osid
		4. don't make new hooks inline.
	oct 01: Remove some debugging that is redundant with
		avc log data.
	sep 10: (Most addressing suggestions by Stephen Smalley)
		1. change xyz_get_ctx() to xyz_checkpoint().
		2. check entrypoint permission on cred_restore
		3. always dec context length by 1
		4. don't allow SECSID_NULL when that's not valid
		5. when SECSID_NULL is valid, restore it
		6. c/r task->osid
		7. Just print nothing instead of 'null' for SECSID_NULL
		8. sids are __u32, as are lenghts passed to sid_to_context.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/restart.c                         |    1 +
 kernel/cred.c                                |    2 +
 security/selinux/hooks.c                     |  367 ++++++++++++++++++++++++++
 security/selinux/include/av_perm_to_string.h |    5 +
 security/selinux/include/av_permissions.h    |    5 +
 5 files changed, 380 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 55bd2b5..008a116 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -471,6 +471,7 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 		/* to be implemented later, per-lsm */
 		if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
 				strcmp(ctx->lsm_name, "smack") != 0 &&
+				strcmp(ctx->lsm_name, "selinux") != 0 &&
 				strcmp(ctx->lsm_name, "default") != 0) {
 			pr_warning("c/r: RESTART_KEEP_LSM unsupported for %s\n",
 					ctx->lsm_name);
diff --git a/kernel/cred.c b/kernel/cred.c
index 06bc676..5eb09b8 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -732,6 +732,8 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	if (!h)
 		return -ENOMEM;
 
+	ckpt_debug("cred uid %d fsuid %d gid %d secref %d\n", cred->uid,
+		cred->fsuid, cred->gid, sec_ref);
 	h->uid = cred->uid;
 	h->suid = cred->suid;
 	h->euid = cred->euid;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 8d8b69c..7e16a56 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -76,6 +76,7 @@
 #include <linux/selinux.h>
 #include <linux/mutex.h>
 #include <linux/posix-timers.h>
+#include <linux/checkpoint.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -2961,6 +2962,104 @@ static int selinux_file_permission(struct file *file, int mask)
 	return selinux_revalidate_file_permission(file, mask);
 }
 
+/*
+ * for file context, we print both the fsec->sid and fsec->fown_sid
+ * as string representations, separated by ':::'
+ * We don't touch isid - if you wanted that set you shoulda set up the
+ * fs correctly.
+ */
+static char *selinux_file_checkpoint(void *security)
+{
+	struct file_security_struct *fsec = security;
+	char *s1 = NULL, *s2 = NULL, *sfull;
+	u32 len1, len2, lenfull;
+	int ret;
+
+	if (fsec->sid == 0 || fsec->fown_sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(fsec->sid, &s1, &len1);
+	if (ret)
+		return ERR_PTR(ret);
+	len1--;
+	ret = security_sid_to_context(fsec->fown_sid, &s2, &len2);
+	if (ret) {
+		kfree(s1);
+		return ERR_PTR(ret);
+	}
+	len2--;
+	lenfull = len1+len2+3;
+	sfull = kmalloc(lenfull+1, GFP_KERNEL);
+	if (!sfull) {
+		sfull = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	sfull[lenfull] = '\0';
+	sprintf(sfull, "%s:::%s", s1, s2);
+
+out:
+	kfree(s1);
+	kfree(s2);
+	return sfull;
+}
+
+static int selinux_file_restore(struct file *file, char *ctx)
+{
+	char *s1, *s2;
+	u32 sid1 = 0, sid2 = 0;
+	int ret = -EINVAL;
+	struct file_security_struct *fsec = file->f_security;
+
+	/*
+	 * Objhash made sure the string is null-terminated.
+	 * We make a copy so we can mangle it.
+	 */
+	s1 = kstrdup(ctx, GFP_KERNEL);
+	if (!s1)
+		return -ENOMEM;
+	s2 = strstr(s1, ":::");
+	if (!s2)
+		goto out;
+
+	*s2 = '\0';
+	s2 += 3;
+	if (*s2 == '\0')
+		goto out;
+
+	/* SECSID_NULL is not valid for file sids */
+	if (strlen(s1) == 0 || strlen(s2) == 0)
+		goto out;
+
+	ret = security_context_to_sid(s1, strlen(s1), &sid1);
+	if (ret)
+		goto out;
+	ret = security_context_to_sid(s2, strlen(s2), &sid2);
+	if (ret)
+		goto out;
+
+	if (sid1 && fsec->sid != sid1) {
+		ret = avc_has_perm(current_sid(), sid1, SECCLASS_FILE,
+					FILE__RESTORE, NULL);
+		if (ret)
+			goto out;
+		fsec->sid = sid1;
+	}
+
+	if (sid2 && fsec->fown_sid != sid2) {
+		ret = avc_has_perm(current_sid(), sid2, SECCLASS_FILE,
+				FILE__FOWN_RESTORE, NULL);
+		if (ret)
+			goto out;
+	       fsec->fown_sid = sid2;
+	}
+
+	ret = 0;
+
+out:
+	kfree(s1);
+	return ret;
+}
+
 static int selinux_file_alloc_security(struct file *file)
 {
 	return file_alloc_security(file);
@@ -3219,6 +3318,187 @@ static int selinux_task_create(unsigned long clone_flags)
 	return current_has_perm(current, PROCESS__FORK);
 }
 
+#define NUMTASKSIDS 6
+/*
+ * for cred context, we print:
+ *   osid, sid, exec_sid, create_sid, keycreate_sid, sockcreate_sid;
+ * as string representations, separated by ':::'
+ */
+static char *selinux_cred_checkpoint(void *security)
+{
+	struct task_security_struct *tsec = security;
+	char *stmp, *sfull = NULL;
+	u32 slen, runlen;
+	int i, ret;
+	u32 sids[NUMTASKSIDS] = { tsec->osid, tsec->sid, tsec->exec_sid,
+		tsec->create_sid, tsec->keycreate_sid, tsec->sockcreate_sid };
+
+	if (sids[0] == 0 || sids[1] == 0)
+		/* SECSID_NULL is not valid for osid or sid */
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(sids[0], &sfull, &runlen);
+	if (ret)
+		return ERR_PTR(ret);
+	runlen--;
+
+	for (i = 1; i < NUMTASKSIDS; i++) {
+		if (sids[i] == 0) {
+			stmp = NULL;
+			slen = 0;
+		} else {
+			ret = security_sid_to_context(sids[i], &stmp, &slen);
+			if (ret) {
+				kfree(sfull);
+				return ERR_PTR(ret);
+			}
+			slen--;
+		}
+		/* slen + runlen + ':::' + \0 */
+		if (slen) {
+			sfull = krealloc(sfull, slen + runlen + 3 + 1, GFP_KERNEL);
+			if (!sfull) {
+				kfree(stmp);
+				return ERR_PTR(-ENOMEM);
+			}
+		}
+		sprintf(sfull+runlen, ":::%s", stmp ? stmp : "");
+		runlen += slen + 3;
+		kfree(stmp);
+	}
+
+	return sfull;
+}
+
+static inline int credrestore_nullvalid(int which)
+{
+	int valid_array[NUMTASKSIDS] = {
+		0, /* task osid */
+		0, /* task sid */
+		1, /* exec sid */
+		1, /* create sid */
+		1, /* keycreate_sid */
+		1, /* sockcreate_sid */
+	};
+
+	return valid_array[which];
+}
+
+static int selinux_cred_restore(struct file *file, struct cred *cred,
+					char *ctx)
+{
+	char *s, *s1, *s2 = NULL;
+	int ret = -EINVAL;
+	struct task_security_struct *tsec = cred->security;
+	int i;
+	u32 sids[NUMTASKSIDS];
+	struct inode *ctx_inode = file->f_dentry->d_inode;
+	struct avc_audit_data ad;
+
+	/*
+	 * objhash made sure the string is null-terminated
+	 * now we want our own copy so we can chop it up with \0's
+	 */
+	s = kstrdup(ctx, GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	s1 = s;
+	for (i = 0; i < NUMTASKSIDS; i++) {
+		if (i < NUMTASKSIDS-1) {
+			ret = -EINVAL;
+			s2 = strstr(s1, ":::");
+			if (!s2)
+				goto out;
+			*s2 = '\0';
+			s2 += 3;
+		}
+		if (strlen(s1) == 0) {
+			ret = -EINVAL;
+			if (credrestore_nullvalid(i))
+				sids[i] = 0;
+			else
+				goto out;
+		} else {
+			ret = security_context_to_sid(s1, strlen(s1), &sids[i]);
+			if (ret)
+				goto out;
+		}
+		s1 = s2;
+	}
+
+	/*
+	 * Check that these transitions are allowed, and effect them.
+	 * XXX: Do these checks suffice?
+	 */
+	if (tsec->osid != sids[0]) {
+		ret = avc_has_perm(current_sid(), sids[0], SECCLASS_PROCESS,
+					PROCESS__RESTORE, NULL);
+		if (ret)
+			goto out;
+		 tsec->osid = sids[0];
+	}
+
+	if (tsec->sid != sids[1]) {
+		struct inode_security_struct *isec;
+		ret = avc_has_perm(current_sid(), sids[1], SECCLASS_PROCESS,
+					PROCESS__RESTORE, NULL);
+		if (ret)
+			goto out;
+
+		/* check whether checkpoint file type is a valid entry
+		 * point to the new domain:  we may want a specific
+		 * 'restore_entrypoint' permission for this, but let's
+		 * see if just entrypoint is deemed sufficient
+		 */
+
+		AVC_AUDIT_DATA_INIT(&ad, FS);
+		ad.u.fs.path = file->f_path;
+
+		isec = ctx_inode->i_security;
+		ret = avc_has_perm(sids[1], isec->sid, SECCLASS_FILE,
+				FILE__ENTRYPOINT, &ad);
+		if (ret)
+			goto out;
+		/* TODO: do we need to check for shared state? */
+		tsec->sid = sids[1];
+	}
+
+	ret = -EPERM;
+	if (sids[2] != tsec->exec_sid) {
+		if (!current_has_perm(current, PROCESS__SETEXEC))
+			goto out;
+		tsec->exec_sid = sids[2];
+	}
+
+	if (sids[3] != tsec->create_sid) {
+		if (!current_has_perm(current, PROCESS__SETFSCREATE))
+			goto out;
+		tsec->create_sid = sids[3];
+	}
+
+	if (tsec->keycreate_sid != sids[4]) {
+		if (!current_has_perm(current, PROCESS__SETKEYCREATE))
+			goto out;
+		if (!may_create_key(sids[4], current))
+			goto out;
+		tsec->keycreate_sid = sids[4];
+	}
+
+	if (tsec->sockcreate_sid != sids[5]) {
+		if (!current_has_perm(current, PROCESS__SETSOCKCREATE))
+			goto out;
+		tsec->sockcreate_sid = sids[5];
+	}
+
+	ret = 0;
+
+out:
+	kfree(s);
+	return ret;
+}
+
+
 /*
  * detach and free the LSM part of a set of credentials
  */
@@ -4658,6 +4938,44 @@ static void ipc_free_security(struct kern_ipc_perm *perm)
 	kfree(isec);
 }
 
+static char *selinux_msg_msg_checkpoint(void *security)
+{
+	struct msg_security_struct *msec = security;
+	char *s;
+	u32 len;
+	int ret;
+
+	if (msec->sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(msec->sid, &s, &len);
+	if (ret)
+		return ERR_PTR(ret);
+	return s;
+}
+
+static int selinux_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	struct msg_security_struct *msec = msg->security;
+	int ret;
+	u32 sid = 0;
+
+	ret = security_context_to_sid(ctx, strlen(ctx), &sid);
+	if (ret)
+		return ret;
+
+	if (msec->sid == sid)
+		return 0;
+
+	ret = avc_has_perm(current_sid(), sid, SECCLASS_MSG,
+				MSG__RESTORE, NULL);
+	if (ret)
+		return ret;
+
+	msec->sid = sid;
+	return 0;
+}
+
 static int msg_msg_alloc_security(struct msg_msg *msg)
 {
 	struct msg_security_struct *msec;
@@ -5061,6 +5379,47 @@ static void selinux_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	*secid = isec->sid;
 }
 
+static char *selinux_ipc_checkpoint(void *security)
+{
+	struct ipc_security_struct *isec = security;
+	char *s;
+	u32 len;
+	int ret;
+
+	if (isec->sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(isec->sid, &s, &len);
+	if (ret)
+		return ERR_PTR(ret);
+	return s;
+}
+
+static int selinux_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	struct ipc_security_struct *isec = ipcp->security;
+	int ret;
+	u32 sid = 0;
+	struct avc_audit_data ad;
+
+	ret = security_context_to_sid(ctx, strlen(ctx), &sid);
+	if (ret)
+		return ret;
+
+	if (isec->sid == sid)
+		return 0;
+
+	AVC_AUDIT_DATA_INIT(&ad, IPC);
+	ad.u.ipc_id = ipcp->key;
+	ret = avc_has_perm(current_sid(), sid, SECCLASS_IPC,
+				IPC__RESTORE, &ad);
+	if (ret)
+		return ret;
+
+	isec->sid = sid;
+	return 0;
+}
+
 static void selinux_d_instantiate(struct dentry *dentry, struct inode *inode)
 {
 	if (inode)
@@ -5382,6 +5741,8 @@ static struct security_operations selinux_ops = {
 	.inode_getsecid =		selinux_inode_getsecid,
 
 	.file_permission =		selinux_file_permission,
+	.file_checkpoint =		selinux_file_checkpoint,
+	.file_restore =			selinux_file_restore,
 	.file_alloc_security =		selinux_file_alloc_security,
 	.file_free_security =		selinux_file_free_security,
 	.file_ioctl =			selinux_file_ioctl,
@@ -5396,6 +5757,8 @@ static struct security_operations selinux_ops = {
 	.dentry_open =			selinux_dentry_open,
 
 	.task_create =			selinux_task_create,
+	.cred_checkpoint =		selinux_cred_checkpoint,
+	.cred_restore =			selinux_cred_restore,
 	.cred_free =			selinux_cred_free,
 	.cred_prepare =			selinux_cred_prepare,
 	.kernel_act_as =		selinux_kernel_act_as,
@@ -5417,8 +5780,12 @@ static struct security_operations selinux_ops = {
 
 	.ipc_permission =		selinux_ipc_permission,
 	.ipc_getsecid =			selinux_ipc_getsecid,
+	.ipc_checkpoint =		selinux_ipc_checkpoint,
+	.ipc_restore =			selinux_ipc_restore,
 
 	.msg_msg_alloc_security =	selinux_msg_msg_alloc_security,
+	.msg_msg_checkpoint =		selinux_msg_msg_checkpoint,
+	.msg_msg_restore =		selinux_msg_msg_restore,
 	.msg_msg_free_security =	selinux_msg_msg_free_security,
 
 	.msg_queue_alloc_security =	selinux_msg_queue_alloc_security,
diff --git a/security/selinux/include/av_perm_to_string.h b/security/selinux/include/av_perm_to_string.h
index 31df1d7..a2c35d7 100644
--- a/security/selinux/include/av_perm_to_string.h
+++ b/security/selinux/include/av_perm_to_string.h
@@ -19,6 +19,8 @@
    S_(SECCLASS_FILE, FILE__ENTRYPOINT, "entrypoint")
    S_(SECCLASS_FILE, FILE__EXECMOD, "execmod")
    S_(SECCLASS_FILE, FILE__OPEN, "open")
+   S_(SECCLASS_FILE, FILE__RESTORE, "restore")
+   S_(SECCLASS_FILE, FILE__FOWN_RESTORE, "fown_restore")
    S_(SECCLASS_CHR_FILE, CHR_FILE__EXECUTE_NO_TRANS, "execute_no_trans")
    S_(SECCLASS_CHR_FILE, CHR_FILE__ENTRYPOINT, "entrypoint")
    S_(SECCLASS_CHR_FILE, CHR_FILE__EXECMOD, "execmod")
@@ -88,9 +90,11 @@
    S_(SECCLASS_PROCESS, PROCESS__EXECHEAP, "execheap")
    S_(SECCLASS_PROCESS, PROCESS__SETKEYCREATE, "setkeycreate")
    S_(SECCLASS_PROCESS, PROCESS__SETSOCKCREATE, "setsockcreate")
+   S_(SECCLASS_PROCESS, PROCESS__RESTORE, "restore")
    S_(SECCLASS_MSGQ, MSGQ__ENQUEUE, "enqueue")
    S_(SECCLASS_MSG, MSG__SEND, "send")
    S_(SECCLASS_MSG, MSG__RECEIVE, "receive")
+   S_(SECCLASS_MSG, MSG__RESTORE, "restore")
    S_(SECCLASS_SHM, SHM__LOCK, "lock")
    S_(SECCLASS_SECURITY, SECURITY__COMPUTE_AV, "compute_av")
    S_(SECCLASS_SECURITY, SECURITY__COMPUTE_CREATE, "compute_create")
@@ -107,6 +111,7 @@
    S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_READ, "syslog_read")
    S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_MOD, "syslog_mod")
    S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_CONSOLE, "syslog_console")
+   S_(SECCLASS_IPC, IPC__RESTORE, "restore")
    S_(SECCLASS_CAPABILITY, CAPABILITY__CHOWN, "chown")
    S_(SECCLASS_CAPABILITY, CAPABILITY__DAC_OVERRIDE, "dac_override")
    S_(SECCLASS_CAPABILITY, CAPABILITY__DAC_READ_SEARCH, "dac_read_search")
diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
index d645192..58ad588 100644
--- a/security/selinux/include/av_permissions.h
+++ b/security/selinux/include/av_permissions.h
@@ -101,6 +101,8 @@
 #define FILE__ENTRYPOINT                          0x00040000UL
 #define FILE__EXECMOD                             0x00080000UL
 #define FILE__OPEN                                0x00100000UL
+#define FILE__RESTORE                             0x00200000UL
+#define FILE__FOWN_RESTORE                        0x00400000UL
 #define LNK_FILE__IOCTL                           0x00000001UL
 #define LNK_FILE__READ                            0x00000002UL
 #define LNK_FILE__WRITE                           0x00000004UL
@@ -453,6 +455,7 @@
 #define PROCESS__EXECHEAP                         0x08000000UL
 #define PROCESS__SETKEYCREATE                     0x10000000UL
 #define PROCESS__SETSOCKCREATE                    0x20000000UL
+#define PROCESS__RESTORE	                  0x40000000UL
 #define IPC__CREATE                               0x00000001UL
 #define IPC__DESTROY                              0x00000002UL
 #define IPC__GETATTR                              0x00000004UL
@@ -462,6 +465,7 @@
 #define IPC__ASSOCIATE                            0x00000040UL
 #define IPC__UNIX_READ                            0x00000080UL
 #define IPC__UNIX_WRITE                           0x00000100UL
+#define IPC__RESTORE                              0x00000200UL
 #define SEM__CREATE                               0x00000001UL
 #define SEM__DESTROY                              0x00000002UL
 #define SEM__GETATTR                              0x00000004UL
@@ -483,6 +487,7 @@
 #define MSGQ__ENQUEUE                             0x00000200UL
 #define MSG__SEND                                 0x00000001UL
 #define MSG__RECEIVE                              0x00000002UL
+#define MSG__RESTORE                              0x00000004UL
 #define SHM__CREATE                               0x00000001UL
 #define SHM__DESTROY                              0x00000002UL
 #define SHM__GETATTR                              0x00000004UL
-- 
1.6.1


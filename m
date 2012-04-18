From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 27/43] userns: Use uid_eq gid_eq helpers when comparing
	kuids and kgids in the vfs
Date: Wed, 18 Apr 2012 19:03:37 +0000
Message-ID: <20120418190337.GE5186@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-27-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-27-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/attr.c                |    8 ++++----
>  fs/exec.c                |   10 +++++-----
>  fs/fcntl.c               |    6 +++---
>  fs/ioprio.c              |    4 ++--
>  fs/locks.c               |    2 +-
>  fs/namei.c               |    8 ++++----
>  include/linux/quotaops.h |    4 ++--
>  7 files changed, 21 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/attr.c b/fs/attr.c
> index 73f69a6..2f094c6 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -47,14 +47,14 @@ int inode_change_ok(const struct inode *inode, struct iattr *attr)
>  
>  	/* Make sure a caller can chown. */
>  	if ((ia_valid & ATTR_UID) &&
> -	    (current_fsuid() != inode->i_uid ||
> -	     attr->ia_uid != inode->i_uid) && !capable(CAP_CHOWN))
> +	    (!uid_eq(current_fsuid(), inode->i_uid) ||
> +	     !uid_eq(attr->ia_uid, inode->i_uid)) && !capable(CAP_CHOWN))
>  		return -EPERM;
>  
>  	/* Make sure caller can chgrp. */
>  	if ((ia_valid & ATTR_GID) &&
> -	    (current_fsuid() != inode->i_uid ||
> -	    (!in_group_p(attr->ia_gid) && attr->ia_gid != inode->i_gid)) &&
> +	    (!uid_eq(current_fsuid(), inode->i_uid) ||
> +	    (!in_group_p(attr->ia_gid) && gid_eq(attr->ia_gid, inode->i_gid))) &&
>  	    !capable(CAP_CHOWN))
>  		return -EPERM;
>  
> diff --git a/fs/exec.c b/fs/exec.c
> index 9a1d9f0..00ae2ef 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1139,7 +1139,7 @@ void setup_new_exec(struct linux_binprm * bprm)
>  	/* This is the point of no return */
>  	current->sas_ss_sp = current->sas_ss_size = 0;
>  
> -	if (current_euid() == current_uid() && current_egid() == current_gid())
> +	if (uid_eq(current_euid(), current_uid()) && gid_eq(current_egid(), current_gid()))
>  		set_dumpable(current->mm, 1);
>  	else
>  		set_dumpable(current->mm, suid_dumpable);
> @@ -1153,8 +1153,8 @@ void setup_new_exec(struct linux_binprm * bprm)
>  	current->mm->task_size = TASK_SIZE;
>  
>  	/* install the new credentials */
> -	if (bprm->cred->uid != current_euid() ||
> -	    bprm->cred->gid != current_egid()) {
> +	if (!uid_eq(bprm->cred->uid, current_euid()) ||
> +	    !gid_eq(bprm->cred->gid, current_egid())) {
>  		current->pdeath_signal = 0;
>  	} else {
>  		would_dump(bprm, bprm->file);
> @@ -2120,7 +2120,7 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
>  	if (__get_dumpable(cprm.mm_flags) == 2) {
>  		/* Setuid core dump mode */
>  		flag = O_EXCL;		/* Stop rewrite attacks */
> -		cred->fsuid = 0;	/* Dump root private */
> +		cred->fsuid = GLOBAL_ROOT_UID;	/* Dump root private */

Sorry, one more - can this be the per-ns root uid?  The coredumps should
be ok to belong to privileged users in the namespace right?

>  	}
>  
>  	retval = coredump_wait(exit_code, &core_state);
> @@ -2221,7 +2221,7 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
>  		 * Dont allow local users get cute and trick others to coredump
>  		 * into their pre-created files.
>  		 */
> -		if (inode->i_uid != current_fsuid())
> +		if (!uid_eq(inode->i_uid, current_fsuid()))
>  			goto close_fail;
>  		if (!cprm.file->f_op || !cprm.file->f_op->write)
>  			goto close_fail;
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index 75e7c1f..d078b75 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -532,9 +532,9 @@ static inline int sigio_perm(struct task_struct *p,
>  
>  	rcu_read_lock();
>  	cred = __task_cred(p);
> -	ret = ((fown->euid == 0 ||
> -		fown->euid == cred->suid || fown->euid == cred->uid ||
> -		fown->uid  == cred->suid || fown->uid  == cred->uid) &&
> +	ret = ((uid_eq(fown->euid, GLOBAL_ROOT_UID) ||
> +		uid_eq(fown->euid, cred->suid) || uid_eq(fown->euid, cred->uid) ||
> +		uid_eq(fown->uid,  cred->suid) || uid_eq(fown->uid,  cred->uid)) &&
>  	       !security_file_send_sigiotask(p, fown, sig));
>  	rcu_read_unlock();
>  	return ret;
> diff --git a/fs/ioprio.c b/fs/ioprio.c
> index 2072e41..5e6dbe89 100644
> --- a/fs/ioprio.c
> +++ b/fs/ioprio.c
> @@ -37,8 +37,8 @@ int set_task_ioprio(struct task_struct *task, int ioprio)
>  
>  	rcu_read_lock();
>  	tcred = __task_cred(task);
> -	if (tcred->uid != cred->euid &&
> -	    tcred->uid != cred->uid && !capable(CAP_SYS_NICE)) {
> +	if (!uid_eq(tcred->uid, cred->euid) &&
> +	    !uid_eq(tcred->uid, cred->uid) && !capable(CAP_SYS_NICE)) {
>  		rcu_read_unlock();
>  		return -EPERM;
>  	}
> diff --git a/fs/locks.c b/fs/locks.c
> index 637694b..3e946cd 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1445,7 +1445,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
>  	struct inode *inode = dentry->d_inode;
>  	int error;
>  
> -	if ((current_fsuid() != inode->i_uid) && !capable(CAP_LEASE))
> +	if ((!uid_eq(current_fsuid(), inode->i_uid)) && !capable(CAP_LEASE))
>  		return -EACCES;
>  	if (!S_ISREG(inode->i_mode))
>  		return -EINVAL;
> diff --git a/fs/namei.c b/fs/namei.c
> index 941c436..86512b4 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -228,7 +228,7 @@ static int acl_permission_check(struct inode *inode, int mask)
>  {
>  	unsigned int mode = inode->i_mode;
>  
> -	if (likely(current_fsuid() == inode->i_uid))
> +	if (likely(uid_eq(current_fsuid(), inode->i_uid)))
>  		mode >>= 6;
>  	else {
>  		if (IS_POSIXACL(inode) && (mode & S_IRWXG)) {
> @@ -1956,13 +1956,13 @@ static int user_path_parent(int dfd, const char __user *path,
>   */
>  static inline int check_sticky(struct inode *dir, struct inode *inode)
>  {
> -	uid_t fsuid = current_fsuid();
> +	kuid_t fsuid = current_fsuid();
>  
>  	if (!(dir->i_mode & S_ISVTX))
>  		return 0;
> -	if (inode->i_uid == fsuid)
> +	if (uid_eq(inode->i_uid, fsuid))
>  		return 0;
> -	if (dir->i_uid == fsuid)
> +	if (uid_eq(dir->i_uid, fsuid))
>  		return 0;
>  	return !inode_capable(inode, CAP_FOWNER);
>  }
> diff --git a/include/linux/quotaops.h b/include/linux/quotaops.h
> index d93f95e..17b9773 100644
> --- a/include/linux/quotaops.h
> +++ b/include/linux/quotaops.h
> @@ -22,8 +22,8 @@ static inline struct quota_info *sb_dqopt(struct super_block *sb)
>  static inline bool is_quota_modification(struct inode *inode, struct iattr *ia)
>  {
>  	return (ia->ia_valid & ATTR_SIZE && ia->ia_size != inode->i_size) ||
> -		(ia->ia_valid & ATTR_UID && ia->ia_uid != inode->i_uid) ||
> -		(ia->ia_valid & ATTR_GID && ia->ia_gid != inode->i_gid);
> +		(ia->ia_valid & ATTR_UID && !uid_eq(ia->ia_uid, inode->i_uid)) ||
> +		(ia->ia_valid & ATTR_GID && !gid_eq(ia->ia_gid, inode->i_gid));
>  }
>  
>  #if defined(CONFIG_QUOTA)
> -- 
> 1.7.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 3/5] cr: add generic LSM c/r support
Date: Fri, 28 Aug 2009 21:30:22 -0700
Message-ID: <4A98AEDE.1000105@schaufler-ca.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210417.GC28048@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090828210417.GC28048@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Documentation/checkpoint/readme.txt begins:
> """
> Application checkpoint/restart is the ability to save the state
> of a running application so that it can later resume its execution
> from the time at which it was checkpointed.
> """
>
> This patch adds generic support for c/r of LSM credentials.  Support
> for Smack and SELinux (and TOMOYO if appropriate) will be added later.
> Capabilities is already supported through generic creds code.
>
> This patch supports ipc_perm, msg_msg, cred (task) and file ->security
> fields.  Inodes, superblocks, netif, and xfrm currently are restored
> not through sys_restart() but through container creation, and so the
> security fields should be done then as well.  Network should be added
> when network c/r is added.
>
> Briefly, all security fields must be exported by the LSM as a simple
> null-terminated string.  They are checkpointed through the
> security_checkpoint_obj() helper, because we must pass it an extra
> sectype field.  Splitting SECURITY_OBJ_SEC into one type per object
> type would not work because, in Smack, one void* security is used for
> all object types.

I do not understand why the Smack behavior is a limitation here.

>   But we must pass the sectype field because in
> SELinux a different type of structure is stashed in each object type.
>   

But each can be expressed as a context, can't it?

> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> ---
>  checkpoint/checkpoint.c          |    1 +
>  checkpoint/files.c               |   30 +++++++++
>  checkpoint/objhash.c             |   93 +++++++++++++++++++++++++++
>  include/linux/checkpoint_hdr.h   |   20 ++++++
>  include/linux/checkpoint_types.h |    7 ++
>  include/linux/security.h         |  128 ++++++++++++++++++++++++++++++++++++++
>  ipc/checkpoint.c                 |   34 +++++++---
>  ipc/checkpoint_msg.c             |   26 +++++++-
>  ipc/checkpoint_sem.c             |    4 +-
>  ipc/checkpoint_shm.c             |    4 +-
>  ipc/util.h                       |    6 +-
>  kernel/cred.c                    |   20 ++++++-
>  security/capability.c            |   48 ++++++++++++++
>  security/security.c              |  105 +++++++++++++++++++++++++++++++
>  14 files changed, 506 insertions(+), 20 deletions(-)
>
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 70e3fac..9dbb33c 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -24,6 +24,7 @@
>  #include <linux/utsname.h>
>  #include <linux/magic.h>
>  #include <linux/hrtimer.h>
> +#include <linux/security.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index 204055b..a26951a 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -143,6 +143,19 @@ static int scan_fds(struct files_struct *files, int **fdtable)
>  	return n;
>  }
>  
> +#ifdef CONFIG_SECURITY
> +int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	return security_checkpoint_obj(ctx, file->f_security,
> +					CKPT_SECURITY_FILE);
> +}
> +#else
> +int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	return -EOPNOTSUPP;
> +}
> +#endif
> +
>  int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
>  			   struct ckpt_hdr_file *h)
>  {
> @@ -155,6 +168,12 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
>  	if (h->f_credref < 0)
>  		return h->f_credref;
>  
> +	h->f_secref = checkpoint_file_security(ctx, file);
> +	if (h->f_secref == -EOPNOTSUPP)
> +		h->f_secref = -1;
> +	else if (h->f_secref < 0)
> +		return h->f_secref;
> +
>  	/* FIX: need also file->f_owner, etc */
>  
>  	return 0;
> @@ -481,6 +500,17 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
>  	put_cred(file->f_cred);
>  	file->f_cred = get_cred(cred);
>  
> +	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->f_secref != -1)) {
> +		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->f_secref,
> +					CKPT_OBJ_SEC);
> +		if (IS_ERR(l))
> +			return PTR_ERR(l);
> +
> +		ret = security_file_restore(file, l->string);
> +		if (ret)
> +			return ret;
> +	}
> +
>  	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
>  	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
>  	if (ret < 0)
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index a9a10d1..2b0ead4 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -16,6 +16,7 @@
>  #include <linux/file.h>
>  #include <linux/fdtable.h>
>  #include <linux/sched.h>
> +#include <linux/kref.h>
>  #include <linux/ipc_namespace.h>
>  #include <linux/user_namespace.h>
>  #include <linux/checkpoint.h>
> @@ -246,6 +247,89 @@ static void obj_sock_drop(void *ptr)
>  	sock_put((struct sock *) ptr);
>  }
>  
> +static void obj_free_sec(struct kref *kref)
> +{
> +	struct ckpt_stored_lsm *s = container_of(kref, struct ckpt_stored_lsm,
> +					kref);
> +	kfree(s->string);
> +	kfree(s);
> +}
> +
> +static int obj_sec_grab(void *ptr)
> +{
> +	struct ckpt_stored_lsm *s = ptr;
> +	kref_get(&s->kref);
> +	return 0;
> +}
> +
> +static void obj_sec_drop(void *ptr)
> +{
> +	struct ckpt_stored_lsm *s = ptr;
> +	kref_put(&s->kref, obj_free_sec);
> +}
> +
> +static int do_checkpoint_security(struct ckpt_ctx *ctx,
> +				const struct ckpt_stored_lsm *l)
> +{
> +	int ret, len;
> +	struct ckpt_hdr_lsm *h;
> +
> +	len = strlen(l->string);
> +	if (len > PAGE_SIZE - sizeof(*h))
> +		return -E2BIG;
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h)+len+1, CKPT_HDR_SEC);
> +	if (!h)
> +		return -ENOMEM;
> +	h->len = len;
> +	h->sectype = l->sectype;
> +	strncpy(h->string, l->string, len);
> +	h->string[len] = '\0';
> +	ret = ckpt_write_obj(ctx, &h->h);
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
> +static int checkpoint_security(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	return do_checkpoint_security(ctx, (struct ckpt_stored_lsm *) ptr);
> +}
> +
> +static struct ckpt_stored_lsm *do_restore_security(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_lsm *h;
> +	struct ckpt_stored_lsm *l;
> +
> +	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_SEC);
> +	if (IS_ERR(h))
> +		return (struct ckpt_stored_lsm *)h;
> +	if (h->len > h->h.len - sizeof(struct ckpt_hdr) ||
> +				h->len > PAGE_SIZE) {
> +		ckpt_hdr_put(ctx, h);
> +		return ERR_PTR(-EINVAL);
> +	}
> +	l = kzalloc(sizeof(*l), GFP_KERNEL);
> +	if (!l) {
> +		ckpt_hdr_put(ctx, h);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +	l->string = kzalloc(h->len + 1, GFP_KERNEL);
> +	if (!l->string) {
> +		kfree(l);
> +		ckpt_hdr_put(ctx, h);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +	kref_init(&l->kref);
> +	l->sectype = h->sectype;
> +	strncpy(l->string, h->string, h->len);
> +	ckpt_hdr_put(ctx, h);
> +	return l;
> +}
> +
> +static void *restore_security(struct ckpt_ctx *ctx)
> +{
> +	return (void *) do_restore_security(ctx);
> +}
> +
>  static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  	/* ignored object */
>  	{
> @@ -382,6 +466,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.ref_drop = obj_sock_drop,
>  		.ref_grab = obj_sock_grab,
>  	},
> +	/* LSM security labels */
> +	{
> +		.obj_name = "LSM",
> +		.obj_type = CKPT_OBJ_SEC,
> +		.ref_drop = obj_sec_drop,
> +		.ref_grab = obj_sec_grab,
> +		.checkpoint = checkpoint_security,
> +		.restore = restore_security,
> +	},
>  };
>  
>  
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 2b166dc..729ca33 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -53,6 +53,7 @@ enum {
>  	CKPT_HDR_BUFFER,
>  	CKPT_HDR_STRING,
>  	CKPT_HDR_OBJREF,
> +	CKPT_HDR_SEC,
>  
>  	CKPT_HDR_TREE = 101,
>  	CKPT_HDR_TASK,
> @@ -136,6 +137,7 @@ enum obj_type {
>  	CKPT_OBJ_USER,
>  	CKPT_OBJ_GROUPINFO,
>  	CKPT_OBJ_SOCK,
> +	CKPT_OBJ_SEC,
>  	CKPT_OBJ_MAX
>  };
>  
> @@ -250,6 +252,8 @@ struct ckpt_hdr_cred {
>  	__u32 gid, sgid, egid, fsgid;
>  	__s32 user_ref;
>  	__s32 groupinfo_ref;
> +	__s32 sec_ref;
> +	__u32 padding;
>  	struct ckpt_capabilities cap_s;
>  } __attribute__((aligned(8)));
>  
> @@ -262,6 +266,16 @@ struct ckpt_hdr_groupinfo {
>  	__u32 groups[0];
>  } __attribute__((aligned(8)));
>  
> +struct ckpt_hdr_lsm {
> +	struct ckpt_hdr h;
> +	__u8 sectype;
> +	__u16 len;
> +	/*
> +	 * This is followed by a string of size len+1,
> +	 * null-terminated
> +	 */
> +	__u8 string[0];
> +} __attribute__((aligned(8)));
>  /*
>   * todo - keyrings and LSM
>   * These may be better done with userspace help though
> @@ -357,6 +371,8 @@ struct ckpt_hdr_file {
>  	__s32 f_credref;
>  	__u64 f_pos;
>  	__u64 f_version;
> +	__s32 f_secref;
> +	__u32 f_padding;
>  } __attribute__((aligned(8)));
>  
>  struct ckpt_hdr_file_generic {
> @@ -595,6 +611,8 @@ struct ckpt_hdr_ipc_perms {
>  	__u32 mode;
>  	__u32 _padding;
>  	__u64 seq;
> +	__s32 sec_ref;
> +	__u32 padding;
>  } __attribute__((aligned(8)));
>  
>  struct ckpt_hdr_ipc_shm {
> @@ -628,6 +646,8 @@ struct ckpt_hdr_ipc_msg_msg {
>  	struct ckpt_hdr h;
>  	__s32 m_type;
>  	__u32 m_ts;
> +	__s32 sec_ref;
> +	__u32 padding;
>  } __attribute__((aligned(8)));
>  
>  struct ckpt_hdr_ipc_sem {
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index 680750d..182878b 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -73,6 +73,13 @@ struct ckpt_ctx {
>  	struct ckpt_stats stats;	/* statistics */
>  };
>  
> +/* stored on hashtable */
> +struct ckpt_stored_lsm {
> +	struct kref kref;
> +	int sectype;
> +	char *string;
> +};
> +
>  #endif /* __KERNEL__ */
>  
>  #endif /* _LINUX_CHECKPOINT_TYPES_H_ */
> diff --git a/include/linux/security.h b/include/linux/security.h
> index f1033a4..61f224f 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -554,6 +554,15 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	created.
>   *	@file contains the file structure to secure.
>   *	Return 0 if the hook is successful and permission is granted.
> + * @file_get_ctx:
> + *	Return a string representing the security context on a file.
> + *	@security contains the security field.
> + *	Returns a char* which the caller will free, or -error on error.
> + * @file_restore:
> + *	Set a security context on a file according to the checkpointed context.
> + *	@file contains the file.
> + *	@ctx contains a string representation of the checkpointed context.
> + *	Returns 0 on success, -error on failure.
>   * @file_free_security:
>   *	Deallocate and free any security structures stored in file->f_security.
>   *	@file contains the file structure being modified.
> @@ -633,6 +642,16 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	manual page for definitions of the @clone_flags.
>   *	@clone_flags contains the flags indicating what should be shared.
>   *	Return 0 if permission is granted.
> + * @cred_get_ctx:
> + *	Return a string representing the security context on the task cred.
> + *	@security contains the security field.
> + *	Returns a char* which the caller will free, or -error on error.
> + * @cred_restore:
> + *	Set a security context on a task cred according to the checkpointed
> + *	context.
> + *	@cred contains the cred.
> + *	@ctx contains a string representation of the checkpointed context.
> + *	Returns 0 on success, -error on failure.
>   * @cred_free:
>   *	@cred points to the credentials.
>   *	Deallocate and clear the cred->security field in a set of credentials.
> @@ -1081,6 +1100,19 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	@ipcp contains the kernel IPC permission structure.
>   *	@secid contains a pointer to the location where result will be saved.
>   *	In case of failure, @secid will be set to zero.
> + * @ipc_get_ctx:
> + *	Return a string representing the security context on the IPC
> + *	permission structure.
> + *	@security contains the security field.
> + *	Returns a char* which the caller will free, or -error on error.
> + * @ipc_restore:
> + *	Set a security context on a IPC permission structure according to
> + *	the checkpointed context.
> + *	@ipcp contains the IPC permission structure, which will have
> + *	already been allocated and initialized when the IPC structure was
> + *	created.
> + *	@ctx contains a string representation of the checkpointed context.
> + *	Returns 0 on success, -error on failure.
>   *
>   * Security hooks for individual messages held in System V IPC message queues
>   * @msg_msg_alloc_security:
> @@ -1089,6 +1121,16 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	created.
>   *	@msg contains the message structure to be modified.
>   *	Return 0 if operation was successful and permission is granted.
> + * @msg_msg_get_ctx:
> + *	Return a string representing the security context on an msg_msg
> + *	struct.
> + *	@security contains the security field
> + *	Returns a char* which the caller will free, or -error on error.
> + * @msg_msg_restore:
> + *	Set msg_msg->security according to the checkpointed context.
> + *	@msg contains the message structure to be modified.
> + *	@ctx contains a string representation of the checkpointed context.
> + *	Return 0 on success, -error on failure.
>   * @msg_msg_free_security:
>   *	Deallocate the security structure for this message.
>   *	@msg contains the message structure to be modified.
> @@ -1443,6 +1485,8 @@ struct security_operations {
>  
>  	int (*file_permission) (struct file *file, int mask);
>  	int (*file_alloc_security) (struct file *file);
> +	char *(*file_get_ctx) (void *security);
> +	int (*file_restore) (struct file *file, char *ctx);
>  	void (*file_free_security) (struct file *file);
>  	int (*file_ioctl) (struct file *file, unsigned int cmd,
>  			   unsigned long arg);
> @@ -1463,6 +1507,8 @@ struct security_operations {
>  	int (*dentry_open) (struct file *file, const struct cred *cred);
>  
>  	int (*task_create) (unsigned long clone_flags);
> +	char *(*cred_get_ctx) (void *security);
> +	int (*cred_restore) (struct cred *cred, char *ctx);
>  	void (*cred_free) (struct cred *cred);
>  	int (*cred_prepare)(struct cred *new, const struct cred *old,
>  			    gfp_t gfp);
> @@ -1496,8 +1542,12 @@ struct security_operations {
>  
>  	int (*ipc_permission) (struct kern_ipc_perm *ipcp, short flag);
>  	void (*ipc_getsecid) (struct kern_ipc_perm *ipcp, u32 *secid);
> +	char *(*ipc_get_ctx) (void *security);
> +	int (*ipc_restore) (struct kern_ipc_perm *ipcp, char *ctx);
>  
>  	int (*msg_msg_alloc_security) (struct msg_msg *msg);
> +	char *(*msg_msg_get_ctx) (void *security);
> +	int (*msg_msg_restore) (struct msg_msg *msg, char *ctx);
>  	void (*msg_msg_free_security) (struct msg_msg *msg);
>  
>  	int (*msg_queue_alloc_security) (struct msg_queue *msq);
> @@ -1701,6 +1751,8 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
>  void security_inode_getsecid(const struct inode *inode, u32 *secid);
>  int security_file_permission(struct file *file, int mask);
>  int security_file_alloc(struct file *file);
> +char *security_file_get_ctx(void *security);
> +int security_file_restore(struct file *file, char *ctx);
>  void security_file_free(struct file *file);
>  int security_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
>  int security_file_mmap(struct file *file, unsigned long reqprot,
> @@ -1716,6 +1768,8 @@ int security_file_send_sigiotask(struct task_struct *tsk,
>  int security_file_receive(struct file *file);
>  int security_dentry_open(struct file *file, const struct cred *cred);
>  int security_task_create(unsigned long clone_flags);
> +char *security_cred_get_ctx(void *security);
> +int security_cred_restore(struct cred *cred, char *ctx);
>  void security_cred_free(struct cred *cred);
>  int security_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp);
>  void security_commit_creds(struct cred *new, const struct cred *old);
> @@ -1746,7 +1800,11 @@ int security_task_prctl(int option, unsigned long arg2, unsigned long arg3,
>  void security_task_to_inode(struct task_struct *p, struct inode *inode);
>  int security_ipc_permission(struct kern_ipc_perm *ipcp, short flag);
>  void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid);
> +char *security_ipc_get_ctx(void *security);
> +int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx);
>  int security_msg_msg_alloc(struct msg_msg *msg);
> +char *security_msg_msg_get_ctx(void *security);
> +int security_msg_msg_restore(struct msg_msg *msg, char *ctx);
>  void security_msg_msg_free(struct msg_msg *msg);
>  int security_msg_queue_alloc(struct msg_queue *msq);
>  void security_msg_queue_free(struct msg_queue *msq);
> @@ -2190,6 +2248,19 @@ static inline int security_file_alloc(struct file *file)
>  	return 0;
>  }
>  
> +static inline char *security_file_get_ctx(void *security)
> +{
> +	/* this shouldn't ever get called if SECURITY=n */
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +static inline int security_file_restore(struct file *file, char *ctx)
> +{
> +	/* we're asked to recreate security contexts for an LSM which had
> +	 * contexts, but CONFIG_SECURITY=n now! */
> +	return -EINVAL;
> +}
> +
>  static inline void security_file_free(struct file *file)
>  { }
>  
> @@ -2256,6 +2327,19 @@ static inline int security_task_create(unsigned long clone_flags)
>  	return 0;
>  }
>  
> +static inline char *security_cred_get_ctx(void *security)
> +{
> +	/* this shouldn't ever get called if SECURITY=n */
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +static inline int security_cred_restore(struct cred *cred, char *ctx)
> +{
> +	/* we're asked to recreate security contexts for an LSM which had
> +	 * contexts, but CONFIG_SECURITY=n now! */
> +	return -EINVAL;
> +}
> +
>  static inline void security_cred_free(struct cred *cred)
>  { }
>  
> @@ -2398,11 +2482,37 @@ static inline void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
>  	*secid = 0;
>  }
>  
> +static inline char *security_ipc_get_ctx(void *security)
> +{
> +	/* this shouldn't ever get called if SECURITY=n */
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +static inline int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
> +{
> +	/* we're asked to recreate security contexts for an LSM which had
> +	 * contexts, but CONFIG_SECURITY=n now! */
> +	return -EINVAL;
> +}
> +
>  static inline int security_msg_msg_alloc(struct msg_msg *msg)
>  {
>  	return 0;
>  }
>  
> +static inline char *security_msg_msg_get_ctx(void *security)
> +{
> +	/* this shouldn't ever get called if SECURITY=n */
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +static inline int security_msg_msg_restore(struct msg_msg *msg, char *ctx)
> +{
> +	/* we're asked to recreate security contexts for an LSM which had
> +	 * contexts, but CONFIG_SECURITY=n now! */
> +	return -EINVAL;
> +}
> +
>  static inline void security_msg_msg_free(struct msg_msg *msg)
>  { }
>  
> @@ -2987,5 +3097,23 @@ static inline void free_secdata(void *secdata)
>  { }
>  #endif /* CONFIG_SECURITY */
>  
> +#ifdef CONFIG_CHECKPOINT
> +#define CKPT_SECURITY_MSG_MSG	1
> +#define CKPT_SECURITY_IPC	2
> +#define CKPT_SECURITY_FILE	3
> +#define CKPT_SECURITY_CRED	4
> +#define CKPT_SECURITY_MAX	4
> +
> +#ifdef CONFIG_SECURITY
> +int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
> +				unsigned sectype);
> +#else
> +static inline int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
> +				unsigned sectype)
> +{ return -1; }
> +#endif /* CONFIG_SECURITY */
> +
> +#endif /* CONFIG_CHECKPOINT */
> +
>  #endif /* ! __LINUX_SECURITY_H */
>  
> diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
> index 8e6e9ba..c0d3f13 100644
> --- a/ipc/checkpoint.c
> +++ b/ipc/checkpoint.c
> @@ -31,7 +31,8 @@ static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
>   * Checkpoint
>   */
>  
> -int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
> +int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
> +			      struct ckpt_hdr_ipc_perms *h,
>  			      struct kern_ipc_perm *perm)
>  {
>  	if (ipcperms(perm, S_IROTH))
> @@ -45,6 +46,15 @@ int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
>  	h->cgid = perm->cgid;
>  	h->mode = perm->mode & S_IRWXUGO;
>  	h->seq = perm->seq;
> +	if (perm->security) {
> +		h->sec_ref = security_checkpoint_obj(ctx, perm->security,
> +					CKPT_SECURITY_IPC);
> +		if (h->sec_ref == -EOPNOTSUPP)
> +			h->sec_ref = -1;
> +		else if (h->sec_ref < 0)
> +			return h->sec_ref;
> +	} else
> +		h->sec_ref = -1;
>  
>  	return 0;
>  }
> @@ -176,7 +186,8 @@ static int validate_created_perms(struct ckpt_hdr_ipc_perms *h)
>  	return 1;
>  }
>  
> -int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
> +int restore_load_ipc_perms(struct ckpt_ctx *ctx,
> +			   struct ckpt_hdr_ipc_perms *h,
>  			   struct kern_ipc_perm *perm)
>  {
>  	if (h->id < 0)
> @@ -205,14 +216,17 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
>  	perm->cgid = h->cgid;
>  	perm->mode = h->mode;
>  	perm->seq = h->seq;
> -	/*
> -	 * Todo: restore perm->security.
> -	 * At the moment it gets set by security_x_alloc() called through
> -	 * ipcget()->ipcget_public()->ops-.getnew (->nequeue for instance)
> -	 * We will want to ask the LSM to consider resetting the
> -	 * checkpointed ->security, based on current_security(),
> -	 * the checkpointed ->security, and the checkpoint file context.
> -	 */
> +
> +	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
> +		int ret;
> +		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
> +					CKPT_OBJ_SEC);
> +		if (IS_ERR(l))
> +			return PTR_ERR(l);
> +		ret = security_ipc_restore(perm, l->string);
> +		if (ret)
> +			return ret;
> +	}
>  
>  	return 0;
>  }
> diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
> index b933c19..24f4097 100644
> --- a/ipc/checkpoint_msg.c
> +++ b/ipc/checkpoint_msg.c
> @@ -37,7 +37,7 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
>  
>  	ipc_lock_by_ptr(&msq->q_perm);
>  
> -	ret = checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
> +	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &msq->q_perm);
>  	if (ret < 0)
>  		goto unlock;
>  
> @@ -64,13 +64,23 @@ static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
>  	struct msg_msgseg *seg;
>  	int total, len;
>  	int ret;
> -
> +	int sec_ref = -1;
> +
> +	if (msg->security) {
> +		sec_ref = security_checkpoint_obj(ctx, msg->security,
> +						CKPT_SECURITY_MSG_MSG);
> +		if (sec_ref == -EOPNOTSUPP)
> +			sec_ref = -1;
> +		else if (sec_ref < 0)
> +			return sec_ref;
> +	}
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
>  	if (!h)
>  		return -ENOMEM;
>  
>  	h->m_type = msg->m_type;
>  	h->m_ts = msg->m_ts;
> +	h->sec_ref = sec_ref;
>  
>  	ret = ckpt_write_obj(ctx, &h->h);
>  	ckpt_hdr_put(ctx, h);
> @@ -177,7 +187,7 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
>  {
>  	int ret = 0;
>  
> -	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
> +	ret = restore_load_ipc_perms(ctx, &h->perms, &msq->q_perm);
>  	if (ret < 0)
>  		return ret;
>  
> @@ -224,6 +234,16 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
>  	msg->next = NULL;
>  	pseg = &msg->next;
>  
> +	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
> +		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
> +					CKPT_OBJ_SEC);
> +		if (IS_ERR(l))
> +			return (struct msg_msg *)l;
> +		ret = security_msg_msg_restore(msg, l->string);
> +		if (ret)
> +			return ERR_PTR(ret);
> +	}
> +
>  	ret = _ckpt_read_buffer(ctx, (msg + 1), len);
>  	if (ret < 0)
>  		goto out;
> diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
> index 76eb2b9..53a19ed 100644
> --- a/ipc/checkpoint_sem.c
> +++ b/ipc/checkpoint_sem.c
> @@ -37,7 +37,7 @@ static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
>  
>  	ipc_lock_by_ptr(&sem->sem_perm);
>  
> -	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
> +	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &sem->sem_perm);
>  	if (ret < 0)
>  		goto unlock;
>  
> @@ -113,7 +113,7 @@ static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
>  {
>  	int ret = 0;
>  
> -	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
> +	ret = restore_load_ipc_perms(ctx, &h->perms, &sem->sem_perm);
>  	if (ret < 0)
>  		return ret;
>  
> diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
> index ad78aa3..571d9bb 100644
> --- a/ipc/checkpoint_shm.c
> +++ b/ipc/checkpoint_shm.c
> @@ -41,7 +41,7 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
>  
>  	ipc_lock_by_ptr(&shp->shm_perm);
>  
> -	ret = checkpoint_fill_ipc_perms(&h->perms, &shp->shm_perm);
> +	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &shp->shm_perm);
>  	if (ret < 0)
>  		goto unlock;
>  
> @@ -166,7 +166,7 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
>  {
>  	int ret;
>  
> -	ret = restore_load_ipc_perms(&h->perms, &shp->shm_perm);
> +	ret = restore_load_ipc_perms(ctx, &h->perms, &shp->shm_perm);
>  	if (ret < 0)
>  		return ret;
>  
> diff --git a/ipc/util.h b/ipc/util.h
> index aa35aaa..93a1ba3 100644
> --- a/ipc/util.h
> +++ b/ipc/util.h
> @@ -199,9 +199,11 @@ void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
>  
>  
>  #ifdef CONFIG_CHECKPOINT
> -extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
> +extern int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
> +				     struct ckpt_hdr_ipc_perms *h,
>  				     struct kern_ipc_perm *perm);
> -extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
> +extern int restore_load_ipc_perms(struct ckpt_ctx *ctx,
> +				  struct ckpt_hdr_ipc_perms *h,
>  				  struct kern_ipc_perm *perm);
>  
>  extern int checkpoint_ipc_shm(int id, void *p, void *data);
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 27e02ca..e43ba45 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -709,7 +709,7 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
>  static int do_checkpoint_cred(struct ckpt_ctx *ctx, const struct cred *cred)
>  {
>  	int ret;
> -	int groupinfo_ref, user_ref;
> +	int groupinfo_ref, user_ref, sec_ref = -1;
>  	struct ckpt_hdr_cred *h;
>  
>  	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
> @@ -719,6 +719,14 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, const struct cred *cred)
>  	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
>  	if (user_ref < 0)
>  		return user_ref;
> +#ifdef CONFIG_SECURITY
> +	sec_ref = security_checkpoint_obj(ctx, cred->security,
> +					CKPT_SECURITY_CRED);
> +	if (sec_ref == -EOPNOTSUPP)
> +		sec_ref = -1;
> +	else if (sec_ref < 0)
> +		return sec_ref;
> +#endif  /* else cred->security doesn't exist and sec_ref = -1 */
>  
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
>  	if (!h)
> @@ -733,6 +741,7 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, const struct cred *cred)
>  	h->sgid = cred->sgid;
>  	h->egid = cred->egid;
>  	h->fsgid = cred->fsgid;
> +	h->sec_ref = sec_ref;
>  
>  	checkpoint_capabilities(&h->cap_s, cred);
>  
> @@ -806,6 +815,15 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
>  	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
>  	if (oldgid != h->fsgid && ret < 0)
>  		goto err_putcred;
> +	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
> +		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
> +					CKPT_OBJ_SEC);
> +		if (IS_ERR(l))
> +			return (struct cred *)l;
> +		ret = security_cred_restore(cred, l->string);
> +		if (ret)
> +			goto err_putcred;
> +	}
>  	ret = restore_capabilities(&h->cap_s, cred);
>  	if (ret)
>  		goto err_putcred;
> diff --git a/security/capability.c b/security/capability.c
> index 21b6cea..28e6495 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -315,6 +315,16 @@ static int cap_file_permission(struct file *file, int mask)
>  	return 0;
>  }
>  
> +static inline char *cap_file_get_ctx(void *security)
> +{
> +	return ERR_PTR(-EOPNOTSUPP);
> +}
> +
> +static int cap_file_restore(struct file *file, char *ctx)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>  static int cap_file_alloc_security(struct file *file)
>  {
>  	return 0;
> @@ -382,6 +392,16 @@ static int cap_task_create(unsigned long clone_flags)
>  	return 0;
>  }
>  
> +static char *cap_cred_get_ctx(void *security)
> +{
> +	return ERR_PTR(-EOPNOTSUPP);
> +}
> +
> +static int cap_cred_restore(struct cred *cred, char *ctx)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>  static void cap_cred_free(struct cred *cred)
>  {
>  }
> @@ -485,11 +505,31 @@ static void cap_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
>  	*secid = 0;
>  }
>  
> +static char *cap_ipc_get_ctx(void *security)
> +{
> +	return ERR_PTR(-EOPNOTSUPP);
> +}
> +
> +static int cap_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>  static int cap_msg_msg_alloc_security(struct msg_msg *msg)
>  {
>  	return 0;
>  }
>  
> +static inline char *cap_msg_msg_get_ctx(void *security)
> +{
> +	return ERR_PTR(-EOPNOTSUPP);
> +}
> +
> +static int cap_msg_msg_restore(struct msg_msg *msg, char *ctx)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>  static void cap_msg_msg_free_security(struct msg_msg *msg)
>  {
>  }
> @@ -937,6 +977,8 @@ void security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, path_truncate);
>  #endif
>  	set_to_cap_if_null(ops, file_permission);
> +	set_to_cap_if_null(ops, file_get_ctx);
> +	set_to_cap_if_null(ops, file_restore);
>  	set_to_cap_if_null(ops, file_alloc_security);
>  	set_to_cap_if_null(ops, file_free_security);
>  	set_to_cap_if_null(ops, file_ioctl);
> @@ -949,6 +991,8 @@ void security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, file_receive);
>  	set_to_cap_if_null(ops, dentry_open);
>  	set_to_cap_if_null(ops, task_create);
> +	set_to_cap_if_null(ops, cred_get_ctx);
> +	set_to_cap_if_null(ops, cred_restore);
>  	set_to_cap_if_null(ops, cred_free);
>  	set_to_cap_if_null(ops, cred_prepare);
>  	set_to_cap_if_null(ops, cred_commit);
> @@ -975,7 +1019,11 @@ void security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, task_to_inode);
>  	set_to_cap_if_null(ops, ipc_permission);
>  	set_to_cap_if_null(ops, ipc_getsecid);
> +	set_to_cap_if_null(ops, ipc_get_ctx);
> +	set_to_cap_if_null(ops, ipc_restore);
>  	set_to_cap_if_null(ops, msg_msg_alloc_security);
> +	set_to_cap_if_null(ops, msg_msg_get_ctx);
> +	set_to_cap_if_null(ops, msg_msg_restore);
>  	set_to_cap_if_null(ops, msg_msg_free_security);
>  	set_to_cap_if_null(ops, msg_queue_alloc_security);
>  	set_to_cap_if_null(ops, msg_queue_free_security);
> diff --git a/security/security.c b/security/security.c
> index 3829156..6bafb9e 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -630,6 +630,16 @@ int security_file_alloc(struct file *file)
>  	return security_ops->file_alloc_security(file);
>  }
>  
> +char *security_file_get_ctx(void *security)
> +{
> +	return security_ops->file_get_ctx(security);
> +}
> +
> +int security_file_restore(struct file *file, char *ctx)
> +{
> +	return security_ops->file_restore(file, ctx);
> +}
> +
>  void security_file_free(struct file *file)
>  {
>  	security_ops->file_free_security(file);
> @@ -689,6 +699,16 @@ int security_task_create(unsigned long clone_flags)
>  	return security_ops->task_create(clone_flags);
>  }
>  
> +char *security_cred_get_ctx(void *security)
> +{
> +	return security_ops->cred_get_ctx(security);
> +}
> +
> +int security_cred_restore(struct cred *cred, char *ctx)
> +{
> +	return security_ops->cred_restore(cred, ctx);
> +}
> +
>  void security_cred_free(struct cred *cred)
>  {
>  	security_ops->cred_free(cred);
> @@ -824,11 +844,31 @@ void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
>  	security_ops->ipc_getsecid(ipcp, secid);
>  }
>  
> +char *security_ipc_get_ctx(void *security)
> +{
> +	return security_ops->ipc_get_ctx(security);
> +}
> +
> +int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
> +{
> +	return security_ops->ipc_restore(ipcp, ctx);
> +}
> +
>  int security_msg_msg_alloc(struct msg_msg *msg)
>  {
>  	return security_ops->msg_msg_alloc_security(msg);
>  }
>  
> +char *security_msg_msg_get_ctx(void *security)
> +{
> +	return security_ops->msg_msg_get_ctx(security);
> +}
> +
> +int security_msg_msg_restore(struct msg_msg *msg, char *ctx)
> +{
> +	return security_ops->msg_msg_restore(msg, ctx);
> +}
> +
>  void security_msg_msg_free(struct msg_msg *msg)
>  {
>  	security_ops->msg_msg_free_security(msg);
> @@ -1249,3 +1289,68 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
>  }
>  
>  #endif /* CONFIG_AUDIT */
> +
> +#ifdef CONFIG_CHECKPOINT
> +
> +#include <linux/checkpoint.h>
> +
> +/**
> + * security_checkpoint_obj - if first checkpoint of this void* security,
> + * then 1. ask the LSM for a string representing the context, 2. checkpoint
> + * that string
> + * @ctx: the checkpoint context
> + * @security: the void* security being checkpointed
> + * @sectype: indicates the type of object, because LSMs can (and do) store
> + * different types of data for different types of objects.
> + *
> + * Returns the objref of the checkpointed ckpt_stored_lsm representing the
> + * context, or -error on error.
> + *
> + * This is only used at checkpoint of course.
> + */
> +int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
> +				unsigned sectype)
> +{
> +	int strref;
> +	struct ckpt_stored_lsm *l;
> +	char *str;
> +	int len;
> +
> +	switch (sectype) {
> +	case CKPT_SECURITY_MSG_MSG:
> +		str = security_msg_msg_get_ctx(security);
> +		break;
> +	case CKPT_SECURITY_IPC:
> +		str = security_ipc_get_ctx(security);
> +		break;
> +	case CKPT_SECURITY_FILE:
> +		str = security_file_get_ctx(security);
> +		break;
> +	case CKPT_SECURITY_CRED:
> +		str = security_cred_get_ctx(security);
> +		break;
> +	default:
> +		str = ERR_PTR(-EINVAL);
> +		break;
> +	}
> +	/* str will be alloc'ed for us by the LSM.  We will free it when
> +	 * we clear out our hashtable */
>   

Why do you think that you need a copy? Sure, SELinux always gives you
a copy, but Smack keeps "contexts" around and making a copy is not only
unnecessary, but wasteful. If you free the "context" with the appropriate
call (security_release_secctx) you will get the "free allocated memory"
behavior desired by SELinux and the "do nothing" behavior of Smack. For
free, assuming that you also fix your Smack hook so that it works in the
way Smack deems "Correct".


> +	if (IS_ERR(str))
> +		return PTR_ERR(str);
> +
> +	len = strlen(str);
> +	l = kzalloc(sizeof(*l) + len + 1, GFP_KERNEL);
> +	if (!l) {
> +		kfree(str);
> +		return -ENOMEM;
> +	}
> +	kref_init(&l->kref);
> +	l->sectype = sectype;
> +	l->string = str;
> +
> +	strref = checkpoint_obj(ctx, l, CKPT_OBJ_SEC);
> +	/* do we need to free l if strref was err? */
> +	return strref;
> +}
> +
> +#endif
>   


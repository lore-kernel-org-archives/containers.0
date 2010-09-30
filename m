From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] Replace pid_t in autofs4 with struct pid reference.
Date: Thu, 30 Sep 2010 17:36:39 -0500
Message-ID: <20100930223639.GA12959@hallyn.com>
References: <1285840564-10251-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1285840564-10251-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Helmut Lichtenberg <heli-dxCdbQ03lbiELgA04lAiVw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> I resurect and refreshed this old patch from
> https://lists.linux-foundation.org/pipermail/containers/2007-February/003726.html
> 
> This patch makes automount to work within a container.
> 
> Make autofs4 container-friendly by caching struct pid reference rather
> than pid_t and using pid_nr() to retreive a task's pid_t.
> 
> ChangeLog:
> 	- Refreshed against linux-next (added dev-ioctl.c)
> 	- Fix Eric Biederman's comments - Use find_get_pid() to hold a
> 	  reference to oz_pgrp and release while unmounting; separate out
> 	  changes to autofs and autofs4.
> 	- Also rollback my earlier change to autofs_wait_queue (pid and tgid
> 	  in the wait queue are just used to write to a userspace daemon's
> 	  pipe).
>         - Fix Cedric's comments: retain old prototype of parse_options()
>           and move necessary change to its caller.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> Cc: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
> Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Cc: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Helmut Lichtenberg <heli-dxCdbQ03lbiELgA04lAiVw@public.gmane.org>
> ---
>  fs/autofs4/autofs_i.h  |   28 ++++++++++++++--------------
>  fs/autofs4/dev-ioctl.c |    2 +-
>  fs/autofs4/inode.c     |   22 ++++++++++++++++------
>  fs/autofs4/root.c      |    3 ++-
>  fs/autofs4/waitq.c     |    4 ++--
>  5 files changed, 35 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
> index 3d283ab..e7298a1 100644
> --- a/fs/autofs4/autofs_i.h
> +++ b/fs/autofs4/autofs_i.h
> @@ -39,25 +39,25 @@
>  /* #define DEBUG */
>  
>  #ifdef DEBUG
> -#define DPRINTK(fmt, args...)				\
> -do {							\
> -	printk(KERN_DEBUG "pid %d: %s: " fmt "\n",	\
> -		current->pid, __func__, ##args);	\
> +#define DPRINTK(fmt, args...)				     \
> +do {							     \
> +	printk(KERN_DEBUG "pid %d: %s: " fmt "\n",	     \
> +	       pid_nr(task_pid(current)), __func__, ##args); \
>  } while (0)
>  #else
>  #define DPRINTK(fmt, args...) do {} while (0)
>  #endif
>  
> -#define AUTOFS_WARN(fmt, args...)			\
> -do {							\
> -	printk(KERN_WARNING "pid %d: %s: " fmt "\n",	\
> -		current->pid, __func__, ##args);	\
> +#define AUTOFS_WARN(fmt, args...)			     \
> +do {							     \
> +	printk(KERN_WARNING "pid %d: %s: " fmt "\n",	     \
> +	       pid_nr(task_pid(current)), __func__, ##args); \
>  } while (0)
>  
> -#define AUTOFS_ERROR(fmt, args...)			\
> -do {							\
> -	printk(KERN_ERR "pid %d: %s: " fmt "\n",	\
> -		current->pid, __func__, ##args);	\
> +#define AUTOFS_ERROR(fmt, args...)			     \
> +do {						             \
> +	printk(KERN_ERR "pid %d: %s: " fmt "\n",	     \
> +	       pid_nr(task_pid(current)), __func__, ##args); \
>  } while (0)
>  
>  /* Unified info structure.  This is pointed to by both the dentry and
> @@ -122,7 +122,7 @@ struct autofs_sb_info {
>  	u32 magic;
>  	int pipefd;
>  	struct file *pipe;
> -	pid_t oz_pgrp;
> +	struct pid *oz_pgrp;
>  	int catatonic;
>  	int version;
>  	int sub_version;
> @@ -156,7 +156,7 @@ static inline struct autofs_info *autofs4_dentry_ino(struct dentry *dentry)
>     filesystem without "magic".) */
>  
>  static inline int autofs4_oz_mode(struct autofs_sb_info *sbi) {
> -	return sbi->catatonic || task_pgrp_nr(current) == sbi->oz_pgrp;
> +	return sbi->catatonic || task_pgrp(current) == sbi->oz_pgrp;
>  }
>  
>  /* Does a dentry have some pending activity? */
> diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
> index eff9a41..94a523a 100644
> --- a/fs/autofs4/dev-ioctl.c
> +++ b/fs/autofs4/dev-ioctl.c
> @@ -377,7 +377,7 @@ static int autofs_dev_ioctl_setpipefd(struct file *fp,
>  			fput(pipe);
>  			goto out;
>  		}
> -		sbi->oz_pgrp = task_pgrp_nr(current);
> +		sbi->oz_pgrp = task_pgrp(current);
>  		sbi->pipefd = pipefd;
>  		sbi->pipe = pipe;
>  		sbi->catatonic = 0;
> diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
> index 821b2b9..b36af5a 100644
> --- a/fs/autofs4/inode.c
> +++ b/fs/autofs4/inode.c
> @@ -111,7 +111,7 @@ void autofs4_kill_sb(struct super_block *sb)
>  
>  	/* Free wait queues, close pipe */
>  	autofs4_catatonic_mode(sbi);
> -
> +	put_pid(sbi->oz_pgrp);
>  	sb->s_fs_info = NULL;
>  	kfree(sbi);
>  
> @@ -133,7 +133,7 @@ static int autofs4_show_options(struct seq_file *m, struct vfsmount *mnt)
>  		seq_printf(m, ",uid=%u", root_inode->i_uid);
>  	if (root_inode->i_gid != 0)
>  		seq_printf(m, ",gid=%u", root_inode->i_gid);
> -	seq_printf(m, ",pgrp=%d", sbi->oz_pgrp);
> +	seq_printf(m, ",pgrp=%d", pid_nr(sbi->oz_pgrp));
>  	seq_printf(m, ",timeout=%lu", sbi->exp_timeout/HZ);
>  	seq_printf(m, ",minproto=%d", sbi->min_proto);
>  	seq_printf(m, ",maxproto=%d", sbi->max_proto);
> @@ -263,6 +263,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>  	int pipefd;
>  	struct autofs_sb_info *sbi;
>  	struct autofs_info *ino;
> +	pid_t pgid;
>  
>  	sbi = kzalloc(sizeof(*sbi), GFP_KERNEL);
>  	if (!sbi)
> @@ -275,7 +276,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>  	sbi->pipe = NULL;
>  	sbi->catatonic = 1;
>  	sbi->exp_timeout = 0;
> -	sbi->oz_pgrp = task_pgrp_nr(current);
> +	sbi->oz_pgrp = task_pgrp(current);
>  	sbi->sb = s;
>  	sbi->version = 0;
>  	sbi->sub_version = 0;
> @@ -314,7 +315,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>  
>  	/* Can this call block? */
>  	if (parse_options(data, &pipefd, &root_inode->i_uid, &root_inode->i_gid,
> -				&sbi->oz_pgrp, &sbi->type, &sbi->min_proto,
> +				&pgid, &sbi->type, &sbi->min_proto,
>  				&sbi->max_proto)) {
>  		printk("autofs: called with bogus options\n");
>  		goto fail_dput;
> @@ -342,12 +343,19 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>  		sbi->version = sbi->max_proto;
>  	sbi->sub_version = AUTOFS_PROTO_SUBVERSION;
>  
> -	DPRINTK("pipe fd = %d, pgrp = %u", pipefd, sbi->oz_pgrp);
> +	DPRINTK("pipe fd = %d, pgrp = %u", pipefd, pgid);
> +
> +	sbi->oz_pgrp = find_get_pid(pgid);

This is a little backward.  You first get current's pgid pid, but don't
take a reference;  then parse_options gets current's pgid pid_nr (and
keeps that if no pgid was specified), passes that back here, and here we
get the pid_nr and take a ref.  I was actually first going to say that
I didn't want to block this patch on this, but it should be cleaned up
at some point (i.e. at top of this function get the struct pid and get
a ref, pass that to parse_options, and have parse_options get the
specified pgid instead if a valid one was passed in.

But now I'm wondering whether this actually is unsafe, bc I'm not quite
sure how to read the comment above task_pgrp() (in sched.h) says not
to dereference this if it wasn't gotten under task_lock or rcu_read_lock.
Which this isn't.  So is this actually unsafe?

> +	if (!sbi->oz_pgrp) {
> +		printk("autofs: could not find process group %d\n", pgid);
> +		goto fail_dput;
> +	}
> +
>  	pipe = fget(pipefd);

thanks,
-serge

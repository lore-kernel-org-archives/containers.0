From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH] Move console redirect to pid namespace
Date: Sat, 9 Feb 2013 19:14:09 +0100
Message-ID: <20130209191409.643c3d7f@neptune.home>
References: <1360376920-30824-1-git-send-email-minyard@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360376920-30824-1-git-send-email-minyard-HInyCGIudOg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Corey Minyard <minyard-HInyCGIudOg@public.gmane.org>
Cc: Corey Minyard <cminyard-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

CCing containers list

On Fri, 08 February 2013 minyard-HInyCGIudOg@public.gmane.org wrote:
> From: Corey Minyard <cminyard-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
> 
> The console redirect - ioctl(fd, TIOCCONS) - is not in a namespace,
> thus a container can do a redirect and grab all the I/O on the host
> and all container consoles.
> 
> This change puts the redirect in the pid namespace.
> 
> Signed-off-by: Corey Minyard <cminyard-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
> ---
> 
> I'm pretty sure this patch is not correct, but I'm not quite sure the
> best way to fix this.  I'm not 100% sure that the pid namespace is the
> right place, but it seemed the most reasonable of all the choices.  The
> other obvious choice is the mount namespace, but it didn't seem as good
> a fit.

With recent changes, tying it to init user namespace might even be better.

> The other problem is that I don't think you can call fput() from
> destroy_pid_namespace().  That can be called from interrupt context,
> and I don't think fput() is safe there.  I know it's not safe in 3.4
> with the RT patch applied.  However, the only way I've come up with to
> fix it is to add a workqueue, and that seems a bit heavy for this.
> 
>  drivers/tty/tty_io.c          |   29 ++++++++++++++++++-----------
>  include/linux/pid_namespace.h |    1 +
>  kernel/pid_namespace.c        |    3 +++
>  3 files changed, 22 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/tty/tty_io.c b/drivers/tty/tty_io.c
> index da9fde8..c93c23d 100644
> --- a/drivers/tty/tty_io.c
> +++ b/drivers/tty/tty_io.c
> @@ -95,6 +95,7 @@
>  #include <linux/seq_file.h>
>  #include <linux/serial.h>
>  #include <linux/ratelimit.h>
> +#include <linux/pid_namespace.h>
>  
>  #include <linux/uaccess.h>
>  
> @@ -503,8 +504,10 @@ static const struct file_operations hung_up_tty_fops = {
>  	.release	= tty_release,
>  };
>  
> +/*
> + * redirect is in the pid namespace, but we use a global lock.
> + */
>  static DEFINE_SPINLOCK(redirect_lock);
> -static struct file *redirect;
>  
>  /**
>   *	tty_wakeup	-	request more data
> @@ -563,15 +566,17 @@ static void __tty_hangup(struct tty_struct *tty)
>  	int    closecount = 0, n;
>  	unsigned long flags;
>  	int refs = 0;
> +	struct file *redir;
>  
>  	if (!tty)
>  		return;
>  
>  
>  	spin_lock(&redirect_lock);
> -	if (redirect && file_tty(redirect) == tty) {
> -		f = redirect;
> -		redirect = NULL;
> +	redir = current->nsproxy->pid_ns->redirect;
> +	if (redir && file_tty(redir) == tty) {
> +		f = redir;
> +		current->nsproxy->pid_ns->redirect = NULL;
>  	}
>  	spin_unlock(&redirect_lock);
>  
> @@ -1163,10 +1168,12 @@ ssize_t redirected_tty_write(struct file *file, const char __user *buf,
>  						size_t count, loff_t *ppos)
>  {
>  	struct file *p = NULL;
> +	struct file *redir;
>  
>  	spin_lock(&redirect_lock);
> -	if (redirect)
> -		p = get_file(redirect);
> +	redir = current->nsproxy->pid_ns->redirect;
> +	if (redir)
> +		p = get_file(redir);
>  	spin_unlock(&redirect_lock);
>  
>  	if (p) {
> @@ -2247,19 +2254,19 @@ static int tioccons(struct file *file)
>  	if (file->f_op->write == redirected_tty_write) {
>  		struct file *f;
>  		spin_lock(&redirect_lock);
> -		f = redirect;
> -		redirect = NULL;
> +		f = current->nsproxy->pid_ns->redirect;
> +		current->nsproxy->pid_ns->redirect = NULL;
>  		spin_unlock(&redirect_lock);
>  		if (f)
>  			fput(f);
>  		return 0;
>  	}
>  	spin_lock(&redirect_lock);
> -	if (redirect) {
> +	if (current->nsproxy->pid_ns->redirect) {
>  		spin_unlock(&redirect_lock);
>  		return -EBUSY;
>  	}
> -	redirect = get_file(file);
> +	current->nsproxy->pid_ns->redirect = get_file(file);
>  	spin_unlock(&redirect_lock);
>  	return 0;
>  }
> diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
> index 215e5e3..b04870f 100644
> --- a/include/linux/pid_namespace.h
> +++ b/include/linux/pid_namespace.h
> @@ -38,6 +38,7 @@ struct pid_namespace {
>  	int hide_pid;
>  	int reboot;	/* group exit code if this pidns was rebooted */
>  	unsigned int proc_inum;
> +	struct file *redirect;
>  };
>  
>  extern struct pid_namespace init_pid_ns;
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index c1c3dc1..af1bfce 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -18,6 +18,7 @@
>  #include <linux/proc_fs.h>
>  #include <linux/reboot.h>
>  #include <linux/export.h>
> +#include <linux/file.h>
>  
>  #define BITS_PER_PAGE		(PAGE_SIZE*8)
>  
> @@ -138,6 +139,8 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
>  {
>  	int i;
>  
> +	if (ns->redirect)
> +	    fput(ns->redirect);
>  	proc_free_inum(ns->proc_inum);
>  	for (i = 0; i < PIDMAP_ENTRIES; i++)
>  		kfree(ns->pidmap[i].page);

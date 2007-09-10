From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: task->tgid conversion in fs/locks.c
Date: Mon, 10 Sep 2007 11:24:36 +0400
Message-ID: <46E4F134.6030402@openvz.org>
References: <20070908010016.GA19565@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070908010016.GA19565-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Pavel,
> 
> I noticed that fcntl tests in LTP fail when LTP is run a child pid
> namespace. I just hacked up this quick patch and seems to fix the
> failures.
> 
> Are you already working on this or do you want me to test and send
> this out for review. 
> 
> I have one concern that I could use some review/confirmation :-)
> 
> Even if the main thread of a process exits before the child threads,
> the main thread will not be reaped until all threads exit.  So, the
> 'task->group_leader' remains valid for the child threads until the
> last non-leader thread exits.
> 
> IOW the call to task_tgid_vnr() is safe in locks_remove_posix() and
> locks_remove_flock().

Well, I missed this place deliberately. This should be converted into
struct pid * usage. I will do the appropriate patch soon.

> ---
>  fs/locks.c |   14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> Index: 2.6.23-rc4-mm1/fs/locks.c
> ===================================================================
> --- 2.6.23-rc4-mm1.orig/fs/locks.c	2007-09-05 12:24:30.000000000 -0700
> +++ 2.6.23-rc4-mm1/fs/locks.c	2007-09-07 09:14:47.000000000 -0700
> @@ -278,7 +278,7 @@ static int flock_make_lock(struct file *
>  		return -ENOMEM;
>  
>  	fl->fl_file = filp;
> -	fl->fl_pid = current->tgid;
> +	fl->fl_pid = task_tgid_vnr(current);
>  	fl->fl_flags = FL_FLOCK;
>  	fl->fl_type = type;
>  	fl->fl_end = OFFSET_MAX;
> @@ -344,7 +344,7 @@ static int flock_to_posix_lock(struct fi
>  		return -EOVERFLOW;
>  	
>  	fl->fl_owner = current->files;
> -	fl->fl_pid = current->tgid;
> +	fl->fl_pid = task_tgid_vnr(current);
>  	fl->fl_file = filp;
>  	fl->fl_flags = FL_POSIX;
>  	fl->fl_ops = NULL;
> @@ -390,7 +390,7 @@ static int flock64_to_posix_lock(struct 
>  		return -EOVERFLOW;
>  	
>  	fl->fl_owner = current->files;
> -	fl->fl_pid = current->tgid;
> +	fl->fl_pid = task_tgid_vnr(current);
>  	fl->fl_file = filp;
>  	fl->fl_flags = FL_POSIX;
>  	fl->fl_ops = NULL;
> @@ -446,7 +446,7 @@ static int lease_init(struct file *filp,
>  		return -EINVAL;
>  
>  	fl->fl_owner = current->files;
> -	fl->fl_pid = current->tgid;
> +	fl->fl_pid = task_tgid_vnr(current);
>  
>  	fl->fl_file = filp;
>  	fl->fl_flags = FL_LEASE;
> @@ -1091,7 +1091,7 @@ int locks_mandatory_area(int read_write,
>  
>  	locks_init_lock(&fl);
>  	fl.fl_owner = current->files;
> -	fl.fl_pid = current->tgid;
> +	fl.fl_pid = task_tgid_vnr(current);
>  	fl.fl_file = filp;
>  	fl.fl_flags = FL_POSIX | FL_ACCESS;
>  	if (filp && !(filp->f_flags & O_NONBLOCK))
> @@ -1963,7 +1963,7 @@ void locks_remove_posix(struct file *fil
>  	lock.fl_start = 0;
>  	lock.fl_end = OFFSET_MAX;
>  	lock.fl_owner = owner;
> -	lock.fl_pid = current->tgid;
> +	lock.fl_pid = task_tgid_vnr(current);
>  	lock.fl_file = filp;
>  	lock.fl_ops = NULL;
>  	lock.fl_lmops = NULL;
> @@ -1990,7 +1990,7 @@ void locks_remove_flock(struct file *fil
>  
>  	if (filp->f_op && filp->f_op->flock) {
>  		struct file_lock fl = {
> -			.fl_pid = current->tgid,
> +			.fl_pid = task_tgid_vnr(current),
>  			.fl_file = filp,
>  			.fl_flags = FL_FLOCK,
>  			.fl_type = F_UNLCK,
> 

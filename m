From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: Re: [RFC PATCH] locks: Show only file_locks created in the same pidns
	as current process
Date: Tue, 2 Aug 2016 17:45:03 +0300
Message-ID: <57A0B1EF.7000603@kyup.com>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1470148943-21835-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
Cc: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



On 08/02/2016 05:42 PM, Nikolay Borisov wrote:
> Currently when /proc/locks is read it will show all the file locks
> which are currently created on the machine. On containers, hosted
> on busy servers this means that doing lsof can be very slow. I
> observed up to 5 seconds stalls reading 50k locks, while the container
> itself had only a small number of relevant entries. Fix it by
> filtering the locks listed by the pidns of the current process
> and the process which created the lock.
> 
> Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
> ---
>  fs/locks.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 6333263b7bc8..53e96df4c583 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -2615,9 +2615,17 @@ static int locks_show(struct seq_file *f, void *v)
>  {
>  	struct locks_iterator *iter = f->private;
>  	struct file_lock *fl, *bfl;
> +	struct pid_namespace *pid_ns = task_active_pid_ns(current);
> +
>  
>  	fl = hlist_entry(v, struct file_lock, fl_link);
>  
> +	pr_info ("Current pid_ns: %p init_pid_ns: %p, fl->fl_nspid: %p nspidof:%p\n", pid_ns, &init_pid_ns,
> +		 fl->fl_nspid, ns_of_pid(fl->fl_nspid));

Obviously I don't intend on including that in the final submission.

> +	if ((pid_ns != &init_pid_ns) && fl->fl_nspid &&
> +		(pid_ns != ns_of_pid(fl->fl_nspid)))
> +		    return 0;
> +
>  	lock_get_status(f, fl, iter->li_pos, "");
>  
>  	list_for_each_entry(bfl, &fl->fl_block, fl_block)
> 

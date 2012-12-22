From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH review 1/3] pidns: Outlaw thread creation after
	unshare(CLONE_NEWPID)
Date: Sat, 22 Dec 2012 13:39:20 -0600
Message-ID: <1356205160.5255.0@driftwood>
References: <877goaela9.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="Flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877goaela9.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (from ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org on
	Fri Dec 21 22:57:34 2012)
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/21/2012 10:57:34 PM, Eric W. Biederman wrote:
> 
> The sequence:
> unshare(CLONE_NEWPID)
> clone(CLONE_THREAD|CLONE_SIGHAND|CLONE_VM)
> 
> Creates a new process in the new pid namespace without setting
> pid_ns->child_reaper.  After forking this results in a NULL
> pointer dereference.
> 
> Avoid this and other nonsense scenarios that can show up after
> creating a new pid namespace with unshare by adding a new
> check in copy_prodcess.
> 
> Pointed-out-by:  Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  kernel/fork.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index a31b823..65ca6d2 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1166,6 +1166,14 @@ static struct task_struct  
> *copy_process(unsigned long clone_flags,
>  				current->signal->flags &  
> SIGNAL_UNKILLABLE)
>  		return ERR_PTR(-EINVAL);
> 
> +	/*
> +	 * If the new process will be in a different pid namespace
> +	 * don't allow the creation of threads.
> +	 */
> +	if ((clone_flags & (CLONE_VM|CLONE_NEWPID)) &&
> +	    (task_active_pid_ns(current) != current->nsproxy->pid_ns))
> +		return ERR_PTR(-EINVAL);
> +

Since the first bit will trigger if clone_flags has just CLONE_VM  
without CLONE_NEWPID, or vice versa, I'm guessing this is a fast path  
optimization? (Otherwise you meant (clone_flags &  
(CLONE_VM|CLONE_NEWPID)) == CLONE_VM|CLONE_NEWPID ?)

(Just trying to wrap my head around it...)

Rob

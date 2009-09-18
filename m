From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH user-cr] s390: define struct pid_set
Date: Fri, 18 Sep 2009 13:00:49 -0400
Message-ID: <4AB3BCC1.8050803@librato.com>
References: <20090917034703.GA25290@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090917034703.GA25290-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Assume the definition was lost in pulling this code out of
> mktree.c.

yes it was... thanks.

> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  clone_s390x.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/clone_s390x.c b/clone_s390x.c
> index 39d12e5..661a5c4 100644
> --- a/clone_s390x.c
> +++ b/clone_s390x.c
> @@ -24,6 +24,12 @@
>   */
>  #if defined(__NR_clone_with_pids)
>  
> +/* this really belongs to some kernel header ! */
> +struct pid_set {
> +	int num_pids;
> +	pid_t *pids;
> +};
> +
>  /* (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html) */
>  
>  #define do_clone_with_pids(stack, flags, ptid, ctid, setp) ({ \
> @@ -47,7 +53,7 @@
>  	})
>  
>  int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
> -			struct target_pid_set *target_pids, void *arg)
> +			struct pid_set *target_pids, void *arg)
>  {
>  	long retval;
>  	retval = do_clone_with_pids(child_stack, flags, NULL, NULL,

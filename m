From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 3/7] Add target_pid parameter to alloc_pidmap()
Date: Mon, 4 May 2009 15:03:18 -0500
Message-ID: <20090504200318.GA29491@us.ibm.com>
References: <12414250653025-git-send-email-sukadev@linux.vnet.ibm.com>
	<12414250651744-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <12414250651744-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  kernel/pid.c |   28 ++++++++++++++++++++++++++--
>  1 files changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/pid.c b/kernel/pid.c
> index fd72ad9..93406c6 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -147,12 +147,36 @@ static int alloc_pidmap_page(struct pidmap *map)
>  	return 0;
>  }
> 
> -static int alloc_pidmap(struct pid_namespace *pid_ns)
> +static int set_pidmap(struct pid_namespace *pid_ns, int pid)
> +{
> +	int offset;
> +	struct pidmap *map;
> +
> +	if (pid >= pid_max)
> +		return -EINVAL;
> +
> +	offset = pid & BITS_PER_PAGE_MASK;
> +	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
> +
> +	if (alloc_pidmap_page(map))
> +		return -ENOMEM;
> +
> +	if (test_and_set_bit(offset, map->page))
> +		return -EBUSY;
> +
> +	atomic_dec(&map->nr_free);
> +	return pid;
> +}
> +
> +static int alloc_pidmap(struct pid_namespace *pid_ns, int target_pid)
>  {
>  	int i, offset, max_scan, pid, last = pid_ns->last_pid;
>  	struct pidmap *map;
>  	int rc = -EAGAIN;
> 
> +	if (target_pid)
> +		return set_pidmap(pid_ns, target_pid);

I think this whole patchset is still NACKed until you tag
pid_namespaces with a creator uid, and ensure that
current_uid()==pid_ns->creator_uid() at each level where
the caller is specifying a pid.

I don't see that in this set.

OTOH, your approach of pulling alloc_pidmap_page() out of
alloc_pidmap() and re-using it may be what Eric wanted to
see.

-serge

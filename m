From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v5][PATCH 4/8]: Add target_pid parameter to alloc_pidmap()
Date: Tue, 8 Sep 2009 09:16:42 -0500
Message-ID: <20090908141641.GA2939__26872.6642513231$1252420029$gmane$org@us.ibm.com>
References: <20090907211302.GA5892@us.ibm.com>
	<20090907211506.GD6685@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090907211506.GD6685-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> 
> Subject: [RFC][v5][PATCH 4/8]: Add target_pid parameter to alloc_pidmap()
> 
> With support for setting a specific pid number for a process,
> alloc_pidmap() will need a 'target_pid' parameter.
> 
> Changelog[v3]:
> 	- (Eric Biederman): Avoid set_pidmap() function. Added couple of
> 	  checks for target_pid in alloc_pidmap() itself.
> Changelog[v2]:
> 	- (Serge Hallyn) Check for 'pid < 0' in set_pidmap().(Code
> 	  actually checks for 'pid <= 0' for completeness).
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> 
> Index: linux-mmotm/kernel/pid.c
> ===================================================================
> --- linux-mmotm.orig/kernel/pid.c	2009-09-05 21:17:36.000000000 -0700
> +++ linux-mmotm/kernel/pid.c	2009-09-05 21:19:11.000000000 -0700
> @@ -146,16 +146,22 @@
>  	return 0;
>  }
> 
> -static int alloc_pidmap(struct pid_namespace *pid_ns)
> +static int alloc_pidmap(struct pid_namespace *pid_ns, int target_pid)
>  {
>  	int i, offset, max_scan, pid, last = pid_ns->last_pid;
>  	int rc = -EAGAIN;
>  	int pid_max = pid_ns->pid_max;
>  	struct pidmap *map;
> 
> -	pid = last + 1;
> -	if (pid >= pid_max)
> -		pid = RESERVED_PIDS;
> +	if (target_pid) {
> +		pid = target_pid;
> +		if (pid < 0 || pid >= pid_max)
> +			return -EINVAL;
> +	} else {
> +		pid = last + 1;
> +		if (pid >= pid_max)
> +			pid = RESERVED_PIDS;
> +	}
>  	offset = pid & BITS_PER_PAGE_MASK;
>  	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
>  	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
> @@ -168,9 +174,14 @@
>  			do {
>  				if (!test_and_set_bit(offset, map->page)) {
>  					atomic_dec(&map->nr_free);
> -					pid_ns->last_pid = pid;
> +					if (!target_pid)
> +						pid_ns->last_pid = pid;
>  					return pid;
> +				} else if (target_pid) {
> +					rc = -EBUSY;
> +					break;
>  				}
> +
>  				offset = find_next_offset(map, offset);
>  				pid = mk_pid(pid_ns, map, offset);
>  			/*
> @@ -196,6 +207,7 @@
>  		}
>  		pid = mk_pid(pid_ns, map, offset);
>  	}
> +
>  	return rc;
>  }
> 
> @@ -272,7 +284,7 @@
> 
>  	tmp = ns;
>  	for (i = ns->level; i >= 0; i--) {
> -		nr = alloc_pidmap(tmp);
> +		nr = alloc_pidmap(tmp, 0);
>  		if (nr < 0)
>  			goto out_free;

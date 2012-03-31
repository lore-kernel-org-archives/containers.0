From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] cgroup: deprecate remount option changes mount option
Date: Sat, 31 Mar 2012 09:41:46 -0700
Message-ID: <20120331164146.GD2557__44978.5421290018$1333212122$gmane$org@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120314215228.GI7349@google.com>
	<20120315165655.GD32137@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120315165655.GD32137-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Li, re-sending to your new address just in case you missed this one.

On Thu, Mar 15, 2012 at 09:56:55AM -0700, Tejun Heo wrote:
> This patch marks the following features for deprecation.
> 
> * Rebinding subsys by remount: Never reached useful state - only works
>   on empty hierarchies.
> 
> * release_agent update by remount: release_agent itself will be
>   replaced with conventional fsnotify notification.
> 
> v2: Lennart pointed out that "name=" is necessary for mounts w/o any
>     controller attached.  Drop "name=" deprecation.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
> ---
>  Documentation/feature-removal-schedule.txt |   10 ++++++++++
>  kernel/cgroup.c                            |    5 +++++
>  2 files changed, 15 insertions(+)
> 
> Index: work/Documentation/feature-removal-schedule.txt
> ===================================================================
> --- work.orig/Documentation/feature-removal-schedule.txt
> +++ work/Documentation/feature-removal-schedule.txt
> @@ -510,3 +510,13 @@ Why:	The pci_scan_bus_parented() interfa
>  	convert to using pci_scan_root_bus() so they can supply a list of
>  	bus resources when the bus is created.
>  Who:	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> +
> +----------------------------
> +
> +What:	cgroup option updates via remount
> +When:	March 2013
> +Why:	Remount currently allows changing bound subsystems and
> +	release_agent.  Rebinding is hardly useful as it only works
> +	when the hierarchy is empty and release_agent itself should be
> +	replaced with conventional fsnotify.
> +Who:	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Index: work/kernel/cgroup.c
> ===================================================================
> --- work.orig/kernel/cgroup.c
> +++ work/kernel/cgroup.c
> @@ -1294,6 +1294,11 @@ static int cgroup_remount(struct super_b
>  	if (ret)
>  		goto out_unlock;
>  
> +	/* See feature-removal-schedule.txt */
> +	if (opts.subsys_bits != root->actual_subsys_bits || opts.release_agent)
> +		pr_warning("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
> +			   task_tgid_nr(current), current->comm);
> +
>  	/* Don't allow flags or name to change at remount */
>  	if (opts.flags != root->flags ||
>  	    (opts.name && strcmp(opts.name, root->name))) {

-- 
tejun

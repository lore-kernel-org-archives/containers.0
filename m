From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: make messages more readable
Date: Mon, 04 May 2009 09:28:26 +0800
Message-ID: <49FE44BA.7080409__45534.8061550923$1241400603$gmane$org@cn.fujitsu.com>
References: <49F76CC4.8050200@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49F76CC4.8050200-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

(sorry for the delayed reply)

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> 
> Fix some cgroup messages to read better.
> Update MAINTAINERS to include mm/*cgroup* files.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  MAINTAINERS      |    1 +
>  mm/page_cgroup.c |   14 +++++++-------
>  2 files changed, 8 insertions(+), 7 deletions(-)
> 
> --- lnx-2630-rc3.orig/mm/page_cgroup.c
> +++ lnx-2630-rc3/mm/page_cgroup.c
> @@ -83,12 +83,12 @@ void __init page_cgroup_init(void)
>  			goto fail;
>  	}
>  	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try cgroup_disable=memory option if you"
> -	" don't want\n");
> +	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
> +	" don't want memory cgroups\n");
>  	return;
>  fail:
> -	printk(KERN_CRIT "allocation of page_cgroup was failed.\n");
> -	printk(KERN_CRIT "please try cgroup_disable=memory boot option\n");
> +	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
> +	printk(KERN_CRIT "please try 'cgroup_disable=memory' boot option\n");
>  	panic("Out of memory");
>  }
>  
> @@ -257,14 +257,14 @@ void __init page_cgroup_init(void)
>  		fail = init_section_page_cgroup(pfn);
>  	}
>  	if (fail) {
> -		printk(KERN_CRIT "try cgroup_disable=memory boot option\n");
> +		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
>  		panic("Out of memory");
>  	} else {
>  		hotplug_memory_notifier(page_cgroup_callback, 0);
>  	}
>  	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try cgroup_disable=memory option if you don't"
> -	" want\n");
> +	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you don't"
> +	" want memory cgroups\n");
>  }
>  
>  void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
> --- lnx-2630-rc3.orig/MAINTAINERS
> +++ lnx-2630-rc3/MAINTAINERS
> @@ -1519,6 +1519,7 @@ L:	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>  S:	Maintained
>  F:	include/linux/cgroup*
>  F:	kernel/cgroup*

May be we should fix it like this:

F: include/linux/cgroup.h
F: kernel/cgroup.c
F: kernel/cgroup_debug.c

?

Since the authors of kernel/cgroup_freezer.c are Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
and Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>.

And the author of net/sched/cls_cgroup.c is Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,

And the maintainer of kernel/ns_cgroup.c and security/device_cgroup.c is
Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>.

> +F:	mm/*cgroup*
>  

And this belongs to memory resource controller (grep 'MEMORY RESOURCE CONTROLLER'
in MAINTAINERS). The maintainers of mm/page_cgroup.c and mm/memcontrol.c are
Balbir and Kamezawa.

>  CORETEMP HARDWARE MONITORING DRIVER
>  P:	Rudolf Marek
> 
> 

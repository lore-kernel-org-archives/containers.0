From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCH 2/5] Container Freezer: Make refrigerator always available
Date: Tue, 12 Aug 2008 22:49:26 +0200
Message-ID: <200808122249.27553.rjw__18800.947481259$1218575968$gmane$org@sisk.pl>
References: <20080811235323.872291138@us.ibm.com>
	<20080811235324.661871296@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080811235324.661871296-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tuesday, 12 of August 2008, Matt Helsley wrote:
> Now that the TIF_FREEZE flag is available in all architectures,
> extract the refrigerator() and freeze_task() from kernel/power/process.c
> and make it available to all.
> 
> The refrigerator() can now be used in a control group subsystem
> implementing a control group freezer.
> 
> Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Your Signed-off-by implies your Tested-by (at least it should ;-)).

> ---
[--snip--]
> Index: linux-2.6.27-rc1-mm1/kernel/power/Kconfig
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/kernel/power/Kconfig
> +++ linux-2.6.27-rc1-mm1/kernel/power/Kconfig
> @@ -85,6 +85,9 @@ config PM_SLEEP
>  	depends on SUSPEND || HIBERNATION || XEN_SAVE_RESTORE
>  	default y
>  
> +config FREEZER
> +	def_bool PM_SLEEP
> +

I'd still prefer this to go into a Kconfig in the parent directory (ie. where
freezer.c and the Makefile building it are located).  Otherwise it's guaranteed
to confuse someone.

>  config SUSPEND
>  	bool "Suspend to RAM and standby"
>  	depends on PM && ARCH_SUSPEND_POSSIBLE
> 

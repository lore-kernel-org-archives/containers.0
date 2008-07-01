From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: Attaching PID 0 to a cgroup
Date: Tue, 1 Jul 2008 16:21:26 +0530
Message-ID: <20080701105126.GA10403@linux.vnet.ibm.com>
References: <20080701094545.GD3925@linux.vnet.ibm.com> <20080701094734.GE3925@linux.vnet.ibm.com> <486A06B7.7020906@cn.fujitsu.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755193AbYGAKvz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <486A06B7.7020906@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, lkml <linux-kernel@vger.kernel.org>, containers@lists.osdl.org, Paul Jackson <pj@sgi.com>
List-Id: containers.vger.kernel.org

On Tue, Jul 01, 2008 at 06:28:07PM +0800, Li Zefan wrote:
> CC: Paul Jackson <pj@sgi.com>
> 
> Dhaval Giani wrote:
> > [put in the wrong alias for containers list correcting it.]
> > 
> > On Tue, Jul 01, 2008 at 03:15:45PM +0530, Dhaval Giani wrote:
> >> Hi Paul,
> >>
> >> Attaching PID 0 to a cgroup caused the current task to be attached to
> >> the cgroup. Looking at the code,
> >>
> 
> [...]
> 
> >>
> >> I was wondering, why this was done. It seems to be unexpected behavior.
> >> Wouldn't something like the following be a better response? (I've used
> >> EINVAL, but I can change it to ESRCH if that is better.)
> >>
> 
> Why is it unexpected? it follows the behavior of cpuset, so this patch will
> break backward compatibility of cpuset.

Ah, I was not aware of that. Thanks!

> 
> But it's better to document this.
> 

Yes please.

> -----------------------------------------
> 
> Document the following cgroup usage:
>  # echo 0 > /dev/cgroup/tasks
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Dhaval Giani <dhaval@linux.vnet.ibm.com>

> ---
>  cgroups.txt |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/Documentation/cgroups.txt b/Documentation/cgroups.txt
> index 824fc02..213f533 100644
> --- a/Documentation/cgroups.txt
> +++ b/Documentation/cgroups.txt
> @@ -390,6 +390,10 @@ If you have several tasks to attach, you have to do it one after another:
>  	...
>  # /bin/echo PIDn > tasks
> 
> +You can attach the current task by echoing 0:
> +
> +# /bin/echo 0 > tasks
> +
>  3. Kernel API
>  =============
> 
> 

-- 
regards,
Dhaval

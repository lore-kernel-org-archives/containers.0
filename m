From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/4] CGroup: Support for named and empty hierarchies
Date: Thu, 23 Jul 2009 14:13:01 +0900
Message-ID: <20090723141301.05401a5c.kamezawa.hiroyu__23646.7598857873$1248326133$gmane$org@jp.fujitsu.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722194644.7481.47805.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 22 Jul 2009 12:50:24 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> The following series implements support for named cgroup hierarchies,
> and for cgroup hierarchies that have no bound subsystems.
> 
> This is a subset of the patch series that I sent out as an RFC earlier
> in the month; I'm not pushing the additional support for
> multiply-bound hierarchies at this point.
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

Thank you. I'd like to look into procps package to allow

 #ps -lf -cgroup=/xxxx/yyy
or
 #top -cgroup=/xxx/yyy

I think this can reduce scanning cost of ps/top/pgrep/pkill etc...
(ps can take 1ms if there are lots of processes.)
If rejected, I'll find some other way ;) ../add cgps to libcgroup.

Thanks,
-Kame



> ---
> 
> Paul Menage (4):
>       Support named cgroups hierarchies
>       Move the cgroup debug subsys into cgroup.c to access internal state
>       Add a back-pointer from struct cg_cgroup_link to struct cgroup
>       Allow cgroup hierarchies to be created with no bound subsystems
> 
> 
>  Documentation/cgroups/cgroups.txt |   19 +
>  kernel/Makefile                   |    1 
>  kernel/cgroup.c                   |  660 +++++++++++++++++++++++++++++--------
>  kernel/cgroup_debug.c             |  105 ------
>  4 files changed, 533 insertions(+), 252 deletions(-)
>  delete mode 100644 kernel/cgroup_debug.c
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

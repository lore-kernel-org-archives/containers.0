From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Fri, 13 Jun 2008 21:46:26 -0700
Message-ID: <20080613214626.9afc892f.randy.dunlap@oracle.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756964AbYFNEvf@vger.kernel.org>
In-Reply-To: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Sat, 07 Jun 2008 20:00:00 +0900 KOSAKI Motohiro wrote:

> ---
>  Documentation/controllers/task.txt |   18 +++
>  include/linux/cgroup_subsys.h      |    4 
>  include/linux/cgroup_task.h        |   33 +++++
>  init/Kconfig                       |   10 +
>  kernel/Makefile                    |    1 
>  kernel/cgroup_task.c               |  213 +++++++++++++++++++++++++++++++++++++
>  kernel/fork.c                      |    4 
>  7 files changed, 283 insertions(+)
> 
> Index: b/init/Kconfig
> ===================================================================
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -289,6 +289,16 @@ config CGROUP_DEBUG
>  
>  	  Say N if unsure
>  
> +config CGROUP_TASK
> +	bool "Simple number of task accounting cgroup subsystem"
> +	depends on CGROUPS && EXPERIMENTAL
> +	default n
> +	help
> +          Provides a simple number of task accounting cgroup subsystem for

Indent help test one tab + 2 spaces, please.
s/for/to/

> +	  prevent fork bomb.

s/bomb/bombs/

> +
> +	  Say N if unsure

end with period (".").

> +
>  config CGROUP_NS
>          bool "Namespace cgroup subsystem"
>          depends on CGROUPS

> Index: b/Documentation/controllers/task.txt
> ===================================================================
> --- /dev/null
> +++ b/Documentation/controllers/task.txt
> @@ -0,0 +1,18 @@
> +Task limit Controller
> +
> +1. Description
> +
> +Implement a cgroup to track number of tasks (process and thread).
> +this feature is useful for prevent fork bomb attack.

s/this/This/
s/for/to/
s/attack/attacks/ or s/prevent fork/prevent a fork/

> +
> +
> +2. User Interface
> +
> +ristrict number of tasks to 100.

   Restrict

> +
> +	# echo 100 > /cgroups/foo/task.max_tasks
> +
> +
> +display current number of tasks.

   Display

> +
> +        # cat > /cgroups/foo/task.nr_tasks
> 
> 
> --


---
~Randy
'"Daemon' is an old piece of jargon from the UNIX operating system,
where it referred to a piece of low-level utility software, a
fundamental part of the operating system."

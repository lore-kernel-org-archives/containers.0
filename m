From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 4/5] Add fair-user scheduler
Date: Mon, 24 Sep 2007 09:56:41 -0700
Message-ID: <20070924095641.12e595b3.randy.dunlap@oracle.com>
References: <20070924163326.GA10291@linux.vnet.ibm.com>
	<20070924164059.GE10291@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760749AbXIXRBh@vger.kernel.org>
In-Reply-To: <20070924164059.GE10291@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, dmitry.adamushko@gmail.com, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, efault@gmx.de
List-Id: containers.vger.kernel.org

On Mon, 24 Sep 2007 22:10:59 +0530 Srivatsa Vaddagiri wrote:

> ---
>  include/linux/sched.h |    4 +++
>  init/Kconfig          |   13 ++++++++++++
>  kernel/sched.c        |    9 ++++++++
>  kernel/sched_debug.c  |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  kernel/user.c         |   43 +++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 121 insertions(+)
> 
> Index: linux-2.6.23-rc6/init/Kconfig
> ===================================================================
> --- linux-2.6.23-rc6.orig/init/Kconfig
> +++ linux-2.6.23-rc6/init/Kconfig
> @@ -289,6 +289,19 @@ config FAIR_GROUP_SCHED
>  	  This feature lets cpu scheduler recognize task groups and control cpu
>  	  bandwidth allocation to such task groups.
>  
> +choice
> +	depends on FAIR_GROUP_SCHED
> +	prompt "Basis for grouping tasks"
> +	default FAIR_USER_SCHED
> +
> + 	config FAIR_USER_SCHED
> + 		bool "user id"
> + 		help
> + 		  This option will choose userid as the basis for grouping
> +		  tasks, thus providing equal cpu bandwidth to each user.

s/cpu/CPU/g please.

and the "bool", "help" and help text are indented by one tab too much.


> +
> +endchoice
> +
>  config SYSFS_DEPRECATED
>  	bool "Create deprecated sysfs files"
>  	default y

---
~Randy
Phaedrus says that Quality is about caring.

From: Gautham R Shenoy <ego@in.ibm.com>
Subject: Re: [-mm PATCH 6/9] Memory controller add per container LRU and reclaim (v4)
Date: Mon, 30 Jul 2007 19:58:18 +0530
Message-ID: <20070730142818.GB22345@in.ibm.com>
References: <20070727200937.31565.78623.sendpatchset@balbir-laptop> <20070727201041.31565.14803.sendpatchset@balbir-laptop> <20070730133758.GB22952@linux.vnet.ibm.com>
Reply-To: ego@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935833AbXG3O2c@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070730133758.GB22952@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

On Mon, Jul 30, 2007 at 07:07:58PM +0530, Dhaval Giani wrote:
> Hi Balbir,
> 
> > diff -puN mm/memcontrol.c~mem-control-lru-and-reclaim mm/memcontrol.c
> > --- linux-2.6.23-rc1-mm1/mm/memcontrol.c~mem-control-lru-and-reclaim	2007-07-28 01:12:50.000000000 +0530
> > +++ linux-2.6.23-rc1-mm1-balbir/mm/memcontrol.c	2007-07-28 01:12:50.000000000 +0530
> 
> >  /*
> >   * The memory controller data structure. The memory controller controls both
> > @@ -51,6 +54,10 @@ struct mem_container {
> >  	 */
> >  	struct list_head active_list;
> >  	struct list_head inactive_list;
> > +	/*
> > +	 * spin_lock to protect the per container LRU
> > +	 */
> > +	spinlock_t lru_lock;
> >  };
> 
> The spinlock is not annotated by lockdep. The following patch should do
> it.
> 
> Signed-off-by: Dhaval Giani <dhaval@linux.vnet.ibm.com>
> Signed-off-by: Gautham Shenoy R <ego@in.ibm.com>
		 ^^^^^^^^^^^^^^^^
		 Gautham R Shenoy
> 
> 
> Index: linux-2.6.23-rc1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.23-rc1.orig/mm/memcontrol.c	2007-07-30 17:27:24.000000000 +0530
> +++ linux-2.6.23-rc1/mm/memcontrol.c	2007-07-30 18:43:40.000000000 +0530
> @@ -501,6 +501,9 @@
> 
>  static struct mem_container init_mem_container;
> 
> +/* lockdep should know about lru_lock */
> +static struct lock_class_key lru_lock_key;
> +
>  static struct container_subsys_state *
>  mem_container_create(struct container_subsys *ss, struct container *cont)
>  {
> @@ -519,6 +522,7 @@
>  	INIT_LIST_HEAD(&mem->active_list);
>  	INIT_LIST_HEAD(&mem->inactive_list);
>  	spin_lock_init(&mem->lru_lock);
> +	lockdep_set_class(&mem->lru_lock, &lru_lock_key);
>  	mem->control_type = MEM_CONTAINER_TYPE_ALL;
>  	return &mem->css;
>  }
> -- 
> regards,
> Dhaval
> 
> I would like to change the world but they don't give me the source code!

-- 
Gautham R Shenoy
Linux Technology Center
IBM India.
"Freedom comes with a price tag of responsibility, which is still a bargain,
because Freedom is priceless!"

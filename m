From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 2/3] Fix the 'current css_set' problem in debug subsystem
Date: Tue, 03 Nov 2009 09:05:38 +0800
Message-ID: <4AEF81E2.3060403@cn.fujitsu.com>
References: <b741c2440911012346k7213befcida229606f10c0399@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757568AbZKCBGk@vger.kernel.org>
In-Reply-To: <b741c2440911012346k7213befcida229606f10c0399@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Liu Aleaxander <aleaxander@gmail.com>
Cc: Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Liu Aleaxander wrote:
>>From 61c93b1a66e43d44820e9b8d22ef0bec80dfc814 Mon Sep 17 00:00:00 2001
> From: Liu Aleaxander <Aleaxander@gmail.com>
> Date: Mon, 2 Nov 2009 14:30:07 +0800
> Subject: [PATCH 2/3] Fix the 'current css_set' problem in debug subsystem
> 
> In the current implementation, it always print the same information
> no matter which group you are in. And this would be meaningless. So
> we should make it print the information of the 'real' current one.
> 
> Well, I am not sure it's the current one, but I'm sure it's the first
> one of that cgroup.
> 

I don't think there is a bug with current 'curent_css_set'. The
"current" in all debug.current_xxx interfaces means "current task".

Besides we already print out a cgroup's css links through
debug.cgroup_css_links, without showing the refcount of
each css_set, but we can, if it can be useful:

  # cat debug.cgroup_css_links
  css_set c10d92e0

> Signed-off-by: Liu Aleaxander <Aleaxander@gmail.com>
> ---
>  include/linux/cgroup.h |    2 --
>  kernel/cgroup.c        |   19 ++++++++++++-------
>  2 files changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 4d63c5c..0008dee 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -389,8 +389,6 @@ int cgroup_add_files(struct cgroup *cgrp,
>              const struct cftype cft[],
>              int count);
> 
> -struct css_set* cgroup_first_css_set(const struct cgroup *cgrp);
> -
>  int cgroup_is_removed(const struct cgroup *cgrp);
> 
>  int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 863089f..ddd4d33 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -340,7 +340,7 @@ static inline void put_css_set_taskexit(struct css_set *cg)
>  /*
>   * Get the first css_set of the cgroup 'cgrp'.
>   */
> -struct css_set* cgroup_first_css_set(const struct cgroup *cgrp)
> +static struct css_set* cgroup_first_css_set(const struct cgroup *cgrp)
>  {
>         struct list_head *head = &cgrp->css_sets;
>         struct cg_cgroup_link *link;
> @@ -4093,17 +4093,22 @@ static u64 debug_taskcount_read(struct cgroup
> *cont, struct cftype *cft)
> 
>  static u64 current_css_set_read(struct cgroup *cont, struct cftype *cft)
>  {
> -    return (u64)(unsigned long)current->cgroups;
> +    return (u64)(long)cgroup_first_css_set(cont);
>  }
> 
>  static u64 current_css_set_refcount_read(struct cgroup *cont,
>                         struct cftype *cft)
>  {
> -    u64 count;
> -
> -    rcu_read_lock();
> -    count = atomic_read(&current->cgroups->refcount);
> -    rcu_read_unlock();
> +    u64 count = 0;
> +    struct css_set *cg;
> +
> +    cg = cgroup_first_css_set(cont);
> +    if (cg) {
> +        rcu_read_lock();
> +        count = atomic_read(&cg->refcount);
> +        rcu_read_unlock();
> +    }
> +
>      return count;
>  }
> 

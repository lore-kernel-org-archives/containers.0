From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH REPOST RFC cgroup/for-3.7] cgroup: mark subsystems with
	broken hierarchy support and whine if cgroups are nested for them
Date: Tue, 11 Sep 2012 10:07:46 -0700
Message-ID: <20120911170746.GL7677__47708.1422265202$1347383283$gmane$org@google.com>
References: <20120910223125.GC7677@google.com>
	<20120910223355.GD7677@google.com>
	<20120911100433.GC8058@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120911100433.GC8058-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Michal.

On Tue, Sep 11, 2012 at 12:04:33PM +0200, Michal Hocko wrote:
> >  	cgroup_unlock();
> > @@ -4953,6 +4958,7 @@ mem_cgroup_create(struct cgroup *cont)
> >  						&per_cpu(memcg_stock, cpu);
> >  			INIT_WORK(&stock->work, drain_local_stock);
> >  		}
> > +		mem_cgroup_subsys.broken_hierarchy = !memcg->use_hierarchy;
> 
> Hmmm, this will warn even if we have
> root (default use_hierarchy=0)
>  \
>   A (use_hierarchy=1)
>    \
>     B <- here
> 
> which is unfortunate because it will add a noise to a reasonable
> configuration.

I suppose you're talking about having root group not performing any
accounting and/or control?  I suppose such could be a valid use case
(is it really necessary tho?)  but I don't think .use_hierarchy is the
right interface for that.  If it's absolutely necessary, I think it
should be a root-only flag (even if that ends up using the same code
path).  Eventually, we really want to kill .use_hierarchy, or at least
make it to RO 1.  As it's currently defined, it's just way too
confusing.

> >  		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
> >  	} else {
> >  		parent = mem_cgroup_from_cont(cont->parent);
> > --- a/net/core/netprio_cgroup.c
> > +++ b/net/core/netprio_cgroup.c
> > @@ -330,7 +330,17 @@ struct cgroup_subsys net_prio_subsys = {
> >  	.subsys_id	= net_prio_subsys_id,
> >  #endif
> >  	.base_cftypes	= ss_files,
> > -	.module		= THIS_MODULE
> > +	.module		= THIS_MODULE,
> > +
> > +	/*
> > +	 * net_prio has artificial limit on the number of cgroups and
> > +	 * disallows nesting making it impossible to co-mount it with other
> > +	 * hierarchical subsystems.  Remove the artificially low PRIOIDX_SZ
> > +	 * limit and properly nest configuration such that children follow
> > +	 * their parents' configurations by default and are allowed to
> > +	 * override and remove the following.
> > +	 */
> > +	.broken_hierarchy = trye,
> 
> typo

Heh, I thought I enabled all controllers.  Thanks. :)

-- 
tejun

From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH REPOST RFC cgroup/for-3.7] cgroup: mark subsystems with
	broken hierarchy support and whine if cgroups are nested for them
Date: Wed, 12 Sep 2012 17:49:07 +0200
Message-ID: <20120912154907.GW21579@dhcp22.suse.cz>
References: <20120910223125.GC7677@google.com>
	<20120910223355.GD7677@google.com>
	<20120911100433.GC8058@dhcp22.suse.cz>
	<5050568B.9090601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5050568B.9090601-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed 12-09-12 13:31:55, Glauber Costa wrote:
> On 09/11/2012 02:04 PM, Michal Hocko wrote:
> > I like the approach in general but see the comments bellow:
> > 
> > On Mon 10-09-12 15:33:55, Tejun Heo wrote:
> > [...]
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -3855,12 +3855,17 @@ static int mem_cgroup_hierarchy_write(st
> >>  	 */
> >>  	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
> >>  				(val == 1 || val == 0)) {
> >> -		if (list_empty(&cont->children))
> >> +		if (list_empty(&cont->children)) {
> >>  			memcg->use_hierarchy = val;
> >> -		else
> >> +			/* we're fully hierarchical iff root uses hierarchy */
> >> +			if (mem_cgroup_is_root(memcg))
> >> +				mem_cgroup_subsys.broken_hierarchy = !val;
> >> +		} else {
> >>  			retval = -EBUSY;
> >> -	} else
> >> +		}
> >> +	} else {
> >>  		retval = -EINVAL;
> >> +	}
> >>  
> >>  out:
> >>  	cgroup_unlock();
> >> @@ -4953,6 +4958,7 @@ mem_cgroup_create(struct cgroup *cont)
> >>  						&per_cpu(memcg_stock, cpu);
> >>  			INIT_WORK(&stock->work, drain_local_stock);
> >>  		}
> >> +		mem_cgroup_subsys.broken_hierarchy = !memcg->use_hierarchy;
> > 
> > Hmmm, this will warn even if we have
> > root (default use_hierarchy=0)
> >  \
> >   A (use_hierarchy=1)
> >    \
> >     B <- here
> > 
> > which is unfortunate because it will add a noise to a reasonable
> > configuration.
> > I think this is fixable if you move the warning after 
> > cgroup_subsys_state::create and broken_hierarchy would be set only if
> > parent is not root and use_hierarchy==0 in mem_cgroup_create. Something
> > like:
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 795e525..d5c93ab 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4973,6 +4973,13 @@ mem_cgroup_create(struct cgroup *cont)
> >  	} else {
> >  		res_counter_init(&memcg->res, NULL);
> >  		res_counter_init(&memcg->memsw, NULL);
> > +		/*
> > +		 * Deeper hierachy with use_hierarchy == false doesn't make
> > +		 * much sense so let cgroup subsystem know about this unfortunate
> > +		 * state in our controller.
> > +		 */
> > +		if (parent && parent != root_mem_cgroup)
> > +			mem_cgroup_subsys.broken_hierarchy = true;
> >  	}
> >  	memcg->last_scanned_node = MAX_NUMNODES;
> >  	INIT_LIST_HEAD(&memcg->oom_notify);
> > 
> > What do you think?
> > 
> I side with Tejun's original intentions.
> 
> While I respect your goal of not warning about any configuration
> with max_level = 1, I believe the only sane configuration as soon
> as we get any 2nd-level child is use_hierarchy = 1 for everybody.
> 
> Everything aside from it should be warned.

Defintely. And that what the above guarantess, doesn't it?

-- 
Michal Hocko
SUSE Labs

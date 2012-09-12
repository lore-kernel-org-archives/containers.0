From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH REPOST RFC cgroup/for-3.7] cgroup: mark subsystems with
	broken hierarchy support and whine if cgroups are nested for them
Date: Wed, 12 Sep 2012 17:47:45 +0200
Message-ID: <20120912154745.GV21579__7725.8609621369$1347464887$gmane$org@dhcp22.suse.cz>
References: <20120910223125.GC7677@google.com>
	<20120910223355.GD7677@google.com>
	<20120911100433.GC8058@dhcp22.suse.cz>
	<20120911170746.GL7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120911170746.GL7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue 11-09-12 10:07:46, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Sep 11, 2012 at 12:04:33PM +0200, Michal Hocko wrote:
> > >  	cgroup_unlock();
> > > @@ -4953,6 +4958,7 @@ mem_cgroup_create(struct cgroup *cont)
> > >  						&per_cpu(memcg_stock, cpu);
> > >  			INIT_WORK(&stock->work, drain_local_stock);
> > >  		}
> > > +		mem_cgroup_subsys.broken_hierarchy = !memcg->use_hierarchy;
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
> 
> I suppose you're talking about having root group not performing any
> accounting and/or control?

It doesn't do any controlling because you cannot set any limit for it.
Root cgroup has always been special.

> I suppose such could be a valid use case
> (is it really necessary tho?)  but I don't think .use_hierarchy is the
> right interface for that.  

I am not sure I understand what you mean by that. My only concern with
is that we shouldn't complain if somebody doesn't do anything wrong.
And creating a group under root without any other children, no matter
what use_hierarchy says, is a valid use case and we shouldn't make too
much noise about that.
The only difference in such a use case is that hierarchical stats will
include numbers from the group only if root had use_hierarchy==1. There
are no other side effects.

> If it's absolutely necessary, I think it should be a root-only flag
> (even if that ends up using the same code path).  Eventually, we
> really want to kill .use_hierarchy, or at least make it to RO 1.  As
> it's currently defined, it's just way too confusing.

Agreed on that, definitely.

-- 
Michal Hocko
SUSE Labs

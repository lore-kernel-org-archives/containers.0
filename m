From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 2.6.32] memcg: warn on deeper hierarchies with
	use_hierarchy==0
Date: Thu, 20 Sep 2012 15:24:00 +0200
Message-ID: <20120920132400.GC23872__11583.8529578925$1348147462$gmane$org@dhcp22.suse.cz>
References: <20120913205827.GO7677@google.com>
	<20120914150306.GQ28039@dhcp22.suse.cz>
	<20120919140203.GA5398@dhcp22.suse.cz>
	<20120919140308.GB5398@dhcp22.suse.cz>
	<alpine.DEB.2.00.1209191237020.749@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1209191237020.749-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed 19-09-12 12:38:18, David Rientjes wrote:
> On Wed, 19 Sep 2012, Michal Hocko wrote:
> 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index f99f599..b61c34b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3106,6 +3106,11 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	} else {
> >  		parent = mem_cgroup_from_cont(cont->parent);
> >  		mem->use_hierarchy = parent->use_hierarchy;
> > +		WARN_ONCE(!mem->use_hierarchy && parent != root_mem_cgroup,
> > +				"Creating hierarchies with use_hierarchy==0 "
> > +				"(flat hierarchy) is considered deprecated. "
> > +				"If you believe that your setup is correct, "
> > +				"we kindly ask you to contact linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org and let us know");
> 
> When I deprecated /proc/pid/oom_adj (now removed), we did a WARN_ONCE() 
> and others complained that this unnecessarily alters userspace scripts 
> that a serious issue has occurred and Linus agreed that we shouldn't do 
> deprecation in this way.  The alternative is to use printk_once() instead.

Yes printk_once is an alternative but I really wanted to have this as
much visible as possible. People tend to react to stack traceces more
and this one will trigger only if somebody is either doing something
wrong or the configuration is the one we are looking for.

Comparing to oom_adj, that one was used much more often so the WARN_ONCE
was too verbose especially when you usually had to wait for an userspace
update which is not the case here.
-- 
Michal Hocko
SUSE Labs

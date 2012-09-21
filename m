From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 2.6.32] memcg: warn on deeper hierarchies with
	use_hierarchy==0
Date: Fri, 21 Sep 2012 09:16:32 +0200
Message-ID: <20120921071632.GA13473__24577.8803168379$1348211819$gmane$org@dhcp22.suse.cz>
References: <20120913205827.GO7677@google.com>
	<20120914150306.GQ28039@dhcp22.suse.cz>
	<20120919140203.GA5398@dhcp22.suse.cz>
	<20120919140308.GB5398@dhcp22.suse.cz>
	<alpine.DEB.2.00.1209191237020.749@chino.kir.corp.google.com>
	<20120920132400.GC23872@dhcp22.suse.cz>
	<alpine.DEB.2.00.1209201531250.17455@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1209201531250.17455-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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

On Thu 20-09-12 15:33:23, David Rientjes wrote:
> On Thu, 20 Sep 2012, Michal Hocko wrote:
> 
> > Yes printk_once is an alternative but I really wanted to have this as
> > much visible as possible. People tend to react to stack traceces more
> > and this one will trigger only if somebody is either doing something
> > wrong or the configuration is the one we are looking for.
> > 
> 
> That's the complete opposite of what Linus has said he wants, he said very 
> specifically that he doesn't want WARN_ONCE() or WARN_ON_ONCE() for 
> deprecation of tunables.  If you want to have this merged, then please get 
> him to ack it.

This is not meant to be merged upstream. I do not think this is a stable
material and Linus tree will get the more generic cgroup based patch
instead. This is just for distributions so that they can help to find
usecases which would prevent use_hierachy removal
 
> > Comparing to oom_adj, that one was used much more often so the WARN_ONCE
> > was too verbose especially when you usually had to wait for an userspace
> > update which is not the case here.
> 
> How is WARN_ONCE() too verbose for oom_adj?  It's printed once!  

It prints much more than one line, right? When I said oom_adj was used
much more I meant more applications cared about the value (so the
prbability of the warning was quite high) not that the message would be
printed multiple times. And to be honest I didn't mind WARN_ONCE being
used for that.

> And how can you claim that userspace doesn't need to change if it's
> creating a hierarchy while use_hierarchy == 0?

It is code vs. configuration change. You have to wait for an update or
change and recompile in the first case while the second one can be done
directly.

-- 
Michal Hocko
SUSE Labs

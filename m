From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 17:03:06 +0200
Message-ID: <20120914150306.GQ28039__21008.275220129$1347635008$gmane$org@dhcp22.suse.cz>
References: <20120913205827.GO7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120913205827.GO7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu 13-09-12 13:58:27, Tejun Heo wrote:
[...]
> 2. memcg's __DEPRECATED_clear_css_refs
> 
>   This is a remnant of another weird design decision of requiring
>   synchronous draining of refcnts on cgroup removal and allowing
>   subsystems to veto cgroup removal - what's the userspace supposed to
>   do afterwards?  Note that this also hinders co-mounting different
>   controllers.
> 
>   The behavior could be useful for development and debugging but it
>   unnecessarily interlocks userland visible behavior with in-kernel
>   implementation details.  To me, it seems outright wrong (either
>   implement proper severing semantics in the controller or do full
>   refcnting) and disallows, for example, lazy drain of caching refs.
>   Also, it complicates the removal path with try / commit / revert
>   logic which has never been fully correct since the beginning.
> 
>   Currently, the only left user is memcg.
> 
>   Solution:
> 
>   * Update memcg->pre_destroy() such that it never fails.
> 
>   * Drop __DEPRECATED_clear_css_refs and all related logic.
>     Convert pre_destroy() to return void.
> 
>   Who:
> 
>   KAMEZAWA, Michal, PLEASE.  I will make __DEPRECATED_clear_css_refs
>   trigger WARN sooner or later.  Let's please get this settled.

I think we are almost there. One big step was that we no longer charge
to the parent and only move statistics but there are still some corner
cases when we race with LRU handling.

[...]
>   * memcg can be fully hierarchical but we need to phase out the flat
>     hierarchy support.  Unfortunately, this involves flipping the
>     behavior for the existing users.  Upstream will try to nudge users
>     with warning messages.  Most burden would be on the distros and at
>     least SUSE seems to be on board with it.  Needs coordination with
>     other distros.

I am currently planning to add a warning to most of the currenly
maintained distributions to have as big coverage as possible. No default
switch for obvious reasons but hopefuly we will get some feedback at
least.

Thanks Tejun for doing this. We needed it for a long time.
-- 
Michal Hocko
SUSE Labs

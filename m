From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH REPOST RFC cgroup/for-3.7] cgroup: mark subsystems with
	broken hierarchy support and whine if cgroups are nested for them
Date: Thu, 13 Sep 2012 14:14:38 +0200
Message-ID: <20120913121438.GC8055@dhcp22.suse.cz>
References: <20120910223125.GC7677@google.com>
	<20120910223355.GD7677@google.com>
	<20120911100433.GC8058@dhcp22.suse.cz>
	<5050568B.9090601@parallels.com>
	<20120912154907.GW21579@dhcp22.suse.cz>
	<20120912171120.GP7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120912171120.GP7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On Wed 12-09-12 10:11:20, Tejun Heo wrote:
> Hello,
> 
> On Wed, Sep 12, 2012 at 05:49:07PM +0200, Michal Hocko wrote:
> > > While I respect your goal of not warning about any configuration
> > > with max_level = 1, I believe the only sane configuration as soon
> > > as we get any 2nd-level child is use_hierarchy = 1 for everybody.
> > > 
> > > Everything aside from it should be warned.
> > 
> > Defintely. And that what the above guarantess, doesn't it?
> 
> I'm getting a bit worried that I might not be fully understanding what
> your concern is.  Can you please elaborate what your worries are and
> the transition plan that you have in your mind regarding
> .use_hierarchy?

I would like to see use_hierarchy go away. The only concern I have is 
to warn only if somebody is doing something wrong (aka flat
hierarchies). Or better put it this way. Do not warn in cases which do
not change if use_hierarchy is gone or default changes to 1.
An example:
root (use_hierarchy=0)
 | \
 |  A (use_hierarchy=0)
 |
 B (use_hierarachy=1)
 |\
 C D

is a perfectly sane configuration and I do not see any reason to fill
logs with some scary warnings when A is created. There will be no
semantical change in this setup When use_hierchy is gone.

So the only thing I am proposing here is to warn only if something
should be fixed in the configuration in order to be prepared for fully
hierarchical (and that is a second level of children from root with
use_hierachy==0).

Does it make more sense now?
-- 
Michal Hocko
SUSE Labs

From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Wed, 19 Sep 2012 16:02:03 +0200
Message-ID: <20120919140203.GA5398__24814.4056801268$1348063347$gmane$org@dhcp22.suse.cz>
References: <20120913205827.GO7677@google.com>
	<20120914150306.GQ28039@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120914150306.GQ28039-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

[CCing Dave, Ben]

Just a short summary as you were not on the CC list. This is sort of
follow up on https://lkml.org/lkml/2012/9/3/211. The end result is
slightly different because Tejun did a more generic cgroup solution (see
bellow). I cannot do the same for OpenSUSE so I will stick with the
memcg specific patch.

On Fri 14-09-12 17:03:06, Michal Hocko wrote:
> I am currently planning to add a warning to most of the currenly
> maintained distributions to have as big coverage as possible. No default
> switch for obvious reasons but hopefuly we will get some feedback at
> least.

Just for the record, I will post backports of the patch I ended up using
for openSUSE 11.4 and 12.[12] and SLES-SP2 as a reply to this email (and
2.6.32 in case somebody is interested).

I hope other distributions can either go with this (which will never be
merged but it should help to identify dubious usage of flat hierarchies
without a risk of breaking anythign) or what Tejun has in his tree[1]
8c7f6edb (cgroup: mark subsystems with broken hierarchy support and
whine if cgroups are nested for them) which is more generic but it is
also slightly more intrusive.

---
[1] - git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7-hierarchy
-- 
Michal Hocko
SUSE Labs

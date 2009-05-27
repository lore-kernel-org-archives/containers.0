From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: handle failure of cgroup_populate_dir() at
	mount/remount
Date: Wed, 27 May 2009 11:24:22 +0800
Message-ID: <4A1CB266.8000400__35491.3555820987$1243394656$gmane$org@cn.fujitsu.com>
References: <4A16153C.2080004@cn.fujitsu.com>	<20090522172545.1e5e5f81.kamezawa.hiroyu@jp.fujitsu.com>	<6599ad830905261506x480f2167naf1034177bbc7036@mail.gmail.com>	<4A1C9253.3060108@cn.fujitsu.com>
	<20090527103404.81d3c1a4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090527103404.81d3c1a4.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 27 May 2009 09:07:31 +0800
> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
>> Paul Menage wrote:
>>> On Fri, May 22, 2009 at 1:25 AM, KAMEZAWA Hiroyuki
>>> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>>>> Hm, shouldn't we allow "noprefix" to be effective only agaisnt cpuset ?
>>>> I think it's just for backward-compatibility of cpuset.
>>>> (I don't like the option at all.)
>>> Yes, exposing the "noprefix" option externally was one of the mistakes
>>> I made when developing cgroups.
>>>
>>> It seems to me really unlikely that anyone is using "noprefix" for
>> And "noprefix" is not documented in cgroups.txt, so I guess not
>> many people know this option. Even libcgroup doesn't handle it.
>>
>>> anything other than implicitly when mounting the "cpuset" filesystem.
>>> So I'd be inclined to just forbid it if we're mounting more than just
>>> the cpuset subsystem. A bit of a nasty abstraction violation, but it
>>> makes more sense overall. The only problem is that someone *might* be
>>> using it - do we have any way to determine how, and how big do they
>>> have to be before we care?
>>>
>> I think we can never know..
> 
> How about this method ?
> 
>  - add "noprefix" to "to-be-removed" list.
>  - add "WARNING: noprefix option will be removed in 2.6.32 (or 2.6.31)" now
>  - remove "noprefix" in 2.6.31-rc or later
> 

I don't see how we can remove noprefix while reserve the compatibility of
old cpuset..

As Paul Menage said, we can allow noprefix to be used only if we mount just
cpuset subsystem:

(pseudo code)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -886,6 +886,11 @@ static int parse_cgroupfs_options(char *data,
                }
        }

+
+       if (test_bit(ROOT_NOPREFIX, &opts->flags) &&
+           (opts->subsys_bits & ~cpuset_subsys_id) != 0)
+               return -EINVAL;
+
        /* We can't have an empty hierarchy */
        if (!opts->subsys_bits)
                return -EINVAL;

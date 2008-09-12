From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] [PATCH -mm 0/2] memcg: per cgroup dirty_ratio
Date: Sat, 13 Sep 2008 01:04:35 +0200
Message-ID: <48CAF583.8060406__37442.9023162977$1221260840$gmane$org@gmail.com>
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>
	<20080912131816.e0cfac7a.akpm@linux-foundation.org>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080912131816.e0cfac7a.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Fri, 12 Sep 2008 17:09:50 +0200
> Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
>> The goal of the patch is to control how much dirty file pages a cgroup can have
>> at any given time (see also [1]).
>>
>> Dirty file and writeback pages are accounted for each cgroup using the memory
>> controller statistics. Moreover, the dirty_ratio parameter is added to the
>> memory controller. It contains, as a percentage of the cgroup memory, the
>> number of dirty pages at which the processes belonging to the cgroup which are
>> generating disk writes will start writing out dirty data.
>>
>> So, the behaviour is actually the same as the global dirty_ratio, except that
>> it works per cgroup.
>>
>> Interface:
>> - two new entries "writeback" and "filedirty" are added to the file
>>   memory.stat, to export to userspace respectively the number of pages under
>>   writeback and the number of dirty file pages in the cgroup
>>
>> - the new file memory.dirty_ratio is added in the cgroup filesystem to show/set
>>   the memcg dirty_ratio
> 
> Seems like a desirable objective.
> 
>> [ This patch is still experimental and I only did few quick tests. I'd like to
>> do run more detailed benchmarks and compare the results, I guess the overhead
>> introduced by this patch shouldn't be so small... and BTW I would prefer a
>> dirty limit in bytes, intead of using a percentage of memory. Bytes are hugely
>> more flexible IMHO, they allow to define more fine-grained limits and so this
>> would work better on large memory machines. ]
>>
>> [1] http://lkml.org/lkml/2008/9/9/245
> 
> I tend to duck experimental and rfc patches ;)
> 
> One thing to think about please: Michael Rubin is hitting problems with
> the existing /proc/sys/vm/dirty-ratio.  Its present granularity of 1%
> is just too coarse for really large machines, and as
> memory-size/disk-speed ratios continue to increase, this will just get
> worse.
> 
> So after thinking about it a bit I encouraged him to propose a patch
> which adds a new /proc/sys/vm/hires-dirty-ratio (for some value of
> "hires" ;)) which simply offers a higher-resolution interface to the
> same internal kernel machinery.
> 
> How does this affect you?  I don't think we should be adding new
> interfaces which have the old 1%-resolution problem.  Once we get this
> higher-resolution interface sorted out, your new interface should do it
> the same way.

Totally agree.

The hires-dirty-ratio interface seems much better. I'll follow the progresses
of this new interface, reusing the same way in my patch doesn't look too difficult,
in any case.

BTW why not use a simple dirty-ratio-in-bytes?

Thanks for commenting,
-Andrea

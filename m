From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] [PATCH -mm 0/2] memcg: per cgroup dirty_ratio
Date: Wed, 8 Oct 2008 10:16:42 +0900
Message-ID: <20081008101642.fcfb9186.kamezawa.hiroyu__285.853996365582$1223429150$gmane$org@jp.fujitsu.com>
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>
	<20080912131816.e0cfac7a.akpm@linux-foundation.org>
	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>
	<48EB4236.1060100@linux.vnet.ibm.com> <48EB851D.2030300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48EB851D.2030300-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 07 Oct 2008 17:49:49 +0200
Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Balbir Singh wrote:
> > Michael Rubin wrote:
> >> On Fri, Sep 12, 2008 at 1:18 PM, Andrew Morton
> >> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> >>> One thing to think about please: Michael Rubin is hitting problems with
> >>> the existing /proc/sys/vm/dirty-ratio.  Its present granularity of 1%
> >>> is just too coarse for really large machines, and as
> >>> memory-size/disk-speed ratios continue to increase, this will just get
> >>> worse.
> >> Re-sending since I top-posted before. Never again. Also adding more
> >> thoughts on a byte based interface.
> >>
> >> Currently the problem we are hitting is that we cannot specify pdflush
> >> to have background limits less than 1% of memory. I am currently
> >> finishing up a patch right now that adds a dirty_ratio_millis
> >> interface.  I hope to submit the patch to LKML by the end of the week.
> >>
> >> The idea is that we don't want to break backwards compatibility and we
> >> also don't want to have two conflicting knobs in the sysctl or
> >> /proc/sys/vm/ space. I thought adding a new knob for those who want to
> >> specify finer grained functionality was a compromise. So the patch has
> >> a vm_dirty_ratio and a vm_dirty_ratio_millis interface. The first to
> >> specify 0-100% and the second to specify .0 to .999%.
> >>
> >> So to represent 0.125% of RAM we set
> >> vm_dirty_ratio = 0
> >> vm_dirty_ratio_millis = 125
> >>
> >> The same for the background_ratio.
> >>
> >> I would also prefer using a bytes interface but I am not sure how to
> >> offer that without  either removing the legacy interface of the ratios
> >> or by offering a concurrent interface that might be confusing such as
> >> when users are looking at the old one and not aware of a new one.
> >>
> > 
> > Just provide a vm_dirty_ration_in_bytes interface and keep it in sync with
> > vm_dirty_ratio (they are just two representations of the same internal value)
> > and for higher resolution propose that users use the bytes interface.
> 
> Hi Balbir,
> 
> now that I read carefully the documentation, the description in
> Documentation/filesystems/proc.txt seems to be a bit misleading. In
> proc.txt we say that dirty_ratio and dirty_background_ratio are "a
> percentage of total system memory", but in mm/page-writeback.c we apply
> the percentages to the dirtyable memory: free pages + reclaimable pages.
> So, first of all I think we should clarify this in the documentation...
> 
> Saying that, keeping in sync the vm_dirty_amount_in_bytes according to
> dirty_ratio_in_percentage is not a trivial task. One is a static value,
> the other depends on the dirtyable memory in the system. If we want to
> preserve the same behaviour we should do the following:
> 
> dirty_ratio = x => dirty_amount_in_bytes = x * dirtyable_memory / 100
> 
> dirty_amount_in_bytes = y => dirty_ratio = y / dirtyable_memory * 100
> 
> But anytime the dirtyable memory (or the total memory in the system)
> changes we should update both values accordingly to preserve the
> coherency between them (ouch!).
> 
> Possible solutions:
> 
> 1) introduce fine-grained dirty_ratio handling decimals by an opportune
>    parser (disadvantage: this would break the compatibility with all the
>    userspace apps that expect to read an int from vm_dirty_ratio)
> 
> 2) introduce dirty_ratio + dirty_ratio_millis (disadvantage: can
>    generate unexpected behaviours when something is written to
>    dirty_ratio ignoring the existence of dirty_ratio_millis)
> 
> 3) introduce dirty_ratio + dirty_amount_in_bytes mutually exclusive,
>    writing to one automatically "disable" the other (disadvantage:
>    writing to dirty_ratio ignoring dirty_amount_in_bytes can cause
>    unexpected behaviours)
> 
> 4) introduce dirty_ratio + dirty_amount_in_bytes and change the
>    old behaviour: when something is written to dirty_ratio,
>    dirty_amount_in_bytes is evaluated in function of totalram_pages (or
>    the memcg limit) and then we always use this static value, instead of
>    something that depends on the dirtyable memory - we can easily update
>    dirty_amount_in_bytes also when totalram_pages or the memcg limit
>    changes (disadvantage: change an old - working - behaviour).
> 
> 5) handle fine-grained dirty_ratio decimals by an opportune parser when
>    writing something to dirty_ratio; export the percentage units via
>    dirty_ratio, and the decimals via dirty_ratio_decimals; writing to
>    dirty_ratio_decimals is not allowed.
> 
> I tend to choose 5. The same for dirty_background_ratio.
> 

Hmm... I agree to "5"... like this ?
==
prvoides
  - vm.dirty_ratio (1/100)
  - vm.dirty_ratio_percentmille(1/100,000, pcm)

and allow
#echo 0.05 > vm/dirty_ratio
#cat vm/dirty_ratio 
0
#cat vm/dirty_ratio_percentmille
500
==

Thanks,
-Kame

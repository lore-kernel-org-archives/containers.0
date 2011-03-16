From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v6 8/9] memcg: check memcg dirty limits in page writeback
Date: Tue, 15 Mar 2011 19:35:26 -0700
Message-ID: <AANLkTimLNxcLQ23SRtdeynC19Htxe_aBm7sLuax_fQTX@mail.gmail.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-9-git-send-email-gthelen@google.com> <20110314175408.GE31120@redhat.com>
 <20110314211002.GD4998@quack.suse.cz> <AANLkTikCt90o2qRV=0cJijtnA_W44dcUCBOmZ53Biv07@mail.gmail.com>
 <20110315231230.GC4995@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110315231230.GC4995@quack.suse.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Tue, Mar 15, 2011 at 4:12 PM, Jan Kara <jack@suse.cz> wrote:
> On Mon 14-03-11 20:27:33, Greg Thelen wrote:
>> On Mon, Mar 14, 2011 at 2:10 PM, Jan Kara <jack@suse.cz> wrote:
>> > On Mon 14-03-11 13:54:08, Vivek Goyal wrote:
>> >> On Fri, Mar 11, 2011 at 10:43:30AM -0800, Greg Thelen wrote:
>> >> > If the current process is in a non-root memcg, then
>> >> > balance_dirty_pages() will consider the memcg dirty limits as w=
ell as
>> >> > the system-wide limits. =A0This allows different cgroups to hav=
e distinct
>> >> > dirty limits which trigger direct and background writeback at d=
ifferent
>> >> > levels.
>> >> >
>> >> > If called with a mem_cgroup, then throttle_vm_writeout() querie=
s the
>> >> > given cgroup for its dirty memory usage limits.
>> >> >
>> >> > Signed-off-by: Andrea Righi <arighi@develer.com>
>> >> > Signed-off-by: Greg Thelen <gthelen@google.com>
>> >> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >> > Acked-by: Wu Fengguang <fengguang.wu@intel.com>
>> >> > ---
>> >> > Changelog since v5:
>> >> > - Simplified this change by using mem_cgroup_balance_dirty_page=
s() rather than
>> >> > =A0 cramming the somewhat different logic into balance_dirty_pa=
ges(). =A0This means
>> >> > =A0 the global (non-memcg) dirty limits are not passed around i=
n the
>> >> > =A0 struct dirty_info, so there's less change to existing code.
>> >>
>> >> Yes there is less change to existing code but now we also have a =
separate
>> >> throttlig logic for cgroups.
>> >>
>> >> I thought that we are moving in the direction of IO less throttli=
ng
>> >> where bdi threads always do the IO and Jan Kara also implemented =
the
>> >> logic to distribute the finished IO pages uniformly across the wa=
iting
>> >> threads.
>> > =A0Yes, we'd like to avoid doing IO from balance_dirty_pages(). Bu=
t if the
>> > logic in cgroups specific part won't get too fancy (which it doesn=
't seem
>> > to be the case currently), it shouldn't be too hard to convert it =
to the new
>> > approach.
>>
>> Handling memcg hierarchy was something that was not trivial to imple=
ment in
>> mem_cgroup_balance_dirty_pages.
>>
>> > We can talk about it at LSF but at least with my approach to IO-le=
ss
>> > balance_dirty_pages() it would be easy to convert cgroups throttli=
ng to
>> > the new way. With Fengguang's approach it might be a bit harder si=
nce he
>> > computes a throughput and from that necessary delay for a throttle=
d task
>> > but with cgroups that is impossible to compute so he'd have to add=
 some
>> > looping if we didn't write enough pages from the cgroup yet. But s=
till it
>> > would be reasonable doable AFAICT.
>>
>> I am definitely interested in finding a way to merge these feature
>> cleanly together.
> =A0What my patches do is that instead of calling writeback_inodes_wb(=
) the
> process waits for IO on enough pages to get completed. Now if we can =
tell
> for each page against which cgroup it is accounted (and I believe we =
are
> able to do so), we can as well properly account amount of pages compl=
eted
> against a particular cgroup and thus wait for right amount of pages f=
or
> that cgroup to get written. The only difficult part is that for BDI I=
 can
> estimate throughput, set sleep time appropriately, and thus avoid
> unnecessary looping checking whether pages have already completed or =
not.
> With per-cgroup this is impossible (cgroups share the resource) so we=
'd have
> to check relatively often...
>
>> >> Keeping it separate for cgroups, reduces the complexity but also =
forks
>> >> off the balancing logic for root and other cgroups. So if Jan Kar=
a's
>> >> changes go in, it automatically does not get used for memory cgro=
ups.
>> >>
>> >> Not sure how good a idea it is to use a separate throttling logic=
 for
>> >> for non-root cgroups.
>> > =A0Yeah, it looks a bit odd. I'd think that we could just cap
>> > task_dirty_limit() by a value computed from a cgroup limit and be =
done
>> > with that but I probably miss something...
>>
>> That is an interesting idea. =A0When looking at upstream balance_dir=
ty_pages(),
>> the result of task_dirty_limit() is compared per bdi_nr_reclaimable =
and
>> bdi_nr_writeback. =A0I think we should be comparing memcg usage to m=
emcg limits
>> to catch cases where memcg usage is above memcg limits.
>> Or am I missing something in your apporach?
> =A0Oh right. It was too late yesterday :).
>
>> > Sure there is also a different
>> > background limit but that's broken anyway because a flusher thread=
 will
>> > quickly stop doing writeback if global background limit is not exc=
eeded.
>> > But that's a separate topic so I'll reply with this to a more appr=
opriate
>> > email ;)
>> ;) =A0I am also interested in the this bg issue, but I should also t=
ry
>> to stay on topic.
> =A0I found out I've already deleted the relevant email and thus have =
no good
> way to reply to it. So in the end I'll write it here: As Vivek pointe=
d out,
> you try to introduce background writeback that honors per-cgroup limi=
ts but
> the way you do it it doesn't quite work. To avoid livelocking of flus=
her
> thread, any essentially unbounded work (and background writeback of b=
di or
> in your case a cgroup pages on the bdi is in principle unbounded) has=
 to
> give way to other work items in the queue (like a work submitted by
> sync(1)). Thus wb_writeback() stops for_background works if there are=
 other
> works to do with the rationale that as soon as that work is finished,=
 we
> may happily return to background cleaning (and that other work works =
for
> background cleaning as well anyway).
>
> But with your introduction of per-cgroup background writeback we are =
going
> to loose the information in which cgroup we have to get below backgro=
und
> limit. And if we stored the context somewhere and tried to return to =
it
> later, we'd have the above problems with livelocking and we'd have to
> really carefully handle cases where more cgroups actually want their =
limits
> observed.
>
> I'm not decided what would be a good solution for this. It seems that
> a flusher thread should check all cgroups whether they are not exceed=
ing
> their background limit and if yes, do writeback. I'm not sure how pra=
ctical
> that would be but possibly we could have a list of cgroups with excee=
ded
> limits and flusher thread could check that?
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>

mem_cgroup_balance_dirty_pages() queues a bdi work item which already
includes a memcg that is available to wb_writeback() in '[PATCH v6
9/9] memcg: make background writeback memcg aware'.  Background
writeback checks the given memcg usage vs memcg limit rather than
global usage vs global limit.

If we amend this to requeue an interrupted background work to the end
of the per-bdi work_list, then I think that would address the
livelocking issue.

To prevent a memcg writeback work item from writing irrelevant inodes
(outside the memcg) then bdi writeback could call
mem_cgroup_queue_io(memcg, bdi) to locate an inode to writeback for
the memcg under dirty pressure.  mem_cgroup_queue_io() would scan the
memcg lru for dirty pages belonging to the particular bdi.

If mem_cgroup_queue_io() is unable to find any dirty inodes for the
bdi, then it would return an empty set.  Then wb_writeback() would
abandon background writeback because there is nothing useful to write
back to that bdi.  In patch 9/9, wb_writeback() calls
mem_cgroup_bg_writeback_done() when writeback completes.
mem_cgroup_bg_writeback_done() could check that cgroup is still over
background thresh and use the memcg lru to select another bdi to start
per-memcg bdi writeback on.  This allows one queued per-memcg bdi
background writeback work item to pass off to another bdi to continue
per-memcg background writeback.

Does this seem reasonable?

Unfortunately the approach above would only queue a memcg's bg writes
to one bdi at a time.  Another way to approach the problem would be to
have a per-memcg flusher thread that is able to queue inodes to
multiple bdis concurrently.
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

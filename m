From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v8 00/12] memcg: per cgroup dirty page accounting
Date: Fri, 3 Jun 2011 15:50:28 -0700
Message-ID: <BANLkTik50YQtoLVHFg7BP6KLz7GtvU1KzEjdCwx620oYWBH0qQ@mail.gmail.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com> <BANLkTikureiwJ=hSfnwo2y0wWoW3hGge9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikureiwJ=hSfnwo2y0wWoW3hGge9Q@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Fri, Jun 3, 2011 at 3:46 PM, Hiroyuki Kamezawa
<kamezawa.hiroyuki@gmail.com> wrote:
> 2011/6/4 Greg Thelen <gthelen@google.com>:
>> This patch series provides the ability for each cgroup to have indep=
endent dirty
>> page usage limits. =A0Limiting dirty memory fixes the max amount of =
dirty (hard to
>> reclaim) page cache used by a cgroup. =A0This allows for better per =
cgroup memory
>> isolation and fewer ooms within a single cgroup.
>>
>> Having per cgroup dirty memory limits is not very interesting unless=
 writeback
>> is cgroup aware. =A0There is not much isolation if cgroups have to w=
riteback data
>> from other cgroups to get below their dirty memory threshold.
>>
>> Per-memcg dirty limits are provided to support isolation and thus cr=
oss cgroup
>> inode sharing is not a priority. =A0This allows the code be simpler.
>>
>> To add cgroup awareness to writeback, this series adds a memcg field=
 to the
>> inode to allow writeback to isolate inodes for a particular cgroup. =
=A0When an
>> inode is marked dirty, i_memcg is set to the current cgroup. =A0When=
 inode pages
>> are marked dirty the i_memcg field compared against the page's cgrou=
p. =A0If they
>> differ, then the inode is marked as shared by setting i_memcg to a s=
pecial
>> shared value (zero).
>>
>> Previous discussions suggested that a per-bdi per-memcg b_dirty list=
 was a good
>> way to assoicate inodes with a cgroup without having to add a field =
to struct
>> inode. =A0I prototyped this approach but found that it involved more=
 complex
>> writeback changes and had at least one major shortcoming: detection =
of when an
>> inode becomes shared by multiple cgroups. =A0While such sharing is n=
ot expected to
>> be common, the system should gracefully handle it.
>>
>> balance_dirty_pages() calls mem_cgroup_balance_dirty_pages(), which =
checks the
>> dirty usage vs dirty thresholds for the current cgroup and its paren=
ts. =A0If any
>> over-limit cgroups are found, they are marked in a global over-limit=
 bitmap
>> (indexed by cgroup id) and the bdi flusher is awoke.
>>
>> The bdi flusher uses wb_check_background_flush() to check for any me=
mcg over
>> their dirty limit. =A0When performing per-memcg background writeback=
,
>> move_expired_inodes() walks per bdi b_dirty list using each inode's =
i_memcg and
>> the global over-limit memcg bitmap to determine if the inode should =
be written.
>>
>> If mem_cgroup_balance_dirty_pages() is unable to get below the dirty=
 page
>> threshold writing per-memcg inodes, then downshifts to also writing =
shared
>> inodes (i_memcg=3D0).
>>
>> I know that there is some significant writeback changes associated w=
ith the
>> IO-less balance_dirty_pages() effort. =A0I am not trying to derail t=
hat, so this
>> patch series is merely an RFC to get feedback on the design. =A0Ther=
e are probably
>> some subtle races in these patches. =A0I have done moderate function=
al testing of
>> the newly proposed features.
>>
>
> Thank you...hmm, is this set really "merely RFC ?". I'd like to merge
> this function
> before other new big hammer works because this makes behavior of memc=
g
> much better.

Oops.  I meant to remove the above RFC paragraph.   This -v8 patch
series is intended for merging into mmotm.

> I'd like to review and test this set (but maybe I can't do much in th=
e
> weekend...)

Thank you.

> Anyway, thank you.
> -Kame



>> Here is an example of the memcg-oom that is avoided with this patch =
series:
>> =A0 =A0 =A0 =A0# mkdir /dev/cgroup/memory/x
>> =A0 =A0 =A0 =A0# echo 100M > /dev/cgroup/memory/x/memory.limit_in_by=
tes
>> =A0 =A0 =A0 =A0# echo $$ > /dev/cgroup/memory/x/tasks
>> =A0 =A0 =A0 =A0# dd if=3D/dev/zero of=3D/data/f1 bs=3D1k count=3D1M =
&
>> =A0 =A0 =A0 =A0# dd if=3D/dev/zero of=3D/data/f2 bs=3D1k count=3D1M =
&
>> =A0 =A0 =A0 =A0# wait
>> =A0 =A0 =A0 =A0[1]- =A0Killed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dd =
if=3D/dev/zero of=3D/data/f1 bs=3D1M count=3D1k
>> =A0 =A0 =A0 =A0[2]+ =A0Killed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dd =
if=3D/dev/zero of=3D/data/f1 bs=3D1M count=3D1k
>>
>> Known limitations:
>> =A0 =A0 =A0 =A0If a dirty limit is lowered a cgroup may be over its =
limit.
>>
>> Changes since -v7:
>> - Merged -v7 09/14 'cgroup: move CSS_ID_MAX to cgroup.h' into
>> =A0-v8 09/13 'memcg: create support routines for writeback'
>>
>> - Merged -v7 08/14 'writeback: add memcg fields to writeback_control=
'
>> =A0into -v8 09/13 'memcg: create support routines for writeback' and
>> =A0-v8 10/13 'memcg: create support routines for page-writeback'. =A0=
This
>> =A0moves the declaration of new fields with the first usage of the
>> =A0respective fields.
>>
>> - mem_cgroup_writeback_done() now clears corresponding bit for cgrou=
p that
>> =A0cannot be referenced. =A0Such a bit would represent a cgroup prev=
iously over
>> =A0dirty limit, but that has been deleted before writeback cleaned a=
ll pages. =A0By
>> =A0clearing bit, writeback will not continually try to writeback the=
 deleted
>> =A0cgroup.
>>
>> - Previously mem_cgroup_writeback_done() would only finish writeback=
 when the
>> =A0cgroup's dirty memory usage dropped below the dirty limit. =A0Thi=
s was the wrong
>> =A0limit to check. =A0This now correctly checks usage against the ba=
ckground dirty
>> =A0limit.
>>
>> - over_bground_thresh() now sets shared_inodes=3D1. =A0In -v7 per me=
mcg
>> =A0background writeback did not, so it did not write pages of shared
>> =A0inodes in background writeback. =A0In the (potentially common) ca=
se
>> =A0where the system dirty memory usage is below the system backgroun=
d
>> =A0dirty threshold but at least one cgroup is over its background di=
rty
>> =A0limit, then per memcg background writeback is queued for any
>> =A0over-background-threshold cgroups. =A0Background writeback should=
 be
>> =A0allowed to writeback shared inodes. =A0The hope is that writing s=
uch
>> =A0inodes has good chance of cleaning the inodes so they can transit=
ion
>> =A0from shared to non-shared. =A0Such a transition is good because t=
hen the
>> =A0inode will remain unshared until it is written by multiple cgroup=
=2E
>> =A0Non-shared inodes offer better isolation.
>>
>> Single patch that can be applied to mmotm-2011-05-12-15-52:
>> =A0http://www.kernel.org/pub/linux/kernel/people/gthelen/memcg/memcg=
-dirty-limits-v8-on-mmotm-2011-05-12-15-52.patch
>>
>> Patches are based on mmotm-2011-05-12-15-52.
>>
>> Greg Thelen (12):
>> =A0memcg: document cgroup dirty memory interfaces
>> =A0memcg: add page_cgroup flags for dirty page tracking
>> =A0memcg: add mem_cgroup_mark_inode_dirty()
>> =A0memcg: add dirty page accounting infrastructure
>> =A0memcg: add kernel calls for memcg dirty page stats
>> =A0memcg: add dirty limits to mem_cgroup
>> =A0memcg: add cgroupfs interface to memcg dirty limits
>> =A0memcg: dirty page accounting support routines
>> =A0memcg: create support routines for writeback
>> =A0memcg: create support routines for page-writeback
>> =A0writeback: make background writeback cgroup aware
>> =A0memcg: check memcg dirty limits in page writeback
>>
>> =A0Documentation/cgroups/memory.txt =A0| =A0 70 ++++
>> =A0fs/fs-writeback.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 34 ++-
>> =A0fs/inode.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
3 +
>> =A0fs/nfs/write.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 =
+
>> =A0include/linux/cgroup.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
>> =A0include/linux/fs.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 +
>> =A0include/linux/memcontrol.h =A0 =A0 =A0 =A0| =A0 63 ++++-
>> =A0include/linux/page_cgroup.h =A0 =A0 =A0 | =A0 23 ++
>> =A0include/linux/writeback.h =A0 =A0 =A0 =A0 | =A0 =A05 +-
>> =A0include/trace/events/memcontrol.h | =A0198 +++++++++++
>> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 -
>> =A0mm/filemap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
1 +
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0708 ++++=
++++++++++++++++++++++++++++++++-
>> =A0mm/page-writeback.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 42 ++-
>> =A0mm/truncate.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 =
+
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
2 +-
>> =A016 files changed, 1138 insertions(+), 27 deletions(-)
>> =A0create mode 100644 include/trace/events/memcontrol.h
>>
>> --
>> 1.7.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Date: Fri, 18 Mar 2011 00:57:09 -0700
Message-ID: <AANLkTinPsfz1-2O9HNXE_ej-oUa+N5YOdN+cQQimOCBP@mail.gmail.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org> <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com> <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com> <20110316131324.GM2140@cmpxchg.org>
 <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
 <20110316215214.GO2140@cmpxchg.org> <AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
 <20110317124350.GQ2140@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110317124350.GQ2140@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>
List-Id: containers.vger.kernel.org

On Thu, Mar 17, 2011 at 5:43 AM, Johannes Weiner <hannes@cmpxchg.org> w=
rote:
> On Wed, Mar 16, 2011 at 09:41:48PM -0700, Greg Thelen wrote:
>> In '[PATCH v6 8/9] memcg: check memcg dirty limits in page writeback=
' Jan and
>> Vivek have had some discussion around how memcg and writeback mesh.
>> In my mind, the
>> discussions in 8/9 are starting to blend with this thread.
>>
>> I have been thinking about Johannes' struct memcg_mapping. =A0I thin=
k the idea
>> may address several of the issues being discussed, especially
>> interaction between
>> IO-less balance_dirty_pages() and memcg writeback.
>>
>> Here is my thinking. =A0Feedback is most welcome!
>>
>> The data structures:
>> - struct memcg_mapping {
>> =A0 =A0 =A0 =A0struct address_space *mapping;
>> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
>> =A0 =A0 =A0 =A0int refcnt;
>> =A0 };
>> - each memcg contains a (radix, hash_table, etc.) mapping from bdi t=
o memcg_bdi.
>> - each memcg_bdi contains a mapping from inode to memcg_mapping. =A0=
This may be a
>> =A0 very large set representing many cached inodes.
>> - each memcg_mapping represents all pages within an bdi,inode,memcg.=
 =A0All
>> =A0 corresponding cached inode pages point to the same memcg_mapping=
 via
>> =A0 pc->mapping. =A0I assume that all pages of inode belong to no mo=
re than one bdi.
>> - manage a global list of memcg that are over their respective backg=
round dirty
>> =A0 limit.
>> - i_mapping continues to point to a traditional non-memcg mapping (n=
o change
>> =A0 here).
>> - none of these memcg_* structures affect root cgroup or kernels wit=
h memcg
>> =A0 configured out.
>
> So structures roughly like this:
>
> struct mem_cgroup {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0/* key is struct backing_dev_info * */
> =A0 =A0 =A0 =A0struct rb_root memcg_bdis;
> };
>
> struct memcg_bdi {
> =A0 =A0 =A0 =A0/* key is struct address_space * */
> =A0 =A0 =A0 =A0struct rb_root memcg_mappings;
> =A0 =A0 =A0 =A0struct rb_node node;
> };
>
> struct memcg_mapping {
> =A0 =A0 =A0 =A0struct address_space *mapping;
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> =A0 =A0 =A0 =A0struct rb_node node;
> =A0 =A0 =A0 =A0atomic_t count;
> };
>
> struct page_cgroup {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0struct memcg_mapping *memcg_mapping;
> };
>
>> The routines under discussion:
>> - memcg charging a new inode page to a memcg: will use inode->mappin=
g and inode
>> =A0 to walk memcg -> memcg_bdi -> memcg_mapping and lazily allocatin=
g missing
>> =A0 levels in data structure.
>>
>> - Uncharging a inode page from a memcg: will use pc->mapping->memcg =
to locate
>> =A0 memcg. =A0If refcnt drops to zero, then remove memcg_mapping fro=
m the memcg_bdi.
>> =A0 Also delete memcg_bdi if last memcg_mapping is removed.
>>
>> - account_page_dirtied(): nothing new here, continue to set the per-=
page flags
>> =A0 and increment the memcg per-cpu dirty page counter. =A0Same goes=
 for routines
>> =A0 that mark pages in writeback and clean states.
>
> We may want to remember the dirty memcg_mappings so that on writeback
> we don't have to go through every single one that the memcg refers to=
?

I think this is a good idea to allow per memcg per bdi list of dirty ma=
ppings.

It feels like some of this is starting to gel.  I've been sketching
some of the code to see how the memcg locking will work out.  The
basic structures I see are:

struct mem_cgroup {
        ...
        /*
         * For all file pages cached by this memcg sort by bdi.
         * key is struct backing_dev_info *; value is struct memcg_bdi =
*
         * Protected by bdis_lock.
         */
        struct rb_root bdis;
        spinlock_t bdis_lock;  /* or use rcu structure, memcg:bdi set
could be fairly static */
};

struct memcg_bdi {
        struct backing_dev_info *bdi;
        /*
         * key is struct address_space *; value is struct
memcg_mapping *
         * memcg_mappings live within either mappings or
dirty_mappings set.
         */
        struct rb_root mappings;
        struct rb_root dirty_mappings;
        struct rb_node node;
        spinlock_t lock; /* protect [dirty_]mappings */
};

struct memcg_mapping {
        struct address_space *mapping;
        struct memcg_bdi *memcg_bdi;
        struct rb_node node;
        atomic_t nr_pages;
        atomic_t nr_dirty;
};

struct page_cgroup {
        ...
        struct memcg_mapping *memcg_mapping;
};

- each memcg contains a mapping from bdi to memcg_bdi.
- each memcg_bdi contains two mappings:
  mappings: from address_space to memcg_mapping for clean pages
  dirty_mappings: from address_space to memcg_mapping when there are
some dirty pages
- each memcg_mapping represents a set of cached pages within an
bdi,inode,memcg.  All
 corresponding cached inode pages point to the same memcg_mapping via
 pc->mapping.  I assume that all pages of inode belong to no more than =
one bdi.
- manage a global list of memcg that are over their respective backgrou=
nd dirty
 limit.
- i_mapping continues to point to a traditional non-memcg mapping (no c=
hange
 here).
- none of these memcg_* structures affect root cgroup or kernels with m=
emcg
 configured out.

The routines under discussion:
- memcg charging a new inode page to a memcg: will use inode->mapping a=
nd inode
 to walk memcg -> memcg_bdi -> mappings and lazily allocating missing
 levels in data structure.

- Uncharging a inode page from a memcg: will use pc->mapping->memcg to =
locate
 memcg.  If refcnt drops to zero, then remove memcg_mapping from the
memcg_bdi.[dirty_]mappings.
 Also delete memcg_bdi if last memcg_mapping is removed.

- account_page_dirtied(): increment nr_dirty.  If first dirty page,
then move memcg_mapping from memcg_bdi.mappings to
memcg_bdi.dirty_mappings page counter.  When marking page clean, do
the opposite.

- mem_cgroup_balance_dirty_pages(): if memcg dirty memory usage if abov=
e
 background limit, then add memcg to global memcg_over_bg_limit list an=
d use
 memcg's set of memcg_bdi to wakeup each(?) corresponding bdi flusher. =
 If over
 fg limit, then use IO-less style foreground throttling with per-memcg =
per-bdi
 (aka memcg_bdi) accounting structure.

- bdi writeback: will revert some of the mmotm memcg dirty limit change=
s to
 fs-writeback.c so that wb_do_writeback() will return to checking
 wb_check_background_flush() to check background limits and being
interruptible if sync flush occurs.  wb_check_background_flush() will
check the global
 memcg_over_bg_limit list for memcg that are over their dirty limit.
Within each memcg write inodes from the dirty_mappings list until a
threshold page count has been reached (MAX_WRITEBACK_PAGES).  Then
move to next listed memcg.

- over_bground_thresh() will determine if memcg is still over bg limit.
 If over limit, then it per bdi per memcg background flushing will cont=
inue.
 If not over limit then memcg will be removed from memcg_over_bg_limit =
list.

I'll post my resulting patches in RFC form, or (at the least) my conclu=
sions.

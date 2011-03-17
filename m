From: Curt Wohlgemuth <curtw@google.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Date: Thu, 17 Mar 2011 08:42:28 -0700
Message-ID: <AANLkTikfNv9FNgxRTAerb-kXJZsU4ofhH2MdnOwi+hV7@mail.gmail.com>
References: <20110311171006.ec0d9c37.akpm@linux-foundation.org>
	<AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
	<20110314202324.GG31120@redhat.com>
	<AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
	<20110315184839.GB5740@redhat.com>
	<20110316131324.GM2140@cmpxchg.org>
	<AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
	<20110316215214.GO2140@cmpxchg.org>
	<AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
	<20110317124350.GQ2140@cmpxchg.org>
	<20110317145301.GD4116@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110317145301.GD4116@quack.suse.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Thu, Mar 17, 2011 at 7:53 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 17-03-11 13:43:50, Johannes Weiner wrote:
>> > - mem_cgroup_balance_dirty_pages(): if memcg dirty memory usage if=
 above
>> > =A0 background limit, then add memcg to global memcg_over_bg_limit=
 list and use
>> > =A0 memcg's set of memcg_bdi to wakeup each(?) corresponding bdi f=
lusher. =A0If over
>> > =A0 fg limit, then use IO-less style foreground throttling with pe=
r-memcg per-bdi
>> > =A0 (aka memcg_bdi) accounting structure.
>>
>> I wonder if we could just schedule a for_background work manually in
>> the memcg case that writes back the corresponding memcg_bdi set (and
>> e.g. having it continue until either the memcg is below bg thresh OR
>> the global bg thresh is exceeded OR there is other work scheduled)?
>> Then we would get away without the extra list, and it doesn't sound
>> overly complex to implement.
> =A0But then when you stop background writeback because of other work,=
 you
> have to know you should restart it after that other work is done. For=
 this
> you basically need the list. With this approach of one-work-per-memcg
> you also get into problems that one cgroup can livelock the flusher t=
hread
> and thus other memcgs won't get writeback. So you have to switch betw=
een
> memcgs once in a while.

In pre-2.6.38 kernels (when background writeback enqueued work items,
and we didn't break the loop in wb_writeback() with for_background for
other work items), we experimented with this issue.  One solution we
came up with was enqueuing a background work item for a given memory
cgroup, but limiting nr_pages to something like 2048 instead of
LONG_MAX, to avoid livelock.  Writeback would only operate on inodes
with dirty pages from this memory cgroup.

If BG writeback takes place for all memcgs that are over their BG
limts, it seems that simply asking if each inode is "related" somehow
to the a of dirty memcgs is the simplest way to go.  Assuming of
course that efficient data structures are built to answer this
question.

Thanks,
Curt

> We've tried several approaches with global background writeback befor=
e we
> arrived at what we have now and what seems to work at least reasonabl=
y...
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

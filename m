From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC][PATCH v7 11/14] memcg: create support routines for writeback
Date: Sun, 15 May 2011 12:56:24 -0700
Message-ID: <BANLkTim_Ur_9T2qW5UauuiPCLErMpp3cBQ@mail.gmail.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
 <1305276473-14780-12-git-send-email-gthelen@google.com> <20110513190458.ddc0fbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110513190458.ddc0fbe2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Fri, May 13, 2011 at 3:04 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 13 May 2011 01:47:50 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Introduce memcg routines to assist in per-memcg writeback:
>>
>> - mem_cgroups_over_bground_dirty_thresh() determines if any cgroups need
>> =A0 writeback because they are over their dirty memory threshold.
>>
>> - should_writeback_mem_cgroup_inode() determines if an inode is
>> =A0 contributing pages to an over-limit memcg.
>>
>> - mem_cgroup_writeback_done() is used periodically during writeback to
>> =A0 update memcg writeback data.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> I'm okay with the bitmap..then, problem will be when set/clear wbc->for_c=
group...

wbc->for_cgroup is only set in two conditions:

a) when mem_cgroup_balance_dirty_pages() is trying to get a cgroup
below its dirty memory foreground threshold.  This is in patch 12/14.

b) when bdi-flusher is performing background writeback and determines
that at any of the cgroup are over their respective background dirty
memory threshold.  This is in patch 13/14.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

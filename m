From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC][PATCH v7 08/14] writeback: add memcg fields to writeback_control
Date: Sun, 15 May 2011 12:53:08 -0700
Message-ID: <BANLkTi=t+Wn5GWR49f++be_AeZ9fjGACTA@mail.gmail.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
 <1305276473-14780-9-git-send-email-gthelen@google.com> <20110513184120.0f9444bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110513184120.0f9444bc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Fri, May 13, 2011 at 2:41 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 13 May 2011 01:47:47 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Add writeback_control fields to differentiate between bdi-wide and
>> per-cgroup writeback. =A0Cgroup writeback is also able to differenti=
ate
>> between writing inodes isolated to a particular cgroup and inodes sh=
ared
>> by multiple cgroups.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Personally, I want to see new flags with their usage in a patch...

Ok.  Next version will merge the flag definition with first usage of th=
e flag.

>> ---
>> =A0include/linux/writeback.h | =A0 =A02 ++
>> =A01 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> index d10d133..4f5c0d2 100644
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -47,6 +47,8 @@ struct writeback_control {
>> =A0 =A0 =A0 unsigned for_reclaim:1; =A0 =A0 =A0 =A0 /* Invoked from =
the page allocator */
>> =A0 =A0 =A0 unsigned range_cyclic:1; =A0 =A0 =A0 =A0/* range_start i=
s cyclic */
>> =A0 =A0 =A0 unsigned more_io:1; =A0 =A0 =A0 =A0 =A0 =A0 /* more io t=
o be dispatched */
>> + =A0 =A0 unsigned for_cgroup:1; =A0 =A0 =A0 =A0 =A0/* enable cgroup=
 writeback */
>> + =A0 =A0 unsigned shared_inodes:1; =A0 =A0 =A0 /* write inodes span=
ning cgroups */
>> =A0};
>
>
> If shared_inode is really rare case...we don't need to have this shar=
ed_inodes
> flag and do writeback shared_inode always.....No ?
>
> Thanks,
> -Kame

The shared_inodes field is present to avoid punishing cgroups that are
not sharing, if they are run on a system that also includes sharing.

This issue is being debated in another thread: "[RFC][PATCH v7 00/14]
memcg: per cgroup dirty page accounting".  Depending on the decision,
we may be able to delete the shared_inode fields if we choose to
always write shared inodes in both cgroup foreground and cgroup
background writeback.
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

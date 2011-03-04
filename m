From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v5 9/9] memcg: check memcg dirty limits in page writeback
Date: Thu, 3 Mar 2011 16:30:23 -0800
Message-ID: <AANLkTinSrmH-XGuFMBve9SczdXsmKzJbFN4cZ234=z9A@mail.gmail.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-10-git-send-email-gthelen@google.com> <20110302231727.GG2547@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110302231727.GG2547@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Wed, Mar 2, 2011 at 3:17 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Fri, Feb 25, 2011 at 01:36:00PM -0800, Greg Thelen wrote:
>
> [..]
>> @@ -500,18 +527,27 @@ static void balance_dirty_pages(struct address=
_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_info(&sys_info);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg_dirty_info(NULL, &memcg_info))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_info =3D sys_info;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Throttle it only when the backgroun=
d writeback cannot
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* catch-up. This avoids (excessively)=
 small writeouts
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* when the bdi limits are ramping up.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (dirty_info_reclaimable(&sys_info) + sy=
s_info.nr_writeback <=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 if ((dirty_info_reclaimable(&sys_info) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_info.nr_writeback <=3D
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (sys_inf=
o.background_thresh +
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_inf=
o.dirty_thresh) / 2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_inf=
o.dirty_thresh) / 2) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dirty_info_reclaimable(&memcg_inf=
o) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg_info.nr_writeback <=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (memcg_inf=
o.background_thresh +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg_i=
nfo.dirty_thresh) / 2))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi, sys_in=
fo.dirty_thresh);
>> + =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 min(sys_in=
fo.dirty_thresh,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 me=
mcg_info.dirty_thresh));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D task_dirty_limit(current,=
 bdi_thresh);
>
> Greg, so currently we seem to have per_bdi/per_task dirty limits and
> now with this patch it will sort of become per_cgroup/per_bdi/per_tas=
k
> dirty limits? I think that kind of makes sense to me.
>
> Thanks
> Vivek
>

Vivek,  you are correct.  This patch adds per_cgroup limits to the
existing system, bdi, and system dirty memory limits.

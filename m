From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v7 10/14] memcg: dirty page accounting support
 routines
Date: Mon, 16 May 2011 14:58:11 +0900
Message-ID: <20110516145811.405a6790.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
	<1305276473-14780-11-git-send-email-gthelen@google.com>
	<20110513185612.84b466ec.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin6_CiP-Q8MyN=PKhpUhGhdmUQyEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <BANLkTin6_CiP-Q8MyN=PKhpUhGhdmUQyEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Sun, 15 May 2011 12:56:00 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Fri, May 13, 2011 at 2:56 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 13 May 2011 01:47:49 -0700
> > Greg Thelen <gthelen@google.com> wrote:

> >> +static unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum m=
em_cgroup_page_stat_item item)
> >
> > How about mem_cgroup_file_cache_stat() ?
>=20
> The suggested rename is possible.  But for consistency I assume we
> would also want to rename:
> * mem_cgroup_local_page_stat()
> * enum mem_cgroup_page_stat_item
> * mem_cgroup_update_page_stat()
> * mem_cgroup_move_account_page_stat()
>=20

Yes, maybe clean up is necessary.

> I have a slight preference for leaving it as is,
> mem_cgroup_page_stat(), to allow for future coverage of pages other
> that just file cache pages.  But I do not feel very strongly.
>=20

ok, I'm not have big concern on naming for now. please do as you like.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

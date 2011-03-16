From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Date: Wed, 16 Mar 2011 22:52:14 +0100
Message-ID: <20110316215214.GO2140@cmpxchg.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org>
 <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com>
 <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com>
 <20110316131324.GM2140@cmpxchg.org>
 <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Greg Thelen <gthelen@google.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Wed, Mar 16, 2011 at 02:19:26PM -0700, Greg Thelen wrote:
> On Wed, Mar 16, 2011 at 6:13 AM, Johannes Weiner <hannes@cmpxchg.org>=
 wrote:
> > On Tue, Mar 15, 2011 at 02:48:39PM -0400, Vivek Goyal wrote:
> >> I think even for background we shall have to implement some kind o=
f logic
> >> where inodes are selected by traversing memcg->lru list so that fo=
r
> >> background write we don't end up writting too many inodes from oth=
er
> >> root group in an attempt to meet the low background ratio of memcg=
=2E
> >>
> >> So to me it boils down to coming up a new inode selection logic fo=
r
> >> memcg which can be used both for background as well as foreground
> >> writes. This will make sure we don't end up writting pages from th=
e
> >> inodes we don't want to.
> >
> > Originally for struct page_cgroup reduction, I had the idea of
> > introducing something like
> >
> > =A0 =A0 =A0 =A0struct memcg_mapping {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct address_space *mapping;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> > =A0 =A0 =A0 =A0};
> >
> > hanging off page->mapping to make memcg association no longer per-p=
age
> > and save the pc->memcg linkage (it's not completely per-inode eithe=
r,
> > multiple memcgs can still refer to a single inode).
> >
> > We could put these descriptors on a per-memcg list and write inodes
> > from this list during memcg-writeback.
> >
> > We would have the option of extending this structure to contain hin=
ts
> > as to which subrange of the inode is actually owned by the cgroup, =
to
> > further narrow writeback to the right pages - iff shared big files
> > become a problem.
> >
> > Does that sound feasible?
>=20
> If I understand your memcg_mapping proposal, then each inode could
> have a collection of memcg_mapping objects representing the set of
> memcg that were charged for caching pages of the inode's data.  When =
a
> new file page is charged to a memcg, then the inode's set of
> memcg_mapping would be scanned to determine if current's memcg is
> already in the memcg_mapping set.  If this is the first page for the
> memcg within the inode, then a new memcg_mapping would be allocated
> and attached to the inode.  The memcg_mapping may be reference counte=
d
> and would be deleted when the last inode page for a particular memcg
> is uncharged.

Dead-on.  Well, on which side you put the list - a per-memcg list of
inodes, or a per-inode list of memcgs - really depends on which way
you want to do the lookups.  But this is the idea, yes.

>   page->mapping =3D &memcg_mapping
>   inode->i_mapping =3D collection of memcg_mapping, grows/shrinks wit=
h [un]charge

If the memcg_mapping list (or hash-table for quick find-or-create?)
was to be on the inode side, I'd put it in struct address_space, since
this is all about page cache, not so much an fs thing.

Still, correct in general.
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Date: Wed, 16 Mar 2011 17:35:10 +0100
Message-ID: <20110316163510.GN2140@cmpxchg.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org>
 <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com>
 <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com>
 <20110316131324.GM2140@cmpxchg.org>
 <20110316145959.GA13562@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110316145959.GA13562@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Wed, Mar 16, 2011 at 10:59:59AM -0400, Vivek Goyal wrote:
> On Wed, Mar 16, 2011 at 02:13:24PM +0100, Johannes Weiner wrote:
> > On Tue, Mar 15, 2011 at 02:48:39PM -0400, Vivek Goyal wrote:
> > > On Mon, Mar 14, 2011 at 07:41:13PM -0700, Greg Thelen wrote:
> > > > On Mon, Mar 14, 2011 at 1:23 PM, Vivek Goyal <vgoyal@redhat.com=
> wrote:
> > > > > On Mon, Mar 14, 2011 at 11:29:17AM -0700, Greg Thelen wrote:
> > > > >
> > > > > [..]
> > > > >> > We could just crawl the memcg's page LRU and bring things =
under control
> > > > >> > that way, couldn't we? =A0That would fix it. =A0What were =
the reasons for
> > > > >> > not doing this?
> > > > >>
> > > > >> My rational for pursuing bdi writeback was I/O locality. =A0=
I have heard that
> > > > >> per-page I/O has bad locality. =A0Per inode bdi-style writeb=
ack should have better
> > > > >> locality.
> > > > >>
> > > > >> My hunch is the best solution is a hybrid which uses a) bdi =
writeback with a
> > > > >> target memcg filter and b) using the memcg lru as a fallback=
 to identify the bdi
> > > > >> that needed writeback. =A0I think the part a) memcg filterin=
g is likely something
> > > > >> like:
> > > > >> =A0http://marc.info/?l=3Dlinux-kernel&m=3D129910424431837
> > > > >>
> > > > >> The part b) bdi selection should not be too hard assuming th=
at page-to-mapping
> > > > >> locking is doable.
> > > > >
> > > > > Greg,
> > > > >
> > > > > IIUC, option b) seems to be going through pages of particular=
 memcg and
> > > > > mapping page to inode and start writeback on particular inode=
?
> > > >=20
> > > > Yes.
> > > >=20
> > > > > If yes, this might be reasonably good. In the case when cgrou=
ps are not
> > > > > sharing inodes then it automatically maps one inode to one cg=
roup and
> > > > > once cgroup is over limit, it starts writebacks of its own in=
ode.
> > > > >
> > > > > In case inode is shared, then we get the case of one cgroup w=
ritting
> > > > > back the pages of other cgroup. Well I guess that also can be=
 handeled
> > > > > by flusher thread where a bunch or group of pages can be comp=
ared with
> > > > > the cgroup passed in writeback structure. I guess that might =
hurt us
> > > > > more than benefit us.
> > > >=20
> > > > Agreed.  For now just writing the entire inode is probably fine=
=2E
> > > >=20
> > > > > IIUC how option b) works then we don't even need option a) wh=
ere an N level
> > > > > deep cache is maintained?
> > > >=20
> > > > Originally I was thinking that bdi-wide writeback with memcg fi=
lter
> > > > was a good idea.  But this may be unnecessarily complex.  Now I=
 am
> > > > agreeing with you that option (a) may not be needed.  Memcg cou=
ld
> > > > queue per-inode writeback using the memcg lru to locate inodes
> > > > (lru->page->inode) with something like this in
> > > > [mem_cgroup_]balance_dirty_pages():
> > > >=20
> > > >   while (memcg_usage() >=3D memcg_fg_limit) {
> > > >     inode =3D memcg_dirty_inode(cg);  /* scan lru for a dirty p=
age, then
> > > > grab mapping & inode */
> > > >     sync_inode(inode, &wbc);
> > > >   }
> > > >=20
> > > >   if (memcg_usage() >=3D memcg_bg_limit) {
> > > >     queue per-memcg bg flush work item
> > > >   }
> > >=20
> > > I think even for background we shall have to implement some kind =
of logic
> > > where inodes are selected by traversing memcg->lru list so that f=
or
> > > background write we don't end up writting too many inodes from ot=
her
> > > root group in an attempt to meet the low background ratio of memc=
g.
> > >=20
> > > So to me it boils down to coming up a new inode selection logic f=
or
> > > memcg which can be used both for background as well as foreground
> > > writes. This will make sure we don't end up writting pages from t=
he
> > > inodes we don't want to.
> >=20
> > Originally for struct page_cgroup reduction, I had the idea of
> > introducing something like
> >=20
> > 	struct memcg_mapping {
> > 		struct address_space *mapping;
> > 		struct mem_cgroup *memcg;
> > 	};
> >=20
> > hanging off page->mapping to make memcg association no longer per-p=
age
> > and save the pc->memcg linkage (it's not completely per-inode eithe=
r,
> > multiple memcgs can still refer to a single inode).
>=20
> So page->mapping will basically be a list where multiple memcg_mappin=
gs
> are hanging?

No, a single memcg_mapping per page.  A page can only be part of one
mapping, and only be part of one memcg at any point in time.

But not all pages backing an inode belong to the same memcg.  So the
two extremes are 1) every page associated individually with one memcg,
which is what we have now or 2) all pages in an inode collectively
associated with one memcg, which is not feasible.

The trade-off I propose is grouping all pages backing an inode that
are associated with the same memcg.  struct memcg_mapping would be the
representation of this group.

> That will essentially tell what memory cgroups own pages
> in this inode?

The idea is to have it efficiently the other way round: quickly find
all inodes referenced by one memcg.

> And similary every cgroup will have a list where these memcg_mapping
> are hanging allowing to trace which memcg is doing IO on which inodes=
?

Yes.

> > We could put these descriptors on a per-memcg list and write inodes
> > from this list during memcg-writeback.
> >=20
> > We would have the option of extending this structure to contain hin=
ts
> > as to which subrange of the inode is actually owned by the cgroup, =
to
> > further narrow writeback to the right pages - iff shared big files
> > become a problem.
> >=20
> > Does that sound feasible?
>=20
> May be. I am really not an expert in this area.
>=20
> IIUC, this sounds more like a solution to quickly come up with a list=
 of
> inodes one should be writting back. One could also come up with this =
kind of
> list by going through memcg->lru list also (approximate). So this can=
 be
> an improvement over going through memcg->lru instead go through
> memcg->mapping_list.

Well, if you operate on a large file it may make a difference between
taking five inodes off the list and crawling through hundreds of
thousands of pages to get to those same five inodes.

And having efficient inode lookup for a memcg makes targetted
background writeback more feasible: pass the memcg in the background
writeback work and have the flusher go through memcg->mappings,
selecting those that match the bdi.

Am I missing something?  I feel like I missed your point.
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

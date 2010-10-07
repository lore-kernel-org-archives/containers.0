From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Date: Thu, 7 Oct 2010 14:39:57 +0900
Message-ID: <20101007143957.e75127e6.kamezawa.hiroyu__21639.6308657297$1286430387$gmane$org@jp.fujitsu.com>
References: <20101006142314.GG4195@balbir.in.ibm.com>
	<20101007085858.0e07de59.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007031203.GK4195@balbir.in.ibm.com>
	<20101007121816.bbd009c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007035608.GN4195@balbir.in.ibm.com>
	<20101007132233.f695aa2c.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007053117.GQ4195@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101007053117.GQ4195-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 7 Oct 2010 11:01:17 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-10-07 13:22:33]:
> 
> > On Thu, 7 Oct 2010 09:26:08 +0530
> > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-10-07 12:18:16]:
> > > 
> > > > On Thu, 7 Oct 2010 08:42:04 +0530
> > > > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > > > 
> > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-10-07 08:58:58]:
> > > > > 
> > > > > > On Wed, 6 Oct 2010 19:53:14 +0530
> > > > > > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > > > > > 
> > > > > > > I propose restricting page_cgroup.flags to 16 bits. The patch for the
> > > > > > > same is below. Comments?
> > > > > > > 
> > > > > > > 
> > > > > > > Restrict the bits usage in page_cgroup.flags
> > > > > > > 
> > > > > > > From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > > > > > > 
> > > > > > > Restricting the flags helps control growth of the flags unbound.
> > > > > > > Restriciting it to 16 bits gives us the possibility of merging
> > > > > > > cgroup id with flags (atomicity permitting) and saving a whole
> > > > > > > long word in page_cgroup
> > > > > > > 
> > > > > > > Signed-off-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > > > > > 
> > > > > > Doesn't make sense until you show the usage of existing bits.
> > > > > 
> > > > > ??
> > > > > 
> > > > Limiting something for NOT EXISTING PATCH doesn't make sense, in general.
> > > > 
> > > > 
> > > > > > And I guess 16bit may be too large on 32bit systems.
> > > > > 
> > > > > too large on 32 bit systems? My intention is to keep the flags to 16
> > > > > bits and then use cgroup id for the rest and see if we can remove
> > > > > mem_cgroup pointer
> > > > > 
> > > > 
> > > > You can't use flags field to store mem_cgroup_id while we use lock bit on it.
> > > > We have to store something more stable...as pfn or node-id or zone-id.
> > > > 
> > > > It's very racy. 
> > > >
> > > 
> > > Yes, correct it is racy, there is no easy way from what I know we can write
> > > the upper 16 bits of the flag without affecting the lower 16 bits, if
> > > the 16 bits are changing. One of the techniques could be to have lock
> > > for the unsigned long word itself - but I don't know what performance
> > > overhead that would add. Having said that I would like to explore
> > > techniques that allow me to merge the two.
> > > 
> > 
> > to store pfn, we need to limit under 12bit.
> > I'll schedule my patch if dirty_ratio one goes.
> >
> 
> cool! We'll redo the patch then and lets make this work. We'll need to
> see how many bits we need for section/node/zone to do pc_to_pfn() and
> pfn_to_page().
> 

As far as I know now,

!CONFIG_HIGHMEM -> we can store pfn.
CONFIG_HIGHMEM && CONFIG_SPARSEMEM -> we can store section
CONFIG_HIGHMEM && !CONFIG_SPARSEMEM -> we can store node-id
CONFIG_HIGHMEM && CONFIG_SPARSEMEM_VMEMMAP -> there is no arch.

I think we can do.

-Kame

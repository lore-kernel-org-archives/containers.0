From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup
 aware
Date: Wed, 8 Jun 2011 09:18:15 +0900
Message-ID: <20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-12-git-send-email-gthelen@google.com>
	<20110607193835.GD26965@redhat.com>
	<xr93lixdv0df.fsf@gthelen.mtv.corp.google.com>
	<20110607210540.GB30919@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110607210540.GB30919@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Tue, 7 Jun 2011 17:05:40 -0400
Vivek Goyal <vgoyal@redhat.com> wrote:

> On Tue, Jun 07, 2011 at 01:43:08PM -0700, Greg Thelen wrote:
> > Vivek Goyal <vgoyal@redhat.com> writes:
> > 
> > > On Fri, Jun 03, 2011 at 09:12:17AM -0700, Greg Thelen wrote:
> > >> When the system is under background dirty memory threshold but a cgroup
> > >> is over its background dirty memory threshold, then only writeback
> > >> inodes associated with the over-limit cgroup(s).
> > >> 
> > >
> > > [..]
> > >> -static inline bool over_bground_thresh(void)
> > >> +static inline bool over_bground_thresh(struct bdi_writeback *wb,
> > >> +				       struct writeback_control *wbc)
> > >>  {
> > >>  	unsigned long background_thresh, dirty_thresh;
> > >>  
> > >>  	global_dirty_limits(&background_thresh, &dirty_thresh);
> > >>  
> > >> -	return (global_page_state(NR_FILE_DIRTY) +
> > >> -		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
> > >> +	if (global_page_state(NR_FILE_DIRTY) +
> > >> +	    global_page_state(NR_UNSTABLE_NFS) > background_thresh) {
> > >> +		wbc->for_cgroup = 0;
> > >> +		return true;
> > >> +	}
> > >> +
> > >> +	wbc->for_cgroup = 1;
> > >> +	wbc->shared_inodes = 1;
> > >> +	return mem_cgroups_over_bground_dirty_thresh();
> > >>  }
> > >
> > > Hi Greg,
> > >
> > > So all the logic of writeout from mem cgroup works only if system is
> > > below background limit. The moment we cross background limit, looks
> > > like we will fall back to existing way of writting inodes?
> > 
> > Correct.  If the system is over its background limit then the previous
> > cgroup-unaware background writeback occurs.  I think of the system
> > limits as those of the root cgroup.  If the system is over the global
> > limit than all cgroups are eligible for writeback.  In this situation
> > the current code does not distinguish between cgroups over or under
> > their dirty background limit.
> > 
> > Vivek Goyal <vgoyal@redhat.com> writes:
> > > If yes, then from design point of view it is little odd that as long
> > > as we are below background limit, we share the bdi between different
> > > cgroups. The moment we are above background limit, we fall back to
> > > algorithm of sharing the disk among individual inodes and forget
> > > about memory cgroups. Kind of awkward.
> > >
> > > This kind of cgroup writeback I think will atleast not solve the problem
> > > for CFQ IO controller, as we fall back to old ways of writting back inodes
> > > the moment we cross dirty ratio.
> > 
> > It might make more sense to reverse the order of the checks in the
> > proposed over_bground_thresh(): the new version would first check if any
> > memcg are over limit; assuming none are over limit, then check global
> > limits.  Assuming that the system is over its background limit and some
> > cgroups are also over their limits, then the over limit cgroups would
> > first be written possibly getting the system below its limit.  Does this
> > address your concern?
> 
> Do you treat root group also as any other cgroup? If no, then above logic
> can lead to issue of starvation of root group inode. Or unfair writeback.
> So I guess it will be important to treat root group same as other groups.
> 

As far as I can say, you should not place programs onto ROOT cgroups if you need
performance isolation. 

From the code, I think if the system hits dirty_ratio, "1" bit of bitmap should be
set and background writeback can work for ROOT cgroup seamlessly.

Thanks,
-Kame


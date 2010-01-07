From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v4 0/4] cgroups: support for module-loadable subsystems
Date: Thu, 7 Jan 2010 03:04:38 -0500
Message-ID: <20100107080438.GB16656@andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
	<20100106160414.bd555474.akpm@linux-foundation.org>
	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4B45824B.9030108@cn.fujitsu.com>
	<20100107161627.34b31e0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107074812.GA16656@andrew.cmu.edu>
	<20100107165117.dca1dc52.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100107165117.dca1dc52.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jan 07, 2010 at 04:51:17PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 7 Jan 2010 02:48:12 -0500
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> 
> > >  2. Making this to be reasonable value.
> > > #define CGROUP_SUBSYS_COUNT (BITS_PER_BYTE*sizeof(unsigned long))
> > >    I can't find why.
> > 
> > "We limit to this many since cgroupfs_root has subsys_bits to keep track
> > of all of them." should it be less, perhaps?
> 
> It's ok if it's clear that
> "this decistion is done by implementation choice, not by cgroup's nature"

mhm, well, it is the upper limit due to nature, but why it and not a
smaller number is by choice.

> 
> > the memory footprint is not
> > great, it is true, but implementing dynamically sized subsystem tracking
> > data structures requires much cleverer code in many places.
> > 
> yes. I don't request that.

it might be possible to have a config option as CGROUP_EXTRA_SUBSYSTEMS
(with max being 64 or 32) which would add slots for subsystems outside
of the kernel tree, to avoid using up a lot of blank slots in typical
use cases. not entirely sure how to implement it in the scope of the
configuration world, just speculation.

> > >  3. show whehter a subsys is a loadable module or not via /proc/cgroups
> > 
> > with just "y" or "n"? possible, and probably easy. do note that since
> > they are sorted by subsys_id, all the ones above a certain line will be
> > "n" and all below will be "y".
> > 
> yes. 
> 
> #subsys_name    hierarchy       num_cgroups     enabled  module
> cpuset  0       1       1	0
> 
> and 0/1 to show y/n ? (but this cause interface incompatibility...)

well, format should be agreed upon. 1/0 would be consistent with the
rest of the output.

> 
> 
> Thanks,
> -Kame
>    
> 
> 

From: Daniel Poelzleithner <poelzi-j3Gp85GwYS0dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/5] blk-throttle: writeback and swap IO control
Date: Wed, 23 Mar 2011 19:48:58 +0100
Message-ID: <20110323194858.34fca58d@sol>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<20110222193403.GG28269@redhat.com>
	<20110222224141.GA23723@linux.develer.com>
	<20110223000358.GM28269@redhat.com>
	<20110223083206.GA2174@linux.develer.com>
	<20110223152354.GA2526@redhat.com>
	<20110223231410.GB1744@linux.develer.com>
	<20110224001033.GF2526@redhat.com>
	<20110224094039.89c07bea.kamezawa.hiroyu@jp.fujitsu.com>
	<20110224161844.GD18494__23141.7772280567$1298564487$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110224161844.GD18494__23141.7772280567$1298564487$gmane$org-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 24 Feb 2011 11:18:44 -0500
Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> > I think swap I/O should be controlled by memcg's dirty_ratio.
> > But, IIRC, NEC guy had a requirement for this...
> > 
> > I think some enterprise cusotmer may want to throttle the whole
> > speed of swapout I/O (not swapin)...so, they may be glad if they
> > can limit throttle the I/O against a disk partition or all I/O
> > tagged as 'swapio' rather than some cgroup name.
> 
> If swap is on a separate disk, then one can control put write
> throttling rules on systemwide swapout. Though I still don't
> understand how that can help.

I have experimented a lot with cgroups to control bad situations like
swap of death, memleaks, etc.
I found that a system will not swap of death if I ensure that free mem
+ cache don't drop below 10% of system memory. Currently i cap the
  rss of a memory hogging process with cgroups which works quite well.
  The overall system performance is still not good as the swapping
  process heavily affects the io of the system. As currently swap io is
  not accounted through the blkio cgroup, other processes suffer
  greatly. I personally I don't care about throttling bandwidth, the
  weight factor seems much more sensible for swap. Through blkio.weight
  the effect of processes could be controlled more effectively. 


kind regards
 Daniel

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: optimization for iog deletion when
	elevator exiting
Date: Tue, 30 Jun 2009 21:34:25 -0400
Message-ID: <20090701013425.GC13958__45181.7392641262$1246412218$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-6-git-send-email-vgoyal@redhat.com>
	<4A4850D3.3000700@cn.fujitsu.com>
	<20090629140631.GA4622@redhat.com>
	<e98e18940906301014n146e7146vb5a73c2f33c9e819@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940906301014n146e7146vb5a73c2f33c9e819-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 30, 2009 at 10:14:48AM -0700, Nauman Rafique wrote:
> On Mon, Jun 29, 2009 at 7:06 AM, Vivek Goyal<vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Mon, Jun 29, 2009 at 01:27:47PM +0800, Gui Jianfeng wrote:
> >> Hi Vivek,
> >>
> >> There's no need to travel the iocg->group_data for each iog
> >> when exiting a elevator, that costs too much. An alternative
> >> solution is reseting iocg_id as soon as an io group unlinking
> >> from a iocg. Make a decision that whether it's need to carry
> >> out deleting action by checking iocg_id.
> >>
> >
> > Thanks Gui. This makes sense to me. We can check iog->iocg_id to determine
> > wheter group is still on iocg list or not instead of traversing the list.
> >
> > Nauman, do you see any issues with the patch?
> 
> Looks like this should work. The only iog with zero id is associated
> with root group, which gets deleted outside of this function anyways.
> 

Minor correction. Even root group has id "1" and not zero. 0 is associated
with error when cgroup is not present.

Thanks
Vivek

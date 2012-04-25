From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Wed, 25 Apr 2012 10:42:43 +0800
Message-ID: <20120425024243.GA6572__5227.34043556756$1335321809$gmane$org@localhost>
References: <20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
	<20120411192231.GF16008@quack.suse.cz>
	<20120412203719.GL2207@redhat.com>
	<20120412205148.GA24056@google.com>
	<20120414143639.GA31241@localhost>
	<20120416145744.GA15437@redhat.com>
	<20120424113340.GA12509@localhost>
	<20120424145655.GA1474@quack.suse.cz>
	<20120424155843.GG26708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120424155843.GG26708-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 24, 2012 at 11:58:43AM -0400, Vivek Goyal wrote:
> On Tue, Apr 24, 2012 at 04:56:55PM +0200, Jan Kara wrote:
> 
> [..]
> > > > I think having separate weigths for sync IO groups and async IO is not
> > > > very appealing. There should be one notion of group weight and bandwidth
> > > > distrubuted among groups according to their weight.
> > > 
> > > There have to be some scheme, either explicitly or implicitly. Maybe
> > > you are baring in mind some "equal split among queues" policy? For
> > > example, if the cgroup has 9 active sync queues and 1 async queue,
> > > split the weight equally to the 10 queues?  So the sync IOs get 90%
> > > share, and the async writes get 10% share.
> >   Maybe I misunderstand but there doesn't have to be (and in fact isn't)
> > any split among sync / async IO in CFQ. At each moment, we choose a queue
> > with the highest score and dispatch a couple of requests from it. Then we
> > go and choose again. The score of the queue depends on several factors
> > (like age of requests, whether the queue is sync or async, IO priority,
> > etc.).
> > 
> > Practically, over a longer period system will stabilize on some ratio
> > but that's dependent on the load so your system should not impose some
> > artificial direct/buffered split but rather somehow deal with the reality
> > how IO scheduler decides to dispatch requests...
> 
> Yes. CFQ does not have the notion of giving a fixed share to async
> requests. In fact right now it is so biased in favor of sync reqeusts,
> that in some cases it can starve async writes or introduce long delays
> resulting in "task hung for 120 second" warnings.
> 
> So if there are issues w.r.t how disk is shared between sync/async IO
> with in a cgroup, that should be handled at IO scheduler level. Writeback
> code trying to dictate that ratio, sounds odd.

Indeed it sounds odd.. However it does look that there need some
sync/async ratio to avoid livelock issues, say 80:20 or whatever.
What's you original plan to deal with this in the IO scheduler?

> > > For dirty throttling w/o cgroup awareness, balance_dirty_pages()
> > > splits the writeout bandwidth equally among all dirtier tasks. Since
> > > cfq works with queues, it seems most natural for it to do equal split
> > > among all queues (inside the cgroup).
> >   Well, but we also have IO priorities which change which queue should get
> > preference.
> > 
> > > I'm not sure when there are N dd tasks doing direct IO, cfq will
> > > continuously run N sync queues for them (without many dynamic queue
> > > deletion and recreations). If that is the case, it should be trivial
> > > to support the queue based fair split in the global async queue
> > > scheme. Otherwise I'll have some trouble detecting the N value when
> > > trying to do the N:1 sync:async weight split.
> >   And also sync queues for several processes can get merged when CFQ
> > observes these processes cooperate together on one area of disk and get
> > split again when processes stop cooperating. I don't think you really want
> > to second-guess what CFQ does inside...
> 
> Agreed. Trying to predict what CFQ will do and then trying to influence
> sync/async ration based on root cgroup weight does not seem to be the
> right way. Especially that will also mean either assuming that everything
> in root group is sync or we shall have to split sync/async weight notion.

It seems there is some misunderstanding to the sync/async split.
No, root cgroup tasks won't be any special wrt the weight split.
Although in the current patch I does make assumption that no IO
is happening in the root cgroup.

To make it look easier, we may as well move the flusher thread to a
standalone cgroup. Then if the root cgroup has both aggressive
sync/async IOs, the split will be carried out the same way as other
cgroups:

        rootcg->dio_weight = rootcg->weight / 2
        flushercg->async_weight += rootcg->weight / 2

> sync/async ratio is a IO scheduler thing and is not fixed. So writeback
> layer making assumptions and changing weigths sounds very awkward to me.

OK the ratio is not fixed, so I'm not going to do the guess work.
However there is still the question: how are we going to fix the
sync-starve-async IO problem without some guaranteed ratio?

Thanks,
Fengguang

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Mon, 16 Apr 2012 10:57:45 -0400
Message-ID: <20120416145744.GA15437__11884.8759601407$1334588290$gmane$org@redhat.com>
References: <20120407080027.GA2584@quack.suse.cz>
	<20120410180653.GJ21801@redhat.com>
	<20120410210505.GE4936@quack.suse.cz>
	<20120410212041.GP21801@redhat.com>
	<20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
	<20120411192231.GF16008@quack.suse.cz>
	<20120412203719.GL2207@redhat.com>
	<20120412205148.GA24056@google.com>
	<20120414143639.GA31241@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120414143639.GA31241@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Apr 14, 2012 at 10:36:39PM +0800, Fengguang Wu wrote:

[..]
> Yeah the backpressure idea would work nicely with all possible
> intermediate stacking between the bdi and leaf devices. In my attempt
> to do combined IO bandwidth control for
> 
> - buffered writes, in balance_dirty_pages()
> - direct IO, in the cfq IO scheduler
> 
> I have to look into the cfq code in the past days to get an idea how
> the two throttling layers can cooperate (and suffer from the pains
> arise from the violations of layers). It's also rather tricky to get
> two previously independent throttling mechanisms to work seamlessly
> with each other for providing the desired _unified_ user interface. It
> took a lot of reasoning and experiments to work the basic scheme out...
> 
> But here is the first result. The attached graph shows progress of 4
> tasks:
> - cgroup A: 1 direct dd + 1 buffered dd
> - cgroup B: 1 direct dd + 1 buffered dd
> 
> The 4 tasks are mostly progressing at the same pace. The top 2
> smoother lines are for the buffered dirtiers. The bottom 2 lines are
> for the direct writers. As you may notice, the two direct writers are
> somehow stalled for 1-2 times, which increases the gaps between the
> lines. Otherwise, the algorithm is working as expected to distribute
> the bandwidth to each task.
> 
> The current code's target is to satisfy the more realistic user demand
> of distributing bandwidth equally to each cgroup, and inside each
> cgroup, distribute bandwidth equally to buffered/direct writes. On top
> of which, weights can be specified to change the default distribution.
> 
> The implementation involves adding "weight for direct IO" to the cfq
> groups and "weight for buffered writes" to the root cgroup. Note that
> current cfq proportional IO conroller does not offer explicit control
> over the direct:buffered ratio.
> 
> When there are both direct/buffered writers in the cgroup,
> balance_dirty_pages() will kick in and adjust the weights for cfq to
> execute. Note that cfq will continue to send all flusher IOs to the
> root cgroup.  balance_dirty_pages() will compute the overall async
> weight for it so that in the above test case, the computed weights
> will be

I think having separate weigths for sync IO groups and async IO is not
very appealing. There should be one notion of group weight and bandwidth
distrubuted among groups according to their weight.

Now one can argue that with-in a group, there might be one knob in CFQ
which allows to change the share or sync/async IO.

Also Tejun and Jan have expressed the desire that once we have figured
out a way to communicate the submitter's context for async IO, we would
like to account that IO in associated cgroup instead of root cgroup (as
we do today).

> 
> - 1000 async weight for the root cgroup (2 buffered dds)
> - 500 dio weight for cgroup A (1 direct dd)
> - 500 dio weight for cgroup B (1 direct dd)
> 
> The second graph shows result for another test case:
> - cgroup A, weight 300: 1 buffered cp
> - cgroup B, weight 600: 1 buffered dd + 1 direct dd
> - cgroup C, weight 300: 1 direct dd
> which is also working as expected.
> 
> Once the cfq properly grants total async IO share to the flusher,
> balance_dirty_pages() will then do its original job of distributing
> the buffered write bandwidth among the buffered dd tasks.
> 
> It will have to assume that the devices under the same bdi are
> "symmetry". It also needs further stats feedback on IOPS or disk time
> in order to do IOPS/time based IO distribution. Anyway it would be
> interesting to see how far this scheme can go. I'll cleanup the code
> and post it soon.

Your proposal relies on few things.

- Bandwidth needs to be divided eually among sync and async IO.
- Flusher thread async IO will always to go to root cgroup.
- I am not sure how this scheme is going to work when we introduce
  hierarchical blkio cgroups.
- cgroup weights for sync IO seems to be being controlled by user and
  somehow root cgroup weight seems to be controlled by this async IO
  logic silently.

Overall sounds very odd design to me. I am not sure what are we achieving
by this. In current scheme one should be able to just adjust the weight
of root cgroup using cgroup interface and achieve same results which you
are showing. So where is the need of dynamically changing it inside
kernel.

Thanks
Vivek

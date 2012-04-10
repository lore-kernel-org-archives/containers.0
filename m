From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Tue, 10 Apr 2012 14:06:53 -0400
Message-ID: <20120410180653.GJ21801__20035.3403612555$1334081239$gmane$org@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120407080027.GA2584-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Apr 07, 2012 at 10:00:27AM +0200, Jan Kara wrote:
Hi Jan,

[..]
> > In general, the core of the issue is that filesystems are not cgroup aware
> > and if you do throttling below filesystems, then invariably one or other
> > serialization issue will come up and I am concerned that we will be constantly
> > fixing those serialization issues. Or the desgin point could be so central
> > to filesystem design that it can't be changed.
>   We talked about this at LSF and Dave Chinner had the idea that we could
> make processes wait at the time when a transaction is started. At that time
> we don't hold any global locks so process can be throttled without
> serializing other processes. This effectively builds some cgroup awareness
> into filesystems but pretty simple one so it should be doable.

Ok. So what is the meaning of "make process wait" here? What it will be
dependent on? I am thinking of a case where a process has 100MB of dirty
data, has 10MB/s write limit and it issues fsync. So before that process
is able to open a transaction, one needs to wait atleast 10seconds
(assuming other processes are not doing IO in same cgroup). 

If this wait is based on making sure all dirty data has been written back
before opening transaction, then it will work without any interaction with
block layer and sounds more feasible.

> 
> > In general, if you do throttling deeper in the stakc and build back
> > pressure, then all the layers sitting above should be cgroup aware
> > to avoid problems. Two layers identified so far are writeback and
> > filesystems. Is it really worth the complexity. How about doing 
> > throttling in higher layers when IO is entering the kernel and
> > keep proportional IO logic at the lowest level and current mechanism
> > of building pressure continues to work?
>   I would like to keep single throttling mechanism for different limitting
> methods - i.e. handle proportional IO the same way as IO hard limits. So we
> cannot really rely on the fact that throttling is work preserving.
> 
> The advantage of throttling at IO layer is that we can keep all the details
> inside it and only export pretty minimal information (like is bdi congested
> for given cgroup) to upper layers. If we wanted to do throttling at upper
> layers (such as Fengguang's buffered write throttling), we need to export
> the internal details to allow effective throttling...

For absolute throttling we really don't have to expose any details. In
fact in my implementation of throttling buffered writes, I just had exported
a single function to be called in bdi dirty rate limit. The caller will
simply sleep long enough depending on the size of IO it is doing and
how many other processes are doing IO in same cgroup.

So implementation was still in block layer and only a single function
was exposed to higher layers.

One more factor makes absolute throttling interesting and that is global
throttling and not per device throttling. For example in case of btrfs,
there is no single stacked device on which to put total throttling
limits.

So if filesystems can handle serialization issue, then back pressure
method looks more clean (thought complex).

Thanks
Vivek

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Fri, 5 Sep 2008 11:38:32 -0400
Message-ID: <20080905153832.GE13742__38759.5319924459$1220630562$gmane$org@redhat.com>
References: <20080822185527.GD27964@redhat.com>
	<1219660569.16371.161.camel@sebastian.kern.oss.ntt.co.jp>
	<20080905.205016.28412219.taka@valinux.co.jp>
	<20080905.210017.44596963.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080905.210017.44596963.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Sep 05, 2008 at 09:00:17PM +0900, Hirokazu Takahashi wrote:
> Hi, fernando,
> 
> > > IMHO, optimizing the synchronous path alone would justify the addition
> > > of io_context in bio. There is more to this though.
> > > 
> > > As you point out, it would seem that aio and buffered IO would not
> > > benefit from caching the io context in the bio itself, but there are
> > > some subtleties here. Let's consider stacking devices and buffered IO,
> > > for example. When a bio enters such a device it may get replicated
> > > several times and, depending on the topology, some other derivative bios
> > > will be created (RAID1 and parity configurations come to mind,
> > > respectively). The problem here is that the memory allocated for the
> > > newly created bios will be owned by the corresponding dm or md kernel
> > > thread, not the originator of the bio we are replicating or calculating
> > > the parity bits from.
> > 
> > I've already tried implementing this feature. Will you take a look
> > at the thread whose subject is "I/O context inheritance" in
> > http://www.uwsg.iu.edu/hypermail/linux/kernel/0804.2/index.html#2857.
> 
> When I started to implement this, I would make each bio have two
> io_contexts -- per-process io_context which had ionice and
> and per-cgroup io_context.
> 

Hi Hirokazu,

I had a question. Why are we trying to create another io_context or why
are we trying to mix up existing io_context (which is per task or per
thread group) with cgroups?

To me we just need to know the "cgroup id" to take a specific action with
a bio. We don't need whole io_context strucutre. So can't we just use
something like, page->page_cgroup->bio_cgroup->cgrou_id or something like
that.

What I mean is that the only thing which we seem to require to differentiate
between various bio is cgroup id it belongs to and that can be a single
"unsigned long" stored at appropriate place. Why are we looking at
creating a full io_context structure and trying to share it among all the
members of a cgroup?

Thanks
Vivek

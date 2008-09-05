From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Fri, 05 Sep 2008 20:50:16 +0900 (JST)
Message-ID: <20080905.205016.28412219.taka@valinux.co.jp>
References: <1219296306.28324.82.camel@sebastian.kern.oss.ntt.co.jp>
	<20080822185527.GD27964@redhat.com>
	<1219660569.16371.161.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219660569.16371.161.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, fernando,

> > > > > As an aside, when the IO context of a certain IO operation is known
> > > > > (synchronous IO comes to mind) I think it should be cashed in the
> > > > > resulting bio so that we can do without the expensive accesses to
> > > > > bio_cgroup once it enters the block layer.
> > > > 
> > > > Will this give you everything you need for accounting and control (from the
> > > > block layer?)
> > > 
> > > Well, it depends on what you are trying to achieve.
> > > 
> > > Current IO schedulers such as CFQ only care about the io_context when
> > > scheduling requests. When a new request comes in CFQ assumes that it was
> > > originated in the context of the current task, which obviously does not
> > > hold true for buffered IO and aio. This problem could be solved by using
> > > bio-cgroup for IO tracking, but accessing the io context information is
> > > somewhat expensive: 
> > > 
> > > page->page_cgroup->bio_cgroup->io_context.
> > > 
> > > If at the time of building a bio we know its io context (i.e. the
> > > context of the task or cgroup that generated that bio) I think we should
> > > store it in the bio itself, too. With this scheme, whenever the kernel
> > > needs to know the io_context of a particular block IO operation the
> > > kernel would first try to retrieve its io_context directly from the bio,
> > > and, if not available there, would resort to the slow path (accessing it
> > > through bio_cgroup). My gut feeling is that elevator-based IO resource
> > > controllers would benefit from such an approach, too.
> > > 
> > 
> > Hi Fernando,
> > 
> > Had a question.
> > 
> > IIUC, at the time of submtting the bio, io_context will be known only for 
> > synchronous request. For asynchronous request it will not be known
> > (ex. writing the dirty pages back to disk) and one shall have to take
> > the longer path (bio-cgroup thing) to ascertain the io_context associated
> > with a request.
> > 
> > If that's the case, than it looks like we shall have to always traverse the
> > longer path in case of asynchronous IO. By putting the io_context pointer
> > in bio, we will just shift the time of pointer traversal. (From CFQ to higher
> > layers).
> > 
> > So probably it is not worth while to put io_context pointer in bio? Am I
> > missing something?
> 
> Hi Vivek!
> 
> IMHO, optimizing the synchronous path alone would justify the addition
> of io_context in bio. There is more to this though.
> 
> As you point out, it would seem that aio and buffered IO would not
> benefit from caching the io context in the bio itself, but there are
> some subtleties here. Let's consider stacking devices and buffered IO,
> for example. When a bio enters such a device it may get replicated
> several times and, depending on the topology, some other derivative bios
> will be created (RAID1 and parity configurations come to mind,
> respectively). The problem here is that the memory allocated for the
> newly created bios will be owned by the corresponding dm or md kernel
> thread, not the originator of the bio we are replicating or calculating
> the parity bits from.

I've already tried implementing this feature. Will you take a look
at the thread whose subject is "I/O context inheritance" in
http://www.uwsg.iu.edu/hypermail/linux/kernel/0804.2/index.html#2857.

This code is not merged with bio-cgroup yet but I believe some of the code
will help you implement what you want.

Through this work, I realized that if you want introduce
per-device-io_context -- each cgroup can have several io_contexts
for several devices -- it is unable to determine which io_context
should be used when read or write I/O is requested because the device
is determined right before the request is passed to the block I/O layer.

I mean a bio is allocated in the VFS while the device which handles
the I/O request is determined in one of the underlying filesystems.

> The implication of this is that if we took the longer path (via
> bio_cgroup) to obtain the io_context of those bios we would end up
> charging the wrong guy for that IO: the kernel thread, not the
> perpetrator of the IO.
> 
> A possible solution to this could be to track the original bio inside
> the stacking device so that the io context of derivative bios can be
> obtained from its bio_cgroup. However, I am afraid such an approach
> would be overly complex and slow.
> 
> My feeling is that storing the io_context also in bios is the right way
> to go: once the bio enters the block layer the kernel we can forget
> about memory-related issues, thus avoiding what is arguably a layering
> violation; io context information is not lost inside stacking devices
> (we just need to make sure that whenever new bios are created the
> io_context is carried over from the original one); and, finally, the
> synchronous path can be easily optimized.
> 
> I hope this makes sense.
> 
> Thank you for your comments.
> 
> - Fernando

Thank you,
Hirokazu Takahashi.

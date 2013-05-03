From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Fri, 3 May 2013 15:26:56 -0400
Message-ID: <20130503192656.GD6062@redhat.com>
References: <20130502184514.GI30020@redhat.com>
	<20130502184953.GP19814@mtj.dyndns.org>
	<20130502190732.GK30020@redhat.com>
	<CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw@mail.gmail.com>
	<20130502193139.GL30020@redhat.com>
	<20130502231307.GT19814@mtj.dyndns.org>
	<20130503175652.GB6062@redhat.com>
	<20130503185751.GA22860@mtj.dyndns.org>
	<20130503190823.GC6062@redhat.com>
	<20130503191418.GC22860@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130503191418.GC22860-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 03, 2013 at 12:14:18PM -0700, Tejun Heo wrote:
> On Fri, May 03, 2013 at 03:08:23PM -0400, Vivek Goyal wrote:
> > 		T1	T2	T3	T4	T5	T6	T7
> > parent:			b1	b2	b3		b4 	b5
> > child: 		b1	b2	b3		b4	b5	
> > 
> > 
> > So continuity breaks down because application is waiting for previous
> > IO to finish. This forces expiry of existing time slices and new time
> > slice start both in child and parent and penalty keep on increasing.
> 
> It's a problem even in flat mode as the "child" above can easily be
> just a process which is throttling itself and it won't be able to get
> the configured bandwidth due to the scheduling bubbles introduced
> whenever new slice is started.  Shouldn't be too difficult to get rid
> of, right?

Key thing here is when to start a new slice. Generally when an IO has been
dispatched from a group, we do not expire slice immediately. We kind of
give group some grace period of throtl_slice (100ms). If next IO does not
come with-in that duration, we start a fresh slice upon next IO arrival.

I think similar problem should happen if there are two stacked devices
and both are doing throttling and if delays between 2 IOs are big enough
that it forces expirty of slice on each device.

Atleast for the hiearchy case, we should be able to start a fresh time
slice when child transfer bio to parent. I will write a patch and do
some experiment.

Thanks
Vivek

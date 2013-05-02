From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Thu, 2 May 2013 15:31:39 -0400
Message-ID: <20130502193139.GL30020__13311.438173014$1367523120$gmane$org@redhat.com>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
	<20130502173428.GA4771@redhat.com>
	<20130502175701.GL19814@mtj.dyndns.org>
	<20130502181747.GH30020@redhat.com>
	<20130502182933.GN19814@mtj.dyndns.org>
	<20130502184514.GI30020@redhat.com>
	<20130502184953.GP19814@mtj.dyndns.org>
	<20130502190732.GK30020@redhat.com>
	<CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Thu, May 02, 2013 at 12:11:30PM -0700, Tejun Heo wrote:
> Hey,
> 
> 
> On Thu, May 2, 2013 at 12:07 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > It should not. Why do you think in flat model an application which
> > throttles itself will be penalized.
> >
> > So application issue an bio of size 1MB in a group of rate 1MB/s. bio
> > gets queued and gets dispatched after 1 second. Almost immediately next
> > bio will come from application (as application also is throttling
> > itself at 1MB/s rate). And then this bio waits for a second. So we
> > almost get steady rate of 1MB/s as configured.
> 
> I'm confused now, so why does the hierarchy make any difference? When
> seen from the parent, what's the difference between a process issuing
> IO directly and an IO which already went through another throttle
> layer if the IOs arrive at the same intervals?

I think my example was little flawed previously. I think you are right.
Penalty is not probably as bad as I have been thinking.

So if both parent and child have limit of 1MB/s and application is doing
IO (say at 2MB/sec), in long term it should still see 1MB/s rate.

		T1	T2	T3	T4	T5	T6
Parent group:		B1	B2	B3	B4	B5
Child group:	B1	B2	B3	B4	B5	B6 

Above B1 to B6 are bios of 1MB size. T1 to T6 are 1 second time interval.
B1 waits for T1 interval in child group and then for T2 interval in
parent group and then gets dispatched. But a pipe line has formed in
child group and B2 is waiting in child group in T2 slice. So penalty
is not double.

So each group migration will add one extra wait period. In above case
5 bios dispatched in 6 seconds. Longer the sampling interval, delay
remains the constant to one time interval and % penalty goes down.

Thanks
Vivek

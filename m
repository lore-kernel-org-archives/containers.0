From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Fri, 3 May 2013 15:08:23 -0400
Message-ID: <20130503190823.GC6062__45833.0612317242$1367608127$gmane$org@redhat.com>
References: <20130502181747.GH30020@redhat.com>
	<20130502182933.GN19814@mtj.dyndns.org>
	<20130502184514.GI30020@redhat.com>
	<20130502184953.GP19814@mtj.dyndns.org>
	<20130502190732.GK30020@redhat.com>
	<CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw@mail.gmail.com>
	<20130502193139.GL30020@redhat.com>
	<20130502231307.GT19814@mtj.dyndns.org>
	<20130503175652.GB6062@redhat.com>
	<20130503185751.GA22860@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130503185751.GA22860-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

On Fri, May 03, 2013 at 11:57:51AM -0700, Tejun Heo wrote:

[..]
> > # set limit to 1000000 bytes/second both in parent and child cgroup
> > # dd if=/dev/vdb of=/dev/null iflag=direct
> > 
> > I will capture blktrace and analyze it though to understand better
> > what's happening.
> 
> Try using larger block size.  It looks like dispatch windows being
> reset depending on timing is hurting the overall bandwidth.  It
> becomes pronounced with larger IOs.

Ok, I tried dd with block size 1M and I can now see it happening.

dd if=/dev/vdb of=/dev/null bs=1M iflag=direct

dd program sends down 2-3 bios of 512K each. And then it is waiting
for all the bios to finish before it issues more IO.

So if three bios b1, b2, and b3 have been sent down, b4 does not
get issued till b3 has finished. Hence following happens.

		T1	T2	T3	T4	T5	T6	T7
parent:			b1	b2	b3		b4 	b5
child: 		b1	b2	b3		b4	b5	


So continuity breaks down because application is waiting for previous
IO to finish. This forces expiry of existing time slices and new time
slice start both in child and parent and penalty keep on increasing.

Thanks
Vivek

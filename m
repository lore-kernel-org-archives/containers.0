From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Thu, 20 Nov 2008 18:20:53 +0900 (JST)
Message-ID: <20081120.182053.220301508585579959.ryov__5266.39722888849$1227172974$gmane$org@valinux.co.jp>
References: <20081113.180558.519459540419535699.ryov@valinux.co.jp>
	<20081113155834.GE7542@redhat.com>
	<20081113221304.GH7542@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081113221304.GH7542-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

Sorry for late reply.

> > > Do you have any benchmark results?
> > > I'm especially interested in the followings:
> > > - Comparison of disk performance with and without the I/O controller patch.
> > 
> > If I dynamically disable the bio control, then I did not observe any
> > impact on performance. Because in that case practically it boils down
> > to just an additional variable check in __make_request().
> > 
> 
> Oh.., I understood your question wrong. You are looking for what's the 
> performance penalty if I enable the IO controller on a device.

Yes, that is what I want to know.

> I have not done any extensive benchmarking. If I run two dd commands
> without controller, I get 80MB/s from disk (roughly 40 MB for each task).
> With bio group enabled (default token=2000), I was getting total BW of
> roughly 68 MB/s.
>
> I have not done any performance analysis or optimizations at this point of
> time. I plan to do that once we have some sort of common understanding about
> a particular approach. There are so many IO controllers floating, right now
> I am more concerned if we can all come to a common platform.

I understood the reason of posting the patch well.

> Ryo, do you still want to stick to two level scheduling? Given the problem
> of it breaking down underlying scheduler's assumptions, probably it makes
> more sense to the IO control at each individual IO scheduler.

I don't want to stick to it. I'm considering implementing dm-ioband's
algorithm into the block I/O layer experimentally.

Thanks,
Ryo Tsuruta

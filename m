From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] cgroup: don't show pid list on tasks/procs in ascending
	order
Date: Tue, 15 Jan 2013 08:17:02 -0800
Message-ID: <20130115161702.GA2668__24148.0492325083$1358266649$gmane$org@htj.dyndns.org>
References: <50F4E902.20202@oracle.com> <20130115062507.GA21358@sergelap>
	<50F4F76D.2050409@oracle.com> <20130115063412.GA25338@sergelap>
	<50F4FD99.7070406@oracle.com> <20130115140811.GA4082@sergelap>
	<20130115154332.GA2598@htj.dyndns.org>
	<20130115161420.GA6885@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130115161420.GA6885-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Serge.

On Tue, Jan 15, 2013 at 04:14:20PM +0000, Serge E. Hallyn wrote:
> Seriously, once we switch over to using a library anyway, it makes sense.
> Now I do see that removing the sorting would help move people over to
> using a library...  is there a separate place where the library is being
> discussed/designed?  Requirements being gathered?

It's still just a pipe dream of mine.  I have some requirements on
mind but don't yet have any concrete plan on how to actually do it.
For me, it's queued after unified hierarchy support in kernel, which I
think we're progressing towards better than I originally expected.  If
anyone is intereted in jumping in, please be my guest.

Thanks.

-- 
tejun

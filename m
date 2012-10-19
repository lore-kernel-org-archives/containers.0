From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cgroup_freezer: allow migration
	regardless of freezer state and update locking
Date: Thu, 18 Oct 2012 17:01:53 -0700
Message-ID: <20121019000153.GZ13370__6166.57084688104$1350604932$gmane$org@google.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<20121017191606.GA6223@us.ibm.com>
	<20121018211434.GI13370@google.com>
	<20121018222155.GB6223@us.ibm.com>
	<20121018223517.GQ13370@google.com>
	<20121018234726.GC6223@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121018234726.GC6223-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Matt.

On Thu, Oct 18, 2012 at 04:47:26PM -0700, Matt Helsley wrote:
> > I think the only sane way would be having a userland arbitrator which
> > owns the kernel interface to itself and makes policy decisions from
> > userland clients and configures cgroup accordingly.
> 
> OK -- yeah, solving the arbitration issue in userspace might be best.

Yeah, I think we need that but there currently isn't any concrete (or
even floppy) plan for it.  If anyone is interested, beer is on me. :)

> > I think that should be solved via userland policies rather than
> > depending on this accidental cgroup_freezer feature.
> 
> It's not accidental -- it *was an intended feature*:
> 
>   22 # This bash script tests freezer code by starting a long sleep process.
>   23 # The sleep process is frozen. We then move the sleep process to a THAWED
>   24 # cgroup. We expect moving the sleep process to fail.
> 
> ( This atrocious link is the easiest way to see the testcase:
> http://ltp.git.sourceforge.net/git/gitweb.cgi?p=ltp/ltp.git;a=blob;f=testcases/kernel/controllers/freezer/freeze_move_thaw.sh;h=b2d5a83506a8425b117be9ff775d9f73d2d58393;hb=0436176dbfe6fdaaf97590d2356eb23d2739b2c2
> )
> 
> It was intended for something very much like the CRIU case I mentioned
> :).

I probably have chosen the wrong word.  I mean that it's a hierarchy
management feature implemented at the wrong layer.  If we want to
provide cgroup migration locking, it should be implemented at the
cgroup core layer as a controller independent feature.  It's kinda
interesting the incorrect layering here almost directly caused messy
locking problem too.  I hope we don't need it with (the imaginary)
proper userland arbitration but even if we do implementing it in
cgroup proper as a separate feature would be a lot less messy.

Thanks.

-- 
tejun

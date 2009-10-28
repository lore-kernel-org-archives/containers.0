From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: kernel based checkpoint/restart: about X windows application
	checkpoint and restart support.
Date: Wed, 28 Oct 2009 01:47:17 -0700
Message-ID: <20091028084717.GO31446@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Will Huang <will.huang-lvxLlxTUKJQIhP1ydL5T/A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Oct 28, 2009 at 10:51:32AM +0800, Will Huang wrote:
> Dear All,
> 
>          Did the Kernel based checkpoint/restart patch support X windows
> application such as firefox?

No, and I think it may be a long time before that happens.

(Disclaimer: I haven't even tried to see what part of checkpointing
X breaks first. I suspect it'd be the open device files...)

The display and input device hardware presents a serious challenge for 
one thing. They may not be available during restart if it occurs
on a different machine -- or they may be entirely different hardware. 

Perhaps checkpoint/restart of programs with these devices open should
"simulate" hot-[un]plug. Checkpoint could save enough information to make
the kernel generate the necessary uevents. At restart the file
descriptors for those devices are never opened and syscalls on them will
return errno==EBADF. Next we'd need to send uevents for the
"new-but-not-new" devices. There's a "new-but-not-new" uevent pathway in
the kernel used during boot -- perhaps there's some way to reuse that.
Lastly, we send the unplug uevents to get X to drop its use of the old
devices -- send those last so X always thinks there's hardware.

That's one way it _could_ be done. Others might rely on device
"virtualization" -- writing pseudo-device code (CUSE?).

X also has its own session support. As far as I know how that could
work with kernel-based checkpoint/restart hasn't been discussed yet.

Of course this is all off the top of my head. Others are welcome to
make considerate use of cluebats to inform me of any misconceptions I
may have.

Cheers,
	-Matt Helsley

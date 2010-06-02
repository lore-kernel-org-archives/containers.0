From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: USB Write Checkpoint
Date: Wed, 2 Jun 2010 08:22:57 -0500
Message-ID: <20100602132257.GA19349@hallyn.com>
References: <AANLkTikYoK7EIJ4AoAT83qDujVFeDhPoo08GbzEF07b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikYoK7EIJ4AoAT83qDujVFeDhPoo08GbzEF07b6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ganzoo Awaasuren <ganaa.8.91-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Ganzoo Awaasuren (ganaa.8.91-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Dear All
> 
> Now I am changing and developing some kernel stuffs which is related to
> Linux FileSystems.
> 
> My work is just to find the solution for the inconvinence use of the USB
> disk. We have to click "safe remove" button for flush the buffer data to
> disk before the plug off the USB disk .

...

> As far as i understand from your developed checkpoint technique on linux
> kernel , probably i can get it and apply it for my purpose. So is it
> possible to call that sys_checkpoint function in kernel's sys_write system
> call ? if it is possible then , is this checkpointed image will include that
> all of the open files ?

Short answer is no.  We freezer the userspace tasks for the duration
of the checkpoint, but we are only guaranteeing consistency with respect
to the read/write syscalls (we currently even refuse checkpoint for
aio).  What happens in the kernel to effect a write is not doesn't
matter to us, it's assumed to complete.

I'd imagine you could catch the fact that a write occurs to a disconnected
device, start queueing up the data to be written, send an error message
up through to userspace, through dbus to an error dialog, and warn the user
to re-insert the device.  But application c/r work is not going to be
helpful here - unless an application is still actively writing, in which
case part of the userspace callbacks in response to the error message from
the kernel might be to do an lsof to find guilty tasks, and freeze them.

-serge

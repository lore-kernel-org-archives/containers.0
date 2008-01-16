From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] An attempt to have an unlimitedly extendable sys_clone
Date: Wed, 16 Jan 2008 09:52:57 -0800
Message-ID: <1200505977.22674.182.camel@localhost>
References: <478CAC32.4080809@openvz.org>
	<39689.192.168.101.12.1200407681.squirrel@intranet>
	<478DB1AC.6050508@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <478DB1AC.6050508-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-01-16 at 10:26 +0300, Pavel Emelyanov wrote:
> > This means that software built against a newer kernel won't work on an
> > older one. Surely that's not intended?
> 
> It is intended. If I ask an old kernel to clone the mq namespace, but
> it doesn't support such, that I'd better like to get an -EINVAL error
> rather than be silently held in an old global namespace.

There's at least one thing that this doesn't handle.  Let's say we have
a clone64(long, long) but that the kernel we're running is old and don't
know about any valid flags in the second long, yet. 

Somebody who knows about lots of new flags 10 years down the line passes
clone(0x1234, 0x0) to the old kernel.  That's OK, because the kernel
knows about all of the flags that *ARE* set.

Your proposal is basically this:

	clone(flags, {size, stuff});

and if the in-kernel size isn't exactly the same as the size passed in,
it punts.  It doesn't matter if anything in "stuff" was actually going
to be used, or if the old kernel *could* have handled it, it just punts.

Honestly, I don't think it's that big of a deal, I just wish you'd
acknowledge it. ;)

-- Dave

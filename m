From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] checkpoint/restart of robust futex lists
Date: Thu, 18 Jun 2009 23:41:13 -0400
Message-ID: <4A3B08D9.5010805@cs.columbia.edu>
References: <20090603041919.GO9285@us.ibm.com>
	<4A3A7572.9030907@cs.columbia.edu> <m31vphgxa0.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m31vphgxa0.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:
> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
>> What happens if we checkpoint on a system with CONFIG_FUTEX and
>> restart on a a system with !CONFIG_FUTEX ?
> 
> You can't disable FUTEX unless EMBEDDED=y, and EMBEDDED is the "I know
> what I'm doing" knob.  Is this really worth worrying about?
> 

Good point.

Still, a warning won't hurt, and can be done in userspace.
Even if you "know what you're doing", you may miss this detail.

But more importantly, this brings up the issue of how to encode
the configuration of the kernel used when a checkpoint is taken.

This information would indicate, in a sense, the set of assumptions
on the environments that can possibly restart from that checkpoint.

This can be checked by user space against the current kernel at
restart, and at the very least issue a warning about possible
incompatibility. User could override and proceed as is, or modify
the image, etc.

Coincidentally a similar discussion starts in the other thread
on combinations of namespace config options - "[PATCH 1/1] cr:
fix compilation with CONFIG_UTS_NS=n", so I'll raise it there.

Oren.

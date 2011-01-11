From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 04/11] checkpoint: introduce device vma type
Date: Tue, 11 Jan 2011 08:15:03 -0600
Message-ID: <1294755303.26638.29.camel@tp-t61>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
	<1287601006-13794-5-git-send-email-ntl@pobox.com>
	<4D2BC09B.1010402@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D2BC09B.1010402-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2011-01-10 at 21:29 -0500, Oren Laadan wrote:
> Hi,
> 
> Thanks for bringing up the issue.
> 
> We clearly will need device-specific vma types (in plural!),
> and I suspect that the way it will work is that devices will
> register their vma types at boot time or dynamically (for
> kernel modules).
> 
> On 10/20/2010 02:56 PM, Nathan Lynch wrote:
> > This is intended to be used by drivers that allow userspace to map
> > hardware resources via mmap(2).  The mapping is restored but we don't
> > worry about the contents.  This is pretty much how we treat shared
> > file mappings, where it is the user's responsibility to ensure file
> > (device) availability and integrity for restart.  I think this is a
> > reasonable approach for the timer implementations in drivers/char as
> > well as the bsr driver (for which a patch follows).
> 
> The given use case is for a specific device, and assumes special
> userspace behavior and awareness (if not the application, at 
> least the admin that runs the c/r).
> 
> A similar solution will also apply for memory regions marked by
> the process as "scratch" - a way for programmers to tell the kernel
> that certain memory need not be saved/restored beyond the mapping.
> 
> I'm a bit concerned about tying this behavior permanently to a
> drivers. (Although, it may make sense for some drivers). What do
> you think ?
> 
> Otherwise, the patch looks correct. Perhaps modify the types to
> something more generic, like CKPT_VMA_VANILLA ?

My use case has disappeared in the interim and I've moved on to other
matters, so I'm inclined to defer c/r of device mappings until another
user comes along.

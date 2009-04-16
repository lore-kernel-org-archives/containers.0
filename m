From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: C/R without "leaks"
Date: Thu, 16 Apr 2009 14:39:05 -0400
Message-ID: <49E77B49.3020102@cs.columbia.edu>
References: <49E40662.2040508@cs.columbia.edu>
	<20090414163633.GE27461@x200.localdomain>
	<49E4D89D.9060903@cs.columbia.edu>
	<20090415195629.GD26994@x200.localdomain>
	<1239835337.6610.6.camel@bahia>
	<20090416161215.GA8505@x200.localdomain>
	<49E774B1.5060505@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49E774B1.5060505-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chris Friesen <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Chris Friesen wrote:
> Alexey Dobriyan wrote:
>> On Thu, Apr 16, 2009 at 12:42:17AM +0200, Greg Kurz wrote:
>>> On Wed, 2009-04-15 at 23:56 +0400, Alexey Dobriyan wrote:
>>
>>>> There are sockets and live netns as the most complex example. I'm not
>>>> prepared to describe it exactly, but people wishing to do C/R with
>>>> "leaks" should be very careful with their wishes.
>>> They should close their sockets before checkpoint and find/have some way
>>> to reconnect after. This implies some kind of C/R awareness in the code
>>> to be checkpointed.
>>
>> How do you imagine sshd closing sockets and reconnecting?
> 
> Don't you already have to handle the case where an sshd connection is
> checkpointed, then the system is shutdown and the restore doesn't happen
> until after the TCP timeout?

Any connection in that case is, of course, lost, and it's up to the
application to do something about it. If the application relies on
the state of the connection, it will have to give up (e.g. sshd, and
ssh, die).

However, there are many application that can withstand connection
lost without crashing. They simply retry (web browser, irc client,
db clients). With time, there may be more applications that are
'c/r-aware'.

Moreover, in some cases you could, on restart, use a wrapper to
create a new connection to somewhere (*), then ask restart(2) to
use that socket instead of the original, such that from the user
point of view things continue to work well, transparently.

(*) that somewhere, could be the original peer, or another server,
if it has a way to somehow continue a cut connection, or a special
wrapper server that you right for that purpose.

Oren.

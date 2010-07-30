From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/4] restart thread safety: remove malloc from genstack
Date: Fri, 30 Jul 2010 14:57:36 -0400
Message-ID: <4C5320A0.6000205@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>
	<1280509713-6745-3-git-send-email-orenl@cs.columbia.edu>
	<20100730184641.GB3426@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100730184641.GB3426-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
List-Id: containers.vger.kernel.org


Matt Helsley wrote:
> On Fri, Jul 30, 2010 at 01:08:32PM -0400, Oren Laadan wrote:
>> We use clone and eclone directly and not through glibc, therefore
>> must explicitly care about thread-safety of malloc.
>>
>> This patch eliminates the use of malloc() in genstack_alloc().
>> Use mmap() instead. While an overkill, I don't expect performance
>> issues of this.
> 
> Should work so long as we know the glibc mmap wrappers themselves are
> reentrant/thread-safe. I expect they are but this might be a good thing
> to confirm.

True. And that goes for every system call we use in there -
including, for example, setsid().

One alternative is to call all those syscall directly using
the syscall() syscall. Not sure it's worth our time now, though.

Oren.

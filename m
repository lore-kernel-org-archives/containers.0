From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: user-cr thread safety
Date: Thu, 29 Jul 2010 18:14:57 -0400
Message-ID: <4C51FD61.8070201@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>	
	<4C51968D.3000301@cs.columbia.edu>
	<1280425072.3143.206.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280425072.3143.206.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 07/29/2010 01:37 PM, Nathan Lynch wrote:
> On Thu, 2010-07-29 at 10:56 -0400, Oren Laadan wrote:
>> 1) The separate fd-table between the coordinator and the feeder
>> is just a convenience and can be relatively easily relaxed so
>> that pthreads may be used. However, ...
>>
>> 2) More importantly, malloc() and printf() also occur in the
>> processes and threads generated during the creation of the new
>> (restored) task tree. So the same problems may occur there as
>> well. Unfortunately, here we can't use glibc, in part because
>> it is not even supported by glibc.
>>
>> Maybe a more robust way to address this is to: (1) use mmap()
>> and munmap() instead of malloc() and free(), and also (2) use
>> sprintf() + write() instead of printf().
>> That should make everything thread-safe. Did you notice other
>> libc calls which may be problematic ?
> 
> No, I think you covered it.  The only remaining concern I have is
> whether accesses to global state (like the context) are adequately
> serialized, and if not, what mechanism could provide mutual exclusion
> (semaphores?).

That global variables (*) like the context are set once prior
to the fork/clone starts, and are immutable thereafter.

So I'll go ahead and clean it up.

(*) except for signal handling, which I'd like to remove anyway.

Oren.

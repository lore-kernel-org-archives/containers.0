From: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
Subject: Re: user-cr thread safety
Date: Thu, 29 Jul 2010 12:37:52 -0500
Message-ID: <1280425072.3143.206.camel@localhost>
References: <1280169472.7875.4290.camel@localhost>
	<4C51968D.3000301@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C51968D.3000301-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

On Thu, 2010-07-29 at 10:56 -0400, Oren Laadan wrote:
> 1) The separate fd-table between the coordinator and the feeder
> is just a convenience and can be relatively easily relaxed so
> that pthreads may be used. However, ...
> 
> 2) More importantly, malloc() and printf() also occur in the
> processes and threads generated during the creation of the new
> (restored) task tree. So the same problems may occur there as
> well. Unfortunately, here we can't use glibc, in part because
> it is not even supported by glibc.
> 
> Maybe a more robust way to address this is to: (1) use mmap()
> and munmap() instead of malloc() and free(), and also (2) use
> sprintf() + write() instead of printf().
> That should make everything thread-safe. Did you notice other
> libc calls which may be problematic ?

No, I think you covered it.  The only remaining concern I have is
whether accesses to global state (like the context) are adequately
serialized, and if not, what mechanism could provide mutual exclusion
(semaphores?).

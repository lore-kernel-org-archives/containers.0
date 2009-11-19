From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Thu, 19 Nov 2009 13:32:36 -0800
Message-ID: <1258666356.20093.9622.camel@nimitz>
References: <20091119004838.AD278DE0@kernel>
	<20091119095844.GP4379@hawkmoon.kerlabs.com>
	<1258652929.20093.8941.camel@nimitz>
	<20091119212646.GA4767@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091119212646.GA4767@localdomain>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2009-11-19 at 22:26 +0100, Louis Rilling wrote:
> But actually this is even better :D:
> 
>          __asm__  __volatile__(
>                   "movq %3, %%r10\n\t"           /* pids in r10*/
>                   "pushq %%rbp\n\t"              /* save value of ebp */
>                  :
>                  :"D" (flags_low), /* rdi */
>                   "S" (clone_args),/* rsi */
>                   "d" (args_size), /* rdx */
>                   "r10" (pids)     /* Linux reads its fourth arg from r10 */
>                  );

That gives me:

clone-lib.c:28: error: matching constraint references invalid operand
number


-- Dave

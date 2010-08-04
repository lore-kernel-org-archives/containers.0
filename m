From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/4] restart thread-safety: avoid malloc in ckpt_msg()
Date: Wed, 04 Aug 2010 19:56:47 -0400
Message-ID: <4C59FE3F.6090803@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>	
	<1280509713-6745-4-git-send-email-orenl@cs.columbia.edu>
	<1280964604.9502.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280964604.9502.16.camel@localhost>
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



On 08/04/2010 07:30 PM, Nathan Lynch wrote:
> On Fri, 2010-07-30 at 13:08 -0400, Oren Laadan wrote:
>> We use clone and eclone directly and not through glibc, therefore
>> must explicitly care about thread-safety of malloc.
>>
>> This patch removes the use of malloc in ckpt_msg() and instead
>> allocate a buffer on the stack. Also convert calls to strerr() to
>> to calls to strerr_r() which are thread-safe.
>
> Well, strerror_r is safe only for code that uses glibc/libpthread
> interfaces to create threads, right?
>
> Furthermore, strerror_r has different behaviors depending on whether
> you're using the XSI- or GNU-specified version.  My local strerror(3)
> man page says:
>
> "The GNU-specific strerror_r() returns a pointer to a string  containing
> the  error  message.  This may be either a pointer to a string that the
> function stores in buf, or a pointer to some (immutable) static  string
> (in which case buf is unused)."
>
> And I'm seeing garbage output from ckpt_perror() with this patch
> applied, implying that the GNU version is in use and that it is electing
> not to modify the supplied buffer.

Doh ... I should have known better.

Ok from the manpage:
"""
    Feature Test Macro Requirements for glibc (see
    feature_test_macros(7)):

        The XSI-compliant version of strerror_r() is provided if:
        (_POSIX_C_SOURCE >= 200112L || _XOPEN_SOURCE >= 600) && !_GNU_SOURCE
        Otherwise, the GNU-specific version is provided.
"""

so how about:

#if (_POSIX_C_SOURCE >= 200112L || _XOPEN_SOURCE >= 600) && !_GNU_SOURCE
   use-XSI
#else
   use-GNU
#endif

>
> Surely strerror(errno) is "good enough" for error paths?

Heh .. given that errno can already be scrambled between threads...

Oren.

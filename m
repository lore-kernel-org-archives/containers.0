From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH user-cr] Allow for logfile for kernel debug messages	(v2)
Date: Wed, 21 Oct 2009 18:18:37 -0400
Message-ID: <4ADF88BD.20400@librato.com>
References: <20091021210507.GA2098@us.ibm.com>
	<20091021210533.GA2165@us.ibm.com> <4ADF8140.3010102@librato.com>
	<20091021220245.GA8994@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091021220245.GA8994-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> Serge E. Hallyn wrote:
>>> If unspecified, -1 will be sent for logfd to the kernel, and there
>>> will be no debug log.   If specified, then checkpoint and restart
>>> debug msgs will be sent to the logfile.
>> The new interface will cover error reporting, so when run without '-l'
> 
> Not sure what you mean by 'the new interface will cover error reporting'.

I mean that using an logging fd rids the need to write an error record
to the checkpoint image. So I think we may retire ckpt_write_err() in
favor of the new interface.

The downside (if any) is that the error message is cannot be recovered
from the partial image file (so what ?).

And, unlike now, it's a way to report the reason for a restart failure
back to the caller.

I'd like both 'checkpoint' and 'restart' to report the reason for a
failure to the caller (either by default, or with a new switch).

> 
>> both 'checkpoint' and 'restart' (unless asked to run extra silently)
>> need to provide a pipe to the syscall, and if an error occurs, display
>> pull the error reason from the pipe and print it.
> 
> Sounds like a useful feature, but to be clear note that what is now
> ckpt_err() output from the kernel was debug output before, so compared
> to without this patchset, the user is not losing any information.

True for checkpoint. But the motivation for the new interface (besides
debugging), is to have the same error reporting for restart, too.

> 
> In fact what you're saying sounds like even more justification for
> changing some of the
> 
> 	ret = abc();
> 	ckpt_debug("...", ret);
> 	if (!ret)
> 		ret = cdef();
> 	ckpt_debug("...", ret);
> 
> type of flow into one where ckpt_err() is used and only in the case of
> a definite error.  Yes?

Hmm... I'm not sure.

I think (...) I'm suggesting two classes of output:
- ckpt_error() to report an error to the user
- ckpt_debug() to report debugging info for developers

The value of a @ret is interesting for error reporting only when
it is negative; but for debugging it may be interesting even if
an error did not occur.

Also, I expect more places where we want to see @ret for debugging.
So @ret may be negative, but ckpt_error() will be called later (e.g.
by our caller).

Oren.

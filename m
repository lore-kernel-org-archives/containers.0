From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/7] restart.c: use ckpt_err
Date: Mon, 16 Nov 2009 11:57:05 -0500
Message-ID: <4B018461.5050206@cs.columbia.edu>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
	<1257465619-1777-3-git-send-email-serue@us.ibm.com>
	<4B017780.6080609@cs.columbia.edu>
	<20091116164314.GA16493@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091116164314.GA16493-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> Is it your intent to entirely get rid of ckpt_debug() ?
> 
> Replace with a new ckpt_log(), yes.  I think that's too much to do
> all at once so figured ckpt_err() in v19, then start adding ckpt_log(),
> and converting callers one file at a time.
> 
>> We originally discussed two levels of details: only error status
>> or a detailed log (and we also thought of a detailed debug, that can
>> be compiled out to save space). How does that fit with the patch(es) ?
> 
> FIts perfectly.  ckpt_err() always is dumped, ckpt_log() can be deemed
> 'informative' and optionally dumped.  When we implement it.

Yes. I guess my point was that it seemed to me that there was
'informative' messages in ckpt_err() at several places.

> 
>> To "define" what's "error status" and what's "log" (and maybe what's
>> "debug"), I suggest a test like:
>>
>> 1) error status: what conveys the most specific reason of failure,
>> e.g. "failed to open file to restore fd";  The caller should be able
>> to assume that the total message(s) length will not exceed a pipe
>> buffer.
>>
>> 2) log status: that gives status about progress, or what lead to and
>> what followed an error, e.g. file open failure may have happened
>> when restoring a file descriptor, or when restore a vma, so a log
>> like "failed to restore vma" would be helpful.
> 
> I think 'failed to open file' should always be 'error', so that we
> know which file failed to open.  If all we print is a generic
> 'failed to restore open files' then the user isn't much better off
> than getting -EBADF for sys_restart().

Yes, that was a bad example of "specific".. you're right.

> 
>> 3) debug status: that we want to be able to compile out without having
>> to reintroduce it for every bug that it may help us debug.
> 
> <shrug>  This may be useful and good, but in any case starting
> with just implementing (1) seemed like the most practical approach.
> The patchset accomplishes getting rid of ckpt_write_err(), and sending
> error messages to the user logfile, so I think it's plenty useful
> without trying to do everything (with resulting in all the extra
> patch churn).
> 

I agree, and also suggest to avoid proliferation of ckpt_err()
where it would otherwise be 'informative' or debug - just leave
it as is in 'ckpt_debug()' state.

>>> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
>>> index 130b4b2..e1bd0ad 100644
>>> --- a/checkpoint/restart.c
>>> +++ b/checkpoint/restart.c
>>> @@ -64,7 +64,7 @@ static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
>>>  
>>>  	s = kmalloc(sizeof(*s), GFP_KERNEL);
>>>  	if (!s) {
>>> -		ckpt_debug("no memory to register ?!\n");
>>> +		ckpt_err(ctx, 0, "no memory to register ?!\n");
>>>  		return -ENOMEM;
>> What is the purpose in passing '0' instead of -ENOMEM to ckpt_err() ?
>> (a few more instances below).
> 
> Hmm, I think that can pass errno now.  I probably had done that bc
> originally ckpt_err() was going to do the restore_notify_error
> too.
> 
>> Are you still concerned about the increase in code size with c/r ?
> 
> Yes, I am.  But our first priority should be to empower a user to
> debug why a checkpoint or restart failed.  Once we're settled with
> that, we can look at how to decrease code size.  Compiling out the
> log and debug messages is fair game imo, but compiling out ckpt_err()
> is not.  If users can't tell that checkpoint failed because they had
> an unlinked file which used to be called .vimrc open, then I don't
> think we can reasonably hope to get this upstream (as per previous
> 'toy implementation' arguments).

In replying to other patches I suggested two ways of reducing the
size which also make the report more concise:

1) Report where the error occurs: e.g. report in ckpt_obj_fetch()
and not in the caller of ckpt_obj_fetch().

2) If function foo() returns and error, and function foo() already
reported the error, then the caller should not use ckpt_err() too.
Instead it should use log/debug mode.

Oren.

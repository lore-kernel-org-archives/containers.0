From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH 11/17] define function to print error messages to
	user log
Date: Wed, 28 Oct 2009 17:50:45 -0400
Message-ID: <4AE8BCB5.4030406@librato.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>	<1256683587-23961-12-git-send-email-serge@us.ibm.com>	<20091028181415.GB14023@count0.beaverton.ibm.com>
	<20091028205424.GA27394@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091028205424.GA27394-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>> @@ -401,6 +409,9 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>>>  		case 'E':
>>>  			len += sprintf(format+len, "[%s]", "err %d");
>>>  			break;
>>> +		case 'C': /* count of bytes read/written to checkpoint image */
>>> +			len += sprintf(format+len, "[%s]", "pos %d");
>>> +			break;
>> Instead we could always output ckpt->total and then we wouldn't need %(C). I
>> suspect it's such a useful piece of information that it'll be repeated
>> in many/all format strings eventually.
> 
> Yes, likewise %(T).  If that's what we want to do.

I agree. For the cases when there is not task, can put "none"

> 
> Should we discuss here what we want an entry to look like?  For both
> ckpt_write_err (to the checkpoint image) and ckpt_error()?
> 

Yes please !

>>>  		case 'O':
>>>  			len += sprintf(format+len, "[%s]", "obj %d");
>>>  			break;
>>> @@ -435,6 +446,51 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>>>  	return format;
>>>  }
>>>
>>> +void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
>>> +{
>>> +	mm_segment_t fs;
>>> +	struct file *file;
>>> +	int count;
>>> +	va_list ap, aq, az;
>>> +	char *format;
>>> +	char buf[200], *bufp = buf;
>> I believe this buffer is too big for a kernel stack -- especially
>> for ckpt_log_error() which might be invoked "deep" in
>> the kernel stack.
> 
> 200 bytes?  Well, I guess I can try with 50 which still may often be
> enough.

How about using a dedicated buffer on @ctx for that ?

> 
>>> +	if (!ctx || !ctx->logfile)
>>> +		return;
>>> +	file = ctx->logfile;
>>> +
>>> +	va_start(ap, fmt);
>>> +	format = ckpt_generate_fmt(ctx, fmt);
>>> +	va_copy(aq, ap);
>>> +	va_copy(az, ap);
>>> +	/* I'm not clear here - can I re-use aq, or do i need
>>> +	 * a third copy? */
>> I'm no varargs expert but I have re-read the man page and
>> seen a purported snippet of the standard. :)
>>
>> I think you need a third copy operation but you may only need
>> two va_lists so long as you do a va_end before the next va_copy:
>>
>> 	va_copy(aq, ap);
>> 	... <use aq> ...
>> 	va_end(aq);
>> 	va_copy(aq, ap);
>> 	... <use aq> ...
>> 	va_end(aq);
>> 	...
>> 	va_end(ap); 
>>
>> Based on my reading it sounded like some arch/ABIs require space
>> proportional to the number of arguments for each un-va_end-ed copy.
> 
> Ok, I'll do that, thanks.
> 
>>> +	count = vsnprintf(bufp, 200, format ? : fmt, aq);
>> BTW -- I think you can use snprintf() without the buffer and length
>> arguments if you just need the length calculated. Perhaps the same
>> is possible with vsnprintf():
>>
>> 	count = vsnprintf(NULL, 0, format ? : fmt, aq);
>>
>> If that works with vsnprintf() too then you could get rid of the
>> stack buf and always kmalloc the space..
> 
> Hmm, yeah...  though i don't know that I *want* to always kmalloc
> the space :)  It does look like it should work (though no comment
> to that effect), but there is no speed advantage, save a bit of
> memcpy (vs. always having a kmalloc).

Again, a dedicated buffer on @ctx will be helpful here.

Oren.

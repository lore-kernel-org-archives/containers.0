From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 01/17] ckpt_write_err: use single format with %(T)	style
	tokens
Date: Fri, 30 Oct 2009 11:45:07 -0400
Message-ID: <4AEB0A03.7000500@librato.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
	<1256849682-858-2-git-send-email-serue@us.ibm.com>
	<4AEA1527.7090907@librato.com> <20091030021819.GB10379@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091030021819.GB10379-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>
>> serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>>> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]
>>> +	 */
>>> +	alloclen = 37 + 8 * strlen(fmt);
>> This calculation assumed that @fmt had only format string...
>> At the very minimum you could take strlen(fmt)/3 (+1 to round up)
> 
> Yeah, I didn't want to think about that in detail yet :)
> 
>> I thought you were going to use a @ctx->buffer or something ?
> 
> And I am, for my string.  We need one for the expanded fmt here,
> and then one to snprintf the final string into so we can write it
> out.
> 
> Shall I just add a @ctx->fmtbuf?

Sure.

> 
>>> +	format = kzalloc(alloclen, GFP_KERNEL);
>>> +	if (!format)
>>> +		return NULL;
>>> +
>>> +	for (; *fmt; fmt++) {
>>> +		BUG_ON(len > alloclen);
>>> +		if (*fmt != '%' || fmt[1] != '(' || fmt[3] != ')') {
>> This is still a bit risky .. how about adding
>> 	|| fmt[2] == '\0'
>> between the 2nd and 3rd test ?
> 
> Well I can do that, but since we provide the fmt strings and there is
> no risk for an information leak I didn't think it was worth making
> the line even longer.  But ok, I'll add it...

Well, if a developer gives a string like "hello %(", then you
will potentially go past the end of the string and eventually
crash (or worse).

Oren.

From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 07/54] cr: extend arch_setup_additional_pages()
Date: Mon, 04 May 2009 03:25:25 -0400
Message-ID: <49FE9865.4090600@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>	<1240961064-13991-8-git-send-email-orenl@cs.columbia.edu>	<1241190790.29485.168.camel@nimitz>	<20090501154220.GA26771@us.ibm.com>	<1241193421.29485.188.camel@nimitz>
	<20090501161813.GA27516@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090501161813.GA27516-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> On Fri, 2009-05-01 at 10:42 -0500, Serge E. Hallyn wrote:
>>> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>>>> On Tue, 2009-04-28 at 19:23 -0400, Oren Laadan wrote:
>>>>> From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>>
>>>>> Add "start" argument, to request to map vDSO to a specific place,
>>>>> and fail the operation if not.
>>>>>
>>>>> This is useful for restart(2) to ensure that memory layout is restore
>>>>> exactly as needed.
>>>> This needs to go up at the start of the series.  It can get merged
>>>> before everything else.
>>> It does, but now we are sending Oren mixed signals.
>>>
>>> I thought we were talking yesterday on irc about Oren doing append-only
>>> git tree from now on, and someone else (you? :) was going to do patch
>>> integration and sorting and prettifying?
>> I was going to just go and start doing these, but I figured I'd have a
>> run through the patches first.  I probably also shouldn't be doing
>> anything to which Oren (or anyone else) has really strong objections.
>> So, I'll give everyone a chance to discuss and object before I go
>> screwing the patches up. ;)
> 
> True, part of this may be able to go up on its own.  In that case
> 
> 	1. please put the part of my s390 fix patch which applies to
> 	   this patch in
> 

Fixed.

> 	2. as I asked when Alexey posted this, can we remove the
> 	   first argument to arch_setup_additional_pages()?  Noone uses
> 	   it.

I have no objections.

Oren.

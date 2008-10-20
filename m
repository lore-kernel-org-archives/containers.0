From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Mon, 20 Oct 2008 18:37:32 +0200
Message-ID: <48FCB3CC.9030804@fr.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>	<1224286383.1848.65.camel@nimitz>	<20081020111002.GQ15171@hawkmoon.kerlabs.com>
	<48FC86B2.8000606@fr.ibm.com> <48FCA97C.1040108@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FCA97C.1040108-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan wrote:
> 
> Daniel Lezcano wrote:
>> Louis Rilling wrote:
>>> On Fri, Oct 17, 2008 at 04:33:03PM -0700, Dave Hansen wrote:
>>>> On Wed, 2008-09-03 at 14:57 +0400, Andrey Mirkin wrote:
>>>>> This patchset introduces kernel based checkpointing/restart as it is
>>>>> implemented in OpenVZ project. This patchset has limited functionality and
>>>>> are able to checkpoint/restart only single process. Recently Oren Laaden
>>>>> sent another kernel based implementation of checkpoint/restart. The main
>>>>> differences between this patchset and Oren's patchset are:
>>>> Hi Andrey,
>>>>
>>>> I'm curious what you want to happen with this patch set.  Is there
>>>> something specific in Oren's set that deficient which you need
>>>> implemented?  Are there some technical reasons you prefer this code?
>>> To be fair, and since (IIRC) the initial intent was to start with OpenVZ's
>>> approach, shouldn't Oren answer the same questions with respect to Andrey's
>>> patchset?
>>>
>>> I'm afraid that we are forgetting to take the best from both approaches...
>> I agree with Louis.
>>
>> I played with Oren's patchset and tryed to port it on x86_64. I was able 
>> to sys_checkpoint/sys_restart but if you remove the restoring of the 
>> general registers, the restart still works. I am not an expert on asm, 
>> but my hypothesis is when we call sys_checkpoint the registers are saved 
>> on the stack by the syscall and when we restore the memory of the 
>> process, we restore the stack and the stacked registers are restored 
>> when exiting the sys_restart. That make me feel there is an important 
>> gap between external checkpoint and internal checkpoint.
> 
> This is a misconception: my patches are not "internal checkpoint". My
> patches are basically "external checkpoint" by design, which *also*
> accommodates self-checkpointing (aka internal). The same holds for the
> restart. The implementation is demonstrated with "self-checkpoint" to
> avoid complicating things at this early stage of proof-of-concept.

Yep, I read your patchset :)

I just want to clarify what we want to demonstrate with this patchset 
for the proof-of-concept ? A self CR does not show what are the 
complicate parts of the CR, we are just showing we can dump the memory 
from the kernel and do setcontext/getcontext.

We state at the container mini-summit on an approach:

    1. Pre-dump
    2. Freeze the container
    3. Dump
    4. Thaw/Kill the container
    5. Post-dump

We already have the freezer, and we can forget for now pre-dump and 
post-dump.

IMHO, for the proof-of-concept we should do a minimal CR (like you did), 
but conforming with these 5 points, but that means we have to do an 
external checkpoint.

If the POC conforms with that, the patchset will be a little different 
and that will show what are the difficult part for restarting a process, 
especially to restart it at the frozen state :) and that will give an 
idea from 10000 feets of the big picture.

> For multiple processes all that is needed is a container and a loop
> on the checkpoint side, and a method to recreate processes on the
> restart side. Andrew suggests to do it in kernel space, I still have
> doubts.

A question to Andrey, do you, in OpenVZ, restart "externally" or it is 
the first process of the pid namespace which calls sys_restart and then 
  populates the pid namespace ?

> While I held out the multi-process part of the patch so far because I
> was explicitly asked to do it, it seems like this would be a good time
> to push it out and get feedback.

IMHO it is too soon...

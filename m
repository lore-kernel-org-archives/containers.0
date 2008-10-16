From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Thu, 16 Oct 2008 14:35:59 +0200
Message-ID: <48F7352F.3020700__22736.5442588509$1224160731$gmane$org@fr.ibm.com>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu>
	<1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu>
	<1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu>
	<1223571036.11830.32.camel@nimitz>	<20081010153951.GD28977@elte.hu>
	<48F30315.1070909@fr.ibm.com>	<1223916223.29877.14.camel@nimitz>
	<48F6092D.6050400@fr.ibm.com> <48F685A3.1060804@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48F685A3.1060804-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan wrote:
> Cedric Le Goater wrote:
>> Dave Hansen wrote:
>>> On Mon, 2008-10-13 at 10:13 +0200, Cedric Le Goater wrote:
>>>> hmm, that's rather complex, because we have to take into account the 
>>>> kernel stack, no ? This is what Andrey was trying to solve in his patchset 
>>>> back in September :
>>>>
>>>>         http://lkml.org/lkml/2008/9/3/96
>>>>
>>>> the restart phase simulates a clone and switch_to to (not) restore the kernel 
>>>> stack. right ? 
>>> Do we ever have to worry about the kernel stack if we simply say that
>>> tasks have to be *in* userspace when we checkpoint them. 
>> at a syscall boundary for example. that would make our life easier 
>> definitely. 
>>
> 
> The ideal situation is never worry about kernel stack: either we catch
> the task in user space or at a syscall boundary. This is taken care of
> by freezing the tasks prior to checkpoint.
> 
> The one exception (and it is a tedious one !) are states in which the
> task is already frozen by definition: any ptrace blocking point where
> the tracee waits for the tracer to grant permission to proceed with
> its execution. Another example is in vfork(), waiting for completion.

I would say these are perfect places for "may be non-checkpointable" :)

> In both cases, there will be a kernel stack and we cannot avoid it.
> The bad news is that it may be a bit tedious to restart these cases.
> The good news, however, is that they are very well defined locations
> with well defined semantics. So upon restart all that is needed is
> to emulate the expected behavior had we not been checkpointed. This,
> luckily, does not require rebuilding the kernel stack, but instead
> some smart glue code for a finite set of special cases.

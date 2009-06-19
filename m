From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: fix compilation with CONFIG_UTS_NS=n
Date: Fri, 19 Jun 2009 00:14:48 -0400
Message-ID: <4A3B10B8.3020003@cs.columbia.edu>
References: <20090617001723.GA9452@us.ibm.com>
	<4A3A6F61.5030401@cs.columbia.edu> <m3ws79h01p.fsf@pobox.com>
	<20090618223213.GA13179@us.ibm.com> <m3zlc5kugu.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3zlc5kugu.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>>> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
>>>
>>>> I think it's useful to be able to
>>>>
>>>> 1) checkpoint on a system with !CONFIG_UTS_NS,  and -
>>>> 2) checkpoint on a system with CONFIG_UTS_NS and restart on a
>>>> system with !CONFIG_UTS_NS (as long as all tasks in the image
>>>> share a single uts-ns)
>>> In principle I agree, but what confidence can we have that meaningful
>>> testing of such configurations (especially #2) will occur?
>> History says, low confidence.  So far just 1 is bad enough.  It's
>> taking a lot of my time on the LSM c/r (with the various combinations
>> of CONFIG_SECURITY, CONFIG_IPC_NS, and CONFIG_CHECKPOINT), and things
>> like CONFIG_IPC_NS consistently break c/r anyway.
>>
>> So for 2 i'm tempted to say let's encode a sha1sum of the .config
>> into the checkpoint header.  We'll keep *trying* to support (2), and
>> userspace can trivially rewrite the header if it really wants to believe
>> we've succeeded.
> 
> Are you suggesting having sys_restart code path consult the .config
> sha1sum in the image?  Or is it just for the benefit of userspace?  If
> the former, I'm having difficulty grasping the benefit.

A similar topic came up on the futex thread, so I'm bringing the
point I made there to this thread instead:

I think it is useful to encode somehow (some of) the configuration
of the kernel used when a checkpoint is taken.

This information would indicate, in a sense, the set of assumptions
on the environments that can possibly restart from that checkpoint.

This can be checked by user space against the current kernel at
restart, and at the very least issue a warning about possible
incompatibility. (Just like we will need to encode the minimal
CPU capabilities for a restart to succeed).

If an incompatibility is suspected, user could override and proceed
as is, or modify the image, etc.

I wasn't thinking of a sha1, though, because that does not give
knowledge about what is different between the environments, and is
likely to be too restrictive.

And I agree with Nathan that it makes less sense to do this in the
kernel. (For the kernel, garbage-in-garbage-out.)  It can be very
useful to do this in user space, where the user/caller can adjust
before passing an incompatible image to the kernel.

Oren.

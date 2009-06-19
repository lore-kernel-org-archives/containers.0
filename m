From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: fix compilation with CONFIG_UTS_NS=n
Date: Fri, 19 Jun 2009 12:10:36 -0500
Message-ID: <m3ljnogneb.fsf@pobox.com>
References: <20090617001723.GA9452@us.ibm.com>
	<4A3A6F61.5030401@cs.columbia.edu> <m3ws79h01p.fsf@pobox.com>
	<20090618223213.GA13179@us.ibm.com> <m3zlc5kugu.fsf@pobox.com>
	<20090619145606.GB22381@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090619145606.GB22381-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message
	of "Fri\, 19 Jun 2009 09\:56\:06 -0500")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>> > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>> >> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
>> >> 
>> >> > I think it's useful to be able to
>> >> >
>> >> > 1) checkpoint on a system with !CONFIG_UTS_NS,  and -
>> >> > 2) checkpoint on a system with CONFIG_UTS_NS and restart on a
>> >> > system with !CONFIG_UTS_NS (as long as all tasks in the image
>> >> > share a single uts-ns)
>> >> 
>> >> In principle I agree, but what confidence can we have that meaningful
>> >> testing of such configurations (especially #2) will occur?
>> >
>> > History says, low confidence.  So far just 1 is bad enough.  It's
>> > taking a lot of my time on the LSM c/r (with the various combinations
>> > of CONFIG_SECURITY, CONFIG_IPC_NS, and CONFIG_CHECKPOINT), and things
>> > like CONFIG_IPC_NS consistently break c/r anyway.
>> >
>> > So for 2 i'm tempted to say let's encode a sha1sum of the .config
>> > into the checkpoint header.  We'll keep *trying* to support (2), and
>> > userspace can trivially rewrite the header if it really wants to believe
>> > we've succeeded.
>> 
>> Are you suggesting having sys_restart code path consult the .config
>> sha1sum in the image?
>
> Yup.
>
>> Or is it just for the benefit of userspace?  If
>> the former, I'm having difficulty grasping the benefit.
>
> Well we could also do it in userspace, but it seemed easier to actually
> store the sha1sum in a char buf in the c/r code in the kernel, stick it
> in the header at checkpoint, and verify it at restart.
>
> The benefit?  Well...  really I feel opposite today.  Along the lines
> of supporting unprivileged restart as long as possible to make us
> consider security, I guess I'd argue we should support heterogenous
> (in terms of config :) c/r as long as possible.  The reason I was
> thinking otherwise yesterday is that I have to special-case things
> like the task->security objref when CONFIG_SECURITY=n.  It felt
> hacky yesterday, but the end result looks pretty good and is i 
> think better thought out than it would have been were we doing the
> sha1sum thing.

Okay.  My thought was that the sha1sum would be as subject to tampering
as anything else in the image, so the restart path couldn't really rely
on it to convey accurate information about the image contents.  But I
suppose it's moot now.

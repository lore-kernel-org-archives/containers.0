From: Ralph-Gordon Paul <Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
Subject: Re: [PATCH 3/7] make CONFIG_CHECKPOINT depend on
	CONFIG_CHECKPOINT_SUPPORT
Date: Tue, 12 May 2009 13:20:45 +0200
Message-ID: <FB599A4B-F618-4E6C-94D8-FC4EAE3D41D9@uni-duesseldorf.de>
References: <1238022166-13422-1-git-send-email-ntl@pobox.com>
	<1238022166-13422-4-git-send-email-ntl@pobox.com>
	<1238027983.8286.441.camel@nimitz>
	<20090325220931.2653f379@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20090325220931.2653f379-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

in the kernel menuconfig, there should be a note, that  
CHECKPOINT_SUPPORT depends on Compat VDSO (Processor type and features  
--> Compad VDSO support).

It took some time for me to find that out. :-)

Regards,
Ralph-Gordon Paul


Am 26.03.2009 um 04:09 schrieb Nathan Lynch:

> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
>> On Wed, 2009-03-25 at 18:02 -0500, Nathan Lynch wrote:
>>>
>>> diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
>>> index e91e0fd..760c450 100644
>>> --- a/checkpoint/Kconfig
>>> +++ b/checkpoint/Kconfig
>>> @@ -1,6 +1,6 @@
>>> config CHECKPOINT
>>>        bool "Enable checkpoint/restart (EXPERIMENTAL)"
>>> -       depends on (X86_32 || (S390 && 64BIT)) && EXPERIMENTAL
>>> +       depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
>>>        help
>>>          Application checkpoint/restart is the ability to save the
>>>          state of a running application so that it can later resume
>>
>> Yeah, this is the right way to do it, very nice.
>
> Thanks Dave.
>
>
>> Could we add a wee little ARCH_ prepend on 'CHECKPOINT_SUPPORT' in
>> there?  That way, people at least know where to go looking when they
>> want to find out why it isn't enabled.
>
> You have a point, but I'd prefer to keep the name unchanged:
>
> * There doesn't seem to be a strong convention for putting the 'ARCH'
>  string in such symbols.  Examples: LOCKDEP_SUPPORT, HAVE_KPROBES,
>  STACKTRACE_SUPPORT.  Plenty of counter-examples, too, but there's no
>  standard practice AFAICT.
>
> * Making the string more verbose means people are more likely to get
>  it wrong e.g. CONFIG_CHECKPOINT_ARCH_SUPPORT (and this sort of thing
>  can go unnoticed for a while).
>
> * Implementers can grep or cscope for it and figure it out pretty
>  quickly, and they likely would do that anyway regardless of what it's
>  called.
>
> Prepending ARCH_ would imply the right things, but with a comment, we
> can be explicit.
>
>
> commit 07087d9295d1c4dcd7e79b19d70abf19370f59da
> Author: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> Date:   Wed Mar 25 21:32:30 2009 -0500
>
>    document CHECKPOINT_SUPPORT
>
>    Make CHECKPOINT_SUPPORT's intended use clear with a comment in
>    checkpoint/Kconfig.
>
>    Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
>
> diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
> index 760c450..1761b0a 100644
> --- a/checkpoint/Kconfig
> +++ b/checkpoint/Kconfig
> @@ -1,3 +1,7 @@
> +# Architectures should define CHECKPOINT_SUPPORT when they have
> +# implemented the hooks for processor state etc. needed by the
> +# core checkpoint/restart code.
> +
> config CHECKPOINT
> 	bool "Enable checkpoint/restart (EXPERIMENTAL)"
> 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

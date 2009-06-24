From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] C/R: simplify checkpoint debugging
Date: Wed, 24 Jun 2009 14:02:52 -0500
Message-ID: <m3hby5fo9v.fsf@pobox.com>
References: <m33a9st5yk.fsf@pobox.com> <4A425927.6080109@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A425927.6080109-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Wed\, 24 Jun 2009 12\:49\:43 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:

> Nathan Lynch wrote:
>> To enable printing of checkpoint/restart messages, one must enable
>> CHECKPOINT_DEBUG and boot with ckpt_debug= ... something I haven't
>> been able to figure out.  Further complicating matters is that if
>> DYNAMIC_DEBUG is enabled, you still won't get any debugging output
>> unless you manually enable debug output for all the functions you're
>> interested in via <debugfs>/dynamic_debug/control.  At this stage of
>> development most users will want all C/R messages either on or off and
>> don't need a fancy filtering mechanism.
>
> Thanks for bringing this up. In part it has been annoying to me too.
>
> I'm all for replacing pr_debug(...) with printk(KERN_DEBUG ...).
> Done.
>
> I prefer to keep the selection of debug verbosity in - it becomes
> useful when debugging a checkpoint or restart that produce plenty
> of output. It keeps the noise (and time) to an acceptable level.
>
> So I did also change the default (CKPT_DDEFAULT) to select all
> debug flags. So the normal behavior is as intended in this patch.
>
> Given the enthusiastic responses to the proposed changes, do you
> still wish to remove the option to select verbosity level ?

If you add some documentation (in comments or kconfig help) on how to
use ckpt_debug= I wouldn't object.  AFAIK one has to read the code to
figure out which values to use.  Apologies if I've missed something...

In the long term, however, detailed reporting on C/R operations may be
better implemented using static tracepoints -- less runtime overhead
than printk, and (I think) they can be selectively enabled, which would
satisfy the speed/noise concerns you raise above.

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: ckpt-16-dev BUG() - bisected
Date: Wed, 10 Jun 2009 01:07:35 -0500
Message-ID: <m3d49czkns.fsf@pobox.com>
References: <m3vdndkmec.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3vdndkmec.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org> (Nathan Lynch's message of "Wed\, 03
	Jun 2009 17\:00\:59 -0500")
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

Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org> writes:

> Pulled latest updates today, started seeing the bug below when doing
> simple bash shell checkpoint/restart.  Git bisect blames:
>
> commit 505d9949cac385c5111bbd8ff3d2e123d5c468d8
> Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Date:   Sun May 31 12:59:40 2009 -0400
>
>     c/r: [X86_32] validate task's cpu registers and tls during restart

...

> kernel BUG at arch/x86/mm/checkpoint.c:86!

This seems to be fixed in latest ckpt-v16-dev, presumably by
f5867c9c8383c2d2d5361512e79e70df4b730fe9 ("c/r: [X86_32] used
__u16/short to encode/decode segment registers").

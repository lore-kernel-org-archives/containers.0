From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] signals: SEND_SIG_NOINFO should be considered as
	SI_FROMUSER()
Date: Wed, 7 Oct 2009 13:30:49 +0200
Message-ID: <20091007113049.GA3421@redhat.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091003171029.GA30442@us.ibm.com>
	<20091004021844.GA21006@redhat.com>
	<20091004021918.GB21006@redhat.com>
	<20091006073100.4184128@magilla.sf.frob.com>
	<20091006133732.GB8628@redhat.com>
	<20091006175705.6547A22@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091006175705.6547A22-nL1rrgvulkc2UH6IwYuUx0EOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/06, Roland McGrath wrote:
>
> > Perhaps, we should add the comment to explain that both SI_FROMUSER()
> > and si_fromuser() are only valid in the sending pathes.
>
> Yes.  Also now that you put them both in a sentence together, it is clear
> that it is insane to have two different things with those two names that
> differ only in capitalization.

I think this doesn't matter because we need more cleanups. As for naming
I agree, si_fromuser() sucks and I'd be happy to send the patch which
renames it (or re-send these 2 patches).

The problem is, both SI_FROMUSER() and SI_FROMKERNEL() must die imho.
In fact I think they should never exist.

	SI_FROMUSER(siptr)      ((siptr)->si_code <= 0)

note "<=", this means this helper is unuseable. What we need is another
macro/inline which checks "si_code < 0" (or >= 0 depending on naming),
this helper should be used by sys_sigqueueinfo/etc which can not not use
SI_FROMXXX() because SI_USER is rightly forbidden. __send_signal() can
use the new helper too.

Other cleanups which imho makes sense:

	- rename SEND_SIG_XXX

	- redefine them to make sure SEND_SIG_NOINFO != NULL

Oleg.

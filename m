From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] signals: SEND_SIG_NOINFO should be considered as
	SI_FROMUSER()
Date: Mon, 5 Oct 2009 20:39:47 +0200
Message-ID: <20091005183947.GB943@redhat.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091003171029.GA30442@us.ibm.com>
	<20091004021844.GA21006@redhat.com>
	<20091004021918.GB21006@redhat.com>
	<20091005175855.GB30442@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091005175855.GB30442-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/05, Sukadev Bhattiprolu wrote:
>
> Oleg Nesterov [oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
> | >From __send_signal()'s pov they mean
> |
> | 	SEND_SIG_NOINFO		from user
>
> Just to complicate further, all 'SEND_SIG_NOINFO' signals are from user,
> but not all 'from user' signals are SEND_SIG_NOINFO.

Yes, SEND_SIG_NOINFO means: sent by kernel on behalf of some process.

>
> | 	SEND_SIG_PRIV		from kernel
>
> SEND_SIG_PRIV also means there is no real info, just that sender is
> privileged.

Well. Unlike SEND_SIG_FORCED, SEND_SIG_NOINFO/SEND_SIG_NOINFO ask
__send_signal() to allocate and queue "struct sigqueue". But
SEND_SIG_PRIV and SEND_SIG_NOINFO both mean the real info, jut
this info is filled by __send_signal().

> | 	SEND_SIG_FORCED		no info
>
> Are 'forced' signals considered 'from kernel' too ?

I think yes.

> | +static inline bool si_fromuser(const struct siginfo *info)
> | +{
> | +	return info == SEND_SIG_NOINFO ||
> | +		(!is_si_special(info) && SI_FROMUSER(info));
> | +}
> | +
>
> This change makes sense, but can we even drop the SEND_SIG_NOINFO
> altogether and simply check for NULL:
>
> 	return (!info || (is_si_special(info)) && SI_FROMUSER(info))

IOW, you suggest to use NULL instead of SEND_SIG_NOINFO.

Why?

If we use NULL as a "special" info, then SEND_SIG_FORCED semantics
makes more sense because __send_signal(SEND_SIG_FORCED) does not queue
info.

But I don't think we should use NULL. I think it is better to use the
symbolic names instead of NULL which is in fact the "harcoded constant".
But it would be nice to rename them.

Oleg.

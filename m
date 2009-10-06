From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/4] signals: send_signal: use si_fromuser() to detect
	from_ancestor_ns
Date: Mon, 5 Oct 2009 17:16:31 -0700
Message-ID: <20091006001631.GC4390@us.ibm.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091003171029.GA30442@us.ibm.com>
	<20091004021844.GA21006@redhat.com>
	<20091004021954.GC21006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091004021954.GC21006-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
| Change send_signal() to use si_fromuser(). From now SEND_SIG_NOINFO
| triggers the "from_ancestor_ns" check.
| 
| This fixes reparent_thread()->group_send_sig_info(pdeath_signal)
| behaviour, before this patch send_signal() does not detect the
| cross-namespace case when the child of the dying parent belongs
| to the sub-namespace.
| 
| This patch can affect the behaviour of send_sig(), kill_pgrp() and
| kill_pid() when the caller sends the signal to the sub-namespace
| with "priv == 0" but surprisingly all callers seem to use them
| correctly, including disassociate_ctty(on_exit).
| 
| Except: drivers/staging/comedi/drivers/addi-data/*.c incorrectly
| use send_sig(priv => 0). But his is minor and should be fixed
| anyway.
| 
| Reported-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
| Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Since, addressing the problem of container-init sending SIGKILL to itself
would have to be a separate patch:

Reviewed-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

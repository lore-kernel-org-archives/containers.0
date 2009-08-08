From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Fri, 7 Aug 2009 18:51:28 -0700
Message-ID: <2f86c2480908071851t1de88762n7f6b9a44e00fc42f__28386.2093616792$1249696414$gmane$org@mail.gmail.com>
References: <20090803194555.GA10158@us.ibm.com>
	<20090805102057.GT29252@hawkmoon.kerlabs.com>
	<6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
	<2f86c2480908051701s57120404q475edbedb58cdca1@mail.gmail.com>
	<20090806095854.GD26446@hawkmoon.kerlabs.com>
	<6599ad830908060328y21a008c1pc5ed5c27e0ec905d@mail.gmail.com>
	<20090806112450.GF26446@hawkmoon.kerlabs.com>
	<6599ad830908060440g2f6cbed6xdc54c7096cd3745e@mail.gmail.com>
	<2f86c2480908071841h13009856hd8fcae167b1fadbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480908071841h13009856hd8fcae167b1fadbf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Aug 7, 2009 at 6:41 PM, Benjamin Blum<bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> For genericness, I'll have the down_read and up_read on the lock in
> do_fork() directly (instead of cgroup_fork and cgroup_post_fork as it
> is in this version of the patch).

rather, I'll keep the read-locking in the cgroup functions for now and
any future thing that wants the lock too can move them to fork.c, and
a comment to that effect.

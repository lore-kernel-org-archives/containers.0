From: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] signals: send_signal: use si_fromuser() to detect
	from_ancestor_ns
Date: Tue,  6 Oct 2009 11:01:04 -0700 (PDT)
Message-ID: <20091006180104.A433822@magilla.sf.frob.com>
References: <20091003171029.GA30442@us.ibm.com>
	<20091004021844.GA21006@redhat.com>
	<20091004021954.GC21006@redhat.com>
	<20091005181255.GE30442@us.ibm.com>
	<20091005182536.GA943@redhat.com>
	<20091005193738.GF30442@us.ibm.com>
	<20091005194415.GA4560@redhat.com>
	<20091006000631.GA4390@us.ibm.com>
	<20091006010956.GA28233@redhat.com>
	<20091006023401.GA10132@us.ibm.com>
	<20091006131821.GA8628@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Oleg Nesterov's message of  Tuesday,
	6 October 2009 15:18:21 +0200 <20091006131821.GA8628-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> Yes sure, init can't kill itself with or without these changes. But,
> I think this is supposed behaviour which we do not want to change?

I agree.  (Actually, I think init shouldn't be "protected" that way at all.
You shoot downwards, you get your foot.  But we are not talking about
changing the global init behavior, and I do think that the container-init
behavior should be as consistent as possible with what global init sees.)

It's possible to meaningfully swallow a kill() signal because then nothing
happens at all.  The exec failure cases are special because all the damage
is already done so there is no way to avoid dying, and SIGKILL is just
making it more formal and graceful.


Thanks,
Roland

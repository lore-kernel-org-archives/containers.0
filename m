From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.35: unshare(NEWNS) does not work inside a container anymore?
Date: Wed, 1 Sep 2010 11:28:33 -0500
Message-ID: <20100901162833.GA13274@hallyn.com>
References: <4C7CE137.5090009@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C7CE137.5090009-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Michael Tokarev (mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org):
> I just noticed a regression - immediately after updating
> kernel from 2.6.32 to 2.6.35 (I skipped .33 and .34).
> Namely, unshare(CLONE_NEWNS) stopped workin from within
> a container, like this:
> 
> unshare(CLONE_NEWNS)              = -1 EINVAL (Invalid argument)
> 
> There's no other fancy stuff going on around, just plain
> unshare and exec a new shell.

I'm not seeing this behavior.  I'm on 2.6.35-19-generic (ubuntu
maverick), created a lucid container with the standard template,
and tested with ns_exec
	(git clone git://git.sr71.net/~hallyn/cr_tests.git;
	 git checkout ns_exec; make ns_exec;
	 ns_exec -m /bin/bash;  play with mounts; exit)

Can you give us /proc/self/status and capsh --print output
from inside the container before you try to unshare, and
maybe strace output from the program you were using?

> What's wrong with 2.6.35 in this context?
> 
> Thanks.
> 
> /mjt
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

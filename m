From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Wed, 03 Sep 2008 16:26:29 +0200
Message-ID: <48BE9E95.3020706__49449.2982551039$1220452474$gmane$org@fr.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>	<20080903134951.GQ14473@hawkmoon.kerlabs.com>
	<20080903140636.GS14473@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080903140636.GS14473-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

 
> Forgot a global comment: you will probably get the same (rather pointless for a
> proof of concept, IMHO) requests as Oren got, to
> 1) improve coding style:
>   a) especially avoid error handling like:
> 	err = foo();
> 	if (!err)
> 		err = bar();
> 	if (!err)
> 		err = baz();
> 
> and prefer
> 	err = foo();
> 	if (err)
> 		goto foo_err;
> 	err = bar();
> 	...
> 
>   b) do not write conditions on a single line, like
> 	if (foo) bar;
> 
> 2) put arch-dependent code in arch/ subdirs.
> 3) I probably forgot other ones.

./scripts/checkpatch.pl catches most of it (and it does catch a few on your 
patches)

but Dave is even better ! :) 

Cheers, 

C.

 
> I obviously do not personally request you to take these requests into account ;)

From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Wed, 3 Sep 2008 18:53:42 +0400
Message-ID: <200809031853.44212.major@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<20080903140636.GS14473@hawkmoon.kerlabs.com>
	<48BE9E95.3020706@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48BE9E95.3020706-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 03 September 2008 18:26 Cedric Le Goater wrote:
> > Forgot a global comment: you will probably get the same (rather pointless
> > for a proof of concept, IMHO) requests as Oren got, to
> > 1) improve coding style:
> >   a) especially avoid error handling like:
> > 	err = foo();
> > 	if (!err)
> > 		err = bar();
> > 	if (!err)
> > 		err = baz();
> >
> > and prefer
> > 	err = foo();
> > 	if (err)
> > 		goto foo_err;
> > 	err = bar();
> > 	...
> >
> >   b) do not write conditions on a single line, like
> > 	if (foo) bar;
> >
> > 2) put arch-dependent code in arch/ subdirs.
> > 3) I probably forgot other ones.
>
> ./scripts/checkpatch.pl catches most of it (and it does catch a few on your
> patches)

Thanks, I will use this script to brush up the code.

>
> but Dave is even better ! :)
I'm waiting for his comments :)

Regards,
Andrey

>
> > I obviously do not personally request you to take these requests into
> > account ;)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

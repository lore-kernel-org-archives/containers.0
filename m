From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add AF_INET c/r support
Date: Tue, 23 Jun 2009 12:03:52 -0500
Message-ID: <20090623170352.GA22369@us.ibm.com>
References: <1245697976-29159-1-git-send-email-danms@us.ibm.com>
	<20090623145313.GA19332@us.ibm.com>
	<87ocsfyoey.fsf@caffeine.danplanet.com>
	<20090623161406.GA21423@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090623161406.GA21423-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > SH> ckpt_hdr_put(ctx, in) ?
> > 
> > Oops.
> > 
> > >> +	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
> > >> +	if (un->this < 0)
> > >> +		goto out;
> > >> +
> > >> +	if (sk->peer)
> > >> +		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
> > >> +	else
> > >> +		un->peer = 0;
> > >> +
> > >> +	if (un->peer < 0) {
> > >> +		ret = un->peer;
> > >> +		goto out;
> > >> +	}
> > 
> > SH> So what if new == 1 for either un->this or un->peer?  You never
> > SH> actually write them out to the checkpoint image?
> > 
> > On the checkpoint run, the new flag doesn't matter to us (and isn't
> > used here).  Am I missing something?
> 
> Well when is do_sock_file_checkpoint() going to be called?

Ok, I see, h is the actual socket details represented by
un->this.  I was glossing over the writing of h thinking
it was just a ckpt_hdr.

Looks good.

thanks,
-serge

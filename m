From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 4/7] allow killing tasks in your own or child userns
Date: Mon, 10 Jan 2011 16:51:51 -0600
Message-ID: <20110110225151.GA18944__20566.6103320711$1294699962$gmane$org@localhost>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211334.GD22564@mail.hallyn.com>
	<20110110215240.GA21351@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110215240.GA21351-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM
List-Id: containers.vger.kernel.org

Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> On Mon, Jan 10, 2011 at 09:13:34PM +0000, Serge E. Hallyn wrote:
> > +	const struct cred *cred = current_cred();
> > +	const struct cred *tcred = __task_cred(t);
> > +
> > +	if (cred->user->user_ns != tcred->user->user_ns) {
> > +		/* userids are not equivalent - either you have the
> > +		   capability to the target user ns or you don't */
> > +		if (ns_capable(tcred->user->user_ns, CAP_KILL))
> > +			return 1;
> > +		return 0;
> > +	}
> > +
> > +	/* same user namespace - usual credentials checks apply */
> > +	if ((cred->euid ^ tcred->suid) &&
> > +	    (cred->euid ^ tcred->uid) &&
> > +	    (cred->uid  ^ tcred->suid) &&
> > +	    (cred->uid  ^ tcred->uid) &&
> > +	    !ns_capable(tcred->user->user_ns, CAP_KILL))
> > +		return 0;
> > +
> > +	return 1;
> 
> Isn't that equal to this?
> 
> 	if (ns_capable(tcred->user->user_ns, CAP_KILL))
> 		return 1;
> 
> 	if (cred->user->user_ns == tcred->user->user_ns &&
> 	    (cred->euid == tcred->suid ||
> 	     cred->euid == tcred->uid ||
> 	     cred->uid == tcred->suid ||
> 	     cred->uid == tcred->uid))
> 		return 1;
> 
> 	return 0;
> 
> I would consider this much easier to read.

Unfortunately, it's actually not equivalent.  when capable()
returns success, then it sets the current->flags |= PF_SUPERPRIV.
If permission is granted based on userids and the capability
isn't needed, then we don't want to needlessly set PF_SUPERPRIV.

That's why I'm going to such lengths to call capable() as a last
resort.

I'm definately open to any ideas that'll get the code cleaner.

thanks,
-serge

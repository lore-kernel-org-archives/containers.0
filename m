From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/7] allow killing tasks in your own or child userns
Date: Tue, 11 Jan 2011 01:31:52 +0000
Message-ID: <20110111013152.GA23860__20675.7227228538$1294709516$gmane$org@mail.hallyn.com>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211334.GD22564@mail.hallyn.com>
	<20110110215240.GA21351@wavehammer.waldi.eu.org>
	<20110110225151.GA18944@localhost>
	<20110110232335.GA27029@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110232335.GA27029-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> On Mon, Jan 10, 2011 at 04:51:51PM -0600, Serge Hallyn wrote:
> > Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > > Isn't that equal to this?
> > > 
> > > 	if (ns_capable(tcred->user->user_ns, CAP_KILL))
> > > 		return 1;
> > > 
> > > 	if (cred->user->user_ns == tcred->user->user_ns &&
> > > 	    (cred->euid == tcred->suid ||
> > > 	     cred->euid == tcred->uid ||
> > > 	     cred->uid == tcred->suid ||
> > > 	     cred->uid == tcred->uid))
> > > 		return 1;
> > > 
> > > 	return 0;
> > > 
> > > I would consider this much easier to read.
> > 
> > Unfortunately, it's actually not equivalent.  when capable()
> > returns success, then it sets the current->flags |= PF_SUPERPRIV.
> > If permission is granted based on userids and the capability
> > isn't needed, then we don't want to needlessly set PF_SUPERPRIV.
> 
> Well, then switch the two if-clauses.

hup, will do, much nicer, thanks.

> What is this flag used for anyway? I only see it used in the accounting
> stuff, and if every user can get it, it is not longer useful.

hm, I'm not sure...  maybe noone is using it!

From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 4/7] allow killing tasks in your own or child userns
Date: Tue, 11 Jan 2011 00:23:35 +0100
Message-ID: <20110110232335.GA27029__28645.084918435$1294701856$gmane$org@wavehammer.waldi.eu.org>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211334.GD22564@mail.hallyn.com>
	<20110110215240.GA21351@wavehammer.waldi.eu.org>
	<20110110225151.GA18944@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110225151.GA18944@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jan 10, 2011 at 04:51:51PM -0600, Serge Hallyn wrote:
> Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > Isn't that equal to this?
> > 
> > 	if (ns_capable(tcred->user->user_ns, CAP_KILL))
> > 		return 1;
> > 
> > 	if (cred->user->user_ns == tcred->user->user_ns &&
> > 	    (cred->euid == tcred->suid ||
> > 	     cred->euid == tcred->uid ||
> > 	     cred->uid == tcred->suid ||
> > 	     cred->uid == tcred->uid))
> > 		return 1;
> > 
> > 	return 0;
> > 
> > I would consider this much easier to read.
> 
> Unfortunately, it's actually not equivalent.  when capable()
> returns success, then it sets the current->flags |= PF_SUPERPRIV.
> If permission is granted based on userids and the capability
> isn't needed, then we don't want to needlessly set PF_SUPERPRIV.

Well, then switch the two if-clauses.

What is this flag used for anyway? I only see it used in the accounting
stuff, and if every user can get it, it is not longer useful.

Bastian

-- 
Bones: "The man's DEAD, Jim!"

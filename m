From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 6/7] user namespaces: convert all capable checks in
	kernel/sys.c
Date: Mon, 10 Jan 2011 16:56:42 -0600
Message-ID: <20110110225642.GB18944__22424.4917197668$1294700343$gmane$org@localhost>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211406.GF22564@mail.hallyn.com>
	<20110110215937.GB21351@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110215937.GB21351-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
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
> On Mon, Jan 10, 2011 at 09:14:07PM +0000, Serge E. Hallyn wrote:
> > -	if (pcred->uid  != cred->euid &&
> > -	    pcred->euid != cred->euid && !capable(CAP_SYS_NICE)) {
> > +	if (pcred->user->user_ns != cred->user->user_ns &&
> > +	    pcred->uid  != cred->euid &&
> > +	    pcred->euid != cred->euid &&
> > +	    !ns_capable(pcred->user->user_ns, CAP_SYS_NICE)) {
> 
> I don't think this is correct. This would not error out if the both
> userns are the same. Because the same patern (check uid if same userns,
> otherwise only capability) shows up in several parts of the code, maybe
> this should be factored out.

Yes, I'm really not sure what I was thinking here.  Thanks!

> > @@ -496,7 +498,7 @@ SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
> >  	if (rgid != (gid_t) -1) {
> >  		if (old->gid == rgid ||
> >  		    old->egid == rgid ||
> > -		    capable(CAP_SETGID))
> > +		    ns_capable(current_user_ns(), CAP_SETGID))
> 
> Would it not possible to add another function (nsown_capable?) that
> checks against the own userns?

Good idea, I'll add that one.

thanks,
-serge

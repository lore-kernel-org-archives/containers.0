From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 6/7] user namespaces: convert all capable checks in
	kernel/sys.c
Date: Fri, 14 Jan 2011 16:02:17 +0100
Message-ID: <20110114150217.GC20945__1834.15774158693$1295017554$gmane$org@wavehammer.waldi.eu.org>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211406.GF22564@mail.hallyn.com>
	<20110110215937.GB21351@wavehammer.waldi.eu.org>
	<20110111052759.GA24970@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110111052759.GA24970-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 11, 2011 at 05:27:59AM +0000, Serge E. Hallyn wrote:
> Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > On Mon, Jan 10, 2011 at 09:14:07PM +0000, Serge E. Hallyn wrote:
> > > -	if (pcred->uid  != cred->euid &&
> > > -	    pcred->euid != cred->euid && !capable(CAP_SYS_NICE)) {
> > > +	if (pcred->user->user_ns != cred->user->user_ns &&
> > > +	    pcred->uid  != cred->euid &&
> > > +	    pcred->euid != cred->euid &&
> > > +	    !ns_capable(pcred->user->user_ns, CAP_SYS_NICE)) {
> > 
> > I don't think this is correct. This would not error out if the both
> > userns are the same. Because the same patern (check uid if same userns,
> > otherwise only capability) shows up in several parts of the code, maybe
> > this should be factored out.
> 
> Yeah, I'd really like to factor this out because it shows up everywhere
> and I have to think about it every time I look at it.  But each time it
> shows up, the uids being compared slightly change.  There must be some
> clever way of doing it, hopefully it'll fall out soon.

Well, then make mostly identical (_inline_) functions in one location
(include/linux/cred.h comes in mind).  You can ask later why they have
to be different.

You are scaling the complexity up. So you need to make it somehow
manageable, and even slightly different versions in one place are much
easier to handle than the same in many different places.

kill_ok_by_cred would be:
cred_check_euid_suid(struct task_struct *p, X capable)

set_one_prio_perm would be:
cred_check_euid_euid(struct task_struct *p, X capable)

Bastian

-- 
	"Life and death are seldom logical."
	"But attaining a desired goal always is."
		-- McCoy and Spock, "The Galileo Seven", stardate 2821.7

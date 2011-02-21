From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] userns: let clone_uts_ns() handle setting uts->user_ns
Date: Mon, 21 Feb 2011 13:58:03 +0000
Message-ID: <20110221135803.GA15871__32287.1410557584$1298296765$gmane$org@mail.hallyn.com>
References: <20110221040156.GA12580@mail.hallyn.com> <4D623886.3010505@free.fr>
	<20110221134129.GA15563@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110221134129.GA15563-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On 02/21, Daniel Lezcano wrote:
> >
> > On 02/21/2011 05:01 AM, Serge E. Hallyn wrote:
> >> To do so we need to pass in the task_struct who'll get the utsname,
> >> so we can get its user_ns.
> >>
> >> -extern struct uts_namespace *copy_utsname(unsigned long flags,
> >> -					struct uts_namespace *ns);
> >> +extern struct uts_namespace *copy_utsname(struct task_struct *tsk,
> >> +					  unsigned long flags,
> >> +					  struct uts_namespace *ns);
> >
> > Why don't we pass 'user_ns' instead of 'tsk' ? that will look
> > semantically clearer for the caller no ?
> > (example below).
> > ...
> >
> > new_nsp->uts_ns = copy_utsname(flags, tsk->nsproxy->uts_ns, task_cred_xxx(tsk, user)->user_ns);
> 
> To me tsk looks more readable, I mean
> 
> 	new_nsp->uts_ns = copy_utsname(flags, tsk);
> 
> copy_utsname() can find both uts_ns and user_ns looking at task_strcut.

Uh, yeah.  I should remove the 'ns' argument there shouldn't I.

Daniel, does that sway your opinion then?

thanks,
-serge

From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Thoughts on tightening up user namespace creation
Date: Wed, 9 Mar 2016 13:21:03 -0600
Message-ID: <20160309192103.GA2523@mail.hallyn.com>
References: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw@mail.gmail.com>
	<CAGXu5jLB5==RAs9YrsPi4m6ZBPn3UtbCzagu_+gr-rtSgKzB1Q@mail.gmail.com>
	<1457549467.650797.544465346.49653120@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1457549467.650797.544465346.49653120-2RFepEojUI2N1INw9kWLP6GC3tUn3ZHUQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Colin Walters (walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org):
> On Wed, Mar 9, 2016, at 01:14 PM, Kees Cook wrote:
> > On Mon, Mar 7, 2016 at 9:15 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> > > Hi all-
> > >
> > > There are several users and distros that are nervous about user
> > > namespaces from an attack surface point of view.
> > >
> > >  - RHEL and Arch have userns disabled.
> > >
> > >  - Ubuntu requires CAP_SYS_ADMIN
> > >
> > >  - Kees periodically proposes to upstream some sysctl to control
> > > userns creation.
> > 
> > And here's another ring0 escalation flaw, made available to
> > unprivileged users because of userns:
> > 
> > https://code.google.com/p/google-security-research/issues/detail?id=758
> 
> Looks like Andy won't have to eat his hat ;)
> 
> > The change in attack surface is _substantial_. We must have a way to
> > globally disable userns.
> 
> No one would object if it was enabled but only accessible to
> CAP_SYS_ADMIN though, right?  This could be useful for 

I think that would be terrible.  I'd have to expose all of CAP_SYS_ADMIN
to allow use of CLONE_NEWUSER.  I'd be more interested in a new CAP_NEWUSER
capability.  Then systems wanting to support unprivileged users doing user
namespaces could set a pam module giving certain users that cap in pI, and
set it on fI on their container managers.  Userspace has to give access to
mapped uids through /etc/subuid too, so it's not *so* huge added hurdle.
Well that's not quite true - with empty subuid, users can create a userns
with no mapped userids which in itself is useful for sandboxing.

The biggest problem with a CAP_NEWUSER would be that it's more inherently
permanent than a new sysctl.  The increase in attack surface is real, but
over time I'd like to think that we will have dealt with it and should be
able to make CLONE_NEWUSER unprivileged.  Because what we have is an
implementation issue (not in user namespaces), not a design issue.

And I do agree the issue is real.

-serge

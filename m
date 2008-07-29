From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/6] user namespaces: move user_ns from nsproxy into
	user struct
Date: Tue, 29 Jul 2008 12:59:32 -0500
Message-ID: <20080729175932.GA365@us.ibm.com>
References: <20080726002700.GA29686@us.ibm.com>
	<20080726002735.GB29874@us.ibm.com>
	<m1k5f5it4i.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1k5f5it4i.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> >>From ec5f54faf5afd16cb6cef40ebaaf3da25989d185 Mon Sep 17 00:00:00 2001
> > From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Date: Thu, 24 Jul 2008 17:52:41 -0500
> > Subject: [PATCH 2/6] user namespaces: move user_ns from nsproxy into user struct
> >
> > When we get the sysfs support needed to support fair user scheduling
> > along with user namespaces, then we will need to be able to get the
> > user namespace from the user struct.
> >
> > So we need the user_ns to be a part of struct user.  Once we can
> > access it from tsk->user, we no longer have a use for
> > tsk->nsproxy->user_ns.
> 
> Is this true?  Even in the general case of supporting setuid and setgid
> and everything else that potentially is in the user namespace?

Sure.  At any time we can get tsk->user->user_ns, and from that we can
get tsk->user->user_ns->creator.

> I certainly support the cleanups you have made for the reasons you describe.
> I think however that there is there are no technical reasons not to have
>  nsproxy->user_ns after the changes have been made.

Well I ended up tossing it to clarify my thinking about the refcounting.
With that done, I think we could safely not have nsproxy pin the
user_ns, trusting the tsk->user to pin it instead.

But keeping it in two places just seems needlessly complicated.

> I also agree that
> there are no technical reasons for keeping nsproxy->user_ns at the moment.

What is your preference?

> > When a user_namespace is created, the user which created it is
> > marked as its 'creator'.  The user_namespace pins the creator.
> > Each userid in a user_ns pins the user_ns.  This keeps refcounting
> > nice and simple.
> 
> Eric

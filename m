From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Wed, 06 Jan 2010 12:57:30 -0800
Message-ID: <m1k4vvuf2d.fsf@fess.ebiederm.org>
References: <20100106062809.GA17064@us.ibm.com>
	<m17hrv18ad.fsf@fess.ebiederm.org> <20100106173536.GD15784@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100106173536.GD15784-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed\, 6 Jan 2010 11\:35\:36 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > So i was thinking about how to safely but incrementally introduce
>> > targeted capabilities - which we decided was a prereq to making VFS
>> > handle user namespaces - and the following seemed doable.  My main
>> > motivations were (in order):
>> >
>> >         1. don't make any unconverted capable() checks unsafe
>> >         2. minimize performance impact on non-container case
>> >         3. minimize performance impact on containers
>> 
>> My motivation is a bit different.  I would like to get to the
>> unprivileged creation of new namespaces.  It looks like this gets us
>> 90% of the way there, with only potential uid confusion issues left.
>
> Yup, that was actually what I was thinking about last night when I decided
> to give it a shot :)  IMO, my patch + a dummy version of user_namespaces
> for vfs (done in a clean way that can be an incremental step toward full
> vfs userns support - which I haven't yet thought through) is enough to
> give you safe fully unprivileged containers.  Now with the API I have,
> you'd have a program with either setuid-root or cap_sys_admin,cap_setpcap=pe
> which does the prctl and the unshares, but it would theoretically be safe
> to hand that program to unprivileged users.

Yes.

>> I still need to handle getting all caps after creation but otherwise I
>> think I have a good starter patch that achieves all of your goals.
>
> Well in my patch we don't need to clear out the bounding set, or set
> SETUID_NOROOT - so running a setuid root program or becoming root should
> still give you capabilities!  They'll just be targeted at your container.
>
> I really think this is what you need.

Yes.  So far things don't look too hard.  What I meant is that after
CLONE_USERNS you should become uid 0 with a full set of capabilities in
a new user namespace.  Those capabilities aren't good for anything because
they are user namespace relative.

I believe we have a bug today where the new uid 0 does not have a full set
of capabilities, but that it is hidden because only uid 0 can unshare
the user namespace.

>> Of course kill_permission needs the checks you have suggested as well.
>
> Ok, I can't look at your patch in detail right now and don't quite get
> where you're going with a quick glance, so will look in closer detail
> later.   Will also think about a way to get "just-enough" vfs userns
> support to completely give you what you need for privileged users in
> unprivileged containers.

Sounds good.  That uid 0 problem is particularly interesting, because half
the world is owned by uid 0.

As for my patch.  The heart of it is the cap_capable implementation.
The rest is just the obvious consequences of adding a user_namespace parameter
to a security->capable().

int cap_capable(struct task_struct *tsk, const struct cred *cred,
		struct user_namespace *targ_ns, int cap, int audit)
{
	for (;;) {
		/* Do we have the necessary capabilities? */
		if (targ_ns == cred->user->user_ns)
			return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
	
		/* The creator of the user namespace has all caps. */
		if (targ_ns->creator == cred->user)
			return 0;
	
		/* Have we tried all of the parent namespaces? */
		if (targ_ns == &init_user_ns)
			return -EPERM;
	
		/* If you have the capability in a parent user ns you have it
		 * in the over all children user namespaces as well, so see
		 * if this process has the capability in the parent user
		 * namespace.
		 */
		targ_ns = targ_ns->creator->user_ns;
	}
}

Eric

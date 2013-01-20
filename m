From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RESEND] userns: enable tmpfs support for user namespace
Date: Sun, 20 Jan 2013 19:24:03 +0000
Message-ID: <20130120192403.GA26200@mail.hallyn.com>
References: <1358331945-4106-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130116143532.GA4035@sergelap> <50F74EC6.60004@cn.fujitsu.com>
	<20130117171451.GA31219@sergelap> <87fw1zbd03.fsf@xmission.com>
	<20130118042404.GA15079@sergelap> <87vcavys6k.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87vcavys6k.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> >> 
> >> > I actually was waiting for Eric to do it, but I'll happily send it
> >> > to linux-fsdevel and lkml (in a bit).
> >> 
> >> I might just.
> >> 
> >> I will take a look at this in a week or so.  I want to get through the
> >> core userspace bits first so I can just cross those off my list of
> >> things that need to be done.
> >> 
> >> Eric
> >
> > Ok, I'll wait on sending it then - thanks.
> 
> Next up is my patch to shadow-utils and then taking a good hard stare at
> what is left kernel side.
> 
> One of the questions I need to answer is:  Do cgroups actually work
> for what needs to be limited?  Or does the the focus of cgroups on
> processes without other ownership in objects fundamentally limit what

Note that with pam (and presumably through systemd) you can tie a user to
a cgroup at login.  You could chown the cgroup to the user, counting on
proper hierarchy enforcement to not let the user escape, while the user
could still descend in the hierarchy for flexibility (i.e. creating his
own containers).

> can be expressed with cgroups in a problematic way.  In which case would
> some hierarchical limits based on user namespaces and rlimits be easier
> to implement and make more sense.

1. most distros enable cgroups, so the penalty is being paid anyway.
2. if there are real gains to be had by adding another set of limits
   as mentioned here, then I hope someone will look into it.  But that
   it separate from the question of whether the memory cgroup is
   enough to justify allowing tmpfs mounts in user namespaces.

   We could make the FS_USERNS_MOUNT flag in tmpfs conditional on
   the memory cgroup being on?  Though that doesn't guarantee that
   the cgroups will be properly configured.

> I think the answer will be that cgroups are good enough but that
> question certainly needs looking at.
> 
> Anyway.  shadow-utils, minimal tmpfs, minimal devpts, and then the rest.

Sounds good - thanks.

Is there a git tree for the shadow-utils changes which people can start
looking at?

-serge

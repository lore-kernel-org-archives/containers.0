From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH review 5/6] userns: Allow the userns root to mount ramfs.
Date: Sun, 27 Jan 2013 18:23:21 +0000
Message-ID: <20130127182321.GA338@mail.hallyn.com>
References: <87ehh8it9s.fsf@xmission.com> <87ip6khe7w.fsf@xmission.com>
	<20130126212918.GG11274@mail.hallyn.com>
	<87bocb5f8a.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bocb5f8a.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> 
> >> There is no backing store to ramfs and file creation
> >> rules are the same as for any other filesystem so
> >> it is semantically safe to allow unprivileged users
> >> to mount it.
> >> 
> >> The memory control group successfully limits how much
> >> memory ramfs can consume on any system that cares about
> >> a user namespace root using ramfs to exhaust memory
> >> the memory control group can be deployed.
> >
> > But that does mean that to avoid this new type of attack, when handed a
> > new kernel (i.e. by one's distro) one has to explicitly (know about and)
> > configure those limits.  The "your distro should do this for you"
> > argument doesn't seem right.  And I'd really prefer there not be
> > barriers to user namespaces being compiled in when there don't have to
> > be.
> 
> The thing is this really isn't a new type of attack.  There are a lot of

Of course.

> existing methods to exhaust memory with the default configuration on
> most distros.  All this is is a new method to method to implement such
> an attack.

Right.

...

> > What was your thought on the suggestion to only allow FS_USERNS_MOUNT
> > mounts by users confined in a non-init memory cgroup?
> 
> Over design.

Ok.  Fair.

> So shrug.  The mechanisms that I am suggesting people use already exist,
> and appear to have been present long enough to have made it into debian
> stable release February of 2011.

Heh - right, libcgroup does have its problems, but I don't think there
are any problems with the pam module actually.  I'm meant to talk with
the debian maintainer for them soon, will test.

thanks,
-serge

From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Sun, 14 Feb 2010 22:05:29 -0600
Message-ID: <20100215040529.GA20519@us.ibm.com>
References: <20100106062809.GA17064@us.ibm.com>
	<m17hrv18ad.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m17hrv18ad.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
> > So i was thinking about how to safely but incrementally introduce
> > targeted capabilities - which we decided was a prereq to making VFS
> > handle user namespaces - and the following seemed doable.  My main
> > motivations were (in order):
> >
> >         1. don't make any unconverted capable() checks unsafe
> >         2. minimize performance impact on non-container case
> >         3. minimize performance impact on containers
> 
> My motivation is a bit different.  I would like to get to the
> unprivileged creation of new namespaces.  It looks like this gets us
> 90% of the way there, with only potential uid confusion issues left.

Just a pair of instances of uid comparison are now addressed in

	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/feb13.userns.uid_equivs

which has your patch "taking a crack at targeted capabilities" at its
core.  Talk about your baby steps...  But I need to go back and re-read
what we'd discussed over the last few years about how we wanted to
tag superblocks/mounts->inodes before I go on.

Anyway now uid equivalence checks are ns-aware for basic vfs_permission
and task kill at least.  It's a start.

-serge

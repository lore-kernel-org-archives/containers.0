From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] newuidmap, newgidmap: New suid helpers for using
	subordinate uids and gids
Date: Sun, 27 Oct 2013 23:53:44 +0000
Message-ID: <20131027235344.GA14373@mail.hallyn.com>
References: <87d2wxshu0.fsf@xmission.com> <87ehhdpoag.fsf@xmission.com>
	<20131025203025.GA2467@mail.hallyn.com>
	<87zjpw278b.fsf@xmission.com> <20131026023346.GA2753@ac100>
	<87iowjya4j.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87iowjya4j.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> >> 
> >> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> >
> >> > Hi,
> >> >
> >> >> +static bool verify_range(struct passwd *pw, struct map_range *range)
> >> >> +{
> >> >> +	/* An empty range is invalid */
> >> >> +	if (range->count == 0)
> >> >> +		return false;
> >> >> +
> >> >> +	/* Test /etc/subuid */
> >> >> +	if (have_sub_uids(pw->pw_name, range->lower, range->count))
> >> >> +		return true;
> >> >
> >> > I think the have_sub_uids() test should be skipped if we started
> >> > out as root.  Is there a reason not to do that?
> >> 
> >> The only reason I can see for root to use this binary is if it a flavor
> >> of root that has dropped some capbilities.  Is there a reason for root
> >> to use newuidmap and newgid map at all?
> >
> > Of course.  It keeps things simpler for creating mapped containers.
> > Otherwise we have to special-case the "i am root" vs "i am not root"
> > case when untarring a rootfs for a container.
> 
> I guess my practical question is don't we want to reserve a range of
> subuid's for root owned containers as well.  Just so that we know
> someone is using those uids and we don't get them allocated to another
> purpose?
> 
> Or am I missing something here?

That's a not unreasonable argument, but two counters:  1. "someone"
using the uids used by root would mean root assigned those uids to
someone.  That's a misconfiguration, in other words this is keeping
root from shooting himself in the foot.  It's not in the kernel though,
so maybe it's ok.  2.  I like to think that any time something fails
as my user, if it fails due to permission reasons, then if I run it
as root it should work.  That's useful for debugging, and just seems
coherent with how most things work.

-serge

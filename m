From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] newuidmap, newgidmap: New suid helpers for using
	subordinate uids and gids
Date: Fri, 25 Oct 2013 21:33:46 -0500
Message-ID: <20131026023346.GA2753@ac100>
References: <87d2wxshu0.fsf@xmission.com> <87ehhdpoag.fsf@xmission.com>
	<20131025203025.GA2467@mail.hallyn.com>
	<87zjpw278b.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87zjpw278b.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >
> > Hi,
> >
> >> +static bool verify_range(struct passwd *pw, struct map_range *range)
> >> +{
> >> +	/* An empty range is invalid */
> >> +	if (range->count == 0)
> >> +		return false;
> >> +
> >> +	/* Test /etc/subuid */
> >> +	if (have_sub_uids(pw->pw_name, range->lower, range->count))
> >> +		return true;
> >
> > I think the have_sub_uids() test should be skipped if we started
> > out as root.  Is there a reason not to do that?
> 
> The only reason I can see for root to use this binary is if it a flavor
> of root that has dropped some capbilities.  Is there a reason for root
> to use newuidmap and newgid map at all?

Of course.  It keeps things simpler for creating mapped containers.
Otherwise we have to special-case the "i am root" vs "i am not root"
case when untarring a rootfs for a container.

> Otherwise I think it makes sense to enforce whatever the system choosen
> policy is on root, because root is opting in.
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

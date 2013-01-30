From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Wed, 30 Jan 2013 11:38:16 +0400
Message-ID: <20130130073816.GA14301@cachalot>
References: <87d2wxshu0.fsf@xmission.com> <20130130053542.GA6615@cachalot>
	<87vcafyy0k.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87vcafyy0k.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

On Tue, Jan 29, 2013 at 22:40 -0800, Eric W. Biederman wrote:
> Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> writes:
> > Why patch shadow tools?  Why not implement the feature as a PAM
> > module?
> 
> I need hooks into useradd and userdel to managed the subordinate
> user ids and group ids when users are added and removed from the
> system.  PAM doesn't appear to have any hooks like that at all.
> 
> Furthermore shadow-utils is where other uids and gids are allocated
> and it makes sense to keep the allocation functions together so if it
> makes sense they can talk to each other
> 
> > All other capabilities granting things are implemented as PAM modules:
> > pam_group, pam_namespace, pam_cap.
> 
> Except when you want to program the mapping is not at login time.
[...]

Understood.  So, a user needs to:

1) be able to reserve [ug]id ranges (more specifically, root allocated
the range).  These ranges should not be allocated by useradd, etc. afterwards.

2) be able to write to uid_map/gid_map files anytime with reserved
values of current user.

In this case patching shadow utils looks appropriate, yes.


Thanks,

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments

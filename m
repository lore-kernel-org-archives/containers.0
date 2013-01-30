From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Wed, 30 Jan 2013 09:35:42 +0400
Message-ID: <20130130053542.GA6615@cachalot>
References: <87d2wxshu0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87d2wxshu0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Hi Eric,

On Tue, Jan 22, 2013 at 01:11 -0800, Eric W. Biederman wrote:
> The kernel support for user namespaces allows ordinary users to use
> multiple uids and gids if they can get a trusted program to tell the
> kernel the set of subordinate uids and gids they are allowed to use.
> 
> This is my work to make that trusted program.
> Two new files are added /etc/subuid /etc/subgid that specify
> ranges of uids and gids that users may uses.
> 
> useradd, and newusers are modifed to add users to those files.
> 
> userdel is modeifed to remove users from those files.
> 
> usermod is modified to give manual control of what goes in those files.
> 
> newuidmap and newgidmap read the new files and update
> /proc/[pid]/uid_map and /proc/[pid]/gid_map respectively
> as requested by their command line parameters and as allowed
> by the /etc/subuid and /etc/subgid.
> 
> The following patches are against the current developent trunk
> of pkg-shadow svn rev 3745.  With minor tweaking of man/Makefile.am
> these patches also apply to shadow 4.1.5.

Why patch shadow tools?  Why not implement the feature as a PAM module?
All other capabilities granting things are implemented as PAM modules:
pam_group, pam_namespace, pam_cap.  I don't see why it cannot be fully
modularized, a common admin doesn't need multiple uid/gid user_ns for
non-root users at all, why patch basic tools?

Thanks,

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments

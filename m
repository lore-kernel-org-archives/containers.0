From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Tue, 6 Aug 2013 14:54:03 +0000
Message-ID: <20130806145403.GA20913@mail.hallyn.com>
References: <87d2wxshu0.fsf@xmission.com>
	<20130728171451.GX5670@mykerinos.kheops.frmug.org>
	<87r4eilg6y.fsf@xmission.com>
	<11218395-363e-46cd-b7a1-4488079a4986@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <11218395-363e-46cd-b7a1-4488079a4986-2ueSQiBKiTY7tOexoI0I+QC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org wrote:
> 
> >Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org> writes:
> >
> >> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >>> 
> >>> The kernel support for user namespaces allows ordinary users to use
> >>> multiple uids and gids if they can get a trusted program to tell the
> >>> kernel the set of subordinate uids and gids they are allowed to use.
> >>> 
> >>> This is my work to make that trusted program.
> >>> Two new files are added /etc/subuid /etc/subgid that specify
> >>> ranges of uids and gids that users may uses.
> >>> 
> >>> useradd, and newusers are modifed to add users to those files.
> >>> 
> >>> userdel is modeifed to remove users from those files.
> >>> 
> >>> usermod is modified to give manual control of what goes in those
> >files.
> >>> 
> >>> newuidmap and newgidmap read the new files and update
> >>> /proc/[pid]/uid_map and /proc/[pid]/gid_map respectively
> >>> as requested by their command line parameters and as allowed
> >>> by the /etc/subuid and /etc/subgid.
> >>> 
> >>> The following patches are against the current developent trunk
> >>> of pkg-shadow svn rev 3745.  With minor tweaking of man/Makefile.am
> >>> these patches also apply to shadow 4.1.5.
> >>> 
> >>> Eric W. Biederman (11):
> >>>       Documentation for /etc/subuid and /etc/subgid
> >>>       login.defs.5: Document the new variables in login.defs
> >>>       Implement commonio_append.
> >>>       Add backend support for suboridnate uids and gids
> >>>       Implement find_new_sub_uids find_new_sub_gids
> >>>       userdel: Add support for removing subordinate user and group
> >ids.
> >>>       useradd: Add support for subordinate user identifiers
> >>>       Add support for detecting busy subordinate user ids
> >>>       usermod: Add support for subordinate uids and gids.
> >>>       newusers: Add support for assiging subordinate uids and gids.
> >>>       newuidmap,newgidmap: New suid helpers for using subordinate
> >uids and gids
> >>> ---
> >>
> >> OK, now we're ready for this.
> >>
> >> Eric, I have no skills to decide whether your patches can be included
> >> or not. My proposal is to go ahead and include them in the upcomign
> >> 4.2 release, that will be compiled and uploaded in Debian as soon as
> >> released, so that it gets extensive testing.
> >>
> >> We now have an "upstream" git repository at
> >>
> >>
> >> http://github.com/shadow-maint/shadow.git
> >>
> >> Would you mind pushing your set of patches there?
> >>
> >> That requires an account on github and include you in the project
> >> members (Serge Hallyn can do that).
> >>
> >> I would prefer this over committing/pushing myself.
> >>
> >> I really apologize for the too long delay working on this. We now
> >need
> >> to revive shadow's development.
> >
> >Understood.
> >
> >At this point Serge has taken over stewardship of those patches and has
> >a version with all of the known bug fixes applied that has been
> >reviewed
> >and included in Ubuntu.  So I expect the most responsible way is to
> >just
> >pull the branch with those changes that is in Ubuntu.
> >
> >Serge does that sound right?
> >
> >Eric
> 
> Sorry think I just sent a private reply.  To repeat, I can do this when I'm back at a kbd, maybe Friday, definately Monday.

I rebased and pushed the patchset yesterday.

thanks,
-serge

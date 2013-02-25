From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Mon, 25 Feb 2013 08:34:51 -0600
Message-ID: <20130225143451.GE4387__7040.32386788658$1361802935$gmane$org@sergelap>
References: <87d2wxshu0.fsf@xmission.com> <51276189.5040803@parallels.com>
	<87zjyw489z.fsf@xmission.com> <5127A657.3010909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5127A657.3010909-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 02/22/2013 08:34 PM, Eric W. Biederman wrote:
> > Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> > 
> >> On 01/22/2013 01:11 PM, Eric W. Biederman wrote:
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
> >>> usermod is modified to give manual control of what goes in those files.
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
> >>>       userdel: Add support for removing subordinate user and group ids.
> >>>       useradd: Add support for subordinate user identifiers
> >>>       Add support for detecting busy subordinate user ids
> >>>       usermod: Add support for subordinate uids and gids.
> >>>       newusers: Add support for assiging subordinate uids and gids.
> >>>       newuidmap,newgidmap: New suid helpers for using subordinate uids and gids
> >>
> >> Hi,
> >>
> >> Is there any intention to merge this (or any later version thereof) ?
> >> I intend to start excluding uid ranges for containers usage in OpenVZ,
> >> and support for that in tooling would come in handy.
> > 
> > I don't know what the state of the main pkg-shadow package is.  I have
> > heard anything and the repository seems to have been dormant since the
> > last release almost a year ago.
> > 
> > However the last I heard Serge was working on getting these changes into
> > Ubuntu.
> > 
> > So the intention is to get this code merged but I don't know what more
> > needs to be done at this point.
> > 
> I understand, this was more a question for the package maintainers.
> It would be interesting for us to have those changes more widely
> available than just @Ubuntu

Well, I would aim to get it into Debian, from where it should make it
into all its downstreams eventually...  But I know that's not what you
mean :)

Note that the core of this really isn't a big deal, and you can easily
implement your own distro-independent wrappers.  Just provide an easy
tool for admins to assign subuids to users, and a small setuid-root
binary to allow users, subject to those constraints, to write to
/proc/$$/uid_maps.

Shadow integration will be nice, but for your use case you should be
able to by-step it until shadow integration is complete.

-serge

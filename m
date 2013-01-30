From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Tue, 29 Jan 2013 22:40:11 -0800
Message-ID: <87vcafyy0k.fsf@xmission.com>
References: <87d2wxshu0.fsf@xmission.com> <20130130053542.GA6615@cachalot>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130130053542.GA6615@cachalot> (Vasily Kulikov's message of
	"Wed, 30 Jan 2013 09:35:42 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk
	(man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> writes:

> Hi Eric,
>
> On Tue, Jan 22, 2013 at 01:11 -0800, Eric W. Biederman wrote:
>> The kernel support for user namespaces allows ordinary users to use
>> multiple uids and gids if they can get a trusted program to tell the
>> kernel the set of subordinate uids and gids they are allowed to use.
>> 
>> This is my work to make that trusted program.
>> Two new files are added /etc/subuid /etc/subgid that specify
>> ranges of uids and gids that users may uses.
>> 
>> useradd, and newusers are modifed to add users to those files.
>> 
>> userdel is modeifed to remove users from those files.
>> 
>> usermod is modified to give manual control of what goes in those files.
>> 
>> newuidmap and newgidmap read the new files and update
>> /proc/[pid]/uid_map and /proc/[pid]/gid_map respectively
>> as requested by their command line parameters and as allowed
>> by the /etc/subuid and /etc/subgid.
>> 
>> The following patches are against the current developent trunk
>> of pkg-shadow svn rev 3745.  With minor tweaking of man/Makefile.am
>> these patches also apply to shadow 4.1.5.
>
> Why patch shadow tools?  Why not implement the feature as a PAM
> module?

I need hooks into useradd and userdel to managed the subordinate
user ids and group ids when users are added and removed from the
system.  PAM doesn't appear to have any hooks like that at all.

Furthermore shadow-utils is where other uids and gids are allocated
and it makes sense to keep the allocation functions together so if it
makes sense they can talk to each other

> All other capabilities granting things are implemented as PAM modules:
> pam_group, pam_namespace, pam_cap.

Except when you want to program the mapping is not at login time.
Programming the mapping needs to happen when a user namespace is set up.
The admin of the user namespace knows which uids and gids will be used
in that user namespace.  The system is configured to know which uids
and gids that user can map to.

> I don't see why it cannot be fully
> modularized, a common admin doesn't need multiple uid/gid user_ns for
> non-root users at all, why patch basic tools?

The common admin doesn't _yet_ need multiple uid/gid user_ns for
non-root users.

As of linux 3.8 you don't need any special privilege to create a user
namespace.  Once you have a user namespace you can create other
namespaces.  This is good for building containers for light weigh
virtualization and testing and this is good for sandboxing subprocess.
The chrome-browser sandbox uses a setuid application to set a up
namespaces for this purpose.

A couple of extra uids should make the sandboxing uses much more
complete.  Not to mention the advantages of being able to run another
distro in a lighter more portable form than hardware virtualization.

Given the habit of the distributions of enabling everything possible I
believe it will become common for distributions to allocate multiple
uids and gids to users by default.

Eric

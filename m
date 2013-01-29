From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Tue, 29 Jan 2013 14:28:10 -0800
Message-ID: <87libb4oat.fsf@xmission.com>
References: <87d2wxshu0.fsf@xmission.com> <1359483337.32505.57@driftwood>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1359483337.32505.57@driftwood> (Rob Landley's message of "Tue,
	29 Jan 2013 12:15:37 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk
	(man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org> writes:

> I am waaaay behind on email.
>
> On 01/22/2013 03:11:19 AM, Eric W. Biederman wrote:
>> 
>> The kernel support for user namespaces allows ordinary users to use
>> multiple uids and gids if they can get a trusted program to tell the
>> kernel the set of subordinate uids and gids they are allowed to use.
>
> Could you give an example of this? (If this takes off I'll probably  
> want to add support to toybox, but from the man pages I don't  
> understand what it's for.)

The interesting programs for me are useradd, userdel, which I don't
think toybox plays with and newuidmap and newgidmap.

The primary application is running unprivileged containers with user
namespaces.  A user namespace allows setuid and setgid in between
uids and gids that are mapped for that user namespace.

/proc/<pid>/uid_map gives the mapping from uids in the user namespace
to uids on the host system.  The format is multiple lines of the form:
<userns_uid> <system_uid> <count>

/proc/<pid>/gid_map has the same format excpet for gids.

/etc/subuid and /etc/subgid list the extra system uids that we will
allow a user to use in the context of user namespaces.

The idea is that unshare or clone will be used to create a new process
and then wait while another process of the same user outside of the
user namespace will call newuidmap and newgidmap to write to set the
mappings.

I have appened a trivial command line example of using newuidmap and
newgidmap and unshare.

Without privileged helper programs people are limited to using their
own uid as the underlying uid in a user-namespace which seriously
limits what kind of systems you can run in a container.

>> This is my work to make that trusted program.
>> Two new files are added /etc/subuid /etc/subgid that specify
>> ranges of uids and gids that users may uses.
>
> They must use a contiguous range with count, not  
> "landley:4000-4999,6103,7002-7005"?

No.  Although I can see the argument for that format.
Using multiple ranges per line is harder to parse, harder to ensure
that you properly handle arbitarily long lines, and harder to tell
if the last number in the range is included or not.  And I have been
burnt badly by implementations having arbitrarly short line limits in
/etc/group.

So to encode your example it would be:
landley:4000:1000
landley:6103:1
landley:7002:4

As I allow multiple lines for the same user.

In practice I only expect there will need to be a single line per user
in most instances as a single range should be enough for most uses.

Also a contiguous range is important for sanity so a sysadmin can look
at a set of uids and easily recognize they all belong to fred, and even
more important when working with /proc/<pid>/uid_map as the kernel
currently only supports 5 uid mapping ranges.

>> useradd, and newusers are modifed to add users to those files.
>> userdel is modeifed to remove users from those files.
>> usermod is modified to give manual control of what goes in those  
>> files.
>
>> newuidmap and newgidmap read the new files and update
>> /proc/[pid]/uid_map and /proc/[pid]/gid_map respectively
>> as requested by their command line parameters and as allowed
>> by the /etc/subuid and /etc/subgid.
>
> I'm not finding uid_map and gid_map in  
> Documentation/filesystems/proc.txt, is this a pending patch?

Interesting.  I hadn't even registered on the existence of
Documentation/filesystems/proc.txt.

I have sent out man page patches to document or at least start
documenting uid_map and gid_map.  But having just done a git update
it looks like Michael hasn't pushed those changes out in the man-pages
git tree yet. :(  He may be waiting until 3.8 goes final.

Eric

----
#!/bin/bash
set -x
set -e

export IFIFO=/tmp/shadow-test-$$-in
export OFIFO=/tmp/shadow-test-$$-out
rm -f $IFIFO $OFIFO
mkfifo $IFIFO
mkfifo $OFIFO
unshare --user /bin/bash <<'EOF' &
echo waiting-for-uid-and-gid-maps > $OFIFO
read LINE < $IFIFO
$SHELL -l -i < /dev/tty > /dev/tty 2> /dev/tty
EOF
child=$!
read LINE < $OFIFO
uid=$(id --user)
gid=$(id --group)
newuidmap $child 0 $uid 1 1 100000 9999 65534 109999 1
newgidmap $child 0 $gid 1 1 100000 9999 65534 109999 1
echo uid-and-gid-maps > $IFIFO
wait $child
rm -f $IFIFO $OFIFO

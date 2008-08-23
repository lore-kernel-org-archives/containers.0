From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [0/10] User namespaces: introduction
Date: Fri, 22 Aug 2008 20:19:23 -0700
Message-ID: <m1sksw770k.fsf@frodo.ebiederm.org>
References: <20080822194513.GA10262@us.ibm.com>
	<m1d4k0ixzp.fsf@frodo.ebiederm.org>
	<20080823011731.GA22737@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080823011731.GA22737-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 22 Aug 2008 20:17:31 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> It definately seems to make sense in terms of the security
> implications.  And solving this before the filesystem handlers seems
> to make sense too.  Although I would like to get the first 3 patches upstream
> pretty soon, as I believe they are proper fixes.

Reasonable.  I'm not certain about free_user continuing to be an inline
function as it seems a bit non-trivial, but otherwise that sounds correct.

> But wrt userns:capability, the problem that brings to mind is that of
> referring to the userns.  Do we use the userspace-exported id, or do we
> use the actual in-kernel user_ns?  If we use the in-kernel user_ns,
> then we'd have to take a ref for each cap, yuck.  But you had wanted to
> use 'mount' to only have filesystems associate userspace ids with the
> in-kernel struct user_ns, so that complicates the idea of having
> capabilities refer to those.

I don't think so.  In the standard security model there are only 2
intersections between the filesystem and the capabilities.

- CAP_DAC_OVERRIDE.
- The capabilities xattr on a filesystem.

With a filesystem in exactly one user namespace at a time this
is straight forward.  With a filesystem in user namespaces at
a time this is slightly more interesting.

I believe the authentication algorithm becomes:
Map the credentials on the filesystem inode into (fs_user_ns, fs_uid, fs_gid, fs_mode)

Then to see if we have power over the file we test:
capable(fs_user_ns, CAP_DAC_OVERRIDE).

Then if current->user->user_ns != fs_user_ns we can do something like:
uid = 0, gid = 0 mode clear except for the other bits.  We want either
0 or another uid we have reserved for the purpose.

I don't see why the mapping rules should not be universal so we can probably
do all of the mapping foreign uid's and gid's in generic code and just
place a unser_ns pointer into struct inode. 

Which makes things very close to how they are now and it means we can
do the lookup of the user_ns when we cache the struct inode.

> Anyway I like the overall approach, and will think a bit about
> any other actual implementation issues.

Thanks.

It adds more complications then I like not having a view of the filesystem
with a single user_namespace.  However that appears to be necessary to
deal with Al's inode_permission changes, and it seems to be where we
are ultimately heading so it seems more honest.  So I guess I have
to bite the bullet and accept it. ;)

For the case of a shared /usr just having other permission access
should work fairly well.  I just looked on my ubuntu system and I
found only 36 suid executables and only one executable (fusermount)
that was not world executable.  And a shared usr is the only reasonable
case I could think of where I would want a file to at least appear
to have multiple owners.

Eric

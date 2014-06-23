From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Per-user namespace process accounting
Date: Mon, 23 Jun 2014 06:07:32 +0200
Message-ID: <20140623040732.GA24001@mail.hallyn.com>
References: <5386D58D.2080809@1h.com> <87tx88nbko.fsf@x220.int.ebiederm.org>
	<53870EAA.4060101@1h.com> <20140529153232.GB9714@ubuntumail>
	<538DFF72.7000209@parallels.com> <20140603172631.GL9714@ubuntumail>
	<8738flkhf0.fsf@x220.int.ebiederm.org> <538E4088.7010605@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <538E4088.7010605-108MBtLGafw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Marian Marinov (mm-108MBtLGafw@public.gmane.org):
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 06/03/2014 08:54 PM, Eric W. Biederman wrote:
> > Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> > 
> >> Quoting Pavel Emelyanov (xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> >>> On 05/29/2014 07:32 PM, Serge Hallyn wrote:
> >>>> Quoting Marian Marinov (mm-108MBtLGafw@public.gmane.org):
> >>>>> We are not using NFS. We are using a shared block storage that offers us snapshots. So provisioning new
> >>>>> containers is extremely cheep and fast. Comparing that with untar is comparing a race car with Smart. Yes
> >>>>> it can be done and no, I do not believe we should go backwards.
> >>>>> 
> >>>>> We do not share filesystems between containers, we offer them block devices.
> >>>> 
> >>>> Yes, this is a real nuisance for openstack style deployments.
> >>>> 
> >>>> One nice solution to this imo would be a very thin stackable filesystem which does uid shifting, or, better
> >>>> yet, a non-stackable way of shifting uids at mount.
> >>> 
> >>> I vote for non-stackable way too. Maybe on generic VFS level so that filesystems don't bother with it. From
> >>> what I've seen, even simple stacking is quite a challenge.
> >> 
> >> Do you have any ideas for how to go about it?  It seems like we'd have to have separate inodes per mapping for
> >> each file, which is why of course stacking seems "natural" here.
> >> 
> >> Trying to catch the uid/gid at every kernel-userspace crossing seems like a design regression from the current
> >> userns approach.  I suppose we could continue in the kuid theme and introduce a iiud/igid for the in-kernel inode
> >> uid/gid owners.  Then allow a user privileged in some ns to create a new mount associated with a different
> >> mapping for any ids over which he is privileged.
> > 
> > There is a simple solution.
> > 
> > We pick the filesystems we choose to support. We add privileged mounting in a user namespace. We create the user
> > and mount namespace. Global root goes into the target mount namespace with setns and performs the mounts.
> > 
> > 90% of that work is already done.
> > 
> > As long as we don't plan to support XFS (as it XFS likes to expose it's implementation details to userspace) it
> > should be quite straight forward.
> > 
> > The permission check change would probably only need to be:
> > 
> > 
> > @@ -2180,6 +2245,10 @@ static int do_new_mount(struct path *path, const char *fstype, int flags, return -ENODEV;
> > 
> > if (user_ns != &init_user_ns) { +               if (!(type->fs_flags & FS_UNPRIV_MOUNT) && !capable(CAP_SYS_ADMIN))
> > { +                       put_filesystem(type); +                       return -EPERM; +               } if
> > (!(type->fs_flags & FS_USERNS_MOUNT)) { put_filesystem(type); return -EPERM;
> > 
> > 
> > There are also a few funnies with capturing the user namespace of the filesystem when we perform the mount (in the
> > superblock?), and not allowing a mount of that same filesystem in a different user namespace.
> > 
> > But as long as the kuid conversions don't measurably slow down the filesystem when mounted in the initial mount and
> > user namespaces I don't see how this would be a problem for anyone, and is very little code.
> > 
> 
> This may solve one of the problems, but it does not solve the issue with UID/GID maps that overlap in different user
> namespaces.
> In our cases, this means breaking container migration mechanisms.
> 
> Will this at all be addressed or I'm the only one here that has this sort of requirement?

You're not.  The openstack scenario has the same problem.  So we have a
single base rootfs in a qcow2 or raw file which we want to mount into
multiple containers, each of which has a distinct set of uid mappings.

We'd like some way to identify uid mappings at mount time, without having
to walk the whole rootfs to chown every file.

(Of course safety would demand that the shared qcow2 use a set of high
subuids, NOT host uids - i.e. if we end up allowing a container to
own files owned by 0 on the host - even in a usually unmapped qcow2 -
there's danger we'd rather avoid, see again Andy's suggestions of
accidentidally auto-mounted filesystem images which happen to share a
UUID with host's / or /etc.  So we'd want to map uids 100000-106536
in the qcow2 to uids 0-65536 in the container, which in turn map to
uids 200000-206536 on the host)

-serge

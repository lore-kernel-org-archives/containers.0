From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: container support in DazukoFS
Date: Sat, 03 Jul 2010 08:42:36 -0700
Message-ID: <m1vd8wr2qb.fsf@fess.ebiederm.org>
References: <87tyogde9l.fsf@lonestar.fn.ogness.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <87tyogde9l.fsf@lonestar.fn.ogness.net> (John Ogness's message of "Sat\, 03 Jul 2010 12\:57\:10 +0200")
Sender: linux-fsdevel-owner@vger.kernel.org
To: John Ogness <dazukolist3@ogness.net>
Cc: dazuko-devel@nongnu.org, Linux Containers <containers@lists.osdl.org>, linux-fsdevel@vger.kernel.org
List-Id: containers.vger.kernel.org

John Ogness <dazukolist3@ogness.net> writes:

> [Cc: Eric Biederman because of his container feedback on LKML.
>  Hi Eric, the Dazuko-Devel mailing list is register-only, but if you
>  reply to me, then I can post your comments on the list.]

I am not willing to discuss design ideas in detail on a closed list,
as such I have copied a couple appropriate mailing lists to have such
a discussion.

> I've been wondering what we could do to make DazukoFS more acceptable
> for mainline inclusion. Aside from making DazukoFS more complete:
>
> http://lists.gnu.org/archive/html/dazuko-devel/2010-06/msg00000.html
>
> the main issue reported from LKML reviews was that we need to support
> containers. I think I have a solution for this, which will also make
> DazukoFS more flexible when not using containers.

That is a very odd way of putting it.   We really don't allow the
ability to compile out container support.  So you really have only
two cases.  When there is only one instance of various namespaces
or when there are many.    Your code is simply broken if it doesn't
handle namespaces properly, especially the mount namespace.

> My idea is the following:
>
> 1. There is only 1 global device "/dev/dazukofs.ctrl".
>
> 2. When a group is added (using the "add" or "addtrack" commands),
> DazukoFS will create the "/dev/dazukofs.N" group device within the
> container-space of the process adding the group. This means that
> contained environments can create their own local group devices. For
> systems not using containers this is also an improvement because it
> means group devices are created dynamically (instead of the 10 static
> groups that exist now).

What is a container-space ?  So far we only have a single device namespace.

If you are going around creating control devices dynamically, I
suggest a control pseudo filesystem like devpts might be more appropriate.
The you can keep your per instance configuration as per mount data
in your control fs.

> 3. When a process reads the global control device to see the group
> names, only the groups within the same container-space as the reading
> process are shown. This keeps information about other containers
> private.
>
> 4. When a file is accessed, only the groups from container-spaces
> where the file exists in that container-space will be notified.
>
> 5. If an ignore device is desired, it may be created using a new
> command for the control device. Perhaps something like "addign". The
> ignore device would be created within the same container-space of the
> process requesting the ignore device. The ignore scope would only be
> the container-space of the ignore device. This means that if a process
> is being ignored within its container, a non-contained process on the
> host machine could still react to files accesses by the contained
> ignored process.
>
> 6. When a new group is created, it does not go live until the first
> read on the group device has occured. This allows an application to
> setup a new group and set the permissions on the new group device
> before dropping its privileges and beginning file access control.
>
>
> There are a couple things that I like about these changes. First off,
> I like that group and ignore devices are created dynamically. This
> should have been the way it was done from the beginning. This not only
> removes restrictions on the number of groups, but makes it much easier
> to think in terms of containers.
>
> Secondly, I like that a group does not go live until the first read on
> the group device. This makes it much simpler (and cleaner) for
> developing non-privileged applications to perform online file access
> control.
>
> I also see some open issues here. When automatically creating new
> devices, one must always consider the permissions and ownership
> involved. Right now this can be handled using udev rules or by a
> privileged process setting them appropriately. I think that this is
> probably ok for now, especially since complex SElinux rules could come
> into play. But it is something we need to keep in mind.
>
> I am not familiar with how udev works for containers. For example,
> would every container be able to have its own /dev/dazukofs.0 or must
> udev devices be globally unique? Either way, I do not see this as a
> problem, but will need to be considered.
>
> I am also not familiar with the kernel API's for container
> management. So my idea may need to be adjusted a bit, but I think in
> general it should work. If anyone has experience with containers, I'd
> be interested in hearing about this.

For the mount namespace which sounds like you primarily care about the
APIs are:
clone( ... CLONE_NEWNS ... )
unshare( CLONE_NEWNS )
mount( ... )
chroot( ... )

They have been in the kernel since at least 2.5.early.  If you are doing
interesting things with filesystems and you don't understand those APIs
I don't see how you can possibly create correct code.


Eric

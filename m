From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: storage considerations
Date: Tue, 03 Feb 2009 17:38:31 +0100
Message-ID: <49887307.1080105@free.fr>
References: <7B7881568CF40E4388B615CD06F87B980989E9@clara.maurer-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7B7881568CF40E4388B615CD06F87B980989E9-cHQ43lMKbBKenyD9vqZGNUEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Dietmar Maurer wrote:
> Hi Daniel,
>
> I think we should have several options for the root storage:
>
> 1.) simply use the host filesystem (like Openvz)
>
> 	- special quota support is needed (simfs?)
>
> 	- quota support depends on ext3 fs, so this only works for
> 	  local attached storage (does not work on NFS)
>
> 	- LVM snapshots are slow, because the snapshot includes all
> container
> 	  on that filesystem.
>
> 	- it is easy to expand/shrink storage
>
> 	- best storage consolidation (storage overcommit possible)
>   


> 2.) loop mounting an image (dm-loop)
>
> 	- quota works
>
> 	- works on any filesystem (even NFS)
>
> 	- don't know how to make snapshots?
>   
Perhaps we can use the future union mount or unionfs in order to make 
incremental snapshot ?
> 	- difficult to resize (but manageable)
>
> 	- slow
>
> 3.) use a block device
>
> 	- works great with LVM2 volumes 
>
> 	- quota works
>
> 	- best performance
>
> 	- works with shared block devices (incredible fast migrations)
>
> 	- snapshots works (at least when using an LVM2 volume)
>
> 	- it is difficult to resize block devices (but manageable)
>
> The question is: when do we mount the root block device?
>
> OpenVZ has one additional state, called 'mounted'. For example you can
> do:
>
> # vzctl mount VMID
> # vzctl umount VMID
>
> Or we simply mount the root when we create the container?
>
> What do you think?
>   
It is very interesting. Thanks for giving an overview of the available 
storage solutions.
You have a lot of idea and I need some time to compile them :)

At present lxc provides a rootfs which is symlink to the directory to 
chroot. It could be nice is to replace this by a directory and bind 
mount something on top of it. By "something" I mean one of the solutions 
you are proposing or something else.
I would prefer to find a generic solution, that is,  a configuration 
format which can be interpreted in a generic way by lxc.
The fstab file format is a good candidate :)
We can:
 1 - replace the fstab file by a new keyword lxc.mount = "a fstab line"
 2 - each time this keyword is found add a mntentry in a mount list of 
the configuration
 3 - automatically add the bind mount of the rootfs in this list when 
the lxc.rootfs is found

 From the point of view of the configuration / setup:

the lxc-create creates the fstab file (do not mount anything otherwise 
that will be lost at reboot).
the lxc-start/lxc-execute mount everything (it is up to the user to 
define the right order in the configuration file).

For example:

lxc.mount = myhost:/linux /linux nfs defaults 0 0
lxc.rootfs = /root/debian4

That will create the fstab file in the container configuration tree:

myhost:/mydistro /root/mydistro nfs defaults 0 0
/root/mydistro  /var/lxc/debian4/rootfs bind 0 0

This fstab can be used with a script for example to unshare the mount 
namespace, bind mount the fstab on top of /etc/fstab and call mount -a :)

In any case, the configuration file stays generic and a new fs support 
can be added without changing the lxc version.

Shall this fit your needs ?

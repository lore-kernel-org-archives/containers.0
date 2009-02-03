From: "Dietmar Maurer" <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Subject: RE: storage considerations
Date: Tue, 3 Feb 2009 18:14:23 +0100
Message-ID: <7B7881568CF40E4388B615CD06F87B980989FC@clara.maurer-it.com>
References: <7B7881568CF40E4388B615CD06F87B980989E9@clara.maurer-it.com>
	<49887307.1080105@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <49887307.1080105-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

> I would prefer to find a generic solution, that is,  a configuration
> format which can be interpreted in a generic way by lxc.
> The fstab file format is a good candidate :)
> We can:
>  1 - replace the fstab file by a new keyword lxc.mount = "a fstab
line"
>  2 - each time this keyword is found add a mntentry in a mount list of
> the configuration
>  3 - automatically add the bind mount of the rootfs in this list when
> the lxc.rootfs is found
> 
>  From the point of view of the configuration / setup:
> 
> the lxc-create creates the fstab file (do not mount anything otherwise
> that will be lost at reboot).
> the lxc-start/lxc-execute mount everything (it is up to the user to
> define the right order in the configuration file).
> 
> For example:
> 
> lxc.mount = myhost:/linux /linux nfs defaults 0 0
> lxc.rootfs = /root/debian4
> 
> That will create the fstab file in the container configuration tree:
> 
> myhost:/mydistro /root/mydistro nfs defaults 0 0
> /root/mydistro  /var/lxc/debian4/rootfs bind 0 0
> 
> This fstab can be used with a script for example to unshare the mount
> namespace, bind mount the fstab on top of /etc/fstab and call mount -a
> :)
> 
> In any case, the configuration file stays generic and a new fs support
> can be added without changing the lxc version.
> 
> Shall this fit your needs ?

Yes, I guess that would work for me.

- Dietmar

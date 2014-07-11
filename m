From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Could not mount sysfs when enable userns but disable netns
Date: Fri, 11 Jul 2014 09:29:05 -0700
Message-ID: <87ha2nyi3y.fsf@x220.int.ebiederm.org>
References: <5871495633F38949900D2BF2DC04883E562293@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20140711142806.GA26441@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140711142806.GA26441-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 11 Jul 2014 16:28:06 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Serge Hallyn (serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org)" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org (chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>> Hello,
>> 
>> How to reproduce:
>> 1. Prepare a container, enable userns and disable netns
>> 2. use libvirt-lxc to start a container
>> 3. libvirt could not mount sysfs then failed to start.
>> 
>> Then I found that
>> commit 7dc5dbc879bd0779924b5132a48b731a0bc04a1e says:
>> "Don't allow mounting sysfs unless the caller has CAP_SYS_ADMIN rights
>> over the net namespace."
>> 
>> But why should we check sysfs mouont permission over net namespace?
>> We've already checked CAP_SYS_ADMIN though.

We already checked capable(CAP_SYS_ADMIN) and it failed.

>> What the relationship between sysfs and net namespace,
>> or this check is a little redundant?

You want a bind mount not a new fresh mount.

When looking at how evil actors could abuse things it turned out that in
some circumstances the root user (before a user namespace is created)
needs to control the policy on which filesystems may be mounted.  There
are files in sysfs and in proc that you never want to see in a chroot
jail, as they just create more surface area to attack.

The only reason for creating a new fresh mount of sysfs is to get access
to /sys/class/net.  So to keep things simple we restrict creation of
that mount to cases where the mounter has permisions over the network
namespace, and cases where nothing interesing is mounted on top of
sysfs.

If a new /sys/class/net is not needed it is possible to bind mount the
existing copy of sysfs to the new location without loss of
functionality.

> It is not redundant.  The whole point is that after clone(CLONE_NEWUSER)
> you get a newly filled set of capabilities.  But you should not have
> privileges over the host's network namesapce.  After you unshare a new
> network namespace, you *should* have privilege over it.  So the fact
> that we've already check CAP_SYS_ADMIN means nothing, because the
> capabilities need to be targeted.

Exactly the tests are failing because the caller is not the global root
and so the code is properly failing the permission checks.

Eric

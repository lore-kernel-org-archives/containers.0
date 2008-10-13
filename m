From: "Tanaka, Thomas" <thomas.tanaka-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: Building a SECURE cointainer using Cgroups ?
Date: Mon, 13 Oct 2008 13:57:29 -0700
Message-ID: <0A97A441BFADC74EA1E299A79C69DF9212D3F6CA82@orsmsx504.amr.corp.intel.com>
References: <0A97A441BFADC74EA1E299A79C69DF9212D3F6C9E2@orsmsx504.amr.corp.intel.com>
	<1223920496.29877.22.camel@nimitz>
	<0A97A441BFADC74EA1E299A79C69DF9212D3F6CA1B@orsmsx504.amr.corp.intel.com>
	<1223922341.29877.29.camel@nimitz> <20081013192921.GA10814@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081013192921.GA10814-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Thanks for the quick reply.
Just out of curiosity, Is it possible to develop a cgroup subsystem that just does the filesystem isolation?

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Mon, 2008-10-13 at 11:01 -0700, Tanaka, Thomas wrote:
> > Yes absolutely that is what I am trying to achieve.
>
> I'm going to put on my Serge hat and bet that you can do it with
> security modules. :)

Right, your goal is still not very precise, but a security module -
smack or selinux - might be your best bet.

> There's nothing that cgroups or containers gives you that will help with
> your problem.  We actually haven't touched the fs namespaces at all, yet
> because they work great as they stand today.

No, but there is the device whitelist cgroup and capability bounding
sets - perhaps that is what he is asking about?

If you have a normal chroot - or a container created with
clone(CLONE_NEWNS) followed by pivot_root into a completely isolated
file system tree (say, created using debootstrap), then a root user in
that pivot_root can simply mount /dev/hda1 /mnt and chroot back into
that.

So to make the above a little more secure, you can

        1. restrict the container's device whitelist so that it can't
           create or use the devices representing the hard drive.
or
        2. take CAP_MKNOD and CAP_SYS_ADMIN out of the containers'
           capability bounding set and pI, so that root can neither
           mount any filesystems nor create any devices.  (Of course,
           also make sure /dev is suitably empty)  The problem with
           this one is that we still don't have a check upstream to
           force mounts by a user who does not have CAP_MKNOD to be
           nodev.  That's one reason I keep trying to push on the
           user mounts patchset - it brings that check.

-serge

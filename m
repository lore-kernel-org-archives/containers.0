From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: handling of supplemental groups with userns
Date: Tue, 22 Sep 2015 14:40:07 -0500
Message-ID: <87d1xafdk8.fsf@x220.int.ebiederm.org>
References: <20150922162157.GB27286@vapier.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150922162157.GB27286-UgUKS2FnFs9+urZeOPWqwQ@public.gmane.org> (Mike Frysinger's message of
	"Tue, 22 Sep 2015 12:21:57 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org> writes:

> is it possible to map in supplemental groups in a userns when the user
> lacks setgid/etc... capabilities in the parent ns ?  it doesn't seem
> like it's currently possible, but is there a reason to not enable it ?

In your unprivileged use scenario, you won't be able to drop
your supplementary groups so why do you need them mapped?

> basically i have a build tool that i want to isolate a bit, but it
> requires access to some of my supplemental groups.  if i map just
> my effective uid/gid, the build will fail when it tries to use the
> chown/chgrp commands (gets back EINVAL).

Yes.  That really isn't valid as you are dropping groups.  Peculiarly
enough dropping groups can be a security issue as in some permission
checks not being a member of a group can give you enhanced access to
files and directories.

So to do something like what you want, you need a setuid helper (something
like newuidmap or newgidmap) to verify that what you are doing is ok
by local policy.

> my scenario boils down to:
>  - normal unprivileged user (uid=8282)
>  - member of multiple groups (gid=100, getgroups={100,16,250,...})
>  - create a new userns (to get access to other ns like mount/pid)
>    but still have access to existing groups where i'm root
>  - use various features that require caps (new pidns/mntns/etc...)
>  - create another userns and map back non-root users/groups
> i.e. i switch from 8282 to 0, do what i need, then switch back to 8282.

[snip]

> in the mean time, a "quick" fix might be to change new_idmap_permitted
> to walk all the extents, and if all the ranges are set to 1, check the
> supplemental groups in addition to the current egid ?

That allows dropping groups that you could not drop normally and so we
can't allow it, by default.

Eric

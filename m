From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 4/6] user namespaces: add user_ns to super block
Date: Mon, 28 Jul 2008 16:03:45 -0700
Message-ID: <m1skttehm6.fsf@frodo.ebiederm.org>
References: <20080726002700.GA29686@us.ibm.com>
	<20080726002754.GD29874@us.ibm.com>
	<m13altislf.fsf@frodo.ebiederm.org>
	<1217285230.25300.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217285230.25300.19.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org> (Matt Helsley's
	message of "Mon, 28 Jul 2008 15:47:10 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> 	Would this require passing the vfsmount to the filesystems themselves,
> or would they be within the VFS code only? 

The interesting bit is the user_namespace contained in the vfsmount.  We
can pass that down.  I think semantically it makes sense for a filesystem
mount to only operate in a single mount namespace.

> If not wholly within the VFS
> I wonder if Al Viro would object to this. He's resisted past attempts to
> pass the vfsmount structs into more filesystem code paths and I'm
> guessing that could affect whether or not this approach can be
> implemented.

Dave Hansen raised that concern when we were talking about it earlier.  Since
we just care about a property of the mount it isn't a big deal.

Actually thinking about this a little farther it may be simplest to have the
mnt_namespace capture the user_namespace, although that doesn't seem to map
semantically very well with cloning of the filesystem.

This is very much a question of how do we map the uid/gids store in the filesystem
into the uids/gids in the kernel.  Which user namespace do they belong in.

Especially in the case of read only mounts we can safely share a filesystem between
user_namespaces with no changes to the filesystem.    Which I suspect is the
first case we want to allow as that is a tremendous savings in space if you have
lots of instances of the same distro, and people have been doing it with /usr
for years.

Eric

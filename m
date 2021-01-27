Return-Path: <SRS0=oCe4=G6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9140C433E0
	for <containers@archiver.kernel.org>; Wed, 27 Jan 2021 05:40:09 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3F15B20709
	for <containers@archiver.kernel.org>; Wed, 27 Jan 2021 05:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F15B20709
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id CEB4F2049C;
	Wed, 27 Jan 2021 05:40:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id d7wXrbtCS6MR; Wed, 27 Jan 2021 05:40:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 80A752001D;
	Wed, 27 Jan 2021 05:40:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 645D2C08A1;
	Wed, 27 Jan 2021 05:40:07 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9A38DC013A
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:40:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 8D5A52001D
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:40:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id N28Ouvy1W7WL
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:40:02 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by silver.osuosl.org (Postfix) with ESMTPS id 8CB2D2052F
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:40:02 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 93A58864; Tue, 26 Jan 2021 23:40:00 -0600 (CST)
Date: Tue, 26 Jan 2021 23:40:00 -0600
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v6 00/40] idmapped mounts
Message-ID: <20210127054000.GA30832@mail.hallyn.com>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210121131959.646623-1-christian.brauner@ubuntu.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Alban Crequy <alban@kinvolk.io>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org,
 linux-integrity@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, Todd Kjos <tkjos@google.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Jan 21, 2021 at 02:19:19PM +0100, Christian Brauner wrote:
> Hey everyone,
> 
> The only major change is the updated version of hch's pach to port xfs
> to support idmapped mounts. Thanks again to Christoph for doing that
> work.
> (Otherwise Acked-bys and Reviewed-bys were added and the tree reordered
>  to decouple filesystem specific conversion from the vfs work so they
>  can proceed independent.
>  For a full list of major changes between versions see the end of this
>  cover letter. Please also note the large xfstests testsuite in patch 42
>  that has been kept as part of this series. It verifies correct vfs
>  behavior with and without idmapped mounts including covering newer vfs
>  features such as io_uring.
>  I currently still plan to target the v5.12 merge window.)
> 
> With this patchset we make it possible to attach idmappings to mounts,
> i.e. simply put different bind mounts can expose the same file or
> directory with different ownership.
> Shifting of ownership on a per-mount basis handles a wide range of
> long standing use-cases. Here are just a few:
> - Shifting of a subset of ownership-less filesystems (vfat) for use by
>   multiple users, effectively allowing for DAC on such devices
>   (systemd, Android, ...)
> - Allow remapping uid/gid on external filesystems or paths (USB sticks,
>   network filesystem, ...) to match the local system's user and groups.
>   (David Howells intends to port AFS as a first candidate.)
> - Shifting of a container rootfs or base image without having to mangle
>   every file (runc, Docker, containerd, k8s, LXD, systemd ...)
> - Sharing of data between host or privileged containers with
>   unprivileged containers (runC, Docker, containerd, k8s, LXD, ...)
> - Data sharing between multiple user namespaces with incompatible maps
>   (LXD, k8s, ...)
> 
> There has been significant interest in this patchset as evidenced by
> user commenting on previous version of this patchset. They include
> containerd, ChromeOS, systemd, LXD and a range of others. There is
> already a patchset up for containerd, the default Kubernetes container
> runtime https://github.com/containerd/containerd/pull/4734
> to make use of this. systemd intends to use it in their systemd-homed
> implementation for portable home directories. ChromeOS wants to make use
> of it to share data between the host and the Linux containers they run
> on Chrome- and Pixelbooks. There's also a few talks that of people who
> are going to make use of this. The most recent one was a CNCF webinar
> https://www.cncf.io/wp-content/uploads/2020/12/Rootless-Containers-in-Gitpod.pdf
> and upcoming talk during FOSDEM.
> (Fwiw, for fun and since I wanted to do this for a long time I've ported
>  my home directory to be completely portable with a simple service file
>  that now mounts my home directory on an ext4 formatted usb stick with
>  an id mapping mapping all files to the random uid I'm assigned at
>  login.)
> 
> Making it possible to share directories and mounts between users with
> different uids and gids is itself quite an important use-case in
> distributed systems environments. It's of course especially useful in
> general for portable usb sticks, sharing data between multiple users in,
> and sharing home directories between multiple users. The last example is
> now elegantly expressed in systemd's homed concept for portable home
> directories. As mentioned above, idmapped mounts also allow data from
> the host to be shared with unprivileged containers, between privileged
> and unprivileged containers simultaneously and in addition also between
> unprivileged containers with different idmappings whenever they are used
> to isolate one container completely from another container.
> 
> We have implemented and proposed multiple solutions to this before. This
> included the introduction of fsid mappings, a tiny filesystem I've
> authored with Seth Forshee that is currently carried in Ubuntu that has
> shown to be the wrong approach, and the conceptual hack of calling
> override creds directly in the vfs. In addition, to some of these
> solutions being hacky none of these solutions have covered all of the
> above use-cases.
> 
> Idmappings become a property of struct vfsmount instead of tying it to a
> process being inside of a user namespace which has been the case for all
> other proposed approaches. It also allows to pass down the user
> namespace into the filesystems which is a clean way instead of violating
> calling conventions by strapping the user namespace information that is
> a property of the mount to the caller's credentials or similar hacks.
> Each mount can have a separate idmapping and idmapped mounts can even be
> created in the initial user namespace unblocking a range of use-cases.
> 
> To this end the vfsmount struct gains a new struct user_namespace
> member. The idmapping of the user namespace becomes the idmapping of the
> mount. A caller that is privileged with respect to the user namespace of
> the superblock of the underlying filesystem can create an idmapped
> mount. In the future, we can enable unprivileged use-cases by checking
> whether the caller is privileged wrt to the user namespace that an
> already idmapped mount has been marked with, allowing them to change the
> idmapping. For now, keep things simple until the need arises.
> Note, that with syscall interception it is already possible to intercept
> idmapped mount requests from unprivileged containers and handle them in
> a sufficiently privileged container manager. Support for this is already
> available in LXD and will be available in runC where syscall
> interception is currently in the process of becoming part of the runtime
> spec: https://github.com/opencontainers/runtime-spec/pull/1074.
> 
> The user namespace the mount will be marked with can be specified by
> passing a file descriptor refering to the user namespace as an argument
> to the new mount_setattr() syscall together with the new
> MOUNT_ATTR_IDMAP flag. By default vfsmounts are marked with the initial
> user namespace and no behavioral or performance changes are observed.
> All mapping operations are nops for the initial user namespace. When a
> file/inode is accessed through an idmapped mount the i_uid and i_gid of
> the inode will be remapped according to the user namespace the mount has
> been marked with.
> 
> In order to support idmapped mounts, filesystems need to be changed and
> mark themselves with the FS_ALLOW_IDMAP flag in fs_flags. The initial
> version contains fat, ext4, and xfs including a list of examples.
> But patches for other filesystems are actively worked on and will be
> sent out separately. We are here to see this through and there are
> multiple people involved in converting filesystems. So filesystem
> developers are not left alone with this and are provided with a large
> testsuite to verify that their port is correct.
> 
> There is a simple tool available at
> https://github.com/brauner/mount-idmapped that allows to create idmapped
> mounts so people can play with this patch series. Here are a few
> illustrations:
> 
> 1. Create a simple idmapped mount of another user's home directory
> 
> u1001@f2-vm:/$ sudo ./mount-idmapped --map-mount b:1000:1001:1 /home/ubuntu/ /mnt
> u1001@f2-vm:/$ ls -al /home/ubuntu/
> total 28
> drwxr-xr-x 2 ubuntu ubuntu 4096 Oct 28 22:07 .
> drwxr-xr-x 4 root   root   4096 Oct 28 04:00 ..
> -rw------- 1 ubuntu ubuntu 3154 Oct 28 22:12 .bash_history
> -rw-r--r-- 1 ubuntu ubuntu  220 Feb 25  2020 .bash_logout
> -rw-r--r-- 1 ubuntu ubuntu 3771 Feb 25  2020 .bashrc
> -rw-r--r-- 1 ubuntu ubuntu  807 Feb 25  2020 .profile
> -rw-r--r-- 1 ubuntu ubuntu    0 Oct 16 16:11 .sudo_as_admin_successful
> -rw------- 1 ubuntu ubuntu 1144 Oct 28 00:43 .viminfo

So I assume this falls under the buyer beware warning, but it's
probably important to warn people loudly of the fact that, at this
point, the user with uid 1001 can chmod u+s any binary under /mnt
and then run it from /home/ubuntu with euid=1000.  In other words,
that while this has excellent uses, if you *can* use shared group
membership, you should :)

Very cool though.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

Return-Path: <SRS0=O+XM=JK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AA68C433B4
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 08:26:57 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ECA8B613A9
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 08:26:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECA8B613A9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id BB1CB40657;
	Tue, 13 Apr 2021 08:26:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nQNNCt8SN2OY; Tue, 13 Apr 2021 08:26:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 5E45B4065C;
	Tue, 13 Apr 2021 08:26:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 415C2C000C;
	Tue, 13 Apr 2021 08:26:55 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1DEBEC000A
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 08:26:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 09D5E4065C
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 08:26:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2X19YUBZ128r
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 08:26:53 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp4.osuosl.org (Postfix) with ESMTPS id EF6E540657
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 08:26:52 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 7981161242;
 Tue, 13 Apr 2021 08:26:43 +0000 (UTC)
Date: Tue, 13 Apr 2021 10:26:40 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v6 24/40] fs: make helpers idmap mount aware
Message-ID: <20210413082640.krcmqac6y2esuz24@wittgenstein>
References: <E901E25F-41FA-444D-B3C7-A7A786DDD5D5@tuxera.com>
 <CAHk-=wiXqbSgqzv53C98sbaHVqpc+c8NZTpXC7bBMQT3OznE4g@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHk-=wiXqbSgqzv53C98sbaHVqpc+c8NZTpXC7bBMQT3OznE4g@mail.gmail.com>
Cc: "luto@kernel.org" <luto@kernel.org>,
 "zohar@linux.ibm.com" <zohar@linux.ibm.com>,
 "dhowells@redhat.com" <dhowells@redhat.com>,
 "alban@kinvolk.io" <alban@kinvolk.io>, "hch@lst.de" <hch@lst.de>,
 "tycho@tycho.ws" <tycho@tycho.ws>, "paul@paul-moore.com" <paul@paul-moore.com>,
 "corbet@lwn.net" <corbet@lwn.net>,
 "smbarber@chromium.org" <smbarber@chromium.org>,
 Anton Altaparmakov <anton@tuxera.com>,
 "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
 "mpatel@redhat.com" <mpatel@redhat.com>,
 "keescook@chromium.org" <keescook@chromium.org>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "selinux@vger.kernel.org" <selinux@vger.kernel.org>,
 "josh@joshtriplett.org" <josh@joshtriplett.org>,
 "casey@schaufler-ca.com" <casey@schaufler-ca.com>,
 "cyphar@cyphar.com" <cyphar@cyphar.com>,
 "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
 "lennart@poettering.net" <lennart@poettering.net>,
 "hirofumi@mail.parknet.co.jp" <hirofumi@mail.parknet.co.jp>,
 "geofft@ldpreload.com" <geofft@ldpreload.com>,
 "James.Bottomley@hansenpartnership.com"
 <James.Bottomley@hansenpartnership.com>,
 "john.johansen@canonical.com" <john.johansen@canonical.com>,
 "tytso@mit.edu" <tytso@mit.edu>,
 "seth.forshee@canonical.com" <seth.forshee@canonical.com>,
 "dmitry.kasatkin@gmail.com" <dmitry.kasatkin@gmail.com>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>,
 "ebiederm@xmission.com" <ebiederm@xmission.com>,
 "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>,
 "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
 "stephen.smalley.work@gmail.com" <stephen.smalley.work@gmail.com>,
 "tkjos@google.com" <tkjos@google.com>
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

On Mon, Apr 12, 2021 at 09:23:38AM -0700, Linus Torvalds wrote:
> On Mon, Apr 12, 2021 at 5:05 AM Anton Altaparmakov <anton@tuxera.com> wrote:
> >
> > Shouldn't that be using mnt_userns instead of &init_user_ns both for the setattr_prepare() and setattr_copy() calls?
> 
> It doesn't matter for a filesystem that hasn't marked itself as
> supporting idmaps.
> 
> If the filesystem doesn't set FS_ALLOW_IDMAP, then mnt_userns is
> always going to be &init_user_ns.
> 
> That said, I don't think you are wrong - it would probably be a good
> idea to pass down the 'mnt_userns' argument just to avoid confusion.
> But if you look at the history, you'll see that adding the mount
> namespace argument to the helper functions (like setattr_copy())
> happened before the actual "switch the filesystem setattr() function
> over to get the namespace argument".
> 
> So the current situation is partly an artifact of how the incremental
> filesystem changes were done.

I'm not so sure the complaint in the original mail is obviously valid.
Passing down mnt_userns through all filesystem codepaths at once
would've caused way more churn. There are filesystems that e.g. do stuff
like this:

<fstype>_create()
-> __<fstype>_internal_create()
<fstype>_mknod()
-> __<fstype>_internal_create()
<fstype>_rmdir()
-> __<fstype>_internal_create()

where __<fstype>_internal_create() was additionally called in a few
other places.
So instead of only changing <fstype>_<i_op> we would've now also have to
change __<fstype>_internal_create() which would've caused the fs
specific change to be more invasive than it needed to be. The way we
did it allowed us to keep the change legible.

And that's just a simple example.
There are fses that have more convoluted callpaths:
- an internal helper used additionally as a callback in a custom ops
  struct
- or most i_ops boiling down to a single internal function
So the choice was also deliberate.

We've also tried to be consistent when we actually pass down mnt_userns
further within the filesystem and when we simply use init_user_ns in
general. Just looking at setattr_copy() which was in the example:

                   attr.c:void setattr_copy(struct user_namespace *mnt_userns, struct inode *inode,
                   attr.c:EXPORT_SYMBOL(setattr_copy);
                   btrfs/inode.c:          setattr_copy(&init_user_ns, inode, attr);
                   cifs/inode.c:   setattr_copy(&init_user_ns, inode, attrs);
                   cifs/inode.c:   setattr_copy(&init_user_ns, inode, attrs);
                   exfat/file.c:   setattr_copy(&init_user_ns, inode, attr);
                   ext2/inode.c:   setattr_copy(&init_user_ns, inode, iattr);
**FS_ALLOW_IDMAP** ext4/inode.c:           setattr_copy(mnt_userns, inode, attr);
                   f2fs/file.c:static void __setattr_copy(struct user_namespace *mnt_userns,
                   f2fs/file.c:#define __setattr_copy setattr_copy
                   f2fs/file.c:    __setattr_copy(&init_user_ns, inode, attr);
                   fat/file.c:      * setattr_copy can't truncate these appropriately, so we'll
**FS_ALLOW_IDMAP** fat/file.c:     setattr_copy(mnt_userns, inode, attr);
                   gfs2/inode.c:   setattr_copy(&init_user_ns, inode, attr);
                   hfs/inode.c:    setattr_copy(&init_user_ns, inode, attr);
                   hfsplus/inode.c:        setattr_copy(&init_user_ns, inode, attr);
                   hostfs/hostfs_kern.c:   setattr_copy(&init_user_ns, inode, attr);
                   hpfs/inode.c:   setattr_copy(&init_user_ns, inode, attr);
                   hugetlbfs/inode.c:      setattr_copy(&init_user_ns, inode, attr);
                   jfs/file.c:     setattr_copy(&init_user_ns, inode, iattr);
                   kernfs/inode.c: setattr_copy(&init_user_ns, inode, iattr);
**helper library** libfs.c:        setattr_copy(mnt_userns, inode, iattr);
                   minix/file.c:   setattr_copy(&init_user_ns, inode, attr);
                   nilfs2/inode.c: setattr_copy(&init_user_ns, inode, iattr);
                   ocfs2/dlmfs/dlmfs.c:    setattr_copy(&init_user_ns, inode, attr);
                   ocfs2/file.c:   setattr_copy(&init_user_ns, inode, attr);
                   omfs/file.c:    setattr_copy(&init_user_ns, inode, attr);
                   orangefs/inode.c:       setattr_copy(&init_user_ns, inode, iattr);
                   proc/base.c:    setattr_copy(&init_user_ns, inode, attr);
                   proc/generic.c: setattr_copy(&init_user_ns, inode, iattr);
                   proc/proc_sysctl.c:     setattr_copy(&init_user_ns, inode, attr);
                   ramfs/file-nommu.c:     setattr_copy(&init_user_ns, inode, ia);
                   reiserfs/inode.c:               setattr_copy(&init_user_ns, inode, attr);
                   sysv/file.c:    setattr_copy(&init_user_ns, inode, attr);
                   udf/file.c:     setattr_copy(&init_user_ns, inode, attr);
                   ufs/inode.c:    setattr_copy(&init_user_ns, inode, attr);
                   zonefs/super.c: setattr_copy(&init_user_ns, inode, iattr);

so we pass mnt_userns further down for all fses that have FS_ALLOW_IDMAP
set or where it's located in a helper library like libfs whose helpers
might be called by an idmapped mount aware fs.

When an fs is made aware of idmapped mounts the mnt_userns will
naturally be passed down further at which point the relevant fs
developer can decide how to restructure their own internal helpers
instead of vfs developers deciding these internals for them.

The xfs port is a good example where the xfs developers had - rightly so
- opinions on how they wanted the calling conventions for their internal
helpers to look like and how they wanted to pass around mnt_userns. I
don't feel in a position to mandate this from a vfs developers
perspective. I will happily provide input and express my opinion but the
authority of the vfs-calling-convention police mostly ends at the i_op
level.

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

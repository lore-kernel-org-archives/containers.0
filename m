Return-Path: <SRS0=/cWj=E6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A033DC2D0E4
	for <containers@archiver.kernel.org>; Tue, 24 Nov 2020 14:00:18 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C263920708
	for <containers@archiver.kernel.org>; Tue, 24 Nov 2020 14:00:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C263920708
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1C8D5860C4;
	Tue, 24 Nov 2020 14:00:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id h0GMNCuvA7iC; Tue, 24 Nov 2020 14:00:16 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 873D285D95;
	Tue, 24 Nov 2020 14:00:16 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 666ACC163C;
	Tue, 24 Nov 2020 14:00:16 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 18AD9C0052
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 14:00:15 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1339385D95
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 14:00:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id nsGmlEEnurY8
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 14:00:14 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 29D2F85D54
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 14:00:14 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1khYrD-0002SV-VO; Tue, 24 Nov 2020 13:59:48 +0000
Date: Tue, 24 Nov 2020 14:59:46 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Tycho Andersen <tycho@tycho.pizza>
Subject: Re: [PATCH v2 07/39] mount: attach mappings to mounts
Message-ID: <20201124135946.27krt6za2qapyx43@wittgenstein>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-8-christian.brauner@ubuntu.com>
 <20201123154719.GD4025434@cisco> <20201123162428.GA24807@cisco>
 <20201124123035.hbv4sstyoucht7xp@wittgenstein>
 <20201124133740.GA52954@cisco>
 <20201124134035.2l36avuaqp6gxyum@wittgenstein>
 <20201124134459.GB52954@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201124134459.GB52954@cisco>
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, Alban Crequy <alban@kinvolk.io>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>,
 linux-api@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>,
 linux-fsdevel@vger.kernel.org, linux-integrity@vger.kernel.org,
 Stephen Smalley <stephen.smalley.work@gmail.com>, Todd Kjos <tkjos@google.com>
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

On Tue, Nov 24, 2020 at 08:44:59AM -0500, Tycho Andersen wrote:
> On Tue, Nov 24, 2020 at 02:40:35PM +0100, Christian Brauner wrote:
> > On Tue, Nov 24, 2020 at 08:37:40AM -0500, Tycho Andersen wrote:
> > > On Tue, Nov 24, 2020 at 01:30:35PM +0100, Christian Brauner wrote:
> > > > On Mon, Nov 23, 2020 at 11:24:28AM -0500, Tycho Andersen wrote:
> > > > > On Mon, Nov 23, 2020 at 10:47:19AM -0500, Tycho Andersen wrote:
> > > > > > On Sun, Nov 15, 2020 at 11:36:46AM +0100, Christian Brauner wrote:
> > > > > > > +static inline struct user_namespace *mnt_user_ns(const struct vfsmount *mnt)
> > > > > > > +{
> > > > > > > +	return mnt->mnt_user_ns;
> > > > > > > +}
> > > > > > 
> > > > > > I think you might want a READ_ONCE() here. Right now it seems ok, since the
> > > > > > mnt_user_ns can't change, but if we ever allow it to change (and I see you have
> > > > > > a idmapped_mounts_wip_v2_allow_to_change_idmapping branch on your public tree
> > > > > > :D), the pattern of,
> > > > > > 
> > > > > >         user_ns = mnt_user_ns(path->mnt);
> > > > > >         if (mnt_idmapped(path->mnt)) {
> > > > > >                 uid = kuid_from_mnt(user_ns, uid);
> > > > > >                 gid = kgid_from_mnt(user_ns, gid);
> > > > > >         }
> > > > > > 
> > > > > > could race.
> > > > > 
> > > > > Actually, isn't a race possible now?
> > > > > 
> > > > > kuid_from_mnt(mnt_user_ns(path->mnt) /* &init_user_ns */);
> > > > > WRITE_ONCE(mnt->mnt.mnt_user_ns, user_ns);
> > > > > WRITE_ONCE(m->mnt.mnt_flags, flags);
> > > > > kgid_from_mnt(mnt_user_ns(path->mnt) /* the right user ns */);
> > > > > 
> > > > > So maybe it should be:
> > > > > 
> > > > >          if (mnt_idmapped(path->mnt)) {
> > > > >                  barrier();
> > > > >                  user_ns = mnt_user_ns(path->mnt);
> > > > >                  uid = kuid_from_mnt(user_ns, uid);
> > > > >                  gid = kgid_from_mnt(user_ns, gid);
> > > > >          }
> > > > > 
> > > > > since there's no data dependency between mnt_idmapped() and
> > > > > mnt_user_ns()?
> > > > 
> > > > I think I had something to handle this case in another branch of mine.
> > > > The READ_ONCE() you mentioned in another patch I had originally dropped
> > > > because I wasn't sure whether it works on pointers but after talking to
> > > > Jann and David it seems that it handles pointers fine.
> > > > Let me take a look and fix it in the next version. I just finished
> > > > porting the test suite to xfstests as Christoph requested and I'm
> > > > looking at this now.
> > > 
> > > Another way would be to just have mnt_idmapped() test
> > > mnt_user_ns() != &init_user_ns instead of the flags; then I think you
> > > get the data dependency and thus correct ordering for free.
> > 
> > I indeed dropped mnt_idmapped() which is unnecessary. :)
> 
> It still might be a nice helper to prevent people from checking the
> flags and forgetting that there's a memory ordering issue, though.

I just mentioned this offline but for the record: the flag is gone since
we can rely on the pointer alone. :)

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

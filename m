Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3212AC4741F
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 21:06:43 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 44D8F20790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 21:06:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44D8F20790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 9A39E86BF3;
	Thu, 29 Oct 2020 21:06:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lnmfZflZySCh; Thu, 29 Oct 2020 21:06:39 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2AA5686A6B;
	Thu, 29 Oct 2020 21:06:39 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1C4FDC0859;
	Thu, 29 Oct 2020 21:06:39 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 70898C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:06:37 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 42D8720466
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:06:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 45Fr4EZHnYIY
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:06:35 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by silver.osuosl.org (Postfix) with ESMTPS id 6A9992045C
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:06:35 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id 822B35807DF;
 Thu, 29 Oct 2020 17:06:33 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Thu, 29 Oct 2020 17:06:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=fYIDdq21L3PNif5afbEUKONBxow
 yx9f6qw+sQaUQx0Y=; b=bGUYRyMUpthilA5bQ10aPU+KdYNie57r/5wBrgijABq
 s7aehhE86zzIn7RqEp0bZZtxXb1IdY13z3P0HsUCZBcQRwuTEYtrs/0amoA1NzDW
 v9oNCDlok1l91OtHOJfztlU57tX8WM/Ab9slbfpASGWFbLtWO9fBhg+gf41CIzJS
 6/edNyCmFTtrigWwXUqC43SRNCgTTzSzqhGp3G1z7mAy2j44zhy8CdEePT9p0zOq
 OiRJbOWxtkTPdviEnyyUaO4jqOJyJp5dyDRVrVQAVFwa8GHs3CGMnNPWjjo51g1q
 vkDNarhpemR/y7Rm6T8c15bqJi3H6ZPybWdfL9oJjPA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=fYIDdq
 21L3PNif5afbEUKONBxowyx9f6qw+sQaUQx0Y=; b=ANMYYU1hiB/GO9911ZFl+z
 XpknmkW+TvWcsslx+BfrP2kM7LffztVYc9tmktae7/SatO4YkhVbkkUfBylAba2A
 I2a2n2BbulsFMeAsw3WIZN57eLxTYwxBkl/wqQCvjdii2vV69IH3ivUFHOccZ9zE
 dzt1jXnMFhAA6r/ed21mimZYJz1+U51nuqzJXZlme0adofrtZYgTtKB6ltEiTD2t
 tsLwQ3YSVLXZfKlt50fkRenwFYdw86uCLRVPm+dpxWpF/jpgcPAzK4pm6K/F254N
 GuDopL1Eu6i9RT3D07xXogZgfBRi+ipoI/T07NmvM2a7QPR7gAlEGglcNfii9q8w
 ==
X-ME-Sender: <xms:1S6bX5X0UpnxyWSs_x7M_oxu-FyVmL880_Mr3lEYdR-yw_cxrFHMCg>
 <xme:1S6bX5kdYsfSJKzOWQAyfTttpu45AyIzE57ThzMTJJXOtdDqDR41UEF0KSvkYX9hK
 JkZ2QgjUrpBO_8LvQA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrleefgddugeegucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepuddvkedruddtjedrvdeguddrudekieenucevlhhushhtvghrufhiii
 gvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihii
 iigr
X-ME-Proxy: <xmx:1S6bX1ZoyvmB-RXkwwzrD6Q2oIf_1ESIdFCLVwDWTBuqTDS4YVnfhw>
 <xmx:1S6bX8UcFz20aS5YwXGNV9AwhLoFcNUpLxr_kFg2lSHXJMZveaRo7Q>
 <xmx:1S6bXzkCkF5oVC1WJcury6tjEZs37W-4ObyK7W01GC8zfQszN60ZDw>
 <xmx:2S6bX06A-ibhhoXoh2nrAb9pUxvin50aNgPjmRu-yzswG5hG0IICjw>
Received: from cisco (unknown [128.107.241.186])
 by mail.messagingengine.com (Postfix) with ESMTPA id C96743280065;
 Thu, 29 Oct 2020 17:06:22 -0400 (EDT)
Date: Thu, 29 Oct 2020 15:06:20 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201029210620.GB135035@cisco>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <20201029022733.GB306023@dread.disaster.area>
 <20201029161920.zp7p3335x3q2a36e@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201029161920.zp7p3335x3q2a36e@wittgenstein>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Chinner <david@fromorbit.com>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Miklos Szeredi <miklos@szeredi.hu>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 Casey Schaufler <casey@schaufler-ca.com>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>,
 linux-unionfs@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>,
 linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 Alban Crequy <alban@kinvolk.io>, linux-integrity@vger.kernel.org,
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

On Thu, Oct 29, 2020 at 05:19:20PM +0100, Christian Brauner wrote:
> This approach (always) seemed conceptually wrong to me. Like Tycho said
> somewhere else this basically would act like a global variable which
> isn't great.

Elaborating on this a bit: the way Christian has organized this series
(by adding a parameter to the various inode operations) forces people
to make a choice about what user namespace to pass. They can of course
make the wrong choice, but that will show up in a diff somewhere, and
hopefully someone will notice.

If we pass things via current-> somewhere, people could potentially
avoid making this choice, and then we wind more of the kinds of bugs
Eric is worried about elsewhere in the thread.

While it does result in larger patches initally, requiring people to
reason about it explicitly is the right move, IMO.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

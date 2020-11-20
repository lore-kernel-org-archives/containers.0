Return-Path: <SRS0=iYPN=E2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5437DC5519F
	for <containers@archiver.kernel.org>; Fri, 20 Nov 2020 09:14:43 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0FE6D2224C
	for <containers@archiver.kernel.org>; Fri, 20 Nov 2020 09:14:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TTIb8ohQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FE6D2224C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4BCA085B36;
	Fri, 20 Nov 2020 09:14:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WfGsbYQ4iN6u; Fri, 20 Nov 2020 09:14:39 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 89F94867AA;
	Fri, 20 Nov 2020 09:14:39 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 66A14C1825;
	Fri, 20 Nov 2020 09:14:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AE089C0891
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 09:14:37 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 90F9C875CC
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 09:14:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2YIiBJhtWwQu
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 09:14:36 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 19B4C875C3
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 09:14:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
 References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
 Content-Transfer-Encoding:Content-ID:Content-Description;
 bh=mNLnU8cl44VoAwmtF3N/cVr4YIhMWVFWr0ATljQRTes=; b=TTIb8ohQ+PwDq74N++0bgk2zll
 V4Tj1uTEh1nLpZA5CWmWqyId5ggC5fFNgj0pboCtHDqY3L67GCyZNuDKPhIyDglg/E86QFfp03+bI
 wGOy+rZdGneSYckkAgLWS4Lquu6jKns1/3RDzJtgxPXaG/cApFOXbxrjmFwxID+CMkn8bfg2ariPD
 q8PRJnZIyL/pF1pJzmkrZOIsiNWxi9EqbnrSKptOWKTutDymxTvJ3MTHzpDBEzdVC/iFZdmds1m9/
 d0Edw6QH1c1pHG3bkB/sYhvaimIvfkENpPeia3BDp903NdAOst0DSmCRA3GxWKsouD7etMiOrv1DU
 Mvs7rk4A==;
Received: from hch by casper.infradead.org with local (Exim 4.92.3 #3 (Red Hat
 Linux)) id 1kg2TH-0003xV-Ap; Fri, 20 Nov 2020 09:12:47 +0000
Date: Fri, 20 Nov 2020 09:12:47 +0000
From: Christoph Hellwig <hch@infradead.org>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v2 00/39] fs: idmapped mounts
Message-ID: <20201120091247.GA14894@infradead.org>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201120023309.GH9685@magnolia>
 <20201120091044.ofkzgiwoyru23vc4@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201120091044.ofkzgiwoyru23vc4@wittgenstein>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by
 casper.infradead.org. See http://www.infradead.org/rpr.html
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 "Darrick J. Wong" <darrick.wong@oracle.com>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>,
 linux-api@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>,
 Alban Crequy <alban@kinvolk.io>, linux-integrity@vger.kernel.org,
 Todd Kjos <tkjos@google.com>
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

On Fri, Nov 20, 2020 at 10:10:44AM +0100, Christian Brauner wrote:
> Maybe you didn't see this or you're referring to xfstests but this
> series contains a >=4000 lines long test-suite that validates all core
> features with and without idmapped mounts. It's the last patch in this
> version of the series and it's located in:
> tools/testing/selftests/idmap_mounts.
> 
> Everytime a filesystem is added this test-suite will be updated. We
> would perfer if this test would be shipped with the kernel itself and
> not in a separate test-suite such as xfstests. But we're happy to add
> patches for the latter at some point too.

selftests is a complete pain to use, partialy because it is not
integrated with the framework we file system developers use (xfstests)
and partially because having the test suite in the kernel tree really
breaks a lot of the typical use cases.  So I think we'll need to wire
this up in the proper place instead.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

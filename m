Return-Path: <SRS0=iYPN=E2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ED7DC64E69
	for <containers@archiver.kernel.org>; Fri, 20 Nov 2020 21:16:03 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AC09822264
	for <containers@archiver.kernel.org>; Fri, 20 Nov 2020 21:16:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="dU4KoiHZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC09822264
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 2BDCB86F43;
	Fri, 20 Nov 2020 21:16:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zDZDRrvQLe5O; Fri, 20 Nov 2020 21:16:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A43EF86F27;
	Fri, 20 Nov 2020 21:16:01 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 85306C1825;
	Fri, 20 Nov 2020 21:16:01 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3D20DC0891
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 21:16:00 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 28863872A4
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 21:16:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id tvZSkxeDFzQ2
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 21:15:59 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 7E966872A3
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 21:15:59 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id q5so9083971pfk.6
 for <containers@lists.linux-foundation.org>;
 Fri, 20 Nov 2020 13:15:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=h3PVNgWJ4wv679ueVcfOMGTzPLuWakBRGW5tpcXVwpU=;
 b=dU4KoiHZzIEflMXxYsdAq02/ZtKHAbVYN3DUKz1jjW6FqozuzDqj1HhoL1AotmA6iH
 J0FPfOX8vroNiQrqM3+Mg92Tbbg8Ta4YWvs2XOfQEnQO7II6Vndq8Xm0uvHveSP/s0Nq
 YqotYUJAiv3Sjru2HYlJJBB0l/Fq8aCCvoJwg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=h3PVNgWJ4wv679ueVcfOMGTzPLuWakBRGW5tpcXVwpU=;
 b=IEmS16vpI1a/tky7VlHj+Erqy1zZJ3ikjsCQ/7/NF9ZR+yaWMOZEG4mxyZGUEQ4fJQ
 fOnWK1vQxhJV/6FLD23YASUvwKS/ziM7BFUqK3yhycU9xmTvPMP0IZJlsVLyFJupd9qv
 Try8/dHg3Wmv9pR2X9IAPYxrjCVFJlbdSGHRXDvY7vv223n218DFhzm4RyLN4XlpLdR6
 7P3hZ2Dz7lX0u09A+NEd4h+3rC+KtOXgJQgIb6N5Hp+MmcCC4s0RQM8YcgJbPnLypIYb
 MCDupEM6g82ppyBzhHvttmZL+xtgkzMEJBMf1pJu6sxunz8hObOc4wnsKXxUNoRNzqQI
 B/pA==
X-Gm-Message-State: AOAM5308gXvzmMZzLO6epMWZ70ewTw8YfQdC2uMWfgJ9mPx7co1Hh5yV
 ZVCr8KlPN8qmxNWcl/oPfL/0fQ==
X-Google-Smtp-Source: ABdhPJxKoNsqmJfw8FXBuNWzYTFCvMP4QSPsIPE4HroDYde9n5FBnmXaYeQPf9Hkrj1TBoT0dMj64g==
X-Received: by 2002:aa7:8ac1:0:b029:197:7198:e943 with SMTP id
 b1-20020aa78ac10000b02901977198e943mr14806170pfd.58.1605906959108; 
 Fri, 20 Nov 2020 13:15:59 -0800 (PST)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id k9sm4598556pfi.188.2020.11.20.13.15.57
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 20 Nov 2020 13:15:58 -0800 (PST)
Date: Fri, 20 Nov 2020 13:15:57 -0800
From: Kees Cook <keescook@chromium.org>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v2 39/39] tests: add vfs/idmapped mounts test suite
Message-ID: <202011201300.B158F1E4B@keescook>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-40-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201115103718.298186-40-christian.brauner@ubuntu.com>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
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
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org, Todd Kjos <tkjos@google.com>
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

On Sun, Nov 15, 2020 at 11:37:18AM +0100, Christian Brauner wrote:
> This adds a whole test suite for idmapped mounts but in order to ensure that
> there are no regression for the vfs itself it also includes tests for correct
> functionality on non-idmapped mounts. The following tests are currently
> available with more to come in the future:

Awesome! :)

Some glitches in the build, though... something about the ordering or
the Make rules produces odd results on a failure:

$ make
gcc -g -I../../../../usr/include/ -Wall -O2 -pthread    xattr.c internal.h utils.c utils.h -lcap -o /home/kees/src/linux-build/seccomp/tools/testing/selftests/idmap_mounts/xattr
gcc -g -I../../../../usr/include/ -Wall -O2 -pthread    core.c internal.h utils.c utils.h -lcap -o /home/kees/src/linux-build/seccomp/tools/testing/selftests/idmap_mounts/core
core.c:19:10: fatal error: sys/acl.h: No such file or directory
   19 | #include <sys/acl.h>
      |          ^~~~~~~~~~~
compilation terminated.
make: *** [../lib.mk:139: /home/kees/src/linux-build/seccomp/tools/testing/selftests/idmap_mounts/core]
Error 1
$ make
make: Nothing to be done for 'all'.
$ file xattr core
xattr: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=7a3c1951e54f20e657b4181c1be77c7183a54f81, for GNU/Linux 3.2.0, with debug_info, not stripped
core:  GCC precompiled header (version 014) for C

Even after I install libacl1-dev, I still get a "core" file output which
breaks attempts to build again. :)


Is there any way to have the test suite not depend on
__NR_mount_setattr? Running this test on older kernels fails everything.


-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

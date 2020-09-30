Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 302E2C4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:12:30 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BF77F206C1
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:12:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="gm5u2PcQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF77F206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 6EB4E85F82;
	Wed, 30 Sep 2020 23:12:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id v-I7FLT5Szk3; Wed, 30 Sep 2020 23:12:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 05A5784F24;
	Wed, 30 Sep 2020 23:12:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 00C2AC0889;
	Wed, 30 Sep 2020 23:12:29 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 73083C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 5AB51227AD
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id gQuENTT-MJuC
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:26 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by silver.osuosl.org (Postfix) with ESMTPS id E206F20345
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:26 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id gm14so801437pjb.2
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 16:12:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=GcGfH7kHx9j3QvyhQc4NcbAnPXZ+xitJlnC9m04nhjQ=;
 b=gm5u2PcQKPEnnJP1IJQaMsMKmuVSqh4mDV+SE3B7HkfYd1s4DfKRJ5JPUSmnYUHwJ8
 a+XP4WcTYmVhx04y548/+0CYzCszHMJsUlfqTuWHhOFXsePMVlmUXi21FLje4PBXRm98
 Jo1/sYLM65/hhSixFbPryuAHtryh7BTjsn8Us=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=GcGfH7kHx9j3QvyhQc4NcbAnPXZ+xitJlnC9m04nhjQ=;
 b=G8a3YjCKRHdKshWtwqumrdkC/LrdujIXz7GLT/XfQc40LAS40rKRCV/71x1eduk8di
 VklROegVh52QfJS0GOXUHPdK2X4AqjOUbnWZ0uRu9jnXPDtZVtfUvetgUL9enzdt8UhO
 QU6bKRs/nJJfRp0YmxWoJJTjlZ/blmooU2jwgtGB5nPls/Hx93mLug21bCUkv79aOkDv
 scy7CaQv4jEhP+DduC7O5iLfV73YerbSk2CKd3oejVuR6VVBCy9PA8glyyGThErnln9F
 5IMijuyrRMhdrTNBDEWfwq+h1S6rDDl7KQ6p/Tk9hWMPgDNJx5gWRNqdTji0w2jiRHzW
 sUbg==
X-Gm-Message-State: AOAM532Ma7DVx4diGRGlMJpSnaZoVmuUH8PrJLtagFGtbKaBd1ltUrZg
 8SPcf3gjBAI5wQzVcKBof7AofA==
X-Google-Smtp-Source: ABdhPJzERV8mYc2Hm3YRyOthOTUpcKBJEFFaKP6HXJWxaQaOtJgHHdz5S1SjWX7xipFAAf48W71nEw==
X-Received: by 2002:a17:90a:cf13:: with SMTP id
 h19mr941884pju.88.1601507546488; 
 Wed, 30 Sep 2020 16:12:26 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id q15sm1321933pjp.26.2020.09.30.16.12.25
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 16:12:25 -0700 (PDT)
Date: Wed, 30 Sep 2020 16:12:24 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202009301559.49BEDB79D@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
 <CAG48ez0whaSTobwnoJHW+Eyqg5a8H4JCO-KHrgsuNiEg0qbD3w@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez0whaSTobwnoJHW+Eyqg5a8H4JCO-KHrgsuNiEg0qbD3w@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, Oct 01, 2020 at 12:00:46AM +0200, Jann Horn wrote:
> On Wed, Sep 30, 2020 at 5:20 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> [...]
> > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> [...]
> > +int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
> > +                          struct pid *pid, struct task_struct *task)
> > +{
> > +       struct seccomp_filter *f;
> > +
> > +       /*
> > +        * We don't want some sandboxed process know what their seccomp
> > +        * filters consist of.
> > +        */
> > +       if (!file_ns_capable(m->file, &init_user_ns, CAP_SYS_ADMIN))
> > +               return -EACCES;
> > +
> > +       f = READ_ONCE(task->seccomp.filter);
> > +       if (!f)
> > +               return 0;
> 
> Hmm, this won't work, because the task could be exiting, and seccomp
> filters are detached in release_task() (using
> seccomp_filter_release()). And at the moment, seccomp_filter_release()
> just locklessly NULLs out the tsk->seccomp.filter pointer and drops
> the reference.

Oh nice catch. Yeah, this would only happen if it was the only filter
remaining on a process with no children, etc.

> 
> The locking here is kind of gross, but basically I think you can
> change this code to use lock_task_sighand() / unlock_task_sighand()
> (see the other examples in fs/proc/base.c), and bail out if
> lock_task_sighand() returns NULL. And in seccomp_filter_release(), add
> something like this:
> 
> /* We are effectively holding the siglock by not having any sighand. */
> WARN_ON(tsk->sighand != NULL);

Yeah, good idea.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

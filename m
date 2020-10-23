Return-Path: <SRS0=l1uc=D6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A52D4C56201
	for <containers@archiver.kernel.org>; Fri, 23 Oct 2020 01:21:50 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C661420878
	for <containers@archiver.kernel.org>; Fri, 23 Oct 2020 01:21:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="bWPmglrU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C661420878
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 1D738203B5;
	Fri, 23 Oct 2020 01:21:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OWgmWqVG333h; Fri, 23 Oct 2020 01:21:47 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 5B3C920459;
	Fri, 23 Oct 2020 01:21:47 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 442B6C0052;
	Fri, 23 Oct 2020 01:21:47 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D206CC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 01:21:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id B356320459
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 01:21:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id y8T++O8GsyvX
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 01:21:44 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f65.google.com (mail-ej1-f65.google.com
 [209.85.218.65])
 by silver.osuosl.org (Postfix) with ESMTPS id F1F9E203B5
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 01:21:43 +0000 (UTC)
Received: by mail-ej1-f65.google.com with SMTP id a3so49064ejy.11
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 18:21:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=aoxn8RZh5GwLX2OTvbY4F3fYrAFarAXAp+zyIW9UVc0=;
 b=bWPmglrUmUWeh/iJB7I1EBJU+TdBzoO9kJeAZdj0Mj7vyjbv9DyccX5Lt+lUFusiZw
 HWpqEJDPjpY3Pe66lK3CAkBsqcDG1SzJroJ/TrLWOH68lnkP3CHZa96739LkvB31F0p2
 UKaI6v6FS6fL3igL3m2SvuN8QdEUHemh+0A+WspZbjpxU8NlNH1xji6y4zYUku/PAtIG
 VlsE4Z2Vr2DxmyRQoiSH2mQuJn6k9T8lU/ZuPxibEI768Vlsje7dAVkK4A+TJ9+adHG8
 +FBZ1+GlJF4yKcmomBogElmJ3P88v835veafFeBLgDo8obHbAFEfQjagR4wLw4RxeZia
 Dx4Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=aoxn8RZh5GwLX2OTvbY4F3fYrAFarAXAp+zyIW9UVc0=;
 b=dr4rRmsCrUf8/KRJ4CH+3RuuBAsEeTQSACZ0ff5u4HvubsMnZt/HXF/DU+DxeVIlt3
 OAW1hPQCjUJuoXZqaGqXVLXXwXWYn0htI2XxWDYNOgbFX+kZSMFvOMFjROK0KxPYtwWB
 SDIOQo3jzeZA8a+41xw2L5fQz26Bj+9ZJnaUC17WEUwGZtb1MHTS3FVf40Y5Df9oUKBv
 59J/e13jWqveMsKbxi0ofB6lTkIBtidd4amNzdAZkRG54KtLMtqv+KMBqKHuajFkBlY/
 L/ZOqwmnrdgBqcM8n/+RJv875N3fP6PLWPxD+E50N8KeBXA7LnZelhW6U0+uz0nhkEQn
 7P4g==
X-Gm-Message-State: AOAM532+xjPsVYSQNXXebrq+YZ9qPE9VJImMuarYgm+Z7IZO9YY1HpRe
 wbifDLvbUd04PGpjOFoDRBuxkGANT0UGCQllIZ7c
X-Google-Smtp-Source: ABdhPJzDtfnYw+rfKgxc4a8mUFIh6ll/aQ2+0itoJxliGHEeO3L/XBWkrOQEYSixIJb79O9lCBjh5YKgmDlUs8u/x/U=
X-Received: by 2002:a17:906:25cc:: with SMTP id
 n12mr4813564ejb.488.1603416102090; 
 Thu, 22 Oct 2020 18:21:42 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1593198710.git.rgb@redhat.com>
 <6e2e10432e1400f747918eeb93bf45029de2aa6c.1593198710.git.rgb@redhat.com>
 <CAHC9VhSCm5eeBcyY8bBsnxr-hK4rkso9_NJHJec2OXLu4m5QTA@mail.gmail.com>
 <20200729194058.kcbsqjhzunjpipgm@madcap2.tricolour.ca>
 <CAHC9VhRUwCKBjffA_XNSjUwvUn8e6zfmy8WD203dK7R2KD0__g@mail.gmail.com>
 <20201002195231.GH2882171@madcap2.tricolour.ca>
 <20201021163926.GA3929765@madcap2.tricolour.ca>
In-Reply-To: <20201021163926.GA3929765@madcap2.tricolour.ca>
From: Paul Moore <paul@paul-moore.com>
Date: Thu, 22 Oct 2020 21:21:31 -0400
Message-ID: <CAHC9VhRb7XMyTrcrmzM3yQO+eLdO_r2+DOLKr9apDDeH4ua2Ew@mail.gmail.com>
Subject: Re: [PATCH ghak90 V9 05/13] audit: log container info of syscalls
To: Richard Guy Briggs <rgb@redhat.com>
Cc: nhorman@tuxdriver.com, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
 dhowells@redhat.com, Linux-Audit Mailing List <linux-audit@redhat.com>,
 netfilter-devel@vger.kernel.org, ebiederm@xmission.com, simo@redhat.com,
 netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 Eric Paris <eparis@parisplace.org>, mpatel@redhat.com
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

On Wed, Oct 21, 2020 at 12:39 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> Here is an exmple I was able to generate after updating the testsuite
> script to include a signalling example of a nested audit container
> identifier:
>
> ----
> type=PROCTITLE msg=audit(2020-10-21 10:31:16.655:6731) : proctitle=/usr/bin/perl -w containerid/test
> type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=7129731255799087104^3333941723245477888
> type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115583 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=3333941723245477888
> type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115580 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=8098399240850112512^3333941723245477888
> type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115582 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> type=SYSCALL msg=audit(2020-10-21 10:31:16.655:6731) : arch=x86_64 syscall=kill success=yes exit=0 a0=0xfffe3c84 a1=SIGTERM a2=0x4d524554 a3=0x0 items=0 ppid=115564 pid=115567 auid=root uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=ttyS0 ses=1 comm=perl exe=/usr/bin/perl subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=testsuite-1603290671-AcLtUulY
> ----
>
> There are three CONTAINER_ID records which need some way of associating with OBJ_PID records.  An additional CONTAINER_ID record would be present if the killing process itself had an audit container identifier.  I think the most obvious way to connect them is with a pid= field in the CONTAINER_ID record.

Using a "pid=" field as a way to link CONTAINER_ID records to other
records raises a few questions.  What happens if/when we need to
represent those PIDs in the context of a namespace?  Are we ever going
to need to link to records which don't have a "pid=" field?  I haven't
done the homework to know if either of these are a concern right now,
but I worry that this might become a problem in the future.

The idea of using something like "item=" is interesting.  As you
mention, the "item=" field does present some overlap problems with the
PATH record, but perhaps we can do something similar.  What if we
added a "record=" (or similar, I'm not worried about names at this
point) to each record, reset to 0/1 at the start of each event, and
when we needed to link records somehow we could add a "related=1,..,N"
field.  This would potentially be useful beyond just the audit
container ID work.

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

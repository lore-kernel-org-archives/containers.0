Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14D99C388F9
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 01:35:36 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 908F722249
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 01:35:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="Lj2eTMWd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 908F722249
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 1AC508743E;
	Wed, 28 Oct 2020 01:35:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ENzFz3YaKYoe; Wed, 28 Oct 2020 01:35:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 0E2078743A;
	Wed, 28 Oct 2020 01:35:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E632EC088B;
	Wed, 28 Oct 2020 01:35:33 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DB3BBC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 01:35:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 9642A203DC
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 01:35:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 0VNLbwSL+ani
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 01:35:30 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by silver.osuosl.org (Postfix) with ESMTPS id 60BBA203CE
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 01:35:30 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id dt13so4892708ejb.12
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 18:35:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=EhaQv7Xqn9C10/6kPilmFG/LY90YB69CHHSm/P4LmUk=;
 b=Lj2eTMWdQNRX51rp+69kJ+7MIJveC7lv8t0w/6GAwNCZDU97tO7fXzTZewOx55Ac1l
 qfo9NYf3w/1oZOOMsUpmk5QFBOLD6rEq4Y+xGwdcqgYSlAvt/V1eCOoLhOGtMpxn22lY
 BpPv8So2RSzkwV4VqW9Z81xo/sm6G/2qErp4megpsjRLRnCsLMimzT//EYKnBmWXYPYY
 Sljt2SxpJGW+CX70ABsj4p+oWaehsd7e48Xa9uvPlScUQdjQsFInIzQICwjOLHYNYT2Z
 rVKc0MWZtpSmx99XULBfKIiPaFC7zAwivfy+JYaPy+FhDaqHk6y3p83LlgRiUo5yGc2I
 JWSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=EhaQv7Xqn9C10/6kPilmFG/LY90YB69CHHSm/P4LmUk=;
 b=srQBHlphClLVvFzJbJbkgJ1ThQPlpBxpz/+3PLRCi0eCTMN0Ox/r1SGk+YLEbailvq
 WdusYy8ZJIMF2+0UJZpE2ug6YWPkCoyBCYz+vWBGVs9muZeK06ms9ApnQQB+h46KbmI0
 W6oVvjDireuWYfHJwUaHl6m3wfuCnXJ6InsuYLXYKBZJ+RfDzN93vI1xwVLCsXS8WFnT
 PpCmmkUp7VI2Jhe19m0lA+bhPp+rCdmNuIK3qosQrSWIHMAlNmhGoAD/8WqJxxEee9nY
 O+MHVwFnW2MhowjOiayDgN/wNLPffnOvao4ZfkJAOCz0yE43z5tbqW4w/Rlkq9SyI/M/
 nZTg==
X-Gm-Message-State: AOAM530L0KVDoDqjvppUenS0W77nFtR3LxeelWep8PN9vpTXittvTUVa
 zf+KecJiBPeezM5vRK6lv/LDFsBK/6MHhhzllZbk
X-Google-Smtp-Source: ABdhPJydImqf6rjIcFvdKoVKRijlUJM6c3tT5+zpyIh0DgksT/WwCUJmb9M0MAWnaqlVZBE1LbPiRD1v+2NmrHAlBa8=
X-Received: by 2002:a17:906:4811:: with SMTP id
 w17mr4982322ejq.431.1603848928683; 
 Tue, 27 Oct 2020 18:35:28 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1593198710.git.rgb@redhat.com>
 <6e2e10432e1400f747918eeb93bf45029de2aa6c.1593198710.git.rgb@redhat.com>
 <CAHC9VhSCm5eeBcyY8bBsnxr-hK4rkso9_NJHJec2OXLu4m5QTA@mail.gmail.com>
 <20200729194058.kcbsqjhzunjpipgm@madcap2.tricolour.ca>
 <CAHC9VhRUwCKBjffA_XNSjUwvUn8e6zfmy8WD203dK7R2KD0__g@mail.gmail.com>
 <20201002195231.GH2882171@madcap2.tricolour.ca>
 <20201021163926.GA3929765@madcap2.tricolour.ca>
 <CAHC9VhRb7XMyTrcrmzM3yQO+eLdO_r2+DOLKr9apDDeH4ua2Ew@mail.gmail.com>
 <20201023204033.GI2882171@madcap2.tricolour.ca>
In-Reply-To: <20201023204033.GI2882171@madcap2.tricolour.ca>
From: Paul Moore <paul@paul-moore.com>
Date: Tue, 27 Oct 2020 21:35:17 -0400
Message-ID: <CAHC9VhS7Gzd=pQ13eSOHDT8nO-z_yxsVW0E5r6mkpPYi3Txe2g@mail.gmail.com>
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

On Fri, Oct 23, 2020 at 4:40 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2020-10-22 21:21, Paul Moore wrote:
> > On Wed, Oct 21, 2020 at 12:39 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> > > Here is an exmple I was able to generate after updating the testsuite
> > > script to include a signalling example of a nested audit container
> > > identifier:
> > >
> > > ----
> > > type=PROCTITLE msg=audit(2020-10-21 10:31:16.655:6731) : proctitle=/usr/bin/perl -w containerid/test
> > > type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=7129731255799087104^3333941723245477888
> > > type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115583 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> > > type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=3333941723245477888
> > > type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115580 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> > > type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=8098399240850112512^3333941723245477888
> > > type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115582 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> > > type=SYSCALL msg=audit(2020-10-21 10:31:16.655:6731) : arch=x86_64 syscall=kill success=yes exit=0 a0=0xfffe3c84 a1=SIGTERM a2=0x4d524554 a3=0x0 items=0 ppid=115564 pid=115567 auid=root uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=ttyS0 ses=1 comm=perl exe=/usr/bin/perl subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=testsuite-1603290671-AcLtUulY
> > > ----
> > >
> > > There are three CONTAINER_ID records which need some way of associating with OBJ_PID records.  An additional CONTAINER_ID record would be present if the killing process itself had an audit container identifier.  I think the most obvious way to connect them is with a pid= field in the CONTAINER_ID record.
> >
> > Using a "pid=" field as a way to link CONTAINER_ID records to other
> > records raises a few questions.  What happens if/when we need to
> > represent those PIDs in the context of a namespace?  Are we ever going
> > to need to link to records which don't have a "pid=" field?  I haven't
> > done the homework to know if either of these are a concern right now,
> > but I worry that this might become a problem in the future.
>
> Good point about PID namespaces in the future but those accompanying
> records will already have to be conditioned for the PID namespace
> context that is requesting it, so I don't see this as a showstopper.

Possibly, it just gets very messy.  Doubly so when you start looking
at potentially adjusting for multiple audit daemons.  Thankfully it
doesn't look like using the PID is a good idea for other reasons.

> I've forgotten about an important one we already hit, which is a network
> event that only has a NETFILTER_PKT record, but in that case, there is
> no ambiguity since there are no other records associated with that
> event.  So the second is already an issue now.  Using
> task_tgid_nr(current), in the contid testsuite script network event it
> attributed it to ping which caused the event, but we cannot use this
> since it wasn't triggered by a syscall and doesn't accurately reflect
> the kernel thread that received it.  It could just be set to zero for
> network events.

Possibly.  It just seems like too much hackery to start; that's the
stuff you do once it has been in a kernel release for years and need
to find a workaround that doesn't break everything.  I think we should
aim a bit higher right now.

> > The idea of using something like "item=" is interesting.  As you
> > mention, the "item=" field does present some overlap problems with the
> > PATH record, but perhaps we can do something similar.  What if we
> > added a "record=" (or similar, I'm not worried about names at this
> > point) to each record, reset to 0/1 at the start of each event, and
> > when we needed to link records somehow we could add a "related=1,..,N"
> > field.  This would potentially be useful beyond just the audit
> > container ID work.
>
> Does it make any sense to use the same keyword in each type of record
> such as record/records as in PATH/SYSCALL: item/items ?

That was mentioned above, if you can assure yourself and the rest of
us that it can be safely reused I think that might be okay, but I'm
not convinced that is safe at the moment.  Although I will admit those
are fears are not based on an exhaustive search through the code (or a
determined "think").

> (I prefer 0-indexed like item=...)

I have no preference on where we start the index, but it makes sense
to keep the same index starting point as the PATH records.

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

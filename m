Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,TVD_FW_GRAPHIC_NAME_MID,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FE53C4363C
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 19:36:02 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 69E6420738
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 19:36:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b="Ku9Aj0/L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69E6420738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=us.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id F02948531D;
	Mon, 21 Sep 2020 19:36:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pCK7pa03FXZg; Mon, 21 Sep 2020 19:36:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1EFB9851A4;
	Mon, 21 Sep 2020 19:36:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0817FC0889;
	Mon, 21 Sep 2020 19:36:00 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B2251C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:35:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 9568D2045E
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:35:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id jd2cPPgCbiwN
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:35:54 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com
 [148.163.156.1])
 by silver.osuosl.org (Postfix) with ESMTPS id 8DA0F2041C
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:35:54 +0000 (UTC)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
 by mx0a-001b2d01.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id
 08LJVrGC148727
 for <containers@lists.linux-foundation.org>; Mon, 21 Sep 2020 15:35:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com;
 h=mime-version :
 in-reply-to : to : cc : from : date : references : content-type :
 message-id : subject; s=pp1;
 bh=Cz8Uz7G2TbSxNOzI4JOvpe51GjkpZ0YiOQOAx9ICD+g=;
 b=Ku9Aj0/LPATNQdM9hw7mBazcY0PJDIPPix5cUCMq8JSxZgd0hTYls+oMw/ofKILWYwEu
 r+L7drsmUz2F2mn64MUDtx2VhczKbkSbUl30unVm3qHTwPhz1Ra0tjl9/wvhUqXB+Uq3
 7ptaqkURJb1qbczc7MexPulrf34Jxtoa3rm3dKxV/SELgAVNsLk0Z7tvuXR4CShmym/j
 Nb0R/FY7DQd66FB1wQJCVEQDszIvLNCsyUrZ438pcd5Y1W9FkeLBp5jOD3rYAFA01HTe
 gL04NXrhO6s0c5uD0uxbwkr10OgiibD/qLhkOwA+LyWvgv2GQx1XMkp/GYAr8WWH7hZv 2Q== 
Received: from smtp.notes.na.collabserv.com (smtp.notes.na.collabserv.com
 [192.155.248.72])
 by mx0a-001b2d01.pphosted.com with ESMTP id 33q0xn2jhq-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
 for <containers@lists.linux-foundation.org>; Mon, 21 Sep 2020 15:35:53 -0400
Received: from localhost
 by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
 for <containers@lists.linux-foundation.org> from <frankeh@us.ibm.com>;
 Mon, 21 Sep 2020 19:35:53 -0000
Received: from us1a3-smtp04.a3.dal06.isc4sb.com (10.106.154.237)
 by smtp.notes.na.collabserv.com (10.106.227.158) with
 smtp.notes.na.collabserv.com ESMTP; Mon, 21 Sep 2020 19:35:49 -0000
Received: from us1a3-mail116.a3.dal06.isc4sb.com ([10.146.45.125])
 by us1a3-smtp04.a3.dal06.isc4sb.com
 with ESMTP id 2020092119354967-685427 ;
 Mon, 21 Sep 2020 19:35:49 +0000 
MIME-Version: 1.0
In-Reply-To: <CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com>
To: Jann Horn <jannh@google.com>
From: "Hubertus Franke" <frankeh@us.ibm.com>
Date: Mon, 21 Sep 2020 15:35:49 -0400
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com>
X-KeepSent: 8837FC1A:5C0D4D64-852585EA:006B677F;
 type=4; name=$KeepSent
X-Mailer: IBM Notes Release 10.0.1FP1 March 26, 2019
X-LLNOutbound: False
X-Disclaimed: 42883
X-TNEFEvaluated: 1
x-cbid: 20092119-1335-0000-0000-0000050AA1A2
X-IBM-SpamModules-Scores: BY=0.294059; FL=0; FP=0; FZ=0; HX=0; KW=0; PH=0;
 SC=0.373977; ST=0; TS=0; UL=0; ISC=; MB=0.260164
X-IBM-SpamModules-Versions: BY=3.00013869; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000295; SDB=6.01438174; UDB=6.00772637; IPR=6.01220861; 
 MB=3.00034170; MTD=3.00000008; XFM=3.00000015; UTC=2020-09-21 19:35:51
X-IBM-AV-DETECTION: SAVI=unsuspicious REMOTE=unsuspicious XFE=unused
X-IBM-AV-VERSION: SAVI=2020-09-21 16:18:05 - 6.00011866
x-cbparentid: 20092119-1336-0000-0000-00001206A81F
Message-Id: <OF8837FC1A.5C0D4D64-ON852585EA.006B677F-852585EA.006BA663@notes.na.collabserv.com>
Subject: RE: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.235, 18.0.687
 definitions=2020-09-21_08:2020-09-21,
 2020-09-21 signatures=0
X-Proofpoint-Spam-Reason: orgsafe
X-Content-Filtered-By: Mailman/MimeDel 2.1.15
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 kernel list <linux-kernel@vger.kernel.org>,
 Valentin Rothberg <vrothber@redhat.com>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Tianyin Xu <tyxu@illinois.edu>,
 YiFei Zhu <zhuyifei1999@gmail.com>
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
Content-Type: multipart/mixed; boundary="===============2332523105491874235=="
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

--===============2332523105491874235==
Content-type: multipart/related; 
	Boundary="0__=0ABB0F79DFF8E1EF8f9e8a93df938690918c0ABB0F79DFF8E1EF"

--0__=0ABB0F79DFF8E1EF8f9e8a93df938690918c0ABB0F79DFF8E1EF
Content-Transfer-Encoding: quoted-printable
Content-type: text/plain; charset=US-ASCII


I suggest we first bring it down to the minimal features we what and
successively build the functions as these ideas evolve.
We asked YiFei to prepare a minimal set that brings home the basic
features. Might not be 100% optimal but having the hooks, the basic cache
in place and getting a good benefit should be a good starting point
to get this integrated into a linux kernel and then enable a larger
experimentation.
Does that make sense to approach it from that point ?


Hubertus Franke
frankeh@us.ibm.com




From:	Jann Horn <jannh@google.com>
To:	YiFei Zhu <zhuyifei1999@gmail.com>
Cc:	Linux Containers <containers@lists.linux-foundation.org>, YiFei
            Zhu <yifeifz2@illinois.edu>, bpf <bpf@vger.kernel.org>, Andrea
            Arcangeli <aarcange@redhat.com>, Dimitrios Skarlatos
            <dskarlat@cs.cmu.edu>, Giuseppe Scrivano <gscrivan@redhat.com>,
            Hubertus Franke <frankeh@us.ibm.com>, Jack Chen
            <jianyan2@illinois.edu>, Josep Torrellas
            <torrella@illinois.edu>, Kees Cook <keescook@chromium.org>,
            Tianyin Xu <tyxu@illinois.edu>, Tobin Feldman-Fitzthum
            <tobin@ibm.com>, Valentin Rothberg <vrothber@redhat.com>, Andy
            Lutomirski <luto@amacapital.net>, Will Drewry
            <wad@chromium.org>, Aleksa Sarai <cyphar@cyphar.com>, kernel
            list <linux-kernel@vger.kernel.org>
Date:	09/21/2020 03:16 PM
Subject:	[EXTERNAL] Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap
            cache of arg-independent filter results that allow syscalls



On Mon, Sep 21, 2020 at 7:35 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> This series adds a bitmap to cache seccomp filter results if the
> result permits a syscall and is indepenent of syscall arguments.
> This visibly decreases seccomp overhead for most common seccomp
> filters with very little memory footprint.

It would be really nice if, based on this, we could have a new entry
in procfs that has one line per entry in each syscall table. Maybe
something that looks vaguely like:

X86=5F64 0 (read): ALLOW
X86=5F64 1 (write): ALLOW
X86=5F64 2 (open): ERRNO -1
X86=5F64 3 (close): ALLOW
X86=5F64 4 (stat): <argument-dependent>
[...]
I386 0 (restart=5Fsyscall): ALLOW
I386 1 (exit): ALLOW
I386 2 (fork): KILL
[...]

This would be useful both for inspectability (at the moment it's
pretty hard to figure out what seccomp rules really apply to a given
task) and for testing (so that we could easily write unit tests to
verify that the bitmap calculation works as expected).

But if you don't want to implement that right now, we can do that at a
later point - while it would be nice for making it easier to write
tests for this functionality, I don't see it as a blocker.


> The overhead of running Seccomp filters has been part of some past
> discussions [1][2][3]. Oftentimes, the filters have a large number
> of instructions that check syscall numbers one by one and jump based
> on that. Some users chain BPF filters which further enlarge the
> overhead. A recent work [6] comprehensively measures the Seccomp
> overhead and shows that the overhead is non-negligible and has a
> non-trivial impact on application performance.
>
> We propose SECCOMP=5FCACHE, a cache-based solution to minimize the
> Seccomp overhead. The basic idea is to cache the result of each
> syscall check to save the subsequent overhead of executing the
> filters. This is feasible, because the check in Seccomp is stateless.
> The checking results of the same syscall ID and argument remains
> the same.
>
> We observed some common filters, such as docker's [4] or
> systemd's [5], will make most decisions based only on the syscall
> numbers, and as past discussions considered, a bitmap where each bit
> represents a syscall makes most sense for these filters.
[...]
> Statically analyzing BPF bytecode to see if each syscall is going to
> always land in allow or reject is more of a rabbit hole, especially
> there is no current in-kernel infrastructure to enumerate all the
> possible architecture numbers for a given machine.

You could add that though. Or if you think that that's too much work,
you could just do it for x86 and arm64 and then use a Kconfig
dependency to limit this to those architectures for now.

> So rather than
> doing that, we propose to cache the results after the BPF filters are
> run.

Please don't add extra complexity just to work around a limitation in
existing code if you could instead remove that limitation in existing
code. Otherwise, code will become unnecessarily hard to understand and
inefficient.

You could let struct seccomp=5Ffilter contain three bitmasks - one for
the "native" architecture and up to two for "compat" architectures
(gated on some Kconfig flag).

alpha has 1 architecture numbers, arc has 1 (per build config), arm
has 1, arm64 has 2, c6x has 1 (per build config), csky has 1, h8300
has 1, hexagon has 1, ia64 has 1, m68k has 1, microblaze has 1, mips
has 3 (per build config), nds32 has 1 (per build config), nios2 has 1,
openrisc has 1, parisc has 2, powerpc has 2 (per build config), riscv
has 1 (per build config), s390 has 2, sh has 1 (per build config),
sparc has 2, x86 has 2, xtensa has 1.

> And since there are filters like docker's who will check
> arguments of some syscalls, but not all or none of the syscalls, when
> a filter is loaded we analyze it to find whether each syscall is
> cacheable (does not access syscall argument or instruction pointer) by
> following its control flow graph, and store the result for each filter
> in a bitmap. Changes to architecture number or the filter are expected
> to be rare and simply cause the cache to be cleared. This solution
> shall be fully transparent to userspace.

Caching whether a given syscall number has fixed per-architecture
results across all architectures is a pretty gross hack, please don't.



> Ongoing work is to further support arguments with fast hash table
> lookups. We are investigating the performance of doing so [6], and how
> to best integrate with the existing seccomp infrastructure.




--0__=0ABB0F79DFF8E1EF8f9e8a93df938690918c0ABB0F79DFF8E1EF
Content-type: image/gif; 
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <1__=0ABB0F79DFF8E1EF8f9e8a93df938690918c0AB@>
Content-Transfer-Encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7


--0__=0ABB0F79DFF8E1EF8f9e8a93df938690918c0ABB0F79DFF8E1EF--


--===============2332523105491874235==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2332523105491874235==--


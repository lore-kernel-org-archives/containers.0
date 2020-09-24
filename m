Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10008C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:20:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 99868221EB
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:20:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99868221EB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ACULAB.COM
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 331D6874FE;
	Thu, 24 Sep 2020 14:20:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Lb6wIKvTqO7U; Thu, 24 Sep 2020 14:20:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8A652874F6;
	Thu, 24 Sep 2020 14:20:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 768B8C0859;
	Thu, 24 Sep 2020 14:20:18 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B1C53C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:20:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id AD54A874F6
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:20:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 8ki7RCka-jr1
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:20:15 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from eu-smtp-delivery-151.mimecast.com
 (eu-smtp-delivery-151.mimecast.com [207.82.80.151])
 by hemlock.osuosl.org (Postfix) with ESMTPS id E003A874E0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:20:14 +0000 (UTC)
Received: from AcuMS.aculab.com (156.67.243.126 [156.67.243.126]) (Using
 TLS) by relay.mimecast.com with ESMTP id
 uk-mta-218-ndXhimk2PgyG-5cmTZlPGg-1; Thu, 24 Sep 2020 15:20:10 +0100
X-MC-Unique: ndXhimk2PgyG-5cmTZlPGg-1
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) by
 AcuMS.aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) with Microsoft SMTP
 Server (TLS) id 15.0.1347.2; Thu, 24 Sep 2020 15:20:09 +0100
Received: from AcuMS.Aculab.com ([fe80::43c:695e:880f:8750]) by
 AcuMS.aculab.com ([fe80::43c:695e:880f:8750%12]) with mapi id 15.00.1347.000; 
 Thu, 24 Sep 2020 15:20:09 +0100
From: David Laight <David.Laight@ACULAB.COM>
To: 'YiFei Zhu' <zhuyifei1999@gmail.com>
Subject: RE: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
Thread-Topic: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
Thread-Index: AQHWknD17ZW/yCPmvkCTJZb3HlQhMal3ymow///6ngCAABEUAA==
Date: Thu, 24 Sep 2020 14:20:09 +0000
Message-ID: <665ea57e360a421c958fffa08da77920@AcuMS.aculab.com>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <20bbc8ed4b9f2c83d0f67f37955eb2d789268525.1600951211.git.yifeifz2@illinois.edu>
 <7042ba3307b34ce3b95e5fede823514e@AcuMS.aculab.com>
 <CABqSeASWf_CArdOzASLeRBPZQ-S_vtinhZLteYng4iAof4py+w@mail.gmail.com>
In-Reply-To: <CABqSeASWf_CArdOzASLeRBPZQ-S_vtinhZLteYng4iAof4py+w@mail.gmail.com>
Accept-Language: en-GB, en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.202.205.107]
MIME-Version: 1.0
Authentication-Results: relay.mimecast.com;
 auth=pass smtp.auth=C51A453 smtp.mailfrom=david.laight@aculab.com
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: aculab.com
Content-Language: en-US
Cc: Andrea
 Arcangeli <aarcange@redhat.com>, Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 "bpf@vger.kernel.org" <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

From: YiFei Zhu
> Sent: 24 September 2020 15:17
> 
> On Thu, Sep 24, 2020 at 8:47 AM David Laight <David.Laight@aculab.com> wrote:
> > I doubt the compiler will do what you want.
> > Looking at it, in most cases there are one or two entries.
> > I think only MIPS has three.
> 
> It does ;) GCC 10.2.0:
> 
> $ objdump -d kernel/seccomp.o | less
> [...]
> 0000000000001520 <__seccomp_filter>:
> [...]
>     1587:       41 8b 54 24 04          mov    0x4(%r12),%edx
>     158c:       b9 08 01 00 00          mov    $0x108,%ecx
>     1591:       81 fa 3e 00 00 c0       cmp    $0xc000003e,%edx
>     1597:       75 2e                   jne    15c7 <__seccomp_filter+0xa7>
> [...]
>     15c7:       81 fa 03 00 00 40       cmp    $0x40000003,%edx
>     15cd:       b9 40 01 00 00          mov    $0x140,%ecx
>     15d2:       74 c5                   je     1599 <__seccomp_filter+0x79>
>     15d4:       0f 0b                   ud2
> [...]
> 0000000000001cb0 <seccomp_cache_prepare>:
> [...]
>     1cc4:       41 b9 3e 00 00 c0       mov    $0xc000003e,%r9d
> [...]
>     1dba:       41 b9 03 00 00 40       mov    $0x40000003,%r9d
> [...]
> 0000000000002e30 <proc_pid_seccomp_cache>:
> [...]
>     2e72:       ba 3e 00 00 c0          mov    $0xc000003e,%edx
> [...]
>     2eb5:       ba 03 00 00 40          mov    $0x40000003,%edx
> 
> Granted, I have CC_OPTIMIZE_FOR_PERFORMANCE rather than
> CC_OPTIMIZE_FOR_SIZE, but this patch itself is trying to sacrifice
> some of the memory for speed.

Don't both CC_OPTIMIZE_FOR_PERFORMANCE (-??) and CC_OPTIMIZE_FOR_SIZE (-s)
generate terrible code?

Try with a slghtly older gcc.
I think that entire optimisation (discarding const arrays)
is very recent.

	David
 

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

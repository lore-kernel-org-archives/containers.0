Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A3F0C2D0E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:37:54 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C17CB21D24
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:37:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C17CB21D24
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ACULAB.COM
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4949D86C07;
	Thu, 24 Sep 2020 12:37:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dpB5G1pPF2su; Thu, 24 Sep 2020 12:37:52 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id EF17786BFA;
	Thu, 24 Sep 2020 12:37:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E04A2C0890;
	Thu, 24 Sep 2020 12:37:51 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 287C8C0859
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:37:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1680587494
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:37:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id I2s7kuBe0aNZ
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:37:49 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from eu-smtp-delivery-151.mimecast.com
 (eu-smtp-delivery-151.mimecast.com [207.82.80.151])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 8D3328748D
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:37:48 +0000 (UTC)
Received: from AcuMS.aculab.com (156.67.243.126 [156.67.243.126]) (Using
 TLS) by relay.mimecast.com with ESMTP id
 uk-mta-42-w-QZRmrqOgiSZ0QwhDWzxw-1; Thu, 24 Sep 2020 13:37:43 +0100
X-MC-Unique: w-QZRmrqOgiSZ0QwhDWzxw-1
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) by
 AcuMS.aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) with Microsoft SMTP
 Server (TLS) id 15.0.1347.2; Thu, 24 Sep 2020 13:37:42 +0100
Received: from AcuMS.Aculab.com ([fe80::43c:695e:880f:8750]) by
 AcuMS.aculab.com ([fe80::43c:695e:880f:8750%12]) with mapi id 15.00.1347.000; 
 Thu, 24 Sep 2020 13:37:42 +0100
From: David Laight <David.Laight@ACULAB.COM>
To: 'Jann Horn' <jannh@google.com>, Kees Cook <keescook@chromium.org>
Subject: RE: [PATCH 3/6] seccomp: Implement constant action bitmaps
Thread-Topic: [PATCH 3/6] seccomp: Implement constant action bitmaps
Thread-Index: AQHWkm52E4NdUTUYRkuK8ZQr+ESnnKl3uRCg
Date: Thu, 24 Sep 2020 12:37:42 +0000
Message-ID: <ec31caaea19247f0b9bd9c73ccaa7dbd@AcuMS.aculab.com>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <CAG48ez0d80fOSTyn5QbH33WPz5UkzJJOo+V8of7YMR8pVQxumw@mail.gmail.com>
 <202009240018.A4D8274F@keescook>
 <CAG48ez1MWhrtkbWTNpc1v-WqWYiLM_JrCKvuE6DdH6vBY3MJzQ@mail.gmail.com>
In-Reply-To: <CAG48ez1MWhrtkbWTNpc1v-WqWYiLM_JrCKvuE6DdH6vBY3MJzQ@mail.gmail.com>
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
 Will Drewry <wad@chromium.org>, bpf <bpf@vger.kernel.org>,
 YiFei Zhu <yifeifz2@illinois.edu>, Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus
 Franke <frankeh@us.ibm.com>, Andy
 Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>
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

From: Jann Horn
> Sent: 24 September 2020 13:29
...
> I think our goal here should be that if a syscall is always allowed,
> seccomp should execute the smallest amount of instructions we can get
> away with, and touch the smallest amount of memory possible (and
> preferably that memory should be shared between threads). The bitmap
> fastpath should probably also avoid populate_seccomp_data().

If most syscalls are expected to be allowed then an initial:
	if (global_mask & (1u << (syscall_number & 63))
test can be used to skip any further lookups.

Although ISTR someone suggesting that the global_mask should
be per-cpu because even shared read-only cache lines were
expensive on some architecture.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

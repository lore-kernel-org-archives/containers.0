Return-Path: <SRS0=WNTF=CX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A1CC433E2
	for <containers@archiver.kernel.org>; Mon, 14 Sep 2020 12:08:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5D76721974
	for <containers@archiver.kernel.org>; Mon, 14 Sep 2020 12:08:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D76721974
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id BC9B722D10;
	Mon, 14 Sep 2020 12:08:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gRKv4TEKP8Py; Mon, 14 Sep 2020 12:08:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 73BAC20780;
	Mon, 14 Sep 2020 12:07:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5E04AC088B;
	Mon, 14 Sep 2020 12:07:59 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6F2CAC0890
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:07:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 58CBA8698B
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:07:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id PsK5QX60lvf8
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:07:57 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from huawei.com (lhrrgout.huawei.com [185.176.76.210])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 1AE40867F6
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:07:57 +0000 (UTC)
Received: from lhreml706-chm.china.huawei.com (unknown [172.18.7.108])
 by Forcepoint Email with ESMTP id 18FBB84829DDE50B4086;
 Mon, 14 Sep 2020 13:07:55 +0100 (IST)
Received: from fraeml709-chm.china.huawei.com (10.206.15.37) by
 lhreml706-chm.china.huawei.com (10.201.108.55) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1913.5; Mon, 14 Sep 2020 13:07:54 +0100
Received: from lhreml722-chm.china.huawei.com (10.201.108.73) by
 fraeml709-chm.china.huawei.com (10.206.15.37) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1913.5; Mon, 14 Sep 2020 14:07:54 +0200
Received: from lhreml722-chm.china.huawei.com ([10.201.108.73]) by
 lhreml722-chm.china.huawei.com ([10.201.108.73]) with mapi id 15.01.1913.007; 
 Mon, 14 Sep 2020 13:07:53 +0100
From: Krzysztof Struczynski <krzysztof.struczynski@huawei.com>
To: Mimi Zohar <zohar@linux.ibm.com>, Luke Hinds <lhinds@redhat.com>, "Dr.
 Greg" <greg@enjellic.com>
Subject: RE: [RFC PATCH 00/30] ima: Introduce IMA namespace
Thread-Topic: [RFC PATCH 00/30] ima: Introduce IMA namespace
Thread-Index: AQHWdXPBkpeRDLdh20+fyp1BiEOjYak+A3mAgBfGuwCABhxpgIABN8iAgAG3kgCACVyMsA==
Date: Mon, 14 Sep 2020 12:07:53 +0000
Message-ID: <9ed6fa28510c464a97d4283f6d5b21c5@huawei.com>
References: <20200818152037.11869-1-krzysztof.struczynski@huawei.com>
 <20200818164943.va3um7toztazcfud@wittgenstein>
 <d77a6cd783319702fddd06783cb84fdeb86210a6.camel@linux.ibm.com>
 <20200906171413.GA8305@wind.enjellic.com>
 <CAKrSGQR3Pw=Rad2RgUuCHqr0r2Nc6x2nLoo2cVAkD+_8Vbmd7A@mail.gmail.com>
 <d405bab0d262b32fd16e85444791b6c49d820aa2.camel@linux.ibm.com>
In-Reply-To: <d405bab0d262b32fd16e85444791b6c49d820aa2.camel@linux.ibm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.48.217.147]
MIME-Version: 1.0
X-CFilter-Loop: Reflected
Cc: "mkayaalp@cs.binghamton.edu" <mkayaalp@cs.binghamton.edu>,
 "sunyuqiong1988@gmail.com" <sunyuqiong1988@gmail.com>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>, "jannh@google.com" <jannh@google.com>,
 Roberto Sassu <roberto.sassu@huawei.com>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>,
 "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>,
 Silviu Vlasceanu <Silviu.Vlasceanu@huawei.com>,
 "ebiederm@xmission.com" <ebiederm@xmission.com>,
 "dmitry.kasatkin@gmail.com" <dmitry.kasatkin@gmail.com>,
 "nick.dusek@gmail.com" <nick.dusek@gmail.com>,
 "luto@amacapital.net" <luto@amacapital.net>,
 "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
 "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
 "christian@brauner.io" <christian@brauner.io>
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

> From: Mimi Zohar [mailto:zohar@linux.ibm.com]
> Sent: Tuesday, September 8, 2020 4:03 PM
> > > Candidly, given the politics of security technology being viewed as
> > > 'constraining' user rights, I think that a lot of forthcoming security
> > > technology may end up being out of tree moving forward.
> > >
> >
> > I think it's prudent to look forward and plan diligently, but I would
> > not want perfect to be the enemy of good.
> 
> Agreed.  This isn't an abstract problem, but one that has already come
> up and, hopefully, has been addressed appropriately.
> 
> >
> > I approach this more from a user's perspective. We are using IMA in
> > https://keylime.dev to measure a host and would like to measure
> > within a container too. It's the most common request we hear from our
> > users.
> >
> > Perhaps we all collaborate on a proposal extending Stefans work here:
> > https://kernsec.org/wiki/index.php/IMA_Namespacing_design_considerati
> > ons
> >
> > I have seen around 3-4 patches now get submitted, so work has been
> > done before, and as above, users are present too. We could then have
> > some consensus on how this should look and later patches might have
> > more success at landing.
> >
> > Would anyone be interested in this and have recommendations on how we
> > could approach this?
> 
> When Roberto Sassu and Krzysztof Struczynski contacted me about the
> status of Stefan Berger's patch set, based on Yuqiong Sun's work, I was
> under the impression that they would be rebasing it on the latest
> kernel and going forward from there.   Obviously things changed.  I
> pointed out to them resolving the "IMA namespacing" issue would be the
> first thing that needs to be addressed.  So here we are.
> 

The concept of the IMA namespace as a separate namespace, not attached to
the user or mount namespace, remains the same as in the last set of
Stefan's patches. The creation and configuration mechanism changed,
partially because of the changes in the upstream kernel like extension of
the CLONE_ flags, that facilitated other solutions. The main inspiration
in this regard was the new time namespace.

The implemented mechanism is intended to make the configuration of the IMA
namespace as similar as possible to the upstream IMA implementation and
allows to configure the new IMA namespace before any process enters that
namespace, so the very first actions can be measured/appraised/audited.

In this implementation many design points formulated by Stefan still stand.
The significant difference in the presented design is the threat model.
The actions of the host's root and any other user within the container are
measured/appraised/audited according to the container's policy. However,
every action that affects objects in the root namespace, is detected when
processes from the root namespace access them.

Best regards,
Krzysztof

> Definitely, let's have this discussion.
> 
> Mimi

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

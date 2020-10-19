Return-Path: <SRS0=bTwc=D2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E399C433DF
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 09:30:37 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F1CBA22200
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 09:30:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1CBA22200
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 671CE870B1;
	Mon, 19 Oct 2020 09:30:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9JXtPfIPYrYD; Mon, 19 Oct 2020 09:30:35 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7056286D36;
	Mon, 19 Oct 2020 09:30:35 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 63010C0052;
	Mon, 19 Oct 2020 09:30:35 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C6991C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 09:30:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id AA04186C76
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 09:30:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id UICQVED68AO6
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 09:30:32 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from huawei.com (lhrrgout.huawei.com [185.176.76.210])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 7BE0F854E7
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 09:30:32 +0000 (UTC)
Received: from lhreml717-chm.china.huawei.com (unknown [172.18.7.108])
 by Forcepoint Email with ESMTP id 4877FC634ACB4260299F;
 Mon, 19 Oct 2020 10:30:29 +0100 (IST)
Received: from fraeml703-chm.china.huawei.com (10.206.15.52) by
 lhreml717-chm.china.huawei.com (10.201.108.68) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id
 15.1.1913.5; Mon, 19 Oct 2020 10:30:29 +0100
Received: from lhreml722-chm.china.huawei.com (10.201.108.73) by
 fraeml703-chm.china.huawei.com (10.206.15.52) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1913.5; Mon, 19 Oct 2020 11:30:28 +0200
Received: from lhreml722-chm.china.huawei.com ([10.201.108.73]) by
 lhreml722-chm.china.huawei.com ([10.201.108.73]) with mapi id 15.01.1913.007; 
 Mon, 19 Oct 2020 10:30:27 +0100
From: Krzysztof Struczynski <krzysztof.struczynski@huawei.com>
To: Mimi Zohar <zohar@linux.ibm.com>
Subject: RE: [RFC PATCH 00/30] ima: Introduce IMA namespace
Thread-Topic: [RFC PATCH 00/30] ima: Introduce IMA namespace
Thread-Index: AQHWdXPBkpeRDLdh20+fyp1BiEOjYak+A3mAgBfGuwCABhxpgIABN8iAgAG3kgCACVyMsIA21JGg
Date: Mon, 19 Oct 2020 09:30:27 +0000
Message-ID: <a75a6541991d4f8dbaa30e0af517b829@huawei.com>
References: <20200818152037.11869-1-krzysztof.struczynski@huawei.com>
 <20200818164943.va3um7toztazcfud@wittgenstein>
 <d77a6cd783319702fddd06783cb84fdeb86210a6.camel@linux.ibm.com>
 <20200906171413.GA8305@wind.enjellic.com>
 <CAKrSGQR3Pw=Rad2RgUuCHqr0r2Nc6x2nLoo2cVAkD+_8Vbmd7A@mail.gmail.com>
 <d405bab0d262b32fd16e85444791b6c49d820aa2.camel@linux.ibm.com> 
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.48.222.63]
MIME-Version: 1.0
X-CFilter-Loop: Reflected
Cc: "mkayaalp@cs.binghamton.edu" <mkayaalp@cs.binghamton.edu>,
 "sunyuqiong1988@gmail.com" <sunyuqiong1988@gmail.com>,
 Silviu Vlasceanu <Silviu.Vlasceanu@huawei.com>,
 "nick.dusek@gmail.com" <nick.dusek@gmail.com>, "Dr. Greg" <greg@enjellic.com>,
 "jannh@google.com" <jannh@google.com>, Luke Hinds <lhinds@redhat.com>,
 "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
 "christian@brauner.io" <christian@brauner.io>,
 "dmitry.kasatkin@gmail.com" <dmitry.kasatkin@gmail.com>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 Roberto Sassu <roberto.sassu@huawei.com>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>,
 "luto@amacapital.net" <luto@amacapital.net>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>,
 "ebiederm@xmission.com" <ebiederm@xmission.com>,
 "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
 "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
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

> From: Krzysztof Struczynski
> Sent: Monday, September 14, 2020 2:08 PM
> > When Roberto Sassu and Krzysztof Struczynski contacted me about the
> > status of Stefan Berger's patch set, based on Yuqiong Sun's work, I was
> > under the impression that they would be rebasing it on the latest
> > kernel and going forward from there.   Obviously things changed.  I
> > pointed out to them resolving the "IMA namespacing" issue would be the
> > first thing that needs to be addressed.  So here we are.
> >
> 
> The concept of the IMA namespace as a separate namespace, not attached to
> the user or mount namespace, remains the same as in the last set of
> Stefan's patches. The creation and configuration mechanism changed,
> partially because of the changes in the upstream kernel like extension of
> the CLONE_ flags, that facilitated other solutions. The main inspiration
> in this regard was the new time namespace.
> 
> The implemented mechanism is intended to make the configuration of the
> IMA
> namespace as similar as possible to the upstream IMA implementation and
> allows to configure the new IMA namespace before any process enters that
> namespace, so the very first actions can be measured/appraised/audited.
> 
> In this implementation many design points formulated by Stefan still stand.
> The significant difference in the presented design is the threat model.
> The actions of the host's root and any other user within the container are
> measured/appraised/audited according to the container's policy. However,
> every action that affects objects in the root namespace, is detected when
> processes from the root namespace access them.

Do you think that the above proposal addresses the aforementioned "IMA
namespacing" issue? If it doesn't, would you please clarify what are the
main, outstanding problems?
 
> > Definitely, let's have this discussion.

Shall we continue the discussion here, or in addition use a format similar
to the Stefan's "drawing board":
https://kernsec.org/wiki/index.php/IMA_Namespacing_design_considerations

Best regards,
Krzysztof Struczynski
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

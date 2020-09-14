Return-Path: <SRS0=WNTF=CX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CECEFC433E2
	for <containers@archiver.kernel.org>; Mon, 14 Sep 2020 12:06:18 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BFE4A21974
	for <containers@archiver.kernel.org>; Mon, 14 Sep 2020 12:06:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFE4A21974
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 2ABAB20011;
	Mon, 14 Sep 2020 12:06:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id f3AK4IdgVSZZ; Mon, 14 Sep 2020 12:06:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 8514B20014;
	Mon, 14 Sep 2020 12:06:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 74F95C088B;
	Mon, 14 Sep 2020 12:06:14 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0FD5EC0859
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:06:13 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id F247085A7D
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:06:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id LkQ0ZTRabij5
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:06:11 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from huawei.com (lhrrgout.huawei.com [185.176.76.210])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id B152D859D9
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 12:06:11 +0000 (UTC)
Received: from lhreml715-chm.china.huawei.com (unknown [172.18.7.107])
 by Forcepoint Email with ESMTP id 9D53517D0D1F819FF294;
 Mon, 14 Sep 2020 13:06:08 +0100 (IST)
Received: from fraeml708-chm.china.huawei.com (10.206.15.36) by
 lhreml715-chm.china.huawei.com (10.201.108.66) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1913.5; Mon, 14 Sep 2020 13:05:49 +0100
Received: from lhreml722-chm.china.huawei.com (10.201.108.73) by
 fraeml708-chm.china.huawei.com (10.206.15.36) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1913.5; Mon, 14 Sep 2020 14:05:48 +0200
Received: from lhreml722-chm.china.huawei.com ([10.201.108.73]) by
 lhreml722-chm.china.huawei.com ([10.201.108.73]) with mapi id 15.01.1913.007; 
 Mon, 14 Sep 2020 13:05:48 +0100
From: Krzysztof Struczynski <krzysztof.struczynski@huawei.com>
To: Mimi Zohar <zohar@linux.ibm.com>, James Bottomley
 <James.Bottomley@HansenPartnership.com>, "linux-integrity@vger.kernel.org"
 <linux-integrity@vger.kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>
Subject: RE: [RFC PATCH 00/30] ima: Introduce IMA namespace
Thread-Topic: [RFC PATCH 00/30] ima: Introduce IMA namespace
Thread-Index: AQHWdXPBkpeRDLdh20+fyp1BiEOjYak9+wmAgASx5lCAEwwJgIASd/FA
Date: Mon, 14 Sep 2020 12:05:48 +0000
Message-ID: <2a9fa5a443a84f77992959773369beb2@huawei.com>
References: <N> <20200818152037.11869-1-krzysztof.struczynski@huawei.com>
 <1597767571.3898.15.camel@HansenPartnership.com>
 <401a2f36149f450291d1742aeb6c2260@huawei.com>
 <5331e60b5a1afb55e2bc778db1b95998466b687d.camel@linux.ibm.com>
In-Reply-To: <5331e60b5a1afb55e2bc778db1b95998466b687d.camel@linux.ibm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.48.217.147]
MIME-Version: 1.0
X-CFilter-Loop: Reflected
Cc: "mkayaalp@cs.binghamton.edu" <mkayaalp@cs.binghamton.edu>,
 "sunyuqiong1988@gmail.com" <sunyuqiong1988@gmail.com>,
 Roberto Sassu <roberto.sassu@huawei.com>,
 Silviu Vlasceanu <Silviu.Vlasceanu@huawei.com>,
 "dmitry.kasatkin@gmail.com" <dmitry.kasatkin@gmail.com>,
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
> Sent: Wednesday, September 2, 2020 8:53 PM
> > > So I think this can work in the use case where the system owner is
> > > responsible for doing the logging and attestation and the tenants just
> > > trust the owner without requiring an attestation.  However, in a multi-
> > > tenant system you need a way for the attestation to be per-container
> > > (because the combined list of who executed what would be a security
> > > leak between tenants).  Since we can't virtualise the PCRs without
> > > introducing a vtpm this is going to require a vtpm infrastructure like
> > > that used for virtual machines and then we can do IMA logging per
> > > container.
> >
> > I agree and wonder if we should decouple the attestation trust model,
> > which depends on the specific use case (e.g. multi/single tenant,
> > public/private cloud), from the IMA logic of linking the measurements to
> > the container. Indeed, attestation from within the container might require
> > anchoring to a vTPM/vPCR and the current measurement tagging mechanism
> can
> > support several ways of anchoring them to a (virtual) root of trust.
> >
> > > I don't think the above has to be in your first patch set, we just have
> > > to have an idea of how it could be done to show that nothing in this
> > > patch set precludes a follow on from doing this.
> >
> > Given that virtualizing trust anchors seems like a separate problem in
> > which industry consensus is not easy to reach for all use cases, an
> > anchoring mechanism should probably be a separate IMA feature.
> 
> Other trust anchors for "trusted keys" has been discussed, but I wasn't
> aware of any discussion about other trust anchors for the IMA
> measurement list.  The IMA measurement list is very much tied to a TPM.
> 

Agreed. I wouldn't consider anything else than the TPM in the IMA
measurement list context. The anchoring mechanism mentioned above
pertained to the possible extensions of the TPM anchor in the
containerized environment, like the vTPM.

> Including container measurements in the host measurement list, will
> unnecessarily cause the host measurement list to grow.  The decision of
> what should and shouldn't be included in the host measurement list
> shouldn't be defined by the container.
> 

The container has no impact on the measurement list entries other than the
ones related to the processes running within the container. This in turn,
the same as for the original IMA, is defined by the (container's) policy,
loaded on the container's creation.

Best regards,
Krzysztof

> Mimi
> 
> 

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

Return-Path: <SRS0=WWmn=CL=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5E25C433E7
	for <containers@archiver.kernel.org>; Wed,  2 Sep 2020 18:53:47 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8E27C20773
	for <containers@archiver.kernel.org>; Wed,  2 Sep 2020 18:53:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b="nO/4CuY3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E27C20773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 45C3486AB1;
	Wed,  2 Sep 2020 18:53:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Vq6ASxsT3RV7; Wed,  2 Sep 2020 18:53:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 889F386934;
	Wed,  2 Sep 2020 18:53:46 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 77B84C07FF;
	Wed,  2 Sep 2020 18:53:46 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D07E2C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 18:53:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 9F0D2291FC
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 18:53:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id abU9F-u1v2br
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 18:53:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com
 [148.163.158.5])
 by silver.osuosl.org (Postfix) with ESMTPS id 5933A273E3
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 18:53:42 +0000 (UTC)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
 by mx0b-001b2d01.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id
 082IWCL2121893; Wed, 2 Sep 2020 14:53:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com;
 h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=D8h2MQ2BFxQFN1LZrIEeY+TR98t0M6uXFJff0XnwfCo=;
 b=nO/4CuY3MHL193LgWq2pWOz32bp8Wps5HPZ1D15dg+xwybGLqQGGr+ewLMi6AJ7TE+U4
 V9chqW9Lh2zqOMH5EA3kTBjhqnUHroMrkPvUJSC1bsey12HRVPiJKXPMN8chFF+HeSBG
 DgtR7K6nZQMqwV6e0/AwFuWyk1Ej/Cp11y7Ul/jN6VceIOyBVP4PEeqpRW4Yq+r12yxW
 JLS2CsBgPFt4VU1v2kv0TZejCZXUngVgA/PJ/0q4+H0R3ohiDY6zSBylP9oi0+bdBXYe
 OqSYZ2kKyFMsutfd+hfmCAgo7NQXcNyKrgjMtIna8lCrpWJo/PtdMUVfL3j4LoWOVBHT IQ== 
Received: from pps.reinject (localhost [127.0.0.1])
 by mx0b-001b2d01.pphosted.com with ESMTP id 33agp70p4s-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Wed, 02 Sep 2020 14:53:25 -0400
Received: from m0098420.ppops.net (m0098420.ppops.net [127.0.0.1])
 by pps.reinject (8.16.0.36/8.16.0.36) with SMTP id 082IWHbV122282;
 Wed, 2 Sep 2020 14:53:25 -0400
Received: from ppma04fra.de.ibm.com (6a.4a.5195.ip4.static.sl-reverse.com
 [149.81.74.106])
 by mx0b-001b2d01.pphosted.com with ESMTP id 33agp70p42-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Wed, 02 Sep 2020 14:53:25 -0400
Received: from pps.filterd (ppma04fra.de.ibm.com [127.0.0.1])
 by ppma04fra.de.ibm.com (8.16.0.42/8.16.0.42) with SMTP id 082Ir06n023126;
 Wed, 2 Sep 2020 18:53:23 GMT
Received: from b06cxnps3074.portsmouth.uk.ibm.com
 (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
 by ppma04fra.de.ibm.com with ESMTP id 339ap7sd77-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Wed, 02 Sep 2020 18:53:23 +0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com
 [9.149.105.61])
 by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id
 082IrLMC25166286
 (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Wed, 2 Sep 2020 18:53:21 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
 by IMSVA (Postfix) with ESMTP id 53F3211C04C;
 Wed,  2 Sep 2020 18:53:21 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
 by IMSVA (Postfix) with ESMTP id 5A81211C04A;
 Wed,  2 Sep 2020 18:53:18 +0000 (GMT)
Received: from li-f45666cc-3089-11b2-a85c-c57d1a57929f.ibm.com (unknown
 [9.160.121.98])
 by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
 Wed,  2 Sep 2020 18:53:18 +0000 (GMT)
Message-ID: <5331e60b5a1afb55e2bc778db1b95998466b687d.camel@linux.ibm.com>
Subject: Re: [RFC PATCH 00/30] ima: Introduce IMA namespace
From: Mimi Zohar <zohar@linux.ibm.com>
To: Krzysztof Struczynski <krzysztof.struczynski@huawei.com>, James
 Bottomley <James.Bottomley@HansenPartnership.com>,
 "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>
Date: Wed, 02 Sep 2020 14:53:17 -0400
In-Reply-To: <401a2f36149f450291d1742aeb6c2260@huawei.com>
References: <N> <20200818152037.11869-1-krzysztof.struczynski@huawei.com>
 <1597767571.3898.15.camel@HansenPartnership.com>
 <401a2f36149f450291d1742aeb6c2260@huawei.com>
X-Mailer: Evolution 3.28.5 (3.28.5-12.el8) 
Mime-Version: 1.0
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.235, 18.0.687
 definitions=2020-09-02_12:2020-09-02,
 2020-09-02 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0
 lowpriorityscore=0 spamscore=0 malwarescore=0 adultscore=0
 priorityscore=1501 bulkscore=0 phishscore=0 impostorscore=0 mlxscore=0
 mlxlogscore=999 clxscore=1011 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-2006250000 definitions=main-2009020170
Cc: "mkayaalp@cs.binghamton.edu" <mkayaalp@cs.binghamton.edu>,
 "sunyuqiong1988@gmail.com" <sunyuqiong1988@gmail.com>,
 Roberto Sassu <roberto.sassu@huawei.com>,
 Silviu Vlasceanu <Silviu.Vlasceanu@huawei.com>,
 "dmitry.kasatkin@gmail.com" <dmitry.kasatkin@gmail.com>
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

On Fri, 2020-08-21 at 15:13 +0000, Krzysztof Struczynski wrote:
> > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > On Tue, 2020-08-18 at 17:20 +0200, krzysztof.struczynski@huawei.com
> > wrote:
> > > The measurement list remains global, with the assumption that there
> > > is only one TPM in the system. Each IMA namespace has a unique ID,
> > > that allows to track measurements per IMA namespace. Processes in one
> > > namespace, have access only to the measurements from that namespace.
> > > The exception is made for the initial IMA namespace, whose processes
> > > have access to all entries.
> > 
> > So I think this can work in the use case where the system owner is
> > responsible for doing the logging and attestation and the tenants just
> > trust the owner without requiring an attestation.  However, in a multi-
> > tenant system you need a way for the attestation to be per-container
> > (because the combined list of who executed what would be a security
> > leak between tenants).  Since we can't virtualise the PCRs without
> > introducing a vtpm this is going to require a vtpm infrastructure like
> > that used for virtual machines and then we can do IMA logging per
> > container.
> 
> I agree and wonder if we should decouple the attestation trust model,
> which depends on the specific use case (e.g. multi/single tenant,
> public/private cloud), from the IMA logic of linking the measurements to
> the container. Indeed, attestation from within the container might require
> anchoring to a vTPM/vPCR and the current measurement tagging mechanism can
> support several ways of anchoring them to a (virtual) root of trust.
> 
> > I don't think the above has to be in your first patch set, we just have
> > to have an idea of how it could be done to show that nothing in this
> > patch set precludes a follow on from doing this.
> 
> Given that virtualizing trust anchors seems like a separate problem in
> which industry consensus is not easy to reach for all use cases, an
> anchoring mechanism should probably be a separate IMA feature.

Other trust anchors for "trusted keys" has been discussed, but I wasn't
aware of any discussion about other trust anchors for the IMA
measurement list.  The IMA measurement list is very much tied to a TPM.

Including container measurements in the host measurement list, will
unnecessarily cause the host measurement list to grow.  The decision of
what should and shouldn't be included in the host measurement list
shouldn't be defined by the container.

Mimi



_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

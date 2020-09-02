Return-Path: <SRS0=WWmn=CL=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 587F1C433E7
	for <containers@archiver.kernel.org>; Wed,  2 Sep 2020 19:55:32 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EDD31206EB
	for <containers@archiver.kernel.org>; Wed,  2 Sep 2020 19:55:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b="smAOh1vp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDD31206EB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A7F3586AF4;
	Wed,  2 Sep 2020 19:55:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3qvjfKbT0hQU; Wed,  2 Sep 2020 19:55:31 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1AC6D86ADF;
	Wed,  2 Sep 2020 19:55:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F04BBC0052;
	Wed,  2 Sep 2020 19:55:30 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E4C3FC0051
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 19:55:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id D57E9203E2
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 19:55:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Rkd6aXEB3K2h
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 19:55:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com
 [148.163.156.1])
 by silver.osuosl.org (Postfix) with ESMTPS id 81A6C203A6
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Sep 2020 19:55:28 +0000 (UTC)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
 by mx0a-001b2d01.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id
 082JcAus088084; Wed, 2 Sep 2020 15:55:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com;
 h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=0Ea0UcfMe7PHsrVD0pFOiv8VCaP3XQXJw+mmhy0kNNI=;
 b=smAOh1vp77+krhOR+OeLIDMQOZBPjysMP4piRZ0DlNug5kBuKNY29qDhcQlmpw2APScC
 MltcABAA2oB9SdFDxc1n+bTtAVK6owkaodfN+HiHrGZrz7Rz4I/wCWaMULSgIRX8Nx5B
 2Xp2T+g+om7rgyTJlASCHtCYLxbc908pnFZCyWL7GvuYRiMGO6kBzZbPlfQvP1/fGRbd
 gycVy7KtNJ4Ck94fYmyxBnO+Z6vffeIHFk45mCj3fp4su0x3rH0RiQP4dTmmgGlM91b9
 Fu0kqEO4mjRYI5mEXMrJuuNebPUqCFWNGsHci1fz65eKbCVS3waZxiFvSeTMUWs5M8fA Hw== 
Received: from pps.reinject (localhost [127.0.0.1])
 by mx0a-001b2d01.pphosted.com with ESMTP id 33afsubr8c-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Wed, 02 Sep 2020 15:55:09 -0400
Received: from m0098396.ppops.net (m0098396.ppops.net [127.0.0.1])
 by pps.reinject (8.16.0.36/8.16.0.36) with SMTP id 082JcBUT088215;
 Wed, 2 Sep 2020 15:55:08 -0400
Received: from ppma03ams.nl.ibm.com (62.31.33a9.ip4.static.sl-reverse.com
 [169.51.49.98])
 by mx0a-001b2d01.pphosted.com with ESMTP id 33afsubr7j-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Wed, 02 Sep 2020 15:55:08 -0400
Received: from pps.filterd (ppma03ams.nl.ibm.com [127.0.0.1])
 by ppma03ams.nl.ibm.com (8.16.0.42/8.16.0.42) with SMTP id 082JpFm6029703;
 Wed, 2 Sep 2020 19:55:05 GMT
Received: from b06avi18878370.portsmouth.uk.ibm.com
 (b06avi18878370.portsmouth.uk.ibm.com [9.149.26.194])
 by ppma03ams.nl.ibm.com with ESMTP id 337en8d261-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Wed, 02 Sep 2020 19:55:05 +0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com
 (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
 by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP
 id 082Jt36962325230
 (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Wed, 2 Sep 2020 19:55:03 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
 by IMSVA (Postfix) with ESMTP id 81FA4A405B;
 Wed,  2 Sep 2020 19:55:03 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
 by IMSVA (Postfix) with ESMTP id 8C8FAA405F;
 Wed,  2 Sep 2020 19:54:59 +0000 (GMT)
Received: from li-f45666cc-3089-11b2-a85c-c57d1a57929f.ibm.com (unknown
 [9.160.121.98])
 by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
 Wed,  2 Sep 2020 19:54:59 +0000 (GMT)
Message-ID: <d77a6cd783319702fddd06783cb84fdeb86210a6.camel@linux.ibm.com>
Subject: Re: [RFC PATCH 00/30] ima: Introduce IMA namespace
From: Mimi Zohar <zohar@linux.ibm.com>
To: Christian Brauner <christian.brauner@ubuntu.com>,
 krzysztof.struczynski@huawei.com
Date: Wed, 02 Sep 2020 15:54:58 -0400
In-Reply-To: <20200818164943.va3um7toztazcfud@wittgenstein>
References: <N> <20200818152037.11869-1-krzysztof.struczynski@huawei.com>
 <20200818164943.va3um7toztazcfud@wittgenstein>
X-Mailer: Evolution 3.28.5 (3.28.5-12.el8) 
Mime-Version: 1.0
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.235, 18.0.687
 definitions=2020-09-02_14:2020-09-02,
 2020-09-02 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0 spamscore=0
 adultscore=0 lowpriorityscore=0 clxscore=1011 phishscore=0 malwarescore=0
 mlxlogscore=999 priorityscore=1501 impostorscore=0 mlxscore=0 bulkscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2006250000
 definitions=main-2009020178
Cc: mkayaalp@cs.binghamton.edu, sunyuqiong1988@gmail.com,
 containers@lists.linux-foundation.org, jannh@google.com,
 roberto.sassu@huawei.com, linux-kernel@vger.kernel.org,
 viro@zeniv.linux.org.uk, linux-security-module@vger.kernel.org,
 silviu.vlasceanu@huawei.com, ebiederm@xmission.com, dmitry.kasatkin@gmail.com,
 linux-integrity@vger.kernel.org, luto@amacapital.net,
 torvalds@linux-foundation.org
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

On Tue, 2020-08-18 at 18:49 +0200, Christian Brauner wrote:
> On Tue, Aug 18, 2020 at 05:20:07PM +0200, krzysztof.struczynski@huawei.com wrote:
> > From: Krzysztof Struczynski <krzysztof.struczynski@huawei.com>
> > 
> > IMA has not been designed to work with containers. It handles every
> > process in the same way, and it cannot distinguish if a process belongs to
> > a container or not.
> > 
> > Containers use namespaces to make it appear to the processes in the
> > containers that they have their own isolated instance of the global
> > resource. For IMA as well, it is desirable to let processes in the
> 
> IMA is brought up on a regular basis with "we want to have this" for
> years and then non-one seems to really care enough.

There is a lot of interest in IMA namespacing, but the question always
comes back to how to enable it.  Refer to  
https://kernsec.org/wiki/index.php/IMA_Namespacing_design_considerations
 for Stefan's analysis.

I understand "containers" is not a kernel construct, but from my very
limited perspective, IMA namespacing only makes sense in the context of
a "container".  The container owner may want to know which files have
been accessed/executed (measurements, remote attestation) and/or
constrain which files may be accessed/executed based on signatures
(appraisal).

> 
> I'm highly skeptical of the value of ~2500 lines of code even if it
> includes a bunch of namespace boilerplate. It's yet another namespace,
> and yet another security framework.
> Why does IMA need to be a separate namespace? Keyrings are tied to user
> namespaces why can't IMA be? 

In the context of a container, the measurement list and IMA/EVM
keyrings need to be setup before the first file is measured, signature
verified, or file hash included in the audit log.

> I believe Eric has even pointed that out
> before.
> 
> Eric, thoughts?

Any help with the above scenario would very be much appreciated.

Mimi

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers

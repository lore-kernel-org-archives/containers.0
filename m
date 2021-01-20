Return-Path: <SRS0=gu3k=GX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.2 required=3.0 tests=BAYES_20,DATE_IN_PAST_06_12,
	DKIM_INVALID,DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_ABUSE_SURBL,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AA0BC433DB
	for <containers@archiver.kernel.org>; Wed, 20 Jan 2021 23:01:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C0DCD23441
	for <containers@archiver.kernel.org>; Wed, 20 Jan 2021 23:01:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0DCD23441
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=appendleadedm.info
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 50983870BD;
	Wed, 20 Jan 2021 23:01:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id H3cAKd9ZjjFV; Wed, 20 Jan 2021 23:01:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id EA06786FE5;
	Wed, 20 Jan 2021 23:01:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D012AC08A1;
	Wed, 20 Jan 2021 23:01:17 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 17A2FC013A
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 23:01:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id F04068677B
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 23:01:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iOVfgqYwwdjj
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 23:01:14 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from app6.appendleadedm.info (ip227.ip-51-83-191.eu [51.83.191.227])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 014C78675D
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 23:01:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; s=default;
 d=appendleadedm.info; 
 h=Message-ID:Date:Subject:From:Reply-To:To:MIME-Version:Content-Type:List-Unsubscribe:List-Id;
 i=contact@appendleadedm.info; bh=cm1T+vVDyvQD4vf+q5Iq1JmY20A=;
 b=CsgOzs+DItzVXrn7e5f6Ld3zbqSTsmmplLnKq/dz7BrXyNlp9rruiZ3GWlMXt4ungd5G3qsrU0d2
 36NMzbYpUHMZhPx4NwgrqPuri6n+tZzOh4u4AZzALxExpWA6O4pCCo0jkQwUNy64BjhHTixZZ31T
 A9K6p6Hsc2LsqY8pBDPiqR4PfHZzDZyV0yzX5BpNoEd8/ns1WnOfflipKPZwNH3vk7ppOSrIASy/
 jRzQZc2wq7g/CqVcCJk46ScLhA6UOBgtL2UgXozDilyJzekQTCKV+qAFZ4yOX8gWwdP4ubRi5/xx
 AYrMcF9iqtR3lb+3vY5e6XCndjM2otwttfV7tw==
DomainKey-Signature: a=rsa-sha1; c=nofws; q=dns; s=default;
 d=appendleadedm.info; 
 b=SYK5J37YwO8cfPRW0v2Q/heDyxyDUYH0qrapIWe1iTnXnZb7pGCG21gfH32ajpR+coQdefsYJ8kN
 x7zOnwAxb5Z8xN/Hfs6MgtNsEiLuhJ7WflgmgOxyukfKUyHASsym163xki21/fOjdaiCUBId44hE
 /mKwYxOrTAr9b5rjZ450eWRCBdEyRF0Ui+AezSNZZScpTUCMGt7NSS3ehPEeAuywXonWe7SCBJQh
 w98CW7G0zc1BnHHC6MqnUruSoXUIYX+Yn9sGvPf6Ta44yzsZrz+USW0qG3SdhNbVOIeZjAfU4Er9
 y9bX1AmPLQceiOwJN07bVh+mJ1us5KBEnxwRFQ==;
Received: from appendleadedm.info (127.0.0.1) by app1.appendleadedm.info id
 h12r3li19tkc for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 11:22:40 +0000 (envelope-from
 <contact-containers=lists.linux-foundation.org@appendleadedm.info>)
Message-ID: <aa813cef8a01df30e2e075bb9445455d@appendleadedm.info>
Date: Wed, 20 Jan 2021 11:22:40 +0000
Subject: RE: did you see this email
From: Susan Taylor <contact@appendleadedm.info>
To: "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>
MIME-Version: 1.0
X-Sender: contact@appendleadedm.info
X-Report-Abuse: Please report abuse for this campaign here:
 http://appendleadedm.info/emm/index.php/campaigns/kp1330sn4e3ff/report-abuse/vx3511pp1af40/qy5309njxj9f3
X-Receiver: containers@lists.linux-foundation.org
X-Ooqx-Tracking-Did: 0
X-Ooqx-Subscriber-Uid: qy5309njxj9f3
X-Ooqx-Mailer: SwiftMailer - 5.4.x
X-Ooqx-EBS: http://appendleadedm.info/emm/index.php/lists/block-address
X-Ooqx-Delivery-Sid: 1
X-Ooqx-Customer-Uid: fv107j3jh8cf0
X-Ooqx-Customer-Gid: 0
X-Ooqx-Campaign-Uid: kp1330sn4e3ff
Precedence: bulk
List-Unsubscribe-Post: List-Unsubscribe=One-Click
Feedback-ID: kp1330sn4e3ff:qy5309njxj9f3:vx3511pp1af40:fv107j3jh8cf0
X-Content-Filtered-By: Mailman/MimeDel 2.1.15
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Reply-To: Susan Taylor <susan.taylordata@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

QXJlIHlvdSBsb29raW5nIGZvciBhbnkgb2YgdGhlIGZvbGxvd2luZyBFbWFpbCBhbmQgcGhvbmUg
bGlzdCBnYXRoZXJlZApmcm9tIExpbmtlZEluLCBFdmVudHMgYW5kIG1hcmtldCByZXNlYXJjaD8g
UGxlYXNlIHNwZWNpZnkgeW91ciB0YXJnZXQKYXVkaWVuY2Ugc28gdGhhdCB3ZSBjYW4gc2hhcmUg
YSBzYW1wbGUgd2l0aCB5b3UuCiogQXJjaGl0ZWN0cyBhbmQgaW50ZXJpb3IgZGVzaWduZXJzIGVt
YWlsIGxpc3QKKiBDRU8sIG93bmVyLCBQcmVzaWRlbnQgYW5kIENPTyBjb250YWN0cwoqIENGTywg
Q29udHJvbGxlciwgVlAvRGlyZWN0b3IvTWFuYWdlciBvZiBGaW5hbmNlLCBBY2NvdW50cyBQYXlh
YmxlLApBY2NvdW50cyBSZWNlaXZhYmxlLCBBdWRpdCBDb250YWN0cwoqIENoaWVmIEh1bWFuIFJl
c291cmNlcyBPZmZpY2VyLCBWUC9EaXJlY3Rvci9NYW5hZ2VyIG9mIEhSLCBFbXBsb3llZQpCZW5l
Zml0cywgRW1wbG95ZWUgQ29tbXVuaWNhdGlvbnMsIEVtcGxveWVlIENvbXBlbnNhdGlvbiwgRW1w
bG95ZWUKRW5nYWdlbWVudCwgRW1wbG95ZWUgRXhwZXJpZW5jZSBhbmQgRW1wbG95ZWUgUmVsYXRp
b25zLCBUYWxlbnQKQWNxdWlzaXRpb24sIFRhbGVudCBEZXZlbG9wbWVudCwgVGFsZW50IE1hbmFn
ZW1lbnQsIFJlY3J1aXRpbmcKQ29udGFjdHMKKiBDSU8sQ1RPLCBDSVNPLCBWUC9EaXJlY3Rvci9N
YW5hZ2VyIG9mIElULCBJVCBDb21wbGlhbmNlLCBJVCBSaXNrLApCSSwgQ2xvdWQsIERhdGFiYXNl
IGFuZCBJVCBTZWN1cml0eSBDb250YWN0cwoqIENNTywgVlAvRGlyZWN0b3IvTWFuYWdlciBvZiBN
YXJrZXRpbmcsIHNvY2lhbCBtZWRpYSwgU2FsZXMsIGRlbWFuZApnZW5lcmF0aW9uLCBMZWFkIGdl
bmVyYXRpb24sIGluc2lkZSBzYWxlcywgTWFya2V0aW5nIENvbW11bmljYXRpb25zCmNvbnRhY3Rz
IGV0Yy4KKiBDb21wbGlhbmNlIGFuZCBSaXNrIE1hbmFnZW1lbnQgQ29udGFjdHMKKiBDUEEgYW5k
IEJvb2trZWVwZXJzIGVtYWlsIGxpc3QKKiBEYXRhIEFuYWx5dGljcyBhbmQgRGF0YWJhc2UgQWRt
aW5pc3RyYXRvcnMgY29udGFjdHMKKiBEaXNhc3RlciBSZWNvdmVyeSBDb250YWN0cwoqIEUtY29t
bWVyY2Ugb3Igb25saW5lIHJldGFpbGVycyBlbWFpbCBsaXN0CiogRWR1Y2F0aW9uIGluZHVzdHJ5
IGV4ZWN1dGl2ZXMgZW1haWwgbGlzdCAtIFByaW5jaXBhbHMsIERlYW4sCkFkbWlucyBhbmQgdGVh
Y2hlcnMgZnJvbSBTY2hvb2xzLCBDb2xsZWdlcyBhbmQgVW5pdmVyc2l0aWVzCiogRW5naW5lZXJz
IGVtYWlsIGxpc3QKKiBFdmVudCBhbmQgbWVldGluZyBwbGFubmVycyBlbWFpbCBsaXN0CiogRmFj
aWxpdGllcyBhbmQgb2ZmaWNlIG1hbmFnZXIgQ29udGFjdHMKKiBHZW5lcmFsIGFuZCBjb3Jwb3Jh
dGUgY291bnNlbCBhcyB3ZWxsIGxlZ2FsIHByb2Zlc3Npb25hbHMgbGlzdAoqIEdvdmVybm1lbnQg
Y29udHJhY3RvcnMgZW1haWwgbGlzdAoqIEhlYWx0aCAmIFNhZmV0eSBDb250YWN0cwoqIEhpZ2gg
bmV0IHdvcnRoIGluZGl2aWR1YWxzL2ludmVzdG9ycyBlbWFpbCBsaXN0CiogSG9zcGl0YWxzLCBj
bGluaWNzLCBwcml2YXRlIHByYWN0aWNlcywgUGhhcm1hY2V1dGljYWwgYW5kCmJpb3RlY2hub2xv
Z3kgY29tcGFueeKAmXMgdG9wIGRlY2lzaW9uIG1ha2VycyBlbWFpbCBsaXN0CiogSHVtYW4gQ2Fw
aXRhbCBNYW5hZ2VtZW50IENvbnRhY3RzCiogSW5kaXZpZHVhbCBpbnN1cmFuY2UgYWdlbnRzIGxp
c3QKKiBJU1YvVkFScyBsaXN0CiogTGVhcm5pbmcgJiBEZXZlbG9wbWVudCBDb250YWN0cwoqIExv
Z2lzdGljcywgc2hpcHBpbmcgYW5kIHN1cHBseSBjaGFpbiBtYW5hZ2VycyBlbWFpbCBsaXN0Ciog
TWFudWZhY3R1cmluZyBJbmR1c3RyeSBleGVjdXRpdmVzIGxpc3QKKiBOZXR3b3JrIG1hbmFnZXIs
IFN1cnZlaWxsYW5jZSwgU3lzdGVtIEFkbWluaXN0cmF0b3IsIFRlY2huaWNhbApTdXBwb3J0IENv
bnRhY3RzCiogTmV3ICYgVXNlZCBDYXIgRGVhbGVycyBlbWFpbCBsaXN0CiogT2lsLCBHYXMgYW5k
IHV0aWxpdHkgaW5kdXN0cnkgY29udGFjdHMKKiBQaHlzaWNpYW5zLCBEb2N0b3JzLCBOdXJzZXMs
IERlbnRpc3RzLCBUaGVyYXBpc3RzIGVtYWlsIGxpc3QKKiBQbGFudCBNYW5hZ2VyIENvbnRhY3Rz
CiogUHJvZHVjdCBhbmQgcHJvamVjdCBtYW5hZ2VtZW50IGxpc3QKKiBQdXJjaGFzaW5nIGFuZCBQ
cm9jdXJlbWVudCBDb250YWN0cwoqIFNwZWNpZmljIEV2ZW50IGF0dGVuZGVlcyBsaXN0CiogVGVs
ZWNvbSBtYW5hZ2VycywgVk9JUCBtYW5hZ2VycywgQ2xvdWQgYXJjaGl0ZWN0LCBDbG91ZCBtYW5h
Z2VycywKU3RvcmFnZSBtYW5hZ2VycyBlbWFpbCBsaXN0CiogVlAvRGlyZWN0b3IvTWFuYWdlciBv
ZiBDdXN0b21lciBTZXJ2aWNlIGFuZCBDdXN0b21lciBTdWNjZXNzClN1c2FuIFRheWxvcgpEYXRh
YmFzZSBDb25zdWx0YW50CjQyTWlsIEIyQiBhbmQgMjEwTWlsIEIyQyBPcHQtaW4gRW1haWwgYW5k
IHBob25lIGxpc3Qgd2l0aCBvdGhlciBkYXRhCmZpZWxkcwpVbnN1YnNjcmliZQpodHRwOi8vYXBw
ZW5kbGVhZGVkbS5pbmZvL2VtbS9pbmRleC5waHAvbGlzdHMvdngzNTExcHAxYWY0MC91bnN1YnNj
cmliZS9xeTUzMDluanhqOWYzL2twMTMzMHNuNGUzZmYKX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVy
c0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlv
bi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

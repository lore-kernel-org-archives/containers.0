Return-Path: <SRS0=L+uc=JN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B30CFC433ED
	for <containers@archiver.kernel.org>; Fri, 16 Apr 2021 11:33:20 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5793E611AC
	for <containers@archiver.kernel.org>; Fri, 16 Apr 2021 11:33:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5793E611AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 121E160DDC;
	Fri, 16 Apr 2021 11:33:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a8mhE8wIj--P; Fri, 16 Apr 2021 11:33:19 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id D46D060DD4;
	Fri, 16 Apr 2021 11:33:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9D56EC000C;
	Fri, 16 Apr 2021 11:33:18 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 572B8C000A
 for <containers@lists.linux-foundation.org>;
 Fri, 16 Apr 2021 11:33:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 3967D60DD7
 for <containers@lists.linux-foundation.org>;
 Fri, 16 Apr 2021 11:33:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7lfx4zOW_5Hd
 for <containers@lists.linux-foundation.org>;
 Fri, 16 Apr 2021 11:33:16 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from vmicros1.altlinux.org (vmicros1.altlinux.org [194.107.17.57])
 by smtp3.osuosl.org (Postfix) with ESMTP id AD35F60DD4
 for <containers@lists.linux-foundation.org>;
 Fri, 16 Apr 2021 11:33:15 +0000 (UTC)
Received: from imap.altlinux.org (imap.altlinux.org [194.107.17.38])
 by vmicros1.altlinux.org (Postfix) with ESMTP id 4CD1C72C8B5;
 Fri, 16 Apr 2021 14:33:14 +0300 (MSK)
Received: from example.org (ip-94-113-225-162.net.upcbroadband.cz
 [94.113.225.162])
 by imap.altlinux.org (Postfix) with ESMTPSA id F1DC84A47A1;
 Fri, 16 Apr 2021 14:33:12 +0300 (MSK)
Date: Fri, 16 Apr 2021 13:33:10 +0200
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: 08ed4efad6: stress-ng.sigsegv.ops_per_sec -41.9% regression
Message-ID: <20210416113310.vbxrzorycqdxwiyc@example.org>
References: <7abe5ab608c61fc2363ba458bea21cf9a4a64588.1617814298.git.gladkov.alexey@gmail.com>
 <20210408083026.GE1696@xsang-OptiPlex-9020>
 <CAHk-=wigPx+MMQMQ-7EA0pq5_5+kMCNV4qFsOss-WwdCSQmb-w@mail.gmail.com>
 <m1im4wmx9g.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <m1im4wmx9g.fsf@fess.ebiederm.org>
Cc: Jens Axboe <axboe@kernel.dk>, Feng Tang <feng.tang@intel.com>,
 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 lkp@lists.01.org, kernel test robot <oliver.sang@intel.com>, "Huang,
 Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
 zhengjun.xing@intel.com, Linus Torvalds <torvalds@linux-foundation.org>,
 Christian Brauner <christian.brauner@ubuntu.com>,
 Kees Cook <keescook@chromium.org>
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gVGh1LCBBcHIgMDgsIDIwMjEgYXQgMDE6NDQ6NDNQTSAtMDUwMCwgRXJpYyBXLiBCaWVkZXJt
YW4gd3JvdGU6Cj4gTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3Jn
PiB3cml0ZXM6Cj4gCj4gPiBPbiBUaHUsIEFwciA4LCAyMDIxIGF0IDE6MzIgQU0ga2VybmVsIHRl
c3Qgcm9ib3QgPG9saXZlci5zYW5nQGludGVsLmNvbT4gd3JvdGU6Cj4gPj4KPiA+PiBGWUksIHdl
IG5vdGljZWQgYSAtNDEuOSUgcmVncmVzc2lvbiBvZiBzdHJlc3Mtbmcuc2lnc2Vndi5vcHNfcGVy
X3NlYyBkdWUgdG8gY29tbWl0Cj4gPj4gMDhlZDRlZmFkNjg0ICgiW1BBVENIIHYxMCA2LzldIFJl
aW1wbGVtZW50IFJMSU1JVF9TSUdQRU5ESU5HIG9uIHRvcCBvZiB1Y291bnRzIikKPiA+Cj4gPiBP
dWNoLgo+IAo+IFdlIHdlcmUgY2F1dGlvdXNseSBvcHRpbWlzdGljIHdoZW4gbm8gdGVzdCBwcm9i
bGVtcyBzaG93ZWQgdXAgZnJvbQo+IHRoZSBsYXN0IHBvc3RpbmcgdGhhdCB0aGVyZSB3YXMgbm90
aGluZyB0byBsb29rIGF0IGhlcmUuCj4gCj4gVW5mb3J0dW5hdGVseSBpdCBsb29rcyBsaWtlIHRo
ZSBib3RzIGp1c3QgbWlzc2VkIHRoZSBsYXN0IHBvc3RpbmcuIAo+IAo+IFNvIGl0IHNlZW1zIHdl
IGFyZSBmaW5hbGx5IHByZXR0eSBtdWNoIGF0IGNvcnJlY3QgY29kZSBpbiBuZWVkCj4gb2YgcGVy
Zm9ybWFuY2UgdHVuaW5nLgo+IAo+ID4gSSAqdGhpbmsqIHRoaXMgdGVzdCBtYXkgYmUgdGVzdGlu
ZyAic2VuZCBzbyBtYW55IHNpZ25hbHMgdGhhdCBpdAo+ID4gdHJpZ2dlcnMgdGhlIHNpZ25hbCBx
dWV1ZSBvdmVyZmxvdyBjYXNlIi4KPiA+Cj4gPiBBbmQgSSAqdGhpbmsqIHRoYXQgdGhlIHBlcmZv
cm1hbmNlIGRlZ3JhZGF0aW9uIG1heSBiZSBkdWUgdG8gbG90cyBvZgo+ID4gdW5uZWNlc3Nhcnkg
YWxsb2NhdGlvbnMsIGJlY2F1c2UgaXR5IGxvb2tzIGxpa2UgdGhhdCBjb21taXQgY2hhbmdlcwo+
ID4gX19zaWdxdWV1ZV9hbGxvYygpIHRvIGRvCj4gPgo+ID4gICAgICAgICBzdHJ1Y3Qgc2lncXVl
dWUgKnEgPSBrbWVtX2NhY2hlX2FsbG9jKHNpZ3F1ZXVlX2NhY2hlcCwgZmxhZ3MpOwo+ID4KPiA+
ICpiZWZvcmUqIGNoZWNraW5nIHRoZSBzaWduYWwgbGltaXQsIGFuZCB0aGVuIGlmIHRoZSBzaWdu
YWwgbGltaXQgd2FzCj4gPiBleGNlZWRlZCwgaXQgd2lsbCBqdXN0IGJlIGZyZWUnZCBpbnN0ZWFk
Lgo+ID4KPiA+IFRoZSBvbGQgY29kZSB3b3VsZCBjaGVjayB0aGUgc2lnbmFsIGNvdW50IGFnYWlu
c3QgUkxJTUlUX1NJR1BFTkRJTkcKPiA+ICpmaXJzdCosIGFuZCBpZiB0aGVyZSB3ZXJlIG0gb3Jl
IHBlbmRpbmcgc2lnbmFscyB0aGVuIGl0IHdvdWxkbid0IGRvCj4gPiBhbnl0aGluZyBhdCBhbGwg
KGluY2x1ZGluZyBub3QgaW5jcmVtZW50aW5nIHRoYXQgZXhwZW5zaXZlIGF0b21pYwo+ID4gY291
bnQpLgo+IAo+IFRoaXMgaXMgYW4gaW50ZXJlc3RpbmcgdGVzdCBpbiBhIGxvdCBvZiB3YXlzIGFz
IGl0IGlzIHRlc3RpbmcgdGhlCj4gc3luY2hyb25vdXMgc2lnbmFsIGRlbGl2ZXJ5IHBhdGggY2F1
c2VkIGJ5IGFuIGV4Y2VwdGlvbi4gIFRoZSB0ZXN0Cj4gaXMgZWl0aGVyIGV4ZWN1dGluZyAqcHRy
ID0gMCAod2hlcmUgcHRyIHBvaW50cyB0byBhIHJlYWQtb25seSBwYWdlKQo+IG9yIGl0IGV4ZWN1
dGVzIGFuIHg4NiBpbnN0cnVjdGlvbiB0aGF0IGlzIGV4Y2Vzc2l2ZWx5IGxvbmcuCj4gCj4gSSBo
YXZlIGZvdW5kIHRoZSBjb2RlIGJ1dCBJIGhhdmVuJ3QgZmlndXJlZCBvdXQgaG93IGl0IGlzIGJl
aW5nCj4gY2FsbGVkIHlldC4gIFRoZSBjb3JlIGxvb3AgaXMganVzdDoKPiAJZm9yKDs7KSB7Cj4g
CQlzaWdhY3Rpb24oU0lHU0VHViwgJmFjdGlvbiwgTlVMTCk7Cj4gCQlzaWdhY3Rpb24oU0lHSUxM
LCAmYWN0aW9uLCBOVUxMKTsKPiAJCXNpZ2FjdGlvbihTSUdCVVMsICZhY3Rpb24sIE5VTEwpOwo+
IAo+IAkJcmV0ID0gc2lnc2V0am1wKGptcF9lbnYsIDEpOwo+IAkJaWYgKGRvbmUoKSkKPiAgICAg
ICAgICAgICAgICAgCWJyZWFrOwo+IAkJaWYgKHJldCkgewo+ICAgICAgICAgICAgICAgICAJLyog
dmVyaWZ5IHNpZ25hbCAqLwo+ICAgICAgICAgICAgICAgICB9IGVsc2Ugewo+ICAgICAgICAgICAg
ICAgICAJKnB0ciA9IDA7Cj4gICAgICAgICAgICAgICAgIH0KPiAJfQo+IAo+IENvZGUgbGlrZSB0
aGF0IGZ1bmRhbWVudGFsbHkgY2FuIG5vdCBiZSBtdWx0aS10aHJlYWRlZC4gIFNvIHRoZSBvbmx5
IHdheQo+IHRoZSBzaWdwZW5kaW5nIGxpbWl0IGlzIGJlaW5nIGhpdCBpcyBpZiB0aGVyZSBhcmUg
bW9yZSBwcm9jZXNzZXMgcnVubmluZwo+IHRoYXQgY29kZSBzaW11bHRhbmVvdXNseSB0aGFuIHRo
ZSBzaXplIG9mIHRoZSBsaW1pdC4KPiAKPiBGdXJ0aGVyIGl0IGxvb2tzIGxpa2Ugc3RyZXNzLW5n
IHB1c2hlcyBSTElNSVRfU0lHUEVORElORyBhcyBoaWdoIGFzIGl0Cj4gd2lsbCBnbyBiZWZvcmUg
dGhlIHRlc3Qgc3RhcnRzLgo+IAo+IAo+ID4gQWxzbywgdGhlIG9sZCBjb2RlIHdhcyB2ZXJ5IGNh
cmVmdWwgdG8gb25seSBkbyB0aGUgImdldF91c2VyKCkiIGZvcgo+ID4gdGhlICpmaXJzdCogc2ln
bmFsIGl0IGFkZGVkIHRvIHRoZSBxdWV1ZSwgYW5kIGRvIHRoZSAicHV0X3VzZXIoKSIgZm9yCj4g
PiB3aGVuIHJlbW92aW5nIHRoZSBsYXN0IHNpZ25hbC4gRXhhY3RseSBiZWNhdXNlIHRob3NlIGF0
b21pY3MgYXJlIHZlcnkKPiA+IGV4cGVuc2l2ZS4KPiA+Cj4gPiBUaGUgbmV3IGNvZGUganVzdCBk
b2VzIGEgbG90IG9mIHRoZXNlIGF0b21pY3MgdW5jb25kaXRpb25hbGx5Lgo+IAo+IFllcy4gVGhh
dCBzZWVtcyBhIGxpa2VseSBjdWxwcml0Lgo+IAo+ID4gSSBkdW5uby4gVGhlIHByb2ZpbGUgZGF0
YSBpbiB0aGVyZSBpcyBhIGJpdCBoYXJkIHRvIHJlYWQsIGJ1dCB0aGVyZSdzCj4gPiBhIGxvdCBt
b3JlIGNhY2hlZSBtaXNzZXMsIGFuZCBhICpsb3QqIG9mIG5vZGUgY3Jvc3NlcnM6Cj4gPgo+ID4+
ICAgIDU5NjE1NDQgICAgICAgICAgKzE5MC40JSAgIDE3MzE0MzYxICAgICAgICBwZXJmLXN0YXQu
aS5jYWNoZS1taXNzZXMKPiA+PiAgIDIyMTA3NDY2ICAgICAgICAgICsxMTkuMiUgICA0ODQ1NzY1
NiAgICAgICAgcGVyZi1zdGF0LmkuY2FjaGUtcmVmZXJlbmNlcwo+ID4+ICAgICAxNjMyOTIgxIUg
IDMlICAgKzQ1ODIuMCUgICAgNzY0NTQxMCAgICAgICAgcGVyZi1zdGF0Lmkubm9kZS1sb2FkLW1p
c3Nlcwo+ID4+ICAgICAyMjczODggxIUgIDIlICAgKzM3MDguOCUgICAgODY2MDgyNCAgICAgICAg
cGVyZi1zdGF0Lmkubm9kZS1sb2Fkcwo+ID4KPiA+IGFuZCAocHJvYmFibHkgYXMgYSByZXN1bHQp
IGF2ZXJhZ2UgaW5zdHJ1Y3Rpb24gY29zdHMgaGF2ZSBnb25lIHVwIGVub3Jtb3VzbHk6Cj4gPgo+
ID4+ICAgICAgIDMuNDcgICAgICAgICAgICs2Ni44JSAgICAgICA1Ljc5ICAgICAgICBwZXJmLXN0
YXQub3ZlcmFsbC5jcGkKPiA+PiAgICAgIDIyODQ5ICAgICAgICAgICAtNjUuNiUgICAgICAgNzg2
NiAgICAgICAgcGVyZi1zdGF0Lm92ZXJhbGwuY3ljbGVzLWJldHdlZW4tY2FjaGUtbWlzc2VzCj4g
Pgo+ID4gYW5kIGl0IGRvZXMgc2VlbSB0byBiZSBhdCBsZWFzdCBwYXJ0bHkgYWJvdXQgInB1dF91
Y291bnRzKCkiOgo+ID4KPiA+PiAgICAgICAwLjAwICAgICAgICAgICAgKzQuNSAgICAgICAgNC40
NiAgICAgICAgcGVyZi1wcm9maWxlLmNhbGx0cmFjZS5jeWNsZXMtcHAucHV0X3Vjb3VudHMuX19z
aWdxdWV1ZV9mcmVlLmdldF9zaWduYWwuYXJjaF9kb19zaWduYWxfb3JfcmVzdGFydC5leGl0X3Rv
X3VzZXJfbW9kZV9wcmVwYXJlCj4gPgo+ID4gYW5kIGEgbG90IG9mICJnZXRfdWNvdW50cygpIi4K
PiA+Cj4gPiBCdXQgaXQgbWF5IGFsc28gYmUgdGhhdCB0aGUgbmV3ICJnZXQgc2lncGVuZGluZyIg
aXMganVzdCAqc28qIG11Y2gKPiA+IG1vcmUgZXhwZW5zaXZlIHRoYW4gaXQgdXNlZCB0byBiZS4K
PiAKPiBUaGF0IHRvbyBpcyBwb3NzaWJsZS4KPiAKPiBUaGF0IG5vZGUtbG9hZC1taXNzZXMgbnVt
YmVyIGRvZXMgbG9vayBsaWtlIHNvbWV0aGluZyBpcyBib3VuY2luZyBiYWNrCj4gYW5kIGZvcnRo
IGJldHdlZW4gdGhlIG5vZGVzIGEgbG90IG1vcmUuICBTbyBJIHN1c3BlY3Qgc3RyZXNzLW5nIGlz
Cj4gcnVubmluZyBtdWx0aXBsZSBjb3BpZXMgb2YgdGhlIHNpZ3NlZ3YgdGVzdCBpbiBkaWZmZXJl
bnQgcHJvY2Vzc2VzIGF0Cj4gb25jZS4KPiAKPiAKPiAKPiBUaGF0IHJlYWxseSBzdWdnZXN0cyBj
YWNoZSBsaW5lIHBpbmcgcG9uZyBmcm9tIGdldF91Y291bnRzIGFuZAo+IGluY3JlbWVudGluZyBz
aWdwZW5kaW5nLgo+IAo+IEl0IHN1cnByaXNlcyBtZSB0aGF0IG9idGFpbmluZyB0aGUgY2FjaGUg
bGluZXMgZXhjbHVzaXZlbHkgaXMKPiB0aGUgZG9taW5hbnQgY29zdCBvbiB0aGlzIGNvZGUgcGF0
aCBidXQgb2J0YWluaW5nIHR3byBjYWNoZSBsaW5lcwo+IGV4Y2x1c2l2ZWx5IGluc3RlYWQgb2Yg
b25lIGNhY2hlIGNhY2hlIGxpbmUgZXhjbHVzaXZlbHkgaXMgY29uc2lzdGVudAo+IHdpdGggYSBj
YXVzaW5nIHRoZSBleGNlcHRpb24gZGVsaXZlcnkgdG8gdGFrZSBuZWFybHkgdHdpY2UgYXMgbG9u
Zy4KPiAKPiBGb3IgdGhlIG9wdGltaXphdGlvbiB3ZSBvbmx5IGNhcmUgYWJvdXQgdGhlIGxlYWYg
Y291bnQgc28gd2l0aCBhIGxpdHRsZQo+IGNhcmUgd2UgY2FuIHJlc3RvcmUgdGhlIG9wdGltaXph
dGlvbi4gIFNvIHRoYXQgaXMgcHJvYmFibHkgdGhlIHRoaW5nCj4gdG8gZG8gaGVyZS4gIFRoZSBm
ZXdlciBjaGFuZ2VzIHRvIHdvcnJ5IGFib3V0IHRoZSBsZXNzIGxpa2VseSB0byBmaW5kCj4gc3Vy
cHJpc2VzLgo+IAo+IAo+IAo+IFRoYXQgc2FpZCBmb3IgdGhpcyBzcGVjaWZpYyBjYXNlIHRoZXJl
IGlzIGEgbG90IG9mIHBvdGVudGlhbCByb29tIGZvcgo+IGltcHJvdmVtZW50LiAgQXMgdGhpcyBp
cyBhIHBlciB0aHJlYWQgc2lnbmFsIHRoZSBjb2RlIHVwZGF0ZSBzaWdwZW5kaW5nCj4gaW4gY29t
bWl0X2NyZWQgYW5kIG5ldmVyIHdvcnJ5IGFib3V0IG5lZWRpbmcgdG8gcGluIHRoZSBzdHJ1Y3QK
PiB1c2VyX3N0cnVjdCBvciBzdHJ1Y3QgdWNvdW50cy4gIEFzIHRoaXMgaXMgYSBzeW5jaHJvbm91
cyBzaWduYWwgd2UgY291bGQKPiBza2lwIHRoZSBzaWdwZW5kaW5nIGluY3JlbWVudCwgc2tpcCB0
aGUgc2lnbmFsIHF1ZXVlIGVudGlyZWx5LCBhbmQKPiBkZWxpdmVyIHRoZSBzaWduYWwgdG8gdXNl
ci1zcGFjZSBpbW1lZGlhdGVseS4gIFRoZSByZW1vdmFsIG9mIGFsbCBjYWNoZQo+IHBpbmcgcG9u
Z3MgbWlnaHQgbWFrZSBpdCB3b3J0aCBpdC4KPiAKPiBUaGVyZSBpcyBhbHNvIFRob21hcyBHbGVp
eG5lcidzIHJlY2VudCBvcHRpbWl6YXRpb24gdG8gY2FjaGUgb25lCj4gc2lncXVldWUgZW50cnkg
cGVyIHRhc2sgdG8gZ2l2ZSBtb3JlIHByZWRpY3RhYmxlIGJlaGF2aW9yLiAgVGhhdAo+IHdvdWxk
IHJlbW92ZSB0aGUgY29zdCBvZiB0aGUgYWxsb2NhdGlvbi4KCmh0dHBzOi8vZ2l0Lmtlcm5lbC5v
cmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2xlZ2lvbi9saW51eC5naXQvY29tbWl0Lz9oPXBh
dGNoc2V0L3Blci11c2Vyc3BhY2UtcmxpbWl0L3YxMS4xJmlkPTA4ZGIwYzgxNDkyNmM2ZjE2ZTA4
ZGU5OWIyZGUzNGM4YjVmZjY4Y2UKCllvdSBtZWFuIHNvbWV0aGluZyBsaWtlIHRoaXMgPyBJIGRp
ZCBpdCBvbiB0b3Agb2YgVGhvbWFzIEdsZWl4bmVyJ3MKcGF0Y2hlcy4KCi0tIApSZ3JkcywgbGVn
aW9uCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250
YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3Jn
Cmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRh
aW5lcnM=

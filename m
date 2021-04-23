Return-Path: <SRS0=gt/T=JU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4552C433B4
	for <containers@archiver.kernel.org>; Fri, 23 Apr 2021 02:30:29 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3E7006141C
	for <containers@archiver.kernel.org>; Fri, 23 Apr 2021 02:30:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E7006141C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id E349F8436F;
	Fri, 23 Apr 2021 02:30:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wkQX3WhDt4Gd; Fri, 23 Apr 2021 02:30:27 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp1.osuosl.org (Postfix) with ESMTP id A469E84373;
	Fri, 23 Apr 2021 02:30:27 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 792C6C000F;
	Fri, 23 Apr 2021 02:30:27 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 21899C000B
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 02:30:26 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id EE9DC4056B
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 02:30:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id bB0X5owyKxp2
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 02:30:24 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 95EC3404DE
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 02:30:24 +0000 (UTC)
IronPort-SDR: WF3m8KFaAyE1eEdv4TPYA5s6jbtH6X7LrPm/Ov2/f3PXaRvHiBr6be/B/r1XvtiYQ0ENgOgv5W
 5u/ZcbfsNbYw==
X-IronPort-AV: E=McAfee;i="6200,9189,9962"; a="183135459"
X-IronPort-AV: E=Sophos;i="5.82,244,1613462400"; d="scan'208";a="183135459"
Received: from orsmga002.jf.intel.com ([10.7.209.21])
 by orsmga101.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384;
 22 Apr 2021 19:30:22 -0700
IronPort-SDR: 041zm7c8mdnKtAVNeJfVBZZKbigKrKUCxF9Wh+7IK0Le2mfrsZ8U1rGRSju71lU05xj7uEbej4
 +PzfezIkGQ9A==
X-IronPort-AV: E=Sophos;i="5.82,244,1613462400"; d="scan'208";a="402047000"
Received: from xsang-optiplex-9020.sh.intel.com (HELO xsang-OptiPlex-9020)
 ([10.239.159.140])
 by orsmga002-auth.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384;
 22 Apr 2021 19:30:06 -0700
Date: Fri, 23 Apr 2021 10:47:22 +0800
From: Oliver Sang <oliver.sang@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: 08ed4efad6: stress-ng.sigsegv.ops_per_sec -41.9% regression
Message-ID: <20210423024722.GA13968@xsang-OptiPlex-9020>
References: <7abe5ab608c61fc2363ba458bea21cf9a4a64588.1617814298.git.gladkov.alexey@gmail.com>
 <20210408083026.GE1696@xsang-OptiPlex-9020>
 <CAHk-=wigPx+MMQMQ-7EA0pq5_5+kMCNV4qFsOss-WwdCSQmb-w@mail.gmail.com>
 <m1im4wmx9g.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <m1im4wmx9g.fsf@fess.ebiederm.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Jens Axboe <axboe@kernel.dk>, Feng Tang <feng.tang@intel.com>,
 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 lkp@lists.01.org, Alexey Gladkov <legion@kernel.org>, "Huang,
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

aGksIEVyaWMsCgpPbiBUaHUsIEFwciAwOCwgMjAyMSBhdCAwMTo0NDo0M1BNIC0wNTAwLCBFcmlj
IFcuIEJpZWRlcm1hbiB3cm90ZToKPiBMaW51cyBUb3J2YWxkcyA8dG9ydmFsZHNAbGludXgtZm91
bmRhdGlvbi5vcmc+IHdyaXRlczoKPiAKPiA+IE9uIFRodSwgQXByIDgsIDIwMjEgYXQgMTozMiBB
TSBrZXJuZWwgdGVzdCByb2JvdCA8b2xpdmVyLnNhbmdAaW50ZWwuY29tPiB3cm90ZToKPiA+Pgo+
ID4+IEZZSSwgd2Ugbm90aWNlZCBhIC00MS45JSByZWdyZXNzaW9uIG9mIHN0cmVzcy1uZy5zaWdz
ZWd2Lm9wc19wZXJfc2VjIGR1ZSB0byBjb21taXQKPiA+PiAwOGVkNGVmYWQ2ODQgKCJbUEFUQ0gg
djEwIDYvOV0gUmVpbXBsZW1lbnQgUkxJTUlUX1NJR1BFTkRJTkcgb24gdG9wIG9mIHVjb3VudHMi
KQo+ID4KPiA+IE91Y2guCj4gCj4gV2Ugd2VyZSBjYXV0aW91c2x5IG9wdGltaXN0aWMgd2hlbiBu
byB0ZXN0IHByb2JsZW1zIHNob3dlZCB1cCBmcm9tCj4gdGhlIGxhc3QgcG9zdGluZyB0aGF0IHRo
ZXJlIHdhcyBub3RoaW5nIHRvIGxvb2sgYXQgaGVyZS4KPiAKPiBVbmZvcnR1bmF0ZWx5IGl0IGxv
b2tzIGxpa2UgdGhlIGJvdHMganVzdCBtaXNzZWQgdGhlIGxhc3QgcG9zdGluZy4gCgp0aGlzIHJl
cG9ydCBpcyB1cG9uIHYxMC4gZG8geW91IGhhdmUgbmV3ZXIgdmVyc2lvbiB3aGljaCBob3BlIGJv
dCB0ZXN0PwoKcGxlYXNlIGJlIG5vdGVkLCBzb3JyeSB0byBzYXksIGR1ZSB0byB2YXJpb3VzIHJl
YXNvbnMsIGl0IHdpbGwgYmUgYQpiaWcgY2hhbGxlbmdlIGZvciB1cyB0byBjYXB0dXJlIGVhY2gg
dmVyc2lvbiBvZiBhIHBhdGNoIHNldC4KCmUuZy4gd2UgZGlkbid0IG1ha2Ugb3V0IGEgc2ltaWxh
ciBwZXJmb3JtYW5jZSByZWdyZXNzaW9uIGZvcgp2OC92OSB2ZXJzaW9uIG9mIHRoaXMgb25lLi4K
Cj4gCj4gU28gaXQgc2VlbXMgd2UgYXJlIGZpbmFsbHkgcHJldHR5IG11Y2ggYXQgY29ycmVjdCBj
b2RlIGluIG5lZWQKPiBvZiBwZXJmb3JtYW5jZSB0dW5pbmcuCj4gCj4gPiBJICp0aGluayogdGhp
cyB0ZXN0IG1heSBiZSB0ZXN0aW5nICJzZW5kIHNvIG1hbnkgc2lnbmFscyB0aGF0IGl0Cj4gPiB0
cmlnZ2VycyB0aGUgc2lnbmFsIHF1ZXVlIG92ZXJmbG93IGNhc2UiLgo+ID4KPiA+IEFuZCBJICp0
aGluayogdGhhdCB0aGUgcGVyZm9ybWFuY2UgZGVncmFkYXRpb24gbWF5IGJlIGR1ZSB0byBsb3Rz
IG9mCj4gPiB1bm5lY2Vzc2FyeSBhbGxvY2F0aW9ucywgYmVjYXVzZSBpdHkgbG9va3MgbGlrZSB0
aGF0IGNvbW1pdCBjaGFuZ2VzCj4gPiBfX3NpZ3F1ZXVlX2FsbG9jKCkgdG8gZG8KPiA+Cj4gPiAg
ICAgICAgIHN0cnVjdCBzaWdxdWV1ZSAqcSA9IGttZW1fY2FjaGVfYWxsb2Moc2lncXVldWVfY2Fj
aGVwLCBmbGFncyk7Cj4gPgo+ID4gKmJlZm9yZSogY2hlY2tpbmcgdGhlIHNpZ25hbCBsaW1pdCwg
YW5kIHRoZW4gaWYgdGhlIHNpZ25hbCBsaW1pdCB3YXMKPiA+IGV4Y2VlZGVkLCBpdCB3aWxsIGp1
c3QgYmUgZnJlZSdkIGluc3RlYWQuCj4gPgo+ID4gVGhlIG9sZCBjb2RlIHdvdWxkIGNoZWNrIHRo
ZSBzaWduYWwgY291bnQgYWdhaW5zdCBSTElNSVRfU0lHUEVORElORwo+ID4gKmZpcnN0KiwgYW5k
IGlmIHRoZXJlIHdlcmUgbSBvcmUgcGVuZGluZyBzaWduYWxzIHRoZW4gaXQgd291bGRuJ3QgZG8K
PiA+IGFueXRoaW5nIGF0IGFsbCAoaW5jbHVkaW5nIG5vdCBpbmNyZW1lbnRpbmcgdGhhdCBleHBl
bnNpdmUgYXRvbWljCj4gPiBjb3VudCkuCj4gCj4gVGhpcyBpcyBhbiBpbnRlcmVzdGluZyB0ZXN0
IGluIGEgbG90IG9mIHdheXMgYXMgaXQgaXMgdGVzdGluZyB0aGUKPiBzeW5jaHJvbm91cyBzaWdu
YWwgZGVsaXZlcnkgcGF0aCBjYXVzZWQgYnkgYW4gZXhjZXB0aW9uLiAgVGhlIHRlc3QKPiBpcyBl
aXRoZXIgZXhlY3V0aW5nICpwdHIgPSAwICh3aGVyZSBwdHIgcG9pbnRzIHRvIGEgcmVhZC1vbmx5
IHBhZ2UpCj4gb3IgaXQgZXhlY3V0ZXMgYW4geDg2IGluc3RydWN0aW9uIHRoYXQgaXMgZXhjZXNz
aXZlbHkgbG9uZy4KPiAKPiBJIGhhdmUgZm91bmQgdGhlIGNvZGUgYnV0IEkgaGF2ZW4ndCBmaWd1
cmVkIG91dCBob3cgaXQgaXMgYmVpbmcKPiBjYWxsZWQgeWV0LiAgVGhlIGNvcmUgbG9vcCBpcyBq
dXN0Ogo+IAlmb3IoOzspIHsKPiAJCXNpZ2FjdGlvbihTSUdTRUdWLCAmYWN0aW9uLCBOVUxMKTsK
PiAJCXNpZ2FjdGlvbihTSUdJTEwsICZhY3Rpb24sIE5VTEwpOwo+IAkJc2lnYWN0aW9uKFNJR0JV
UywgJmFjdGlvbiwgTlVMTCk7Cj4gCj4gCQlyZXQgPSBzaWdzZXRqbXAoam1wX2VudiwgMSk7Cj4g
CQlpZiAoZG9uZSgpKQo+ICAgICAgICAgICAgICAgICAJYnJlYWs7Cj4gCQlpZiAocmV0KSB7Cj4g
ICAgICAgICAgICAgICAgIAkvKiB2ZXJpZnkgc2lnbmFsICovCj4gICAgICAgICAgICAgICAgIH0g
ZWxzZSB7Cj4gICAgICAgICAgICAgICAgIAkqcHRyID0gMDsKPiAgICAgICAgICAgICAgICAgfQo+
IAl9Cj4gCj4gQ29kZSBsaWtlIHRoYXQgZnVuZGFtZW50YWxseSBjYW4gbm90IGJlIG11bHRpLXRo
cmVhZGVkLiAgU28gdGhlIG9ubHkgd2F5Cj4gdGhlIHNpZ3BlbmRpbmcgbGltaXQgaXMgYmVpbmcg
aGl0IGlzIGlmIHRoZXJlIGFyZSBtb3JlIHByb2Nlc3NlcyBydW5uaW5nCj4gdGhhdCBjb2RlIHNp
bXVsdGFuZW91c2x5IHRoYW4gdGhlIHNpemUgb2YgdGhlIGxpbWl0Lgo+IAo+IEZ1cnRoZXIgaXQg
bG9va3MgbGlrZSBzdHJlc3MtbmcgcHVzaGVzIFJMSU1JVF9TSUdQRU5ESU5HIGFzIGhpZ2ggYXMg
aXQKPiB3aWxsIGdvIGJlZm9yZSB0aGUgdGVzdCBzdGFydHMuCj4gCj4gCj4gPiBBbHNvLCB0aGUg
b2xkIGNvZGUgd2FzIHZlcnkgY2FyZWZ1bCB0byBvbmx5IGRvIHRoZSAiZ2V0X3VzZXIoKSIgZm9y
Cj4gPiB0aGUgKmZpcnN0KiBzaWduYWwgaXQgYWRkZWQgdG8gdGhlIHF1ZXVlLCBhbmQgZG8gdGhl
ICJwdXRfdXNlcigpIiBmb3IKPiA+IHdoZW4gcmVtb3ZpbmcgdGhlIGxhc3Qgc2lnbmFsLiBFeGFj
dGx5IGJlY2F1c2UgdGhvc2UgYXRvbWljcyBhcmUgdmVyeQo+ID4gZXhwZW5zaXZlLgo+ID4KPiA+
IFRoZSBuZXcgY29kZSBqdXN0IGRvZXMgYSBsb3Qgb2YgdGhlc2UgYXRvbWljcyB1bmNvbmRpdGlv
bmFsbHkuCj4gCj4gWWVzLiBUaGF0IHNlZW1zIGEgbGlrZWx5IGN1bHByaXQuCj4gCj4gPiBJIGR1
bm5vLiBUaGUgcHJvZmlsZSBkYXRhIGluIHRoZXJlIGlzIGEgYml0IGhhcmQgdG8gcmVhZCwgYnV0
IHRoZXJlJ3MKPiA+IGEgbG90IG1vcmUgY2FjaGVlIG1pc3NlcywgYW5kIGEgKmxvdCogb2Ygbm9k
ZSBjcm9zc2VyczoKPiA+Cj4gPj4gICAgNTk2MTU0NCAgICAgICAgICArMTkwLjQlICAgMTczMTQz
NjEgICAgICAgIHBlcmYtc3RhdC5pLmNhY2hlLW1pc3Nlcwo+ID4+ICAgMjIxMDc0NjYgICAgICAg
ICAgKzExOS4yJSAgIDQ4NDU3NjU2ICAgICAgICBwZXJmLXN0YXQuaS5jYWNoZS1yZWZlcmVuY2Vz
Cj4gPj4gICAgIDE2MzI5MiDEhSAgMyUgICArNDU4Mi4wJSAgICA3NjQ1NDEwICAgICAgICBwZXJm
LXN0YXQuaS5ub2RlLWxvYWQtbWlzc2VzCj4gPj4gICAgIDIyNzM4OCDEhSAgMiUgICArMzcwOC44
JSAgICA4NjYwODI0ICAgICAgICBwZXJmLXN0YXQuaS5ub2RlLWxvYWRzCj4gPgo+ID4gYW5kIChw
cm9iYWJseSBhcyBhIHJlc3VsdCkgYXZlcmFnZSBpbnN0cnVjdGlvbiBjb3N0cyBoYXZlIGdvbmUg
dXAgZW5vcm1vdXNseToKPiA+Cj4gPj4gICAgICAgMy40NyAgICAgICAgICAgKzY2LjglICAgICAg
IDUuNzkgICAgICAgIHBlcmYtc3RhdC5vdmVyYWxsLmNwaQo+ID4+ICAgICAgMjI4NDkgICAgICAg
ICAgIC02NS42JSAgICAgICA3ODY2ICAgICAgICBwZXJmLXN0YXQub3ZlcmFsbC5jeWNsZXMtYmV0
d2Vlbi1jYWNoZS1taXNzZXMKPiA+Cj4gPiBhbmQgaXQgZG9lcyBzZWVtIHRvIGJlIGF0IGxlYXN0
IHBhcnRseSBhYm91dCAicHV0X3Vjb3VudHMoKSI6Cj4gPgo+ID4+ICAgICAgIDAuMDAgICAgICAg
ICAgICArNC41ICAgICAgICA0LjQ2ICAgICAgICBwZXJmLXByb2ZpbGUuY2FsbHRyYWNlLmN5Y2xl
cy1wcC5wdXRfdWNvdW50cy5fX3NpZ3F1ZXVlX2ZyZWUuZ2V0X3NpZ25hbC5hcmNoX2RvX3NpZ25h
bF9vcl9yZXN0YXJ0LmV4aXRfdG9fdXNlcl9tb2RlX3ByZXBhcmUKPiA+Cj4gPiBhbmQgYSBsb3Qg
b2YgImdldF91Y291bnRzKCkiLgo+ID4KPiA+IEJ1dCBpdCBtYXkgYWxzbyBiZSB0aGF0IHRoZSBu
ZXcgImdldCBzaWdwZW5kaW5nIiBpcyBqdXN0ICpzbyogbXVjaAo+ID4gbW9yZSBleHBlbnNpdmUg
dGhhbiBpdCB1c2VkIHRvIGJlLgo+IAo+IFRoYXQgdG9vIGlzIHBvc3NpYmxlLgo+IAo+IFRoYXQg
bm9kZS1sb2FkLW1pc3NlcyBudW1iZXIgZG9lcyBsb29rIGxpa2Ugc29tZXRoaW5nIGlzIGJvdW5j
aW5nIGJhY2sKPiBhbmQgZm9ydGggYmV0d2VlbiB0aGUgbm9kZXMgYSBsb3QgbW9yZS4gIFNvIEkg
c3VzcGVjdCBzdHJlc3MtbmcgaXMKPiBydW5uaW5nIG11bHRpcGxlIGNvcGllcyBvZiB0aGUgc2ln
c2VndiB0ZXN0IGluIGRpZmZlcmVudCBwcm9jZXNzZXMgYXQKPiBvbmNlLgo+IAo+IAo+IAo+IFRo
YXQgcmVhbGx5IHN1Z2dlc3RzIGNhY2hlIGxpbmUgcGluZyBwb25nIGZyb20gZ2V0X3Vjb3VudHMg
YW5kCj4gaW5jcmVtZW50aW5nIHNpZ3BlbmRpbmcuCj4gCj4gSXQgc3VycHJpc2VzIG1lIHRoYXQg
b2J0YWluaW5nIHRoZSBjYWNoZSBsaW5lcyBleGNsdXNpdmVseSBpcwo+IHRoZSBkb21pbmFudCBj
b3N0IG9uIHRoaXMgY29kZSBwYXRoIGJ1dCBvYnRhaW5pbmcgdHdvIGNhY2hlIGxpbmVzCj4gZXhj
bHVzaXZlbHkgaW5zdGVhZCBvZiBvbmUgY2FjaGUgY2FjaGUgbGluZSBleGNsdXNpdmVseSBpcyBj
b25zaXN0ZW50Cj4gd2l0aCBhIGNhdXNpbmcgdGhlIGV4Y2VwdGlvbiBkZWxpdmVyeSB0byB0YWtl
IG5lYXJseSB0d2ljZSBhcyBsb25nLgo+IAo+IEZvciB0aGUgb3B0aW1pemF0aW9uIHdlIG9ubHkg
Y2FyZSBhYm91dCB0aGUgbGVhZiBjb3VudCBzbyB3aXRoIGEgbGl0dGxlCj4gY2FyZSB3ZSBjYW4g
cmVzdG9yZSB0aGUgb3B0aW1pemF0aW9uLiAgU28gdGhhdCBpcyBwcm9iYWJseSB0aGUgdGhpbmcK
PiB0byBkbyBoZXJlLiAgVGhlIGZld2VyIGNoYW5nZXMgdG8gd29ycnkgYWJvdXQgdGhlIGxlc3Mg
bGlrZWx5IHRvIGZpbmQKPiBzdXJwcmlzZXMuCj4gCj4gCj4gCj4gVGhhdCBzYWlkIGZvciB0aGlz
IHNwZWNpZmljIGNhc2UgdGhlcmUgaXMgYSBsb3Qgb2YgcG90ZW50aWFsIHJvb20gZm9yCj4gaW1w
cm92ZW1lbnQuICBBcyB0aGlzIGlzIGEgcGVyIHRocmVhZCBzaWduYWwgdGhlIGNvZGUgdXBkYXRl
IHNpZ3BlbmRpbmcKPiBpbiBjb21taXRfY3JlZCBhbmQgbmV2ZXIgd29ycnkgYWJvdXQgbmVlZGlu
ZyB0byBwaW4gdGhlIHN0cnVjdAo+IHVzZXJfc3RydWN0IG9yIHN0cnVjdCB1Y291bnRzLiAgQXMg
dGhpcyBpcyBhIHN5bmNocm9ub3VzIHNpZ25hbCB3ZSBjb3VsZAo+IHNraXAgdGhlIHNpZ3BlbmRp
bmcgaW5jcmVtZW50LCBza2lwIHRoZSBzaWduYWwgcXVldWUgZW50aXJlbHksIGFuZAo+IGRlbGl2
ZXIgdGhlIHNpZ25hbCB0byB1c2VyLXNwYWNlIGltbWVkaWF0ZWx5LiAgVGhlIHJlbW92YWwgb2Yg
YWxsIGNhY2hlCj4gcGluZyBwb25ncyBtaWdodCBtYWtlIGl0IHdvcnRoIGl0Lgo+IAo+IFRoZXJl
IGlzIGFsc28gVGhvbWFzIEdsZWl4bmVyJ3MgcmVjZW50IG9wdGltaXphdGlvbiB0byBjYWNoZSBv
bmUKPiBzaWdxdWV1ZSBlbnRyeSBwZXIgdGFzayB0byBnaXZlIG1vcmUgcHJlZGljdGFibGUgYmVo
YXZpb3IuICBUaGF0Cj4gd291bGQgcmVtb3ZlIHRoZSBjb3N0IG9mIHRoZSBhbGxvY2F0aW9uLgo+
IAo+IEVyaWMKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
Q29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9u
Lm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9j
b250YWluZXJz

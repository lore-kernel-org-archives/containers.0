Return-Path: <SRS0=gt/T=JU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09BC1C433ED
	for <containers@archiver.kernel.org>; Fri, 23 Apr 2021 07:44:46 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 687DF6105A
	for <containers@archiver.kernel.org>; Fri, 23 Apr 2021 07:44:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 687DF6105A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 190B84059A;
	Fri, 23 Apr 2021 07:44:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id w5d6LFMM68fx; Fri, 23 Apr 2021 07:44:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 8417840578;
	Fri, 23 Apr 2021 07:44:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5D90AC000E;
	Fri, 23 Apr 2021 07:44:43 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7642EC000B
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 07:44:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 4ED3B40578
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 07:44:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Y12U_xFVXCBn
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 07:44:39 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 7327D4055A
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 07:44:38 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 21391613D7;
 Fri, 23 Apr 2021 07:44:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1619163877;
 bh=8vt7fJFKJyNLj4TruaKcfoqK87/dNszJK3KYc+h7llo=;
 h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
 b=XPM/BW3NJ38gXdx4kC9XLRyu4R5onNo/Wqm16A+sHhEqALBFN8UtvF30xiKtpAM69
 ruMjG+OEgzQ7mzSaFmYzUb8nMNl91VX/734G4IMxS4r2Aym+1c+LknRsdHLVGoaS9J
 poN1lAeOZGP8dhfk81DMMpSp/vslj2BBRMtB1ZuUxTcx3KttlMPWsWZqfW15JERhqO
 82TsZKYZAZXIh4n1KLo7G4q15+De1OCt7xrNyey9VubMs0vDbWnS7DSSg7ufwoniPq
 0nlLbQuBnDVtXl3hK+j4sTazgBAMy+V+bMZaBJRHktnJHXg5VTrWshmxd/3oPM6y99
 YfuILgFmKfsyA==
Date: Fri, 23 Apr 2021 09:44:31 +0200
From: Alexey Gladkov <legion@kernel.org>
To: Oliver Sang <oliver.sang@intel.com>
Subject: Re: 08ed4efad6: stress-ng.sigsegv.ops_per_sec -41.9% regression
Message-ID: <20210423074431.7ob6aqasome2zjbk@example.org>
References: <7abe5ab608c61fc2363ba458bea21cf9a4a64588.1617814298.git.gladkov.alexey@gmail.com>
 <20210408083026.GE1696@xsang-OptiPlex-9020>
 <CAHk-=wigPx+MMQMQ-7EA0pq5_5+kMCNV4qFsOss-WwdCSQmb-w@mail.gmail.com>
 <m1im4wmx9g.fsf@fess.ebiederm.org>
 <20210423024722.GA13968@xsang-OptiPlex-9020>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210423024722.GA13968@xsang-OptiPlex-9020>
Cc: Jens Axboe <axboe@kernel.dk>, Feng Tang <feng.tang@intel.com>,
 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 lkp@lists.01.org, "Eric W. Biederman" <ebiederm@xmission.com>, "Huang,
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

T24gRnJpLCBBcHIgMjMsIDIwMjEgYXQgMTA6NDc6MjJBTSArMDgwMCwgT2xpdmVyIFNhbmcgd3Jv
dGU6Cj4gaGksIEVyaWMsCj4gCj4gT24gVGh1LCBBcHIgMDgsIDIwMjEgYXQgMDE6NDQ6NDNQTSAt
MDUwMCwgRXJpYyBXLiBCaWVkZXJtYW4gd3JvdGU6Cj4gPiBMaW51cyBUb3J2YWxkcyA8dG9ydmFs
ZHNAbGludXgtZm91bmRhdGlvbi5vcmc+IHdyaXRlczoKPiA+IAo+ID4gPiBPbiBUaHUsIEFwciA4
LCAyMDIxIGF0IDE6MzIgQU0ga2VybmVsIHRlc3Qgcm9ib3QgPG9saXZlci5zYW5nQGludGVsLmNv
bT4gd3JvdGU6Cj4gPiA+Pgo+ID4gPj4gRllJLCB3ZSBub3RpY2VkIGEgLTQxLjklIHJlZ3Jlc3Np
b24gb2Ygc3RyZXNzLW5nLnNpZ3NlZ3Yub3BzX3Blcl9zZWMgZHVlIHRvIGNvbW1pdAo+ID4gPj4g
MDhlZDRlZmFkNjg0ICgiW1BBVENIIHYxMCA2LzldIFJlaW1wbGVtZW50IFJMSU1JVF9TSUdQRU5E
SU5HIG9uIHRvcCBvZiB1Y291bnRzIikKPiA+ID4KPiA+ID4gT3VjaC4KPiA+IAo+ID4gV2Ugd2Vy
ZSBjYXV0aW91c2x5IG9wdGltaXN0aWMgd2hlbiBubyB0ZXN0IHByb2JsZW1zIHNob3dlZCB1cCBm
cm9tCj4gPiB0aGUgbGFzdCBwb3N0aW5nIHRoYXQgdGhlcmUgd2FzIG5vdGhpbmcgdG8gbG9vayBh
dCBoZXJlLgo+ID4gCj4gPiBVbmZvcnR1bmF0ZWx5IGl0IGxvb2tzIGxpa2UgdGhlIGJvdHMganVz
dCBtaXNzZWQgdGhlIGxhc3QgcG9zdGluZy4gCj4gCj4gdGhpcyByZXBvcnQgaXMgdXBvbiB2MTAu
IGRvIHlvdSBoYXZlIG5ld2VyIHZlcnNpb24gd2hpY2ggaG9wZSBib3QgdGVzdD8KClllcy4gSSBw
b3N0ZWQgYSBuZXcgdmVyc2lvbiBvZiB0aGlzIHBhdGNoIHNldC4gSSB3b3VsZCBiZSB2ZXJ5IGdy
YXRlZnVsIGlmCnlvdSBjb3VsZCB0ZXN0IGl0LgoKaHR0cHM6Ly9sb3JlLmtlcm5lbC5vcmcvbGtt
bC9jb3Zlci4xNjE5MDk0NDI4LmdpdC5sZWdpb25Aa2VybmVsLm9yZy8KCj4gcGxlYXNlIGJlIG5v
dGVkLCBzb3JyeSB0byBzYXksIGR1ZSB0byB2YXJpb3VzIHJlYXNvbnMsIGl0IHdpbGwgYmUgYQo+
IGJpZyBjaGFsbGVuZ2UgZm9yIHVzIHRvIGNhcHR1cmUgZWFjaCB2ZXJzaW9uIG9mIGEgcGF0Y2gg
c2V0Lgo+IAo+IGUuZy4gd2UgZGlkbid0IG1ha2Ugb3V0IGEgc2ltaWxhciBwZXJmb3JtYW5jZSBy
ZWdyZXNzaW9uIGZvcgo+IHY4L3Y5IHZlcnNpb24gb2YgdGhpcyBvbmUuLgo+IAo+ID4gCj4gPiBT
byBpdCBzZWVtcyB3ZSBhcmUgZmluYWxseSBwcmV0dHkgbXVjaCBhdCBjb3JyZWN0IGNvZGUgaW4g
bmVlZAo+ID4gb2YgcGVyZm9ybWFuY2UgdHVuaW5nLgo+ID4gCj4gPiA+IEkgKnRoaW5rKiB0aGlz
IHRlc3QgbWF5IGJlIHRlc3RpbmcgInNlbmQgc28gbWFueSBzaWduYWxzIHRoYXQgaXQKPiA+ID4g
dHJpZ2dlcnMgdGhlIHNpZ25hbCBxdWV1ZSBvdmVyZmxvdyBjYXNlIi4KPiA+ID4KPiA+ID4gQW5k
IEkgKnRoaW5rKiB0aGF0IHRoZSBwZXJmb3JtYW5jZSBkZWdyYWRhdGlvbiBtYXkgYmUgZHVlIHRv
IGxvdHMgb2YKPiA+ID4gdW5uZWNlc3NhcnkgYWxsb2NhdGlvbnMsIGJlY2F1c2UgaXR5IGxvb2tz
IGxpa2UgdGhhdCBjb21taXQgY2hhbmdlcwo+ID4gPiBfX3NpZ3F1ZXVlX2FsbG9jKCkgdG8gZG8K
PiA+ID4KPiA+ID4gICAgICAgICBzdHJ1Y3Qgc2lncXVldWUgKnEgPSBrbWVtX2NhY2hlX2FsbG9j
KHNpZ3F1ZXVlX2NhY2hlcCwgZmxhZ3MpOwo+ID4gPgo+ID4gPiAqYmVmb3JlKiBjaGVja2luZyB0
aGUgc2lnbmFsIGxpbWl0LCBhbmQgdGhlbiBpZiB0aGUgc2lnbmFsIGxpbWl0IHdhcwo+ID4gPiBl
eGNlZWRlZCwgaXQgd2lsbCBqdXN0IGJlIGZyZWUnZCBpbnN0ZWFkLgo+ID4gPgo+ID4gPiBUaGUg
b2xkIGNvZGUgd291bGQgY2hlY2sgdGhlIHNpZ25hbCBjb3VudCBhZ2FpbnN0IFJMSU1JVF9TSUdQ
RU5ESU5HCj4gPiA+ICpmaXJzdCosIGFuZCBpZiB0aGVyZSB3ZXJlIG0gb3JlIHBlbmRpbmcgc2ln
bmFscyB0aGVuIGl0IHdvdWxkbid0IGRvCj4gPiA+IGFueXRoaW5nIGF0IGFsbCAoaW5jbHVkaW5n
IG5vdCBpbmNyZW1lbnRpbmcgdGhhdCBleHBlbnNpdmUgYXRvbWljCj4gPiA+IGNvdW50KS4KPiA+
IAo+ID4gVGhpcyBpcyBhbiBpbnRlcmVzdGluZyB0ZXN0IGluIGEgbG90IG9mIHdheXMgYXMgaXQg
aXMgdGVzdGluZyB0aGUKPiA+IHN5bmNocm9ub3VzIHNpZ25hbCBkZWxpdmVyeSBwYXRoIGNhdXNl
ZCBieSBhbiBleGNlcHRpb24uICBUaGUgdGVzdAo+ID4gaXMgZWl0aGVyIGV4ZWN1dGluZyAqcHRy
ID0gMCAod2hlcmUgcHRyIHBvaW50cyB0byBhIHJlYWQtb25seSBwYWdlKQo+ID4gb3IgaXQgZXhl
Y3V0ZXMgYW4geDg2IGluc3RydWN0aW9uIHRoYXQgaXMgZXhjZXNzaXZlbHkgbG9uZy4KPiA+IAo+
ID4gSSBoYXZlIGZvdW5kIHRoZSBjb2RlIGJ1dCBJIGhhdmVuJ3QgZmlndXJlZCBvdXQgaG93IGl0
IGlzIGJlaW5nCj4gPiBjYWxsZWQgeWV0LiAgVGhlIGNvcmUgbG9vcCBpcyBqdXN0Ogo+ID4gCWZv
cig7Oykgewo+ID4gCQlzaWdhY3Rpb24oU0lHU0VHViwgJmFjdGlvbiwgTlVMTCk7Cj4gPiAJCXNp
Z2FjdGlvbihTSUdJTEwsICZhY3Rpb24sIE5VTEwpOwo+ID4gCQlzaWdhY3Rpb24oU0lHQlVTLCAm
YWN0aW9uLCBOVUxMKTsKPiA+IAo+ID4gCQlyZXQgPSBzaWdzZXRqbXAoam1wX2VudiwgMSk7Cj4g
PiAJCWlmIChkb25lKCkpCj4gPiAgICAgICAgICAgICAgICAgCWJyZWFrOwo+ID4gCQlpZiAocmV0
KSB7Cj4gPiAgICAgICAgICAgICAgICAgCS8qIHZlcmlmeSBzaWduYWwgKi8KPiA+ICAgICAgICAg
ICAgICAgICB9IGVsc2Ugewo+ID4gICAgICAgICAgICAgICAgIAkqcHRyID0gMDsKPiA+ICAgICAg
ICAgICAgICAgICB9Cj4gPiAJfQo+ID4gCj4gPiBDb2RlIGxpa2UgdGhhdCBmdW5kYW1lbnRhbGx5
IGNhbiBub3QgYmUgbXVsdGktdGhyZWFkZWQuICBTbyB0aGUgb25seSB3YXkKPiA+IHRoZSBzaWdw
ZW5kaW5nIGxpbWl0IGlzIGJlaW5nIGhpdCBpcyBpZiB0aGVyZSBhcmUgbW9yZSBwcm9jZXNzZXMg
cnVubmluZwo+ID4gdGhhdCBjb2RlIHNpbXVsdGFuZW91c2x5IHRoYW4gdGhlIHNpemUgb2YgdGhl
IGxpbWl0Lgo+ID4gCj4gPiBGdXJ0aGVyIGl0IGxvb2tzIGxpa2Ugc3RyZXNzLW5nIHB1c2hlcyBS
TElNSVRfU0lHUEVORElORyBhcyBoaWdoIGFzIGl0Cj4gPiB3aWxsIGdvIGJlZm9yZSB0aGUgdGVz
dCBzdGFydHMuCj4gPiAKPiA+IAo+ID4gPiBBbHNvLCB0aGUgb2xkIGNvZGUgd2FzIHZlcnkgY2Fy
ZWZ1bCB0byBvbmx5IGRvIHRoZSAiZ2V0X3VzZXIoKSIgZm9yCj4gPiA+IHRoZSAqZmlyc3QqIHNp
Z25hbCBpdCBhZGRlZCB0byB0aGUgcXVldWUsIGFuZCBkbyB0aGUgInB1dF91c2VyKCkiIGZvcgo+
ID4gPiB3aGVuIHJlbW92aW5nIHRoZSBsYXN0IHNpZ25hbC4gRXhhY3RseSBiZWNhdXNlIHRob3Nl
IGF0b21pY3MgYXJlIHZlcnkKPiA+ID4gZXhwZW5zaXZlLgo+ID4gPgo+ID4gPiBUaGUgbmV3IGNv
ZGUganVzdCBkb2VzIGEgbG90IG9mIHRoZXNlIGF0b21pY3MgdW5jb25kaXRpb25hbGx5Lgo+ID4g
Cj4gPiBZZXMuIFRoYXQgc2VlbXMgYSBsaWtlbHkgY3VscHJpdC4KPiA+IAo+ID4gPiBJIGR1bm5v
LiBUaGUgcHJvZmlsZSBkYXRhIGluIHRoZXJlIGlzIGEgYml0IGhhcmQgdG8gcmVhZCwgYnV0IHRo
ZXJlJ3MKPiA+ID4gYSBsb3QgbW9yZSBjYWNoZWUgbWlzc2VzLCBhbmQgYSAqbG90KiBvZiBub2Rl
IGNyb3NzZXJzOgo+ID4gPgo+ID4gPj4gICAgNTk2MTU0NCAgICAgICAgICArMTkwLjQlICAgMTcz
MTQzNjEgICAgICAgIHBlcmYtc3RhdC5pLmNhY2hlLW1pc3Nlcwo+ID4gPj4gICAyMjEwNzQ2NiAg
ICAgICAgICArMTE5LjIlICAgNDg0NTc2NTYgICAgICAgIHBlcmYtc3RhdC5pLmNhY2hlLXJlZmVy
ZW5jZXMKPiA+ID4+ICAgICAxNjMyOTIgxIUgIDMlICAgKzQ1ODIuMCUgICAgNzY0NTQxMCAgICAg
ICAgcGVyZi1zdGF0Lmkubm9kZS1sb2FkLW1pc3Nlcwo+ID4gPj4gICAgIDIyNzM4OCDEhSAgMiUg
ICArMzcwOC44JSAgICA4NjYwODI0ICAgICAgICBwZXJmLXN0YXQuaS5ub2RlLWxvYWRzCj4gPiA+
Cj4gPiA+IGFuZCAocHJvYmFibHkgYXMgYSByZXN1bHQpIGF2ZXJhZ2UgaW5zdHJ1Y3Rpb24gY29z
dHMgaGF2ZSBnb25lIHVwIGVub3Jtb3VzbHk6Cj4gPiA+Cj4gPiA+PiAgICAgICAzLjQ3ICAgICAg
ICAgICArNjYuOCUgICAgICAgNS43OSAgICAgICAgcGVyZi1zdGF0Lm92ZXJhbGwuY3BpCj4gPiA+
PiAgICAgIDIyODQ5ICAgICAgICAgICAtNjUuNiUgICAgICAgNzg2NiAgICAgICAgcGVyZi1zdGF0
Lm92ZXJhbGwuY3ljbGVzLWJldHdlZW4tY2FjaGUtbWlzc2VzCj4gPiA+Cj4gPiA+IGFuZCBpdCBk
b2VzIHNlZW0gdG8gYmUgYXQgbGVhc3QgcGFydGx5IGFib3V0ICJwdXRfdWNvdW50cygpIjoKPiA+
ID4KPiA+ID4+ICAgICAgIDAuMDAgICAgICAgICAgICArNC41ICAgICAgICA0LjQ2ICAgICAgICBw
ZXJmLXByb2ZpbGUuY2FsbHRyYWNlLmN5Y2xlcy1wcC5wdXRfdWNvdW50cy5fX3NpZ3F1ZXVlX2Zy
ZWUuZ2V0X3NpZ25hbC5hcmNoX2RvX3NpZ25hbF9vcl9yZXN0YXJ0LmV4aXRfdG9fdXNlcl9tb2Rl
X3ByZXBhcmUKPiA+ID4KPiA+ID4gYW5kIGEgbG90IG9mICJnZXRfdWNvdW50cygpIi4KPiA+ID4K
PiA+ID4gQnV0IGl0IG1heSBhbHNvIGJlIHRoYXQgdGhlIG5ldyAiZ2V0IHNpZ3BlbmRpbmciIGlz
IGp1c3QgKnNvKiBtdWNoCj4gPiA+IG1vcmUgZXhwZW5zaXZlIHRoYW4gaXQgdXNlZCB0byBiZS4K
PiA+IAo+ID4gVGhhdCB0b28gaXMgcG9zc2libGUuCj4gPiAKPiA+IFRoYXQgbm9kZS1sb2FkLW1p
c3NlcyBudW1iZXIgZG9lcyBsb29rIGxpa2Ugc29tZXRoaW5nIGlzIGJvdW5jaW5nIGJhY2sKPiA+
IGFuZCBmb3J0aCBiZXR3ZWVuIHRoZSBub2RlcyBhIGxvdCBtb3JlLiAgU28gSSBzdXNwZWN0IHN0
cmVzcy1uZyBpcwo+ID4gcnVubmluZyBtdWx0aXBsZSBjb3BpZXMgb2YgdGhlIHNpZ3NlZ3YgdGVz
dCBpbiBkaWZmZXJlbnQgcHJvY2Vzc2VzIGF0Cj4gPiBvbmNlLgo+ID4gCj4gPiAKPiA+IAo+ID4g
VGhhdCByZWFsbHkgc3VnZ2VzdHMgY2FjaGUgbGluZSBwaW5nIHBvbmcgZnJvbSBnZXRfdWNvdW50
cyBhbmQKPiA+IGluY3JlbWVudGluZyBzaWdwZW5kaW5nLgo+ID4gCj4gPiBJdCBzdXJwcmlzZXMg
bWUgdGhhdCBvYnRhaW5pbmcgdGhlIGNhY2hlIGxpbmVzIGV4Y2x1c2l2ZWx5IGlzCj4gPiB0aGUg
ZG9taW5hbnQgY29zdCBvbiB0aGlzIGNvZGUgcGF0aCBidXQgb2J0YWluaW5nIHR3byBjYWNoZSBs
aW5lcwo+ID4gZXhjbHVzaXZlbHkgaW5zdGVhZCBvZiBvbmUgY2FjaGUgY2FjaGUgbGluZSBleGNs
dXNpdmVseSBpcyBjb25zaXN0ZW50Cj4gPiB3aXRoIGEgY2F1c2luZyB0aGUgZXhjZXB0aW9uIGRl
bGl2ZXJ5IHRvIHRha2UgbmVhcmx5IHR3aWNlIGFzIGxvbmcuCj4gPiAKPiA+IEZvciB0aGUgb3B0
aW1pemF0aW9uIHdlIG9ubHkgY2FyZSBhYm91dCB0aGUgbGVhZiBjb3VudCBzbyB3aXRoIGEgbGl0
dGxlCj4gPiBjYXJlIHdlIGNhbiByZXN0b3JlIHRoZSBvcHRpbWl6YXRpb24uICBTbyB0aGF0IGlz
IHByb2JhYmx5IHRoZSB0aGluZwo+ID4gdG8gZG8gaGVyZS4gIFRoZSBmZXdlciBjaGFuZ2VzIHRv
IHdvcnJ5IGFib3V0IHRoZSBsZXNzIGxpa2VseSB0byBmaW5kCj4gPiBzdXJwcmlzZXMuCj4gPiAK
PiA+IAo+ID4gCj4gPiBUaGF0IHNhaWQgZm9yIHRoaXMgc3BlY2lmaWMgY2FzZSB0aGVyZSBpcyBh
IGxvdCBvZiBwb3RlbnRpYWwgcm9vbSBmb3IKPiA+IGltcHJvdmVtZW50LiAgQXMgdGhpcyBpcyBh
IHBlciB0aHJlYWQgc2lnbmFsIHRoZSBjb2RlIHVwZGF0ZSBzaWdwZW5kaW5nCj4gPiBpbiBjb21t
aXRfY3JlZCBhbmQgbmV2ZXIgd29ycnkgYWJvdXQgbmVlZGluZyB0byBwaW4gdGhlIHN0cnVjdAo+
ID4gdXNlcl9zdHJ1Y3Qgb3Igc3RydWN0IHVjb3VudHMuICBBcyB0aGlzIGlzIGEgc3luY2hyb25v
dXMgc2lnbmFsIHdlIGNvdWxkCj4gPiBza2lwIHRoZSBzaWdwZW5kaW5nIGluY3JlbWVudCwgc2tp
cCB0aGUgc2lnbmFsIHF1ZXVlIGVudGlyZWx5LCBhbmQKPiA+IGRlbGl2ZXIgdGhlIHNpZ25hbCB0
byB1c2VyLXNwYWNlIGltbWVkaWF0ZWx5LiAgVGhlIHJlbW92YWwgb2YgYWxsIGNhY2hlCj4gPiBw
aW5nIHBvbmdzIG1pZ2h0IG1ha2UgaXQgd29ydGggaXQuCj4gPiAKPiA+IFRoZXJlIGlzIGFsc28g
VGhvbWFzIEdsZWl4bmVyJ3MgcmVjZW50IG9wdGltaXphdGlvbiB0byBjYWNoZSBvbmUKPiA+IHNp
Z3F1ZXVlIGVudHJ5IHBlciB0YXNrIHRvIGdpdmUgbW9yZSBwcmVkaWN0YWJsZSBiZWhhdmlvci4g
IFRoYXQKPiA+IHdvdWxkIHJlbW92ZSB0aGUgY29zdCBvZiB0aGUgYWxsb2NhdGlvbi4KPiA+IAo+
ID4gRXJpYwo+IAoKLS0gClJncmRzLCBsZWdpb24KCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNA
bGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24u
b3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

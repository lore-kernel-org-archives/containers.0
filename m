Return-Path: <SRS0=eD1A=JF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B11B7C433B4
	for <containers@archiver.kernel.org>; Thu,  8 Apr 2021 16:44:44 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3F6B260FE6
	for <containers@archiver.kernel.org>; Thu,  8 Apr 2021 16:44:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F6B260FE6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id EA66840310;
	Thu,  8 Apr 2021 16:44:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xVNuU9nX3HNe; Thu,  8 Apr 2021 16:44:42 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id A34984030A;
	Thu,  8 Apr 2021 16:44:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7BC01C000C;
	Thu,  8 Apr 2021 16:44:42 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9EF72C000A
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:44:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 85D6F40135
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:44:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id p36s_e_ieoCT
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:44:40 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from vmicros1.altlinux.org (vmicros1.altlinux.org [194.107.17.57])
 by smtp2.osuosl.org (Postfix) with ESMTP id ECF5140107
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:44:30 +0000 (UTC)
Received: from imap.altlinux.org (imap.altlinux.org [194.107.17.38])
 by vmicros1.altlinux.org (Postfix) with ESMTP id CD32E72C8B1;
 Thu,  8 Apr 2021 19:44:28 +0300 (MSK)
Received: from example.org (ip-94-113-225-162.net.upcbroadband.cz
 [94.113.225.162])
 by imap.altlinux.org (Postfix) with ESMTPSA id 9991E4A4726;
 Thu,  8 Apr 2021 19:44:27 +0300 (MSK)
Date: Thu, 8 Apr 2021 18:44:26 +0200
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 08ed4efad6: stress-ng.sigsegv.ops_per_sec -41.9% regression
Message-ID: <20210408164426.o5cfvv3ixowsto62@example.org>
References: <7abe5ab608c61fc2363ba458bea21cf9a4a64588.1617814298.git.gladkov.alexey@gmail.com>
 <20210408083026.GE1696@xsang-OptiPlex-9020>
 <CAHk-=wigPx+MMQMQ-7EA0pq5_5+kMCNV4qFsOss-WwdCSQmb-w@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHk-=wigPx+MMQMQ-7EA0pq5_5+kMCNV4qFsOss-WwdCSQmb-w@mail.gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, Feng Tang <feng.tang@intel.com>,
 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 lkp@lists.01.org, kernel test robot <oliver.sang@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>, "Huang,
 Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
 zhengjun.xing@intel.com, Kees Cook <keescook@chromium.org>
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

T24gVGh1LCBBcHIgMDgsIDIwMjEgYXQgMDk6MjI6NDBBTSAtMDcwMCwgTGludXMgVG9ydmFsZHMg
d3JvdGU6Cj4gT24gVGh1LCBBcHIgOCwgMjAyMSBhdCAxOjMyIEFNIGtlcm5lbCB0ZXN0IHJvYm90
IDxvbGl2ZXIuc2FuZ0BpbnRlbC5jb20+IHdyb3RlOgo+ID4KPiA+IEZZSSwgd2Ugbm90aWNlZCBh
IC00MS45JSByZWdyZXNzaW9uIG9mIHN0cmVzcy1uZy5zaWdzZWd2Lm9wc19wZXJfc2VjIGR1ZSB0
byBjb21taXQKPiA+IDA4ZWQ0ZWZhZDY4NCAoIltQQVRDSCB2MTAgNi85XSBSZWltcGxlbWVudCBS
TElNSVRfU0lHUEVORElORyBvbiB0b3Agb2YgdWNvdW50cyIpCj4gCj4gT3VjaC4KPiAKPiBJICp0
aGluayogdGhpcyB0ZXN0IG1heSBiZSB0ZXN0aW5nICJzZW5kIHNvIG1hbnkgc2lnbmFscyB0aGF0
IGl0Cj4gdHJpZ2dlcnMgdGhlIHNpZ25hbCBxdWV1ZSBvdmVyZmxvdyBjYXNlIi4KPiAKPiBBbmQg
SSAqdGhpbmsqIHRoYXQgdGhlIHBlcmZvcm1hbmNlIGRlZ3JhZGF0aW9uIG1heSBiZSBkdWUgdG8g
bG90cyBvZgo+IHVubmVjZXNzYXJ5IGFsbG9jYXRpb25zLCBiZWNhdXNlIGl0eSBsb29rcyBsaWtl
IHRoYXQgY29tbWl0IGNoYW5nZXMKPiBfX3NpZ3F1ZXVlX2FsbG9jKCkgdG8gZG8KPiAKPiAgICAg
ICAgIHN0cnVjdCBzaWdxdWV1ZSAqcSA9IGttZW1fY2FjaGVfYWxsb2Moc2lncXVldWVfY2FjaGVw
LCBmbGFncyk7Cj4gCj4gKmJlZm9yZSogY2hlY2tpbmcgdGhlIHNpZ25hbCBsaW1pdCwgYW5kIHRo
ZW4gaWYgdGhlIHNpZ25hbCBsaW1pdCB3YXMKPiBleGNlZWRlZCwgaXQgd2lsbCBqdXN0IGJlIGZy
ZWUnZCBpbnN0ZWFkLgo+IAo+IFRoZSBvbGQgY29kZSB3b3VsZCBjaGVjayB0aGUgc2lnbmFsIGNv
dW50IGFnYWluc3QgUkxJTUlUX1NJR1BFTkRJTkcKPiAqZmlyc3QqLCBhbmQgaWYgdGhlcmUgd2Vy
ZSBtIG9yZSBwZW5kaW5nIHNpZ25hbHMgdGhlbiBpdCB3b3VsZG4ndCBkbwo+IGFueXRoaW5nIGF0
IGFsbCAoaW5jbHVkaW5nIG5vdCBpbmNyZW1lbnRpbmcgdGhhdCBleHBlbnNpdmUgYXRvbWljCj4g
Y291bnQpLgo+IAo+IEFsc28sIHRoZSBvbGQgY29kZSB3YXMgdmVyeSBjYXJlZnVsIHRvIG9ubHkg
ZG8gdGhlICJnZXRfdXNlcigpIiBmb3IKPiB0aGUgKmZpcnN0KiBzaWduYWwgaXQgYWRkZWQgdG8g
dGhlIHF1ZXVlLCBhbmQgZG8gdGhlICJwdXRfdXNlcigpIiBmb3IKPiB3aGVuIHJlbW92aW5nIHRo
ZSBsYXN0IHNpZ25hbC4gRXhhY3RseSBiZWNhdXNlIHRob3NlIGF0b21pY3MgYXJlIHZlcnkKPiBl
eHBlbnNpdmUuCj4gCj4gVGhlIG5ldyBjb2RlIGp1c3QgZG9lcyBhIGxvdCBvZiB0aGVzZSBhdG9t
aWNzIHVuY29uZGl0aW9uYWxseS4KClllcyBhbmQgcmlnaHQgbm93IEknbSB0cnlpbmcgdG8gcmV3
cml0ZSB0aGlzIHBhdGNoLgoKPiBJIGR1bm5vLiBUaGUgcHJvZmlsZSBkYXRhIGluIHRoZXJlIGlz
IGEgYml0IGhhcmQgdG8gcmVhZCwgYnV0IHRoZXJlJ3MKPiBhIGxvdCBtb3JlIGNhY2hlZSBtaXNz
ZXMsIGFuZCBhICpsb3QqIG9mIG5vZGUgY3Jvc3NlcnM6Cj4gCj4gPiAgICA1OTYxNTQ0ICAgICAg
ICAgICsxOTAuNCUgICAxNzMxNDM2MSAgICAgICAgcGVyZi1zdGF0LmkuY2FjaGUtbWlzc2VzCj4g
PiAgIDIyMTA3NDY2ICAgICAgICAgICsxMTkuMiUgICA0ODQ1NzY1NiAgICAgICAgcGVyZi1zdGF0
LmkuY2FjaGUtcmVmZXJlbmNlcwo+ID4gICAgIDE2MzI5MiDEhSAgMyUgICArNDU4Mi4wJSAgICA3
NjQ1NDEwICAgICAgICBwZXJmLXN0YXQuaS5ub2RlLWxvYWQtbWlzc2VzCj4gPiAgICAgMjI3Mzg4
IMSFICAyJSAgICszNzA4LjglICAgIDg2NjA4MjQgICAgICAgIHBlcmYtc3RhdC5pLm5vZGUtbG9h
ZHMKPiAKPiBhbmQgKHByb2JhYmx5IGFzIGEgcmVzdWx0KSBhdmVyYWdlIGluc3RydWN0aW9uIGNv
c3RzIGhhdmUgZ29uZSB1cCBlbm9ybW91c2x5Ogo+IAo+ID4gICAgICAgMy40NyAgICAgICAgICAg
KzY2LjglICAgICAgIDUuNzkgICAgICAgIHBlcmYtc3RhdC5vdmVyYWxsLmNwaQo+ID4gICAgICAy
Mjg0OSAgICAgICAgICAgLTY1LjYlICAgICAgIDc4NjYgICAgICAgIHBlcmYtc3RhdC5vdmVyYWxs
LmN5Y2xlcy1iZXR3ZWVuLWNhY2hlLW1pc3Nlcwo+IAo+IGFuZCBpdCBkb2VzIHNlZW0gdG8gYmUg
YXQgbGVhc3QgcGFydGx5IGFib3V0ICJwdXRfdWNvdW50cygpIjoKPiAKPiA+ICAgICAgIDAuMDAg
ICAgICAgICAgICArNC41ICAgICAgICA0LjQ2ICAgICAgICBwZXJmLXByb2ZpbGUuY2FsbHRyYWNl
LmN5Y2xlcy1wcC5wdXRfdWNvdW50cy5fX3NpZ3F1ZXVlX2ZyZWUuZ2V0X3NpZ25hbC5hcmNoX2Rv
X3NpZ25hbF9vcl9yZXN0YXJ0LmV4aXRfdG9fdXNlcl9tb2RlX3ByZXBhcmUKPiAKPiBhbmQgYSBs
b3Qgb2YgImdldF91Y291bnRzKCkiLgo+IAo+IEJ1dCBpdCBtYXkgYWxzbyBiZSB0aGF0IHRoZSBu
ZXcgImdldCBzaWdwZW5kaW5nIiBpcyBqdXN0ICpzbyogbXVjaAo+IG1vcmUgZXhwZW5zaXZlIHRo
YW4gaXQgdXNlZCB0byBiZS4KClRoYW5rcyBmb3IgZGVjcnlwdGluZyB0aGlzISBJIHNwZW50IHNv
bWUgdGltZSB0byB1bmRlcnN0YW5kIHRoaXMgcmVwb3J0CmFuZCBzdGlsbCB3YXNuJ3Qgc3VyZSBJ
IHVuZGVyc3Rvb2QgaXQuCgotLSAKUmdyZHMsIGxlZ2lvbgoKX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFp
bmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRh
dGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

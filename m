Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F480C4741F
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 21:59:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C8F372087D
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 21:59:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="ovnhX+qI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8F372087D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 24AF887458;
	Thu, 29 Oct 2020 21:59:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id snVkfAP65zE0; Thu, 29 Oct 2020 21:59:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5962A8733E;
	Thu, 29 Oct 2020 21:59:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3DCB5C088B;
	Thu, 29 Oct 2020 21:59:18 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 56F9CC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:59:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 4A642848A5
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:59:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id WxAJg_cGqPW3
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:59:16 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 54B9084526
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:59:16 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w21so3512984pfc.7
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:59:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amacapital-net.20150623.gappssmtp.com; s=20150623;
 h=content-transfer-encoding:from:mime-version:subject:date:message-id
 :references:cc:in-reply-to:to;
 bh=7mpKGmhk7KbAdNRg8CrtKSJUwgz+Qb8kytsY0ITcAGk=;
 b=ovnhX+qIKiPabZOH4hn59CbnR86mckuEhcSQzDfD4ogDnQOeqgaiDVK+ftwlz4GjBw
 IF1LruixH+2U6xBdFKzvJSsEFdLRlm7NDiQJeYH8lEDgRegvi09Eyiiv8FzMP+YkBG7h
 ErfC2CZ5UKzIDsJHnHHf2T8LL8QH3qahSBYYYcM+SOXYKIjkpy79Ly9naIJkDg8sGB2z
 5bXFt7H0PEyXuS99nQGXBuMc9J66121arDOCzaie84/i+VyFUCX/8Q4tK2WqqJo5rtL0
 KrmO0EobGfrkMQOJZUGWcNnsaI2FFqZ7n7t71N7ySdNYlzkPHlmVRfWSzIMDotoXHJrg
 nPig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:content-transfer-encoding:from:mime-version
 :subject:date:message-id:references:cc:in-reply-to:to;
 bh=7mpKGmhk7KbAdNRg8CrtKSJUwgz+Qb8kytsY0ITcAGk=;
 b=UBhan/rVwAMcP9dGxNSw0at5WmOQPt8nc/SGFSxuIbL9EfFoEK3cZvuHjOFLxSB/D2
 eb5bQlh5XpJkuq71NDM2xG8AHp2PaDWO9fztQ+syJKRAyM5yEblb2s1BqXLAiaK6TRE9
 6HfvYG6WTcIAodxvvQkoPqn7jAXTB1fjVW9wmcm9ShtzQlei8hmhGT92JAt/Gt4JSPQX
 iPQhZG5cXFe+ck0ORhWR5hDg0fJidsGTHvYrX63lh7HN8LBvkA7qQRyZ94MHLZ/H2Lvf
 Y8+sUQngeWX6xIevAwDsnfhGQXFMZoij9ox1PMHkEDBd2xf43eDKr1omeCIRVSDpRPzB
 SAMQ==
X-Gm-Message-State: AOAM530Yi1RMVdbGbtatUN0qAsCfdHXu4RrHfotRHOWJFTBJ2Ny/J8Eb
 H8yvmVw3lbojl6xgF6+7P+fN/g==
X-Google-Smtp-Source: ABdhPJxSWOh4ftHI47KiCrZ0illEdrC1OP4fiqquB1QRs+VL+ywYh7woPj1uc9hDTpndfsW71KZ7Hw==
X-Received: by 2002:a63:1d12:: with SMTP id d18mr5911604pgd.314.1604008755871; 
 Thu, 29 Oct 2020 14:59:15 -0700 (PDT)
Received: from ?IPv6:2600:1012:b011:6d49:b5a8:d1fb:e286:b4a2?
 ([2600:1012:b011:6d49:b5a8:d1fb:e286:b4a2])
 by smtp.gmail.com with ESMTPSA id mp13sm814127pjb.36.2020.10.29.14.59.14
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 29 Oct 2020 14:59:15 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Date: Thu, 29 Oct 2020 14:58:55 -0700
Message-Id: <8E455D54-FED4-4D06-8CB7-FC6291C64259@amacapital.net>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
In-Reply-To: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
X-Mailer: iPhone Mail (18A393)
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <james.bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org, Todd Kjos <tkjos@google.com>
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

Cgo+IE9uIE9jdCAyOCwgMjAyMCwgYXQgNTozNSBQTSwgQ2hyaXN0aWFuIEJyYXVuZXIgPGNocmlz
dGlhbi5icmF1bmVyQHVidW50dS5jb20+IHdyb3RlOgo+IAo+IO+7v0hleSBldmVyeW9uZSwKPiAK
PiBJIHZhbmlzaGVkIGZvciBhIGxpdHRsZSB3aGlsZSB0byBmb2N1cyBvbiB0aGlzIHdvcmsgaGVy
ZSBzbyBzb3JyeSBmb3IKPiBub3QgYmVpbmcgYXZhaWxhYmxlIGJ5IG1haWwgZm9yIGEgd2hpbGUu
Cj4gCj4gU2luY2UgcXVpdGUgYSBsb25nIHRpbWUgd2UgaGF2ZSBpc3N1ZXMgd2l0aCBzaGFyaW5n
IG1vdW50cyBiZXR3ZWVuCj4gbXVsdGlwbGUgdW5wcml2aWxlZ2VkIGNvbnRhaW5lcnMgd2l0aCBk
aWZmZXJlbnQgaWQgbWFwcGluZ3MsIHNoYXJpbmcgYQo+IHJvb3RmcyBiZXR3ZWVuIG11bHRpcGxl
IGNvbnRhaW5lcnMgd2l0aCBkaWZmZXJlbnQgaWQgbWFwcGluZ3MsIGFuZCBhbHNvCj4gc2hhcmlu
ZyByZWd1bGFyIGRpcmVjdG9yaWVzIGFuZCBmaWxlc3lzdGVtcyBiZXR3ZWVuIHVzZXJzIHdpdGgg
ZGlmZmVyZW50Cj4gdWlkcyBhbmQgZ2lkcy4gVGhlIGxhdHRlciB1c2UtY2FzZXMgaGF2ZSBiZWNv
bWUgZXZlbiBtb3JlIGltcG9ydGFudCB3aXRoCj4gdGhlIGF2YWlsYWJpbGl0eSBhbmQgYWRvcHRp
b24gb2Ygc3lzdGVtZC1ob21lZCAoY2YuIFsxXSkgdG8gaW1wbGVtZW50Cj4gcG9ydGFibGUgaG9t
ZSBkaXJlY3Rvcmllcy4KPiAKPiBUaGUgc29sdXRpb25zIHdlIGhhdmUgdHJpZWQgYW5kIHByb3Bv
c2VkIHNvIGZhciBpbmNsdWRlIHRoZSBpbnRyb2R1Y3Rpb24KPiBvZiBmc2lkIG1hcHBpbmdzLCBh
IHRpbnkgb3ZlcmxheSBiYXNlZCBmaWxlc3lzdGVtLCBhbmQgYW4gYXBwcm9hY2ggdG8KPiBjYWxs
IG92ZXJyaWRlIGNyZWRzIGluIHRoZSB2ZnMuIE5vbmUgb2YgdGhlc2Ugc29sdXRpb25zIGhhdmUg
Y292ZXJlZCBhbGwKPiBvZiB0aGUgYWJvdmUgdXNlLWNhc2VzLgo+IAo+IFRoZSBzb2x1dGlvbiBw
cm9wb3NlZCBoZXJlIGhhcyBpdCdzIG9yaWdpbnMgaW4gbXVsdGlwbGUgZGlzY3Vzc2lvbnMKPiBk
dXJpbmcgTGludXggUGx1bWJlcnMgMjAxNyBkdXJpbmcgYW5kIGFmdGVyIHRoZSBlbmQgb2YgdGhl
IGNvbnRhaW5lcnMKPiBtaWNyb2NvbmZlcmVuY2UuCj4gVG8gdGhlIGJlc3Qgb2YgbXkga25vd2xl
ZGdlIHRoaXMgaW52b2x2ZWQgQWxla3NhLCBTdMOpcGhhbmUsIEVyaWMsIERhdmlkLAo+IEphbWVz
LCBhbmQgbXlzZWxmLiBBIHZhcmlhbnQgb2YgdGhlIHNvbHV0aW9uIHByb3Bvc2VkIGhlcmUgaGFz
IGFsc28gYmVlbgo+IGRpc2N1c3NlZCwgYWdhaW4gdG8gdGhlIGJlc3Qgb2YgbXkga25vd2xlZGdl
LCBhZnRlciBhIExpbnV4IGNvbmZlcmVuY2UKPiBpbiBTdC4gUGV0ZXJzYnVyZyBpbiBSdXNzaWEg
YmV0d2VlbiBDaHJpc3RvcGgsIFR5Y2hvLCBhbmQgbXlzZWxmIGluIDIwMTcKPiBhZnRlciBMaW51
eCBQbHVtYmVycy4KPiBJJ3ZlIHRha2VuIHRoZSB0aW1lIHRvIGZpbmFsbHkgaW1wbGVtZW50IGEg
d29ya2luZyB2ZXJzaW9uIG9mIHRoaXMKPiBzb2x1dGlvbiBvdmVyIHRoZSBsYXN0IHdlZWtzIHRv
IHRoZSBiZXN0IG9mIG15IGFiaWxpdGllcy4gVHljaG8gaGFzCj4gc2lnbmVkIHVwIGZvciB0aGlz
IHNsaWd0aGx5IGNyYXp5IGVuZGVhdm91ciBhcyB3ZWxsIGFuZCBoZSBoYXMgaGVscGVkCj4gd2l0
aCB0aGUgY29udmVyc2lvbiBvZiB0aGUgeGF0dHIgY29kZXBhdGhzLgo+IAo+IFRoZSBjb3JlIGlk
ZWEgaXMgdG8gbWFrZSBpZG1hcHBpbmdzIGEgcHJvcGVydHkgb2Ygc3RydWN0IHZmc21vdW50Cj4g
aW5zdGVhZCBvZiB0eWluZyBpdCB0byBhIHByb2Nlc3MgYmVpbmcgaW5zaWRlIG9mIGEgdXNlciBu
YW1lc3BhY2Ugd2hpY2gKPiBoYXMgYmVlbiB0aGUgY2FzZSBmb3IgYWxsIG90aGVyIHByb3Bvc2Vk
IGFwcHJvYWNoZXMuCj4gSXQgbWVhbnMgdGhhdCBpZG1hcHBpbmdzIGJlY29tZSBhIHByb3BlcnR5
IG9mIGJpbmQtbW91bnRzLCBpLmUuIGVhY2gKPiBiaW5kLW1vdW50IGNhbiBoYXZlIGEgc2VwYXJh
dGUgaWRtYXBwaW5nLiBUaGlzIGhhcyB0aGUgb2J2aW91cyBhZHZhbnRhZ2UKPiB0aGF0IGlkbWFw
cGVkIG1vdW50cyBjYW4gYmUgY3JlYXRlZCBpbnNpZGUgb2YgdGhlIGluaXRpYWwgdXNlcgo+IG5h
bWVzcGFjZSwgaS5lLiBvbiB0aGUgaG9zdCBpdHNlbGYgaW5zdGVhZCBvZiByZXF1aXJpbmcgdGhl
IGNhbGxlciB0byBiZQo+IGxvY2F0ZWQgaW5zaWRlIG9mIGEgdXNlciBuYW1lc3BhY2UuIFRoaXMg
ZW5hYmxlcyBzdWNoIHVzZS1jYXNlcyBhcyBlLmcuCj4gbWFraW5nIGEgdXNiIHN0aWNrIGF2YWls
YWJsZSBpbiBtdWx0aXBsZSBsb2NhdGlvbnMgd2l0aCBkaWZmZXJlbnQKPiBpZG1hcHBpbmdzIChz
ZWUgdGhlIHZmYXQgcG9ydCB0aGF0IGlzIHBhcnQgb2YgdGhpcyBwYXRjaCBzZXJpZXMpLgo+IAo+
IFRoZSB2ZnNtb3VudCBzdHJ1Y3QgZ2FpbnMgYSBuZXcgc3RydWN0IHVzZXJfbmFtZXNwYWNlIG1l
bWJlci4gVGhlCj4gaWRtYXBwaW5nIG9mIHRoZSB1c2VyIG5hbWVzcGFjZSBiZWNvbWVzIHRoZSBp
ZG1hcHBpbmcgb2YgdGhlIG1vdW50LiBBCj4gY2FsbGVyIHRoYXQgaXMgZWl0aGVyIHByaXZpbGVn
ZWQgd2l0aCByZXNwZWN0IHRvIHRoZSB1c2VyIG5hbWVzcGFjZSBvZgo+IHRoZSBzdXBlcmJsb2Nr
IG9mIHRoZSB1bmRlcmx5aW5nIGZpbGVzeXN0ZW0gb3IgYSBjYWxsZXIgdGhhdCBpcwo+IHByaXZp
bGVnZWQgd2l0aCByZXNwZWN0IHRvIHRoZSB1c2VyIG5hbWVzcGFjZSBhIG1vdW50IGhhcyBiZWVu
IGlkbWFwcGVkCj4gd2l0aCBjYW4gY3JlYXRlIGEgbmV3IGJpbmQtbW91bnQgYW5kIG1hcmsgaXQg
d2l0aCBhIHVzZXIgbmFtZXNwYWNlLgoKU28gb25lIHdheSBvZiB0aGlua2luZyBhYm91dCB0aGlz
IGlzIHRoYXQgYSB1c2VyIG5hbWVzcGFjZSB0aGF0IGhhcyBhbiBpZG1hcHBlZCBtb3VudCBjYW4s
IGVmZmVjdGl2ZWx5LCBjcmVhdGUgb3IgY2hvd24gZmlsZXMgd2l0aCAqYW55KiBvbi1kaXNrIHVp
ZCBvciBnaWQgYnkgZG9pbmcgaXQgZGlyZWN0bHkgKGlmIHRoYXQgdWlkIGV4aXN0cyBpbi1uYW1l
c3BhY2UsIHdoaWNoIGlzIGxpa2VseSBmb3IgaW50ZXJlc3RpbmcgaWRzIGxpa2UgMCkgb3IgYnkg
Y3JlYXRpbmcgYSBuZXcgdXNlcm5zIHdpdGggdGhhdCBpZCBpbnNpZGUuCgpGb3IgYSBmaWxlIHN5
c3RlbSB0aGF0IGlzIHByaXZhdGUgdG8gYSBjb250YWluZXIsIHRoaXMgc2VlbXMgbW9kZXJhdGVs
eSBzYWZlLCBhbHRob3VnaCB0aGlzIG1heSBkZXBlbmQgb24gd2hhdCBleGFjdGx5IOKAnHByaXZh
dGXigJ0gbWVhbnMuIFdlIHByb2JhYmx5IHdhbnQgYSBtZWNoYW5pc20gc3VjaCB0aGF0LCBpZiB5
b3UgYXJlIG91dHNpZGUgdGhlIG5hbWVzcGFjZSwgYSByZWZlcmVuY2UgdG8gYSBmaWxlIHdpdGgg
dGhlIG5hbWVzcGFjZeKAmXMgdmZzbW50IGRvZXMgbm90IGNvbmZlciBzdWlkIHByaXZpbGVnZS4K
CkltYWdpbmUgdGhlIGZvbGxvd2luZyBhdHRhY2s6IHVzZXIgY3JlYXRlcyBhIG5hbWVzcGFjZSB3
aXRoIGEgcm9vdCB1c2VyIGFuZCBhcnJhbmdlcyB0byBnZXQgYW4gaWRtYXBwZWQgZnMsIGUuZy4g
YnkgaW5zZXJ0aW5nIGFuIGV4dDQgdXNiIHN0aWNrIG9yIHVzaW5nIHdoYXRldmVyIGNvbnRhaW5l
ciBtYW5hZ2VtZW50IHRvb2wgZG9lcyB0aGlzLiAgSW5zaWRlIHRoZSBuYW1lc3BhY2UsIHRoZSB1
c2VyIGNyZWF0ZXMgYSBzdWlkLXJvb3QgZmlsZS4KCk5vdywgb3V0c2lkZSB0aGUgbmFtZXNwYWNl
LCB0aGUgdXNlciBoYXMgcHJpdmlsZWdlIG92ZXIgdGhlIG5hbWVzcGFjZS4gIChJ4oCZbSBhc3N1
bWluZyB0aGVyZSBpcyBzb21lIHRvb2wgdGhhdCB3aWxsIGlkbWFwIHRoaW5ncyBpbiBhIG5hbWVz
cGFjZSBvd25lZCBieSBhbiB1bnByaXZpbGVnZWQgdXNlciwgd2hpY2ggc2VlbXMgbGlrZWx5Liku
IFNvIHRoZSB1c2VyIG1ha2VzIGEgbmV3IGJpbmQgbW91bnQgYW5kIGlmIG1hcHMgaXQgdG8gdGhl
IGluaXQgbmFtZXNwYWNlLiBHYW1lIG92ZXIuCgpTbyBJIHRoaW5rIHdlIG5lZWQgdG8gaGF2ZSBz
b21lIGNvbnRyb2wgdG8gbWl0aWdhdGUgdGhpcyBpbiBhIGNvbXByZWhlbnNpYmxlIHdheS4gQSBi
aWcgaGFtbWVyIHdvdWxkIGJlIHRvIHJlcXVpcmUgbm9zdWlkLiBBIHNtYWxsZXIgaGFtbWVyIG1p
Z2h0IGJlIHRvIHNheSB0aGF0IHlvdSBjYW7igJl0IGNyZWF0ZSBhIG5ldyBpZG1hcHBlZCBtb3Vu
dCB1bmxlc3MgeW91IGhhdmUgcHJpdmlsZWdlIG92ZXIgdGhlIHVzZXJucyB0aGF0IHlvdSB3YW50
IHRvIHVzZSBmb3IgdGhlIGlkbWFwIGFuZCB0byBzYXkgdGhhdCBhIHZmc21udOKAmXMgcGF0aHMg
ZG9u4oCZdCBkbyBzdWlkIG91dHNpZGUgdGhlIGlkbWFwIG5hbWVzcGFjZS4gIFdlIGFscmVhZHkg
ZG8gdGhlIGxhdHRlciBmb3IgdGhlIHZmc21udOKAmXMgbW50bnPigJlzIHVzZXJucy4KCkhtbS4g
IFdoYXQgaGFwcGVucyBpZiB3ZSByZXF1aXJlIHRoYXQgYW4gaWRtYXAgdXNlcm5zIGVxdWFsIHRo
ZSB2ZnNtbnTigJlzIG1udG5z4oCZcyB1c2VybnM/ICBJcyB0aGF0IHRvbyBsaW1pdGluZz8KCkkg
aG9wZSB0aGF0IHdoYXRldmVyIHNvbHV0aW9uIGdldHMgdXNlZCBpcyBzdHJhaWdodGZvcndhcmQg
ZW5vdWdoIHRvIHdyYXAgb25l4oCZcyBoZWFkIGFyb3VuZC4KCj4gV2hlbiBhIGZpbGUvaW5vZGUg
aXMgYWNjZXNzZWQgdGhyb3VnaCBhbiBpZG1hcHBlZCBtb3VudCB0aGUgaV91aWQgYW5kCj4gaV9n
aWQgb2YgdGhlIGlub2RlIHdpbGwgYmUgcmVtYXBwZWQgYWNjb3JkaW5nIHRvIHRoZSB1c2VyIG5h
bWVzcGFjZSB0aGUKPiBtb3VudCBoYXMgYmVlbiBtYXJrZWQgd2l0aC4gV2hlbiBhIG5ldyBvYmpl
Y3QgaXMgY3JlYXRlZCBiYXNlZCBvbiB0aGUKPiBmc3VpZCBhbmQgZnNnaWQgb2YgdGhlIGNhbGxl
ciB0aGV5IHdpbGwgc2ltaWxhcmx5IGJlIHJlbWFwcGVkIGFjY29yZGluZwo+IHRvIHRoZSB1c2Vy
IG5hbWVzcGFjZSBvZiB0aGUgbW91bnQgdGhleSBjYXJlIGNyZWF0ZWQgZnJvbS4KCkJ5IOKAnG1h
cHBlZCBhY2NvcmRpbmcgdG/igJ0sIEkgcHJlc3VtZSB5b3UgbWVhbiB0aGF0IHRoZSBvbi1kaXNr
IHVpZC9naWQgaXMgdGhlIGdpZCBhcyBzZWVuIGluIHRoZSB1c2VyIG5hbWVzcGFjZSBpbiBxdWVz
dGlvbi4KCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpD
b250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24u
b3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Nv
bnRhaW5lcnM=

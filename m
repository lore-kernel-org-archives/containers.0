Return-Path: <SRS0=uLXG=FI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 257D3C4361A
	for <containers@archiver.kernel.org>; Fri,  4 Dec 2020 00:13:27 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AEB3922224
	for <containers@archiver.kernel.org>; Fri,  4 Dec 2020 00:13:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEB3922224
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 82F4787C2D;
	Fri,  4 Dec 2020 00:13:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ERGUz5nblUrv; Fri,  4 Dec 2020 00:13:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B5CB487C29;
	Fri,  4 Dec 2020 00:13:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B080AC163C;
	Fri,  4 Dec 2020 00:13:25 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B90DEC0FA7
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:13:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id A8470878BA
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:13:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hyxYbsXONvfB
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:13:23 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id D786E878A6
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:13:22 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kkyYC-0007ka-U4; Fri, 04 Dec 2020 00:02:17 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v4 34/40] fat: handle idmapped mounts
Date: Fri,  4 Dec 2020 00:57:30 +0100
Message-Id: <20201203235736.3528991-35-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201203235736.3528991-1-christian.brauner@ubuntu.com>
References: <20201203235736.3528991-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 linux-security-module@vger.kernel.org,
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

TGV0IGZhdCBoYW5kbGUgaWRtYXBwZWQgbW91bnRzLiBUaGlzIGFsbG93cyB0byBoYXZlIHRoZSBz
YW1lIGZhdCBtb3VudAphcHBlYXIgaW4gbXVsdGlwbGUgbG9jYXRpb25zIHdpdGggZGlmZmVyZW50
IGlkIG1hcHBpbmdzLiBUaGlzIGFsbG93cyB0bwpleHBvc2UgYSB2ZmF0IGZvcm1hdHRlZCBVU0Ig
c3RpY2sgdG8gbXVsdGlwbGUgdXNlciB3aXRoIGRpZmZlcmVudCBpZHMgb24KdGhlIGhvc3Qgb3Ig
aW4gdXNlciBuYW1lc3BhY2VzIGFsbG93aW5nIGZvciBkYWMgcGVybWlzc2lvbnM6Cgptb3VudCAt
byB1aWQ9MTAwMCxnaWQ9MTAwMCAvZGV2L3NkYiAvbW50Cgp1MTAwMUBmMi12bTovbG93ZXIxJCBs
cyAtbG4gL21udC8KdG90YWwgNAotcnd4ci14ci14IDEgMTAwMCAxMDAwIDQgT2N0IDI4IDAzOjQ0
IGFhYQotcnd4ci14ci14IDEgMTAwMCAxMDAwIDAgT2N0IDI4IDAxOjA5IGJiYgotcnd4ci14ci14
IDEgMTAwMCAxMDAwIDAgT2N0IDI4IDAxOjEwIGNjYwotcnd4ci14ci14IDEgMTAwMCAxMDAwIDAg
T2N0IDI4IDAzOjQ2IGRkZAotcnd4ci14ci14IDEgMTAwMCAxMDAwIDAgT2N0IDI4IDA0OjAxIGVl
ZQoKbW91bnQtaWRtYXBwZWQgLS1tYXAtbW91bnQgYjoxMDAwOjEwMDE6MQoKdTEwMDFAZjItdm06
L2xvd2VyMSQgbHMgLWxuIC9sb3dlcjEvCnRvdGFsIDQKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSA0
IE9jdCAyOCAwMzo0NCBhYWEKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSAwIE9jdCAyOCAwMTowOSBi
YmIKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSAwIE9jdCAyOCAwMToxMCBjY2MKLXJ3eHIteHIteCAx
IDEwMDEgMTAwMSAwIE9jdCAyOCAwMzo0NiBkZGQKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSAwIE9j
dCAyOCAwNDowMSBlZWUKCnUxMDAxQGYyLXZtOi9sb3dlcjEkIHRvdWNoIC9sb3dlcjEvZmZmCgp1
MTAwMUBmMi12bTovbG93ZXIxJCBscyAtbG4gL2xvd2VyMS9mZmYKLXJ3eHIteHIteCAxIDEwMDEg
MTAwMSAwIE9jdCAyOCAwNDowMyAvbG93ZXIxL2ZmZgoKdTEwMDFAZjItdm06L2xvd2VyMSQgbHMg
LWxuIC9tbnQvZmZmCi1yd3hyLXhyLXggMSAxMDAwIDEwMDAgMCBPY3QgMjggMDQ6MDMgL21udC9m
ZmYKCkNjOiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4KQ2M6IERhdmlkIEhvd2VsbHMg
PGRob3dlbGxzQHJlZGhhdC5jb20+CkNjOiBBbCBWaXJvIDx2aXJvQHplbml2LmxpbnV4Lm9yZy51
az4KQ2M6IGxpbnV4LWZzZGV2ZWxAdmdlci5rZXJuZWwub3JnClNpZ25lZC1vZmYtYnk6IENocmlz
dGlhbiBCcmF1bmVyIDxjaHJpc3RpYW4uYnJhdW5lckB1YnVudHUuY29tPgotLS0KLyogdjIgKi8K
dW5jaGFuZ2VkCgovKiB2MyAqLwp1bmNoYW5nZWQKCi8qIHY0ICovCi0gTWF1cmljaW8gVsOhc3F1
ZXogQmVybmFsIDxtYXVyaWNpb0BraW52b2xrLmlvPjoKICAtIEZpeCBtb3VudCBleGFtcGxlIGlu
IGNvbW1pdCBtZXNzYWdlLgoKLSBTZXJnZSBIYWxseW4gPHNlcmdlQGhhbGx5bi5jb20+OgogIC0g
VXNlICJtbnRfdXNlcm5zIiB0byByZWZlciB0byBhIHZmc21vdW50J3MgdXNlcm5zIGV2ZXJ5d2hl
cmUgdG8gbWFrZQogICAgdGVybWlub2xvZ3kgY29uc2lzdGVudC4KLS0tCiBmcy9mYXQvZmlsZS5j
ICAgICAgICB8IDE1ICsrKysrKysrLS0tLS0tLQogZnMvZmF0L25hbWVpX21zZG9zLmMgfCAgMiAr
LQogZnMvZmF0L25hbWVpX3ZmYXQuYyAgfCAgMiArLQogMyBmaWxlcyBjaGFuZ2VkLCAxMCBpbnNl
cnRpb25zKCspLCA5IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2ZzL2ZhdC9maWxlLmMgYi9m
cy9mYXQvZmlsZS5jCmluZGV4IDczYWNkMDg0M2Q5Mi4uNmE2MThlOTQ1MGM4IDEwMDY0NAotLS0g
YS9mcy9mYXQvZmlsZS5jCisrKyBiL2ZzL2ZhdC9maWxlLmMKQEAgLTM5OCw3ICszOTgsNyBAQCBp
bnQgZmF0X2dldGF0dHIoc3RydWN0IHVzZXJfbmFtZXNwYWNlICptbnRfdXNlcm5zLCBjb25zdCBz
dHJ1Y3QgcGF0aCAqcGF0aCwKIAkJc3RydWN0IGtzdGF0ICpzdGF0LCB1MzIgcmVxdWVzdF9tYXNr
LCB1bnNpZ25lZCBpbnQgZmxhZ3MpCiB7CiAJc3RydWN0IGlub2RlICppbm9kZSA9IGRfaW5vZGUo
cGF0aC0+ZGVudHJ5KTsKLQlnZW5lcmljX2ZpbGxhdHRyKCZpbml0X3VzZXJfbnMsIGlub2RlLCBz
dGF0KTsKKwlnZW5lcmljX2ZpbGxhdHRyKG1udF91c2VybnMsIGlub2RlLCBzdGF0KTsKIAlzdGF0
LT5ibGtzaXplID0gTVNET1NfU0IoaW5vZGUtPmlfc2IpLT5jbHVzdGVyX3NpemU7CiAKIAlpZiAo
TVNET1NfU0IoaW5vZGUtPmlfc2IpLT5vcHRpb25zLm5mcyA9PSBGQVRfTkZTX05PU1RBTEVfUk8p
IHsKQEAgLTQ0NywxMiArNDQ3LDEzIEBAIHN0YXRpYyBpbnQgZmF0X3Nhbml0aXplX21vZGUoY29u
c3Qgc3RydWN0IG1zZG9zX3NiX2luZm8gKnNiaSwKIAlyZXR1cm4gMDsKIH0KIAotc3RhdGljIGlu
dCBmYXRfYWxsb3dfc2V0X3RpbWUoc3RydWN0IG1zZG9zX3NiX2luZm8gKnNiaSwgc3RydWN0IGlu
b2RlICppbm9kZSkKK3N0YXRpYyBpbnQgZmF0X2FsbG93X3NldF90aW1lKHN0cnVjdCB1c2VyX25h
bWVzcGFjZSAqbW50X3VzZXJucywKKwkJCSAgICAgIHN0cnVjdCBtc2Rvc19zYl9pbmZvICpzYmks
IHN0cnVjdCBpbm9kZSAqaW5vZGUpCiB7CiAJdW1vZGVfdCBhbGxvd191dGltZSA9IHNiaS0+b3B0
aW9ucy5hbGxvd191dGltZTsKIAotCWlmICghdWlkX2VxKGN1cnJlbnRfZnN1aWQoKSwgaW5vZGUt
PmlfdWlkKSkgewotCQlpZiAoaW5fZ3JvdXBfcChpbm9kZS0+aV9naWQpKQorCWlmICghdWlkX2Vx
KGN1cnJlbnRfZnN1aWQoKSwgaV91aWRfaW50b19tbnQobW50X3VzZXJucywgaW5vZGUpKSkgewor
CQlpZiAoaW5fZ3JvdXBfcChpX2dpZF9pbnRvX21udChtbnRfdXNlcm5zLCBpbm9kZSkpKQogCQkJ
YWxsb3dfdXRpbWUgPj49IDM7CiAJCWlmIChhbGxvd191dGltZSAmIE1BWV9XUklURSkKIAkJCXJl
dHVybiAxOwpAQCAtNDc3LDExICs0NzgsMTEgQEAgaW50IGZhdF9zZXRhdHRyKHN0cnVjdCB1c2Vy
X25hbWVzcGFjZSAqbW50X3VzZXJucywgc3RydWN0IGRlbnRyeSAqZGVudHJ5LAogCS8qIENoZWNr
IGZvciBzZXR0aW5nIHRoZSBpbm9kZSB0aW1lLiAqLwogCWlhX3ZhbGlkID0gYXR0ci0+aWFfdmFs
aWQ7CiAJaWYgKGlhX3ZhbGlkICYgVElNRVNfU0VUX0ZMQUdTKSB7Ci0JCWlmIChmYXRfYWxsb3df
c2V0X3RpbWUoc2JpLCBpbm9kZSkpCisJCWlmIChmYXRfYWxsb3dfc2V0X3RpbWUobW50X3VzZXJu
cywgc2JpLCBpbm9kZSkpCiAJCQlhdHRyLT5pYV92YWxpZCAmPSB+VElNRVNfU0VUX0ZMQUdTOwog
CX0KIAotCWVycm9yID0gc2V0YXR0cl9wcmVwYXJlKCZpbml0X3VzZXJfbnMsIGRlbnRyeSwgYXR0
cik7CisJZXJyb3IgPSBzZXRhdHRyX3ByZXBhcmUobW50X3VzZXJucywgZGVudHJ5LCBhdHRyKTsK
IAlhdHRyLT5pYV92YWxpZCA9IGlhX3ZhbGlkOwogCWlmIChlcnJvcikgewogCQlpZiAoc2JpLT5v
cHRpb25zLnF1aWV0KQpAQCAtNTUxLDcgKzU1Miw3IEBAIGludCBmYXRfc2V0YXR0cihzdHJ1Y3Qg
dXNlcl9uYW1lc3BhY2UgKm1udF91c2VybnMsIHN0cnVjdCBkZW50cnkgKmRlbnRyeSwKIAkJZmF0
X3RydW5jYXRlX3RpbWUoaW5vZGUsICZhdHRyLT5pYV9tdGltZSwgU19NVElNRSk7CiAJYXR0ci0+
aWFfdmFsaWQgJj0gfihBVFRSX0FUSU1FfEFUVFJfQ1RJTUV8QVRUUl9NVElNRSk7CiAKLQlzZXRh
dHRyX2NvcHkoJmluaXRfdXNlcl9ucywgaW5vZGUsIGF0dHIpOworCXNldGF0dHJfY29weShtbnRf
dXNlcm5zLCBpbm9kZSwgYXR0cik7CiAJbWFya19pbm9kZV9kaXJ0eShpbm9kZSk7CiBvdXQ6CiAJ
cmV0dXJuIGVycm9yOwpkaWZmIC0tZ2l0IGEvZnMvZmF0L25hbWVpX21zZG9zLmMgYi9mcy9mYXQv
bmFtZWlfbXNkb3MuYwppbmRleCBhOGYzMzc1ZDlkMTAuLmVmYmEzMDFkNjhhZSAxMDA2NDQKLS0t
IGEvZnMvZmF0L25hbWVpX21zZG9zLmMKKysrIGIvZnMvZmF0L25hbWVpX21zZG9zLmMKQEAgLTY2
Nyw3ICs2NjcsNyBAQCBzdGF0aWMgc3RydWN0IGZpbGVfc3lzdGVtX3R5cGUgbXNkb3NfZnNfdHlw
ZSA9IHsKIAkubmFtZQkJPSAibXNkb3MiLAogCS5tb3VudAkJPSBtc2Rvc19tb3VudCwKIAkua2ls
bF9zYgk9IGtpbGxfYmxvY2tfc3VwZXIsCi0JLmZzX2ZsYWdzCT0gRlNfUkVRVUlSRVNfREVWLAor
CS5mc19mbGFncwk9IEZTX1JFUVVJUkVTX0RFViB8IEZTX0FMTE9XX0lETUFQLAogfTsKIE1PRFVM
RV9BTElBU19GUygibXNkb3MiKTsKIApkaWZmIC0tZ2l0IGEvZnMvZmF0L25hbWVpX3ZmYXQuYyBi
L2ZzL2ZhdC9uYW1laV92ZmF0LmMKaW5kZXggMjM5MzZlY2Y3OWE1Li41MzY5ZDgyZTBiZmIgMTAw
NjQ0Ci0tLSBhL2ZzL2ZhdC9uYW1laV92ZmF0LmMKKysrIGIvZnMvZmF0L25hbWVpX3ZmYXQuYwpA
QCAtMTA2Myw3ICsxMDYzLDcgQEAgc3RhdGljIHN0cnVjdCBmaWxlX3N5c3RlbV90eXBlIHZmYXRf
ZnNfdHlwZSA9IHsKIAkubmFtZQkJPSAidmZhdCIsCiAJLm1vdW50CQk9IHZmYXRfbW91bnQsCiAJ
LmtpbGxfc2IJPSBraWxsX2Jsb2NrX3N1cGVyLAotCS5mc19mbGFncwk9IEZTX1JFUVVJUkVTX0RF
ViwKKwkuZnNfZmxhZ3MJPSBGU19SRVFVSVJFU19ERVYgfCBGU19BTExPV19JRE1BUCwKIH07CiBN
T0RVTEVfQUxJQVNfRlMoInZmYXQiKTsKIAotLSAKMi4yOS4yCgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250
YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3Vu
ZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

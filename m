From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 2/4] Keep nr_dentry per super block
Date: Sun, 14 Aug 2011 19:38:42 +0200
Message-ID: <1313343522.2798.11.camel__32014.1911543489$1313343601$gmane$org@edumazet-laptop>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1313334832-1150-3-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

TGUgZGltYW5jaGUgMTQgYW/Du3QgMjAxMSDDoCAxOToxMyArMDQwMCwgR2xhdWJlciBDb3N0YSBh
IMOpY3JpdCA6Cj4gTm93IHRoYXQgd2UgaGF2ZSBwZXItc2Igc2hyaW5rZXJzLCBpdCBtYWtlcyBz
ZW5zZSB0byBoYXZlIG5yX2RlbnRyaWVzCj4gc3RvcmVkIHBlciBzYiBhcyB3ZWxsLiBXZSB0dXJu
IHRoZW0gaW50byBwZXItY3B1IGNvdW50ZXJzIHNvIHdlIGNhbgo+IGtlZXAgYWNlc3NpbmcgdGhl
bSB3aXRob3V0IGxvY2tpbmcuCj4gCj4gU2lnbmVkLW9mZi1ieTogR2xhdWJlciBDb3N0YSA8Z2xv
bW1lckBwYXJhbGxlbHMuY29tPgoKPiAgfQo+IGRpZmYgLS1naXQgYS9mcy9zdXBlci5jIGIvZnMv
c3VwZXIuYwo+IGluZGV4IDNmNTZhMjYuLmU5NWFjNGYgMTAwNjQ0Cj4gLS0tIGEvZnMvc3VwZXIu
Ywo+ICsrKyBiL2ZzL3N1cGVyLmMKPiBAQCAtMTE5LDYgKzExOSw5IEBAIHN0YXRpYyBzdHJ1Y3Qg
c3VwZXJfYmxvY2sgKmFsbG9jX3N1cGVyKHN0cnVjdCBmaWxlX3N5c3RlbV90eXBlICp0eXBlKQo+
ICAJCQlzID0gTlVMTDsKPiAgCQkJZ290byBvdXQ7Cj4gIAkJfQo+ICsKPiArCQlwZXJjcHVfY291
bnRlcl9pbml0KCZzLT5zX25yX2RlbnRyeSwgMCk7Cj4gKwoKWW91IHNob3VsZCB0YWtlIGNhcmUg
b2YgcG9zc2libGUgZXJyb3IgcmV0dXJuIGF0IHRoaXMgcG9pbnQuCgooV2UgcHJvYmFibHkgc2hv
dWxkIGNoZWNrIHRoZSBwZXJjcHVfY291bnRlcl9pbml0KCkgZG9uZSBpbiB0Y3BfaW5pdCgpLApi
dXQgdGhleSBhcmUgZG9uZSBhdCBib290IHRpbWUsIHdpdGggbmVhcmx5IG5vIGNoYW5jZSBvZiBm
YWlsdXJlKQoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRp
b24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5m
by9jb250YWluZXJz

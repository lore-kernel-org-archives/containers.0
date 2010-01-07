From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for
	notifications
Date: Thu, 7 Jan 2010 14:36:29 +0200
Message-ID: <cc557aab1001070436w446ef85n55dd2af5e733f55e__48518.7667342418$1262867906$gmane$org@mail.gmail.com>
References: <cover.1262186097.git.kirill@shutemov.name>
	<9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
	<6599ad831001061701x72098dacn7a5d916418396e33@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad831001061701x72098dacn7a5d916418396e33-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVGh1LCBKYW4gNywgMjAxMCBhdCAzOjAxIEFNLCBQYXVsIE1lbmFnZSA8bWVuYWdlQGdvb2ds
ZS5jb20+IHdyb3RlOgo+IE9uIFdlZCwgRGVjIDMwLCAyMDA5IGF0IDc6NTcgQU0sIEtpcmlsbCBB
LiBTaHV0ZW1vdgo+IDxraXJpbGxAc2h1dGVtb3YubmFtZT4gd3JvdGU6Cj4+ICsKPj4gKyDCoCDC
oCDCoCBpZiAoIUlTX0VSUihlZmlsZSkpCj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgZnB1dChl
ZmlsZSk7Cj4KPiBXaGlsZSB0aGlzIGlzIE9LIGN1cnJlbnRseSwgaXQncyBhIGJpdCBmcmFnaWxl
LiBlZmlsZSBzdGFydHMgYXMgTlVMTCwKPiBhbmQgSVNfRVJSKE5VTEwpIGlzIGZhbHNlLiBTbyBp
ZiB3ZSBqdW1wIHRvIGZhaWw6IGJlZm9yZSB0cnlpbmcgdG8gZG8KPiB0aGUgZXZlbnRmZF9mZ2V0
KCkgdGhlbiB3ZSdsbCB0cnkgdG8gZnB1dChOVUxMKSwgd2hpY2ggd2lsbCBvb3BzLiBUaGlzCj4g
d29ya3MgYmVjYXVzZSB3ZSBkb24ndCBjdXJyZW50bHkganVtcCB0byBmYWlsOiB1bnRpbCBhZnRl
cgo+IGV2ZW50ZmRfZmdldCgpLCBidXQgc29tZW9uZSBjb3VsZCBhZGQgYW4gZXh0cmEgc2V0dXAg
c3RlcCBiZXR3ZWVuIHRoZQo+IGt6YWxsb2MoKSBhbmQgdGhlIGV2ZW50ZmRfZmdldCgpIHdoaWNo
IGNvdWxkIGZhaWwuCgpTbyB3ZSBuZWVkIHRvIHVzZSBJU19FUlJfT1JfTlVMTCBoZXJlIGluc3Ry
ZWFkIG9mIElTX0VSUiwgZG9uJ3Qgd2U/Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMu
bGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

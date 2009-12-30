From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH v4 4/4] memcg: implement memory thresholds
Date: Wed, 30 Dec 2009 15:03:25 +0200
Message-ID: <cc557aab0912300503o68035872uedab7f840205b7a3__16273.9879255698$1262178271$gmane$org@mail.gmail.com>
References: <cover.1261858972.git.kirill@shutemov.name>
	<3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
	<59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
	<c2379f3965225b6d62e64c64f8c0e67fee085d7f.1261858972.git.kirill@shutemov.name>
	<7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
	<20091228134245.8db992d1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091228134245.8db992d1.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gTW9uLCBEZWMgMjgsIDIwMDkgYXQgNjo0MiBBTSwgRGFpc3VrZSBOaXNoaW11cmEKPG5pc2hp
bXVyYUBteHAubmVzLm5lYy5jby5qcD4gd3JvdGU6Cj4gSXQgd291bGQgYmUgYSBuaXRwaWNrLCBi
dXQgbXkgcGF0Y2goaHR0cDovL21hcmMuaW5mby8/bD1saW51eC1tbS1jb21taXRzJm09MTI2MTUy
ODA0NDIwOTkyJnc9MikKPiBoYXMgYWxyZWFkeSBtb2RpZmllZCBoZXJlLgo+Cj4gSSB0aGluayBp
dCBtaWdodCBiZSBiZXR0ZXIgZm9yIHlvdSB0byBhcHBseSBteSBwYXRjaGVzIGJ5IGhhbmQgb3Ig
d2FpdCBmb3IgbmV4dCBtbW90bQo+IHRvIGJlIHJlbGVhc2VkIHRvIGF2b2lkIGJvdGhlcmluZyBB
bmRyZXcuCj4gKFRoZXJlIGlzIGVub3VnaCB0aW1lIGxlZnQgdGlsbCB0aGUgbmV4dCBtZXJnZSB3
aW5kb3cgOikpCgpJJ2xsIHJlYmFzZSBpdCBsYXRlci4KCj4gKHNuaXApCj4KPj4gK3N0YXRpYyB2
b2lkIF9fbWVtX2Nncm91cF90aHJlc2hvbGQoc3RydWN0IG1lbV9jZ3JvdXAgKm1lbWNnLCBib29s
IHN3YXApCj4+ICt7Cj4+ICsgwqAgwqAgc3RydWN0IG1lbV9jZ3JvdXBfdGhyZXNob2xkX2FyeSAq
dGhyZXNob2xkczsKPj4gKyDCoCDCoCB1NjQgdXNhZ2UgPSBtZW1fY2dyb3VwX3VzYWdlKG1lbWNn
LCBzd2FwKTsKPj4gKyDCoCDCoCBpbnQgaSwgY3VyOwo+PiArCj4gSSB0aGluayBjYWxsaW5nIG1l
bV9jZ3JvdXBfdXNhZ2UoKSBhZnRlciBjaGVja2luZyAiaWYoIXRocmVzaG9sZHMpIgo+IGRlY3Jl
YXNlcyB0aGUgb3ZlcmhlYWQgYSBsaXR0bGUgd2hlbiB3ZSBkb24ndCBzZXQgYW55IHRocmVzaG9s
ZHMuCj4gSSd2ZSBjb25maXJtZWQgdGhhdCB0aGUgY2hhbmdlIG1ha2VzIHRoZSBhc3NlbWJsZXIg
b3V0cHV0IGRpZmZlcmVudC4KClRoYW5rcy4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0
cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3Jn
L21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

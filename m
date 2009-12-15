From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
	for notifications
Date: Tue, 15 Dec 2009 17:03:37 +0200
Message-ID: <cc557aab0912150703qcfe6458paa7da71cb032cb93__14785.9101220549$1260889560$gmane$org@mail.gmail.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
	<20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091215183533.1a1e87d9.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVHVlLCBEZWMgMTUsIDIwMDkgYXQgMTE6MzUgQU0sIEtBTUVaQVdBIEhpcm95dWtpCjxrYW1l
emF3YS5oaXJveXVAanAuZnVqaXRzdS5jb20+IHdyb3RlOgo+IE9uIFR1ZSwgMTUgRGVjIDIwMDkg
MTE6MTE6MTYgKzAyMDAKPiAiS2lyaWxsIEEuIFNodXRlbW92IiA8a2lyaWxsQHNodXRlbW92Lm5h
bWU+IHdyb3RlOgo+Cj4+IENvdWxkIGFueWJvZHkgcmV2aWV3IHRoZSBwYXRjaD8KPj4KPj4gVGhh
bmsgeW91Lgo+Cj4gc29tZSBuaXRwaWNrcy4KPgo+Pgo+PiBPbiBTYXQsIERlYyAxMiwgMjAwOSBh
dCAxMjo1OSBBTSwgS2lyaWxsIEEuIFNodXRlbW92Cj4+IDxraXJpbGxAc2h1dGVtb3YubmFtZT4g
d3JvdGU6Cj4KPj4gPiArIMKgIMKgIMKgIC8qCj4+ID4gKyDCoCDCoCDCoCDCoCogVW5yZWdpc3Rl
ciBldmVudHMgYW5kIG5vdGlmeSB1c2Vyc3BhY2UuCj4+ID4gKyDCoCDCoCDCoCDCoCogRklYTUU6
IEhvdyB0byBhdm9pZCByYWNlIHdpdGggY2dyb3VwX2V2ZW50X3JlbW92ZV93b3JrKCkKPj4gPiAr
IMKgIMKgIMKgIMKgKiDCoCDCoCDCoCDCoHdoaWNoIHJ1bnMgZnJvbSB3b3JrcXVldWU/Cj4+ID4g
KyDCoCDCoCDCoCDCoCovCj4+ID4gKyDCoCDCoCDCoCBtdXRleF9sb2NrKCZjZ3JwLT5ldmVudF9s
aXN0X211dGV4KTsKPj4gPiArIMKgIMKgIMKgIGxpc3RfZm9yX2VhY2hfZW50cnlfc2FmZShldmVu
dCwgdG1wLCAmY2dycC0+ZXZlbnRfbGlzdCwgbGlzdCkgewo+PiA+ICsgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgY2dyb3VwX2V2ZW50X3JlbW92ZShldmVudCk7Cj4+ID4gKyDCoCDCoCDCoCDCoCDCoCDC
oCDCoCBldmVudGZkX3NpZ25hbChldmVudC0+ZXZlbnRmZCwgMSk7Cj4+ID4gKyDCoCDCoCDCoCB9
Cj4+ID4gKyDCoCDCoCDCoCBtdXRleF91bmxvY2soJmNncnAtPmV2ZW50X2xpc3RfbXV0ZXgpOwo+
PiA+ICsKPj4gPiArb3V0Ogo+PiA+IMKgIMKgIMKgIMKgcmV0dXJuIHJldDsKPj4gPiDCoH0KPgo+
IEhvdyBjaXJpdGljYWwgaXMgdGhpcyBGSVhNRSA/Cj4gQnV0IEhtbS4uY2FuJ3Qgd2UgdXNlIFJD
VSA/CgpJdCdzIG5vdCByZWFzb25hYmxlIHRvIGhhdmUgUkNVIGhlcmUsIHNpbmNlIGV2ZW50X2xp
c3QgaXNuJ3QgbW9zdGx5LXJlYWQuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGlu
dXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZy9tYWls
bWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

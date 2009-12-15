From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
	for notifications
Date: Wed, 16 Dec 2009 08:55:52 +0900
Message-ID: <20091216085552.91ebc559.kamezawa.hiroyu__44262.736515566$1260921593$gmane$org@jp.fujitsu.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
	<20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab0912150703qcfe6458paa7da71cb032cb93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cc557aab0912150703qcfe6458paa7da71cb032cb93-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVHVlLCAxNSBEZWMgMjAwOSAxNzowMzozNyArMDIwMAoiS2lyaWxsIEEuIFNodXRlbW92IiA8
a2lyaWxsQHNodXRlbW92Lm5hbWU+IHdyb3RlOgo+ID4+ID4gKyDCoCDCoCDCoCAvKgo+ID4+ID4g
KyDCoCDCoCDCoCDCoCogVW5yZWdpc3RlciBldmVudHMgYW5kIG5vdGlmeSB1c2Vyc3BhY2UuCj4g
Pj4gPiArIMKgIMKgIMKgIMKgKiBGSVhNRTogSG93IHRvIGF2b2lkIHJhY2Ugd2l0aCBjZ3JvdXBf
ZXZlbnRfcmVtb3ZlX3dvcmsoKQo+ID4+ID4gKyDCoCDCoCDCoCDCoCogwqAgwqAgwqAgwqB3aGlj
aCBydW5zIGZyb20gd29ya3F1ZXVlPwo+ID4+ID4gKyDCoCDCoCDCoCDCoCovCj4gPj4gPiArIMKg
IMKgIMKgIG11dGV4X2xvY2soJmNncnAtPmV2ZW50X2xpc3RfbXV0ZXgpOwo+ID4+ID4gKyDCoCDC
oCDCoCBsaXN0X2Zvcl9lYWNoX2VudHJ5X3NhZmUoZXZlbnQsIHRtcCwgJmNncnAtPmV2ZW50X2xp
c3QsIGxpc3QpIHsKPiA+PiA+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgY2dyb3VwX2V2ZW50X3Jl
bW92ZShldmVudCk7Cj4gPj4gPiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGV2ZW50ZmRfc2lnbmFs
KGV2ZW50LT5ldmVudGZkLCAxKTsKPiA+PiA+ICsgwqAgwqAgwqAgfQo+ID4+ID4gKyDCoCDCoCDC
oCBtdXRleF91bmxvY2soJmNncnAtPmV2ZW50X2xpc3RfbXV0ZXgpOwo+ID4+ID4gKwo+ID4+ID4g
K291dDoKPiA+PiA+IMKgIMKgIMKgIMKgcmV0dXJuIHJldDsKPiA+PiA+IMKgfQo+ID4KPiA+IEhv
dyBjaXJpdGljYWwgaXMgdGhpcyBGSVhNRSA/Cj4gPiBCdXQgSG1tLi5jYW4ndCB3ZSB1c2UgUkNV
ID8KPiAKPiBJdCdzIG5vdCByZWFzb25hYmxlIHRvIGhhdmUgUkNVIGhlcmUsIHNpbmNlIGV2ZW50
X2xpc3QgaXNuJ3QgbW9zdGx5LXJlYWQuCj4gCm9rLgoKVGhhbmtzLAotS2FtZQoKX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5n
IGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3Rz
LmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

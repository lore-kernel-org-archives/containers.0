From: Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Fri, 26 Feb 2010 00:36:15 +0900
Message-ID: <28c262361002250736k57543379j8291e0dfb8df194e__33761.0425930054$1267112302$gmane$org@mail.gmail.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
	<alpine.DEB.2.00.1002211321010.22858@chino.kir.corp.google.com>
	<20100221221700.GA5233@linux> <20100222180732.GC3096@redhat.com>
	<20100223115846.GI1882@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100223115846.GI1882@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

SGkKCk9uIFR1ZSwgRmViIDIzLCAyMDEwIGF0IDg6NTggUE0sIEFuZHJlYSBSaWdoaSA8YXJpZ2hp
QGRldmVsZXIuY29tPiB3cm90ZToKPiBPbiBNb24sIEZlYiAyMiwgMjAxMCBhdCAwMTowNzozMlBN
IC0wNTAwLCBWaXZlayBHb3lhbCB3cm90ZToKPj4gPiA+ID4gK3Vuc2lnbmVkIGxvbmcgbWVtX2Nn
cm91cF9kaXJ0eV9ieXRlcyh2b2lkKQo+PiA+ID4gPiArewo+PiA+ID4gPiArIMKgIMKgIMKgIHN0
cnVjdCBtZW1fY2dyb3VwICptZW1jZzsKPj4gPiA+ID4gKyDCoCDCoCDCoCB1bnNpZ25lZCBsb25n
IGRpcnR5X2J5dGVzOwo+PiA+ID4gPiArCj4+ID4gPiA+ICsgwqAgwqAgwqAgaWYgKG1lbV9jZ3Jv
dXBfZGlzYWJsZWQoKSkKPj4gPiA+ID4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXR1cm4gdm1f
ZGlydHlfYnl0ZXM7Cj4+ID4gPiA+ICsKPj4gPiA+ID4gKyDCoCDCoCDCoCByY3VfcmVhZF9sb2Nr
KCk7Cj4+ID4gPiA+ICsgwqAgwqAgwqAgbWVtY2cgPSBtZW1fY2dyb3VwX2Zyb21fdGFzayhjdXJy
ZW50KTsKPj4gPiA+ID4gKyDCoCDCoCDCoCBpZiAobWVtY2cgPT0gTlVMTCkKPj4gPiA+ID4gKyDC
oCDCoCDCoCDCoCDCoCDCoCDCoCBkaXJ0eV9ieXRlcyA9IHZtX2RpcnR5X2J5dGVzOwo+PiA+ID4g
PiArIMKgIMKgIMKgIGVsc2UKPj4gPiA+ID4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCBkaXJ0eV9i
eXRlcyA9IGdldF9kaXJ0eV9ieXRlcyhtZW1jZyk7Cj4+ID4gPiA+ICsgwqAgwqAgwqAgcmN1X3Jl
YWRfdW5sb2NrKCk7Cj4+ID4gPgo+PiA+ID4gVGhlIHJjdV9yZWFkX2xvY2soKSBpc24ndCBwcm90
ZWN0aW5nIGFueXRoaW5nIGhlcmUuCj4+ID4KPj4gPiBSaWdodCEKPj4KPj4gQXJlIHdlIG5vdCBw
cm90ZWN0aW5nICJtZW1jZyIgcG9pbnRlciB1c2luZyByY3UgaGVyZT8KPgo+IFZpdmVrLCB5b3Ug
YXJlIHJpZ2h0Ogo+Cj4gwqBtZW1fY2dyb3VwX2Zyb21fdGFzaygpIC0+IHRhc2tfc3Vic3lzX3N0
YXRlKCkgLT4gcmN1X2RlcmVmZXJlbmNlKCkKPgo+IFNvLCB0aGlzICptdXN0KiBiZSBSQ1UgcHJv
dGVjdGVkLgoKU28sIERvZXNuJ3QgbWVtX2Nncm91cF9mcm9tX3Rhc2sgaW4gbWVtX2Nncm91cF9j
YW5fYXR0YWNoIG5lZWQgUkNVLCB0b28/CgoKLS0gCktpbmQgcmVnYXJkcywKTWluY2hhbiBLaW0K
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVy
cyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRw
czovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVy
cw==

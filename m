From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Fri, 26 Feb 2010 09:23:39 +0900
Message-ID: <20100226092339.1f639cbf.kamezawa.hiroyu__47003.569143317$1267144163$gmane$org@jp.fujitsu.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
	<alpine.DEB.2.00.1002211321010.22858@chino.kir.corp.google.com>
	<20100221221700.GA5233@linux> <20100222180732.GC3096@redhat.com>
	<20100223115846.GI1882@linux>
	<28c262361002250736k57543379j8291e0dfb8df194e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <28c262361002250736k57543379j8291e0dfb8df194e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gRnJpLCAyNiBGZWIgMjAxMCAwMDozNjoxNSArMDkwMApNaW5jaGFuIEtpbSA8bWluY2hhbi5r
aW1AZ21haWwuY29tPiB3cm90ZToKCj4gSGkKPiAKPiBPbiBUdWUsIEZlYiAyMywgMjAxMCBhdCA4
OjU4IFBNLCBBbmRyZWEgUmlnaGkgPGFyaWdoaUBkZXZlbGVyLmNvbT4gd3JvdGU6Cj4gPiBPbiBN
b24sIEZlYiAyMiwgMjAxMCBhdCAwMTowNzozMlBNIC0wNTAwLCBWaXZlayBHb3lhbCB3cm90ZToK
PiA+PiA+ID4gPiArdW5zaWduZWQgbG9uZyBtZW1fY2dyb3VwX2RpcnR5X2J5dGVzKHZvaWQpCj4g
Pj4gPiA+ID4gK3sKPiA+PiA+ID4gPiArIMKgIMKgIMKgIHN0cnVjdCBtZW1fY2dyb3VwICptZW1j
ZzsKPiA+PiA+ID4gPiArIMKgIMKgIMKgIHVuc2lnbmVkIGxvbmcgZGlydHlfYnl0ZXM7Cj4gPj4g
PiA+ID4gKwo+ID4+ID4gPiA+ICsgwqAgwqAgwqAgaWYgKG1lbV9jZ3JvdXBfZGlzYWJsZWQoKSkK
PiA+PiA+ID4gPiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHJldHVybiB2bV9kaXJ0eV9ieXRlczsK
PiA+PiA+ID4gPiArCj4gPj4gPiA+ID4gKyDCoCDCoCDCoCByY3VfcmVhZF9sb2NrKCk7Cj4gPj4g
PiA+ID4gKyDCoCDCoCDCoCBtZW1jZyA9IG1lbV9jZ3JvdXBfZnJvbV90YXNrKGN1cnJlbnQpOwo+
ID4+ID4gPiA+ICsgwqAgwqAgwqAgaWYgKG1lbWNnID09IE5VTEwpCj4gPj4gPiA+ID4gKyDCoCDC
oCDCoCDCoCDCoCDCoCDCoCBkaXJ0eV9ieXRlcyA9IHZtX2RpcnR5X2J5dGVzOwo+ID4+ID4gPiA+
ICsgwqAgwqAgwqAgZWxzZQo+ID4+ID4gPiA+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgZGlydHlf
Ynl0ZXMgPSBnZXRfZGlydHlfYnl0ZXMobWVtY2cpOwo+ID4+ID4gPiA+ICsgwqAgwqAgwqAgcmN1
X3JlYWRfdW5sb2NrKCk7Cj4gPj4gPiA+Cj4gPj4gPiA+IFRoZSByY3VfcmVhZF9sb2NrKCkgaXNu
J3QgcHJvdGVjdGluZyBhbnl0aGluZyBoZXJlLgo+ID4+ID4KPiA+PiA+IFJpZ2h0IQo+ID4+Cj4g
Pj4gQXJlIHdlIG5vdCBwcm90ZWN0aW5nICJtZW1jZyIgcG9pbnRlciB1c2luZyByY3UgaGVyZT8K
PiA+Cj4gPiBWaXZlaywgeW91IGFyZSByaWdodDoKPiA+Cj4gPiDCoG1lbV9jZ3JvdXBfZnJvbV90
YXNrKCkgLT4gdGFza19zdWJzeXNfc3RhdGUoKSAtPiByY3VfZGVyZWZlcmVuY2UoKQo+ID4KPiA+
IFNvLCB0aGlzICptdXN0KiBiZSBSQ1UgcHJvdGVjdGVkLgo+IAo+IFNvLCBEb2Vzbid0IG1lbV9j
Z3JvdXBfZnJvbV90YXNrIGluIG1lbV9jZ3JvdXBfY2FuX2F0dGFjaCBuZWVkIFJDVSwgdG9vPwo+
IApIbSA/IEkgZG9uJ3QgcmVhZCB0aGUgd2hvbGUgdGhyZWFkIGJ1dCBjYW5fYXR0YWNoKCkgaXMg
Y2FsbGVkIHVuZGVyCmNncm91cF9tdXRleCgpLiBTbywgaXQgZG9lc24ndCBuZWVkIHRvIHVzZSBS
Q1UuCgpUaGFua3MsCi1LYW1lCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51
eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxt
YW4vbGlzdGluZm8vY29udGFpbmVycw==

From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] nfs: include xattr.h from fs/nfs/nfs3proc.c
Date: Mon, 3 Feb 2014 15:43:19 -0500
Message-ID: <20140203204319.GI30250__46766.2872317762$1391460217$gmane$org@htj.dyndns.org>
References: <20140203193107.GH30250@htj.dyndns.org>
	<F2DD11A7-8D32-4E1E-BB4D-7384F0932B2D@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <F2DD11A7-8D32-4E1E-BB4D-7384F0932B2D-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Cc: Dr Fields James Bruce <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxnfs <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

T24gTW9uLCBGZWIgMDMsIDIwMTQgYXQgMDI6NDg6MTNQTSAtMDUwMCwgVHJvbmQgTXlrbGVidXN0
IHdyb3RlOgo+IAo+IE9uIEZlYiAzLCAyMDE0LCBhdCAxNDozMSwgVGVqdW4gSGVvIDx0akBrZXJu
ZWwub3JnPiB3cm90ZToKPiAKPiA+IGZzL25mcy9uZnMzcHJvYy5jIGlzIG1ha2luZyB1c2Ugb2Yg
eGF0dHIgYnV0IHdhcyBnZXR0aW5nIGxpbnV4L3hhdHRyLmgKPiA+IGluZGlyZWN0bHkgdGhyb3Vn
aCBsaW51eC9jZ3JvdXAuaCwgd2hpY2ggd2lsbCBzb29uIGRyb3AgdGhlIGluY2x1c2lvbgo+ID4g
b2YgeGF0dHIuaC4gIEV4cGxpY2l0bHkgaW5jbHVkZSBsaW51eC94YXR0ci5oIGZyb20gbmZzM3By
b2MuYyBzbyB0aGF0Cj4gPiBjb21waWxhdGlvbiBkb2Vzbid0IGZhaWwgd2hlbiBsaW51eC9jZ3Jv
dXAuaCBkcm9wcyBsaW51eC94YXR0ci5oLgo+ID4gCj4gPiBBcyB0aGUgZm9sbG93aW5nIGNncm91
cCBjaGFuZ2VzIHdpbGwgZGVwZW5kIG9uIHRoZXNlIGNoYW5nZXMsIGl0Cj4gPiBwcm9iYWJseSB3
b3VsZCBiZSBlYXNpZXIgdG8gcm91dGUgdGhpcyB0aHJvdWdoIGNncm91cCBicmFuY2guICBXb3Vs
ZAo+ID4gdGhhdCBiZSBva2F5Pwo+ID4gCj4gPiBTaWduZWQtb2ZmLWJ5OiBUZWp1biBIZW8gPHRq
QGtlcm5lbC5vcmc+Cj4gPiBDYzogIkouIEJydWNlIEZpZWxkcyIgPGJmaWVsZHNAZmllbGRzZXMu
b3JnPgo+IAo+IEVXUk9OR01BSU5UQUlORVLigKYgOi0pCj4gCj4gQWNrZWQtYnk6IFRyb25kIE15
a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbT4KCk9vcHN5LCB0aGFua3Mh
IDopCgotLSAKdGVqdW4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3Vu
ZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0
aW5mby9jb250YWluZXJz

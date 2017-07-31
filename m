From: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Linux-ima-devel] [RFC PATCH 1/5] ima: extend clone() with IMA
	namespace support
Date: Mon, 31 Jul 2017 07:31:58 -0400
Message-ID: <1501500718.9230.85.camel__13314.3943189227$1501500740$gmane$org@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-2-mkayaalp@linux.vnet.ibm.com>
	<20170725175317.GA727@mail.hallyn.com>
	<1501008554.3689.30.camel@HansenPartnership.com>
	<20170725190406.GA1883@mail.hallyn.com>
	<1501009739.3689.33.camel@HansenPartnership.com>
	<1501012082.27413.17.camel@linux.vnet.ibm.com>
	<645db815-7773-e351-5db7-89f38cd88c3d@linux.vnet.ibm.com>
	<20170725204622.GA4969@mail.hallyn.com>
	<1501016277.27413.50.camel@linux.vnet.ibm.com>
	<20170725210801.GA5628@mail.hallyn.com>
	<1501018134.27413.66.camel@linux.vnet.ibm.com>
	<TU4PR84MB03021F7FDF1B89ECAA8F7FFFFFBE0@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
	<1501166369.28419.171.camel@linux.vnet.ibm.com>
	<TU4PR84MB03025BC4B8DEC44A0D63A298FFBF0@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <TU4PR84MB03025BC4B8DEC44A0D63A298FFBF0-cn0wsXH2uUebani3oaRudNicc1VoeDReZmpNikb/MY7jO8Y7rvWZVA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Magalhaes, Guilherme (Brazil R&D-CL)" <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gRnJpLCAyMDE3LTA3LTI4IGF0IDE0OjE5ICswMDAwLCBNYWdhbGhhZXMsIEd1aWxoZXJtZSAo
QnJhemlsIFImRC0KQ0wpIHdyb3RlOgo+ID4gPiBFYWNoIG1lYXN1cmVtZW50IGVudHJ5IGluIHRo
ZSBsaXN0IGNvdWxkIGhhdmUgbmV3IGZpZWxkcyB0byBpZGVudGlmeQo+ID4gPiB0aGUgbmFtZXNw
YWNlLiBTaW5jZSB0aGUgbmFtZXNwYWNlcyBjYW4gYmUgcmV1c2VkLCBhIHRpbWVzdGFtcCBvcgo+
ID4gPiBvdGhlcnMgZmllbGRzIGNvdWxkIGJlIGFkZGVkIHRvIHVuaXF1ZWx5IGlkZW50aWZ5IHRo
ZSBuYW1lc3BhY2UgaWQuCj4gPiAKPiA+IFRoZSBtb3JlIGZpZWxkcyBpbmNsdWRlZCBpbiB0aGUg
bWVhc3VyZW1lbnQgbGlzdCwgdGhlIG1vcmUKPiA+IG1lYXN1cmVtZW50cyB3aWxsIGJlIGFkZGVk
IHRvIHRoZSBtZWFzdXJlbWVudCBsaXN0LiAgV291bGRuJ3QgaXQgYmUKPiA+IGVub3VnaCB0byBr
bm93IHRoYXQgYSBjZXJ0YWluIGZpbGUgaGFzIGJlZW4gYWNjZXNzZWQvZXhlY3V0ZWQgb24gdGhl
Cj4gPiBzeXN0ZW0gYW5kIGJhc2UgYW55IGFuYWx5dGljcy9mb3JlbnNpY3Mgb24gdGhlIElNQS1h
dWRpdCBkYXRhLgo+IAo+IFdpdGggdGhlIHJlY3Vyc2l2ZSBhcHBsaWNhdGlvbiBvZiBwb2xpY3kg
dGhyb3VnaCB0aGUgbmFtZXNwYWNlIGhpZXJhcmNoeSwKPiBhIG1lYXN1cmVtZW50IGFkZGVkIHRv
IHRoZSBwYXJlbnQgbmFtZXNwYWNlIGNvdWxkIGJlIG1pc2xlYWRpbmcgc2luY2UgCj4gdGhlIGZp
bGUgcGF0aG5hbWUgbWFrZXMgc2Vuc2UgaW4gdGhlIGN1cnJlbnQgbmFtZXNwYWNlIGJ1dCBwb3Nz
aWJseSBub3QKPiBmb3IgdGhlIHBhcmVudCBuYW1lc3BhY2UuCgpGYWlyIGVub3VnaC4KCj4gVGhp
cyBpcyB0aGUgcmVhc29uIHdoeSBJIGJlbGlldmUgc29tZSBuZXcgZmllbGQKPiBtaWdodCBiZSBu
ZWVkZWQgaW4gdGhlIElNQSB0ZW1wbGF0ZSBmb3JtYXQgdG8gaW5kaWNhdGUgb3IgdW5pcXVlbHkg
Cj4gaWRlbnRpZnkgdGhlIG5hbWVzcGFjZS4KCkkgd291bGQgcHJvYmFibHkgaW5jbHVkZSBpbmZv
cm1hdGlvbiB0byB1bmlxdWVseSBpZGVudGlmeSB0aGUgZmlsZQooZWcuIFVVSUQsIG1vdW50cG9p
bnQpLCBub3QgdGhlIG5hbWVzcGFjZS4KwqAKTWltaQoKX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVy
c0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlv
bi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

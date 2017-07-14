From: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Fri, 14 Jul 2017 15:43:46 -0400
Message-ID: <1500061426.3583.65.camel@linux.vnet.ibm.com>
References: <87k23cb6os.fsf@xmission.com>
	<847ccb2a-30c0-a94c-df6f-091c8901eaa0@linux.vnet.ibm.com>
	<87bmoo8bxb.fsf@xmission.com>
	<9a3010e5-ca2b-5e7a-656b-fcc14f7bec4e@linux.vnet.ibm.com>
	<87h8yf7szd.fsf@xmission.com>
	<65dbe654-0d99-03fa-c838-5a726b462826@linux.vnet.ibm.com>
	<20170714133437.GA16737@mail.hallyn.com>
	<596f808b-e21d-8296-5fef-23c1ce7ab778@linux.vnet.ibm.com>
	<20170714173556.GA19669@mail.hallyn.com>
	<1500058090.3583.28.camel@linux.vnet.ibm.com>
	<20170714192909.zoxnlm32nrxguqao@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170714192909.zoxnlm32nrxguqao-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W.
	Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

T24gRnJpLCAyMDE3LTA3LTE0IGF0IDE1OjI5IC0wNDAwLCBUaGVvZG9yZSBUcydvIHdyb3RlOgo+
IE9uIEZyaSwgSnVsIDE0LCAyMDE3IGF0IDAyOjQ4OjEwUE0gLTA0MDAsIE1pbWkgWm9oYXIgd3Jv
dGU6Cj4gPiAKPiA+IElmIEknbSB1bmRlcnN0YW5kaW5nIHRoZSBkaXNjdXNzaW9uIGNvcnJlY3Rs
eSwgdGhpcyBpc24ndCBhbiBpc3N1ZSBmb3IKPiA+IGxheWVyZWQgY29weSBvbiB3cml0ZSBmaWxl
c3lzdGVtcywgYXMgZWFjaCBmcyBsYXllciBjb3VsZCBoYXZlIGl0J3MKPiA+IG93biBzZXQgb2Yg
eGF0dHJzLiDCoFRoZSB1bmRlcmx5aW5nIGFuZCBsYXllcmVkIHhhdHRycyBzaG91bGQgYmUgYWJs
ZQo+ID4gdG8gY28tZXhpc3QuIMKgVXNlIHRoZSBsYXllcmVkIHhhdHRyIGlmIGl0IGV4aXN0cywg
YnV0IGZhbGwgYmFjayB0bwo+ID4gdXNpbmcgdGhlIHVuZGVybHlpbmcgeGF0dHIgaWYgaXQgZG9l
c24ndC4KPiAKPiBOb3RlIHRoYXQgdGhpcyBhc3N1bWVzIHRoYXQgaXQgaXMgcG9zc2libGUgdG8g
ImNvcHkgdXAiIHRoZSB4YXR0cnMKPiB3aXRob3V0IG5lY2Vzc2FyaWx5ICJjb3B5aW5nIHVwIiBh
bGwgb2YgdGhlIGRhdGEgYmxvY2tzLiAgVGhpcyBtaWdodAo+IGJlIHRydWUgZm9yIHNvbWUgbGF5
ZXJzLCBidXQgSSBkb24ndCBiZWxpZXZlIGl0IGlzIGN1cnJlbnRseSB0cnVlIGZvcgo+IG92ZXJs
YXlmcywgZm9yIGV4YW1wbGUuCgpPaywgc28gZm9yIHRoZSB1c2UgY2FzZSBzY25lYXJpbyB3aGVy
ZSB0aGUgY29udGFpbmVyIG93bmVyIGlzIHdpbGxpbmcKdG8gdXNlIHRoZSBwdWJsaWMga2V5IGRp
c3RyaWJ1dGVkIHdpdGggdGhlIGZpbGVzLCB0aGVuIG9ubHkgdGhvc2UKZmlsZXMgdGhhdCBhcmUg
bmV3IG9yIG1vZGlmaWVkIGluIHRoZSBvdmVybGF5IHdvdWxkIG5lZWQgdG8gYmUgc2lnbmVkCndp
dGggYSBrZXkgbG9jYWwgdG8gdGhlIG92ZXJsYXkuIMKgSW4gdGhlIHdvcnN0IGNhc2Ugc2NlbmFy
aW8sIHdoZXJlCnRoZSBjb250YWluZXIgb3duZXIgaXMgb25seSB3aWxsaW5nIHRvIHRydXN0IHRo
ZWlyIG93biBwdWJsaWMga2V5LCBJCmd1ZXNzIHdlIGNhbiBsaXZlIHdpdGggaGF2aW5nIHRvIGNv
cHkgdXAgdGhlIGZpbGVzLgoKTWltaQoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5s
aW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFp
bG1hbi9saXN0aW5mby9jb250YWluZXJz

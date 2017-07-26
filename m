From: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Wed, 26 Jul 2017 09:57:50 -0400
Message-ID: <1501077470.28419.8.camel__8166.72634468905$1501077494$gmane$org@linux.vnet.ibm.com>
References: <847ccb2a-30c0-a94c-df6f-091c8901eaa0@linux.vnet.ibm.com>
	<87bmoo8bxb.fsf@xmission.com>
	<9a3010e5-ca2b-5e7a-656b-fcc14f7bec4e@linux.vnet.ibm.com>
	<87h8yf7szd.fsf@xmission.com>
	<65dbe654-0d99-03fa-c838-5a726b462826@linux.vnet.ibm.com>
	<20170714133437.GA16737@mail.hallyn.com>
	<596f808b-e21d-8296-5fef-23c1ce7ab778@linux.vnet.ibm.com>
	<20170714173556.GA19669@mail.hallyn.com>
	<xagsmtp2.20170714182525.6604@vmsdvm4.vnet.ibm.com>
	<1500060374.3583.57.camel@linux.vnet.ibm.com>
	<20170726030007.GA10087@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170726030007.GA10087-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

T24gVHVlLCAyMDE3LTA3LTI1IGF0IDIyOjAwIC0wNTAwLCBTZXJnZSBFLiBIYWxseW4gd3JvdGU6
Cj4gT24gRnJpLCBKdWwgMTQsIDIwMTcgYXQgMDM6MjY6MTRQTSAtMDQwMCwgTWltaSBab2hhciB3
cm90ZToKPiA+IE9uIEZyaSwgMjAxNy0wNy0xNCBhdCAxMzoxNyAtMDUwMCwgRXJpYyBXLiBCaWVk
ZXJtYW4gd3JvdGU6Cj4gPiA+IFdoaWNoIGJyaW5ncyB1cyB0byB0aGUgc2VtYW50aWMgcXVlc3Rp
b24gb2Ygd291bGQgaXQgYmUgbmljZSB0byBoYXZlCj4gPiA+IHN0YWNrZWQgSU1BL0VWTSBvbiB0
aGUgc2FtZSBmaWxlLgo+ID4gPiAKPiA+ID4gSSByZWFsbHkgZG9uJ3QgdGhpbmsgd2UgZG8uICBJ
IHRoaW5rIGFsbG93aW5nIG11bHRpcGxlIGtleXMgZm9yCj4gPiA+IGRpZmZlcmVudCBwYXJ0IG9m
IHRydXN0aW5nIGZpbGVzIGlzIGVhc3kgZW5vdWdoIHRoYXQgd2Ugc2hvdWxkIGhhdmUgbm8KPiA+
ID4gbmVlZCB0byBmaWdodCBvdmVyIHdoaWNoIGtleXMgZG8gd2hpY2guCj4gPiAKPiA+IFdlIGRl
ZmluaXRlbHkgd2FudCB0byBzdXBwb3J0IGRpZmZlcmVudCBwb2xpY2llcyBvbiB0aGUgbmF0aXZl
IGFuZCBpbgo+ID4gdGhlIG5hbWVzcGFjZSB3aXRoIGRpZmZlcmVudCBrZXlzIGFuZCBrZXlyaW5n
cy4KPiAKPiBPaywgc28gU3RlZmFuJ3MgY29kZSB0byBzdXBwb3J0IHVzZXJzcGFjZSBpbiBhIGNv
bnRhaW5lciByZWFkaW5nCj4gc2VjdXJpdHkuaW1hIGFuZCBnZXR0aW5nIGJhY2sgdGhlIHZhbHVl
IGZvciBzZWN1cml0eS5pbWFAdWlkPTEwMDAKPiAoaWYgMTAwMCBpcyB0aGUga3VpZCBvZiB0aGUg
Y29udGFpbmVyJ3Mgcm9vdCB1c2VyKSBpcyBpbiBmYWN0Cj4gdXNlZnVsIHRvIElNQT8KCkRlZmlu
aXRlbHkhIMKgUm9vdCB3aXRoaW4gdGhlIG5hbWVzcGFjZSBuZWVkcyB0byBiZSBhYmxlIHRvIHJl
YWQgYW5kCndyaXRlIHNlY3VyaXR5LmltYSBpbiBvcmRlciB0byAocmUpc2lnbiBmaWxlcywgd2l0
aCBhIHNwZWNpZmljIGtleQprbm93biB0byB0aGF0IGNvbnRhaW5lci4gwqBTdGVmYW4ncyBjb2Rl
IHByb3ZpZGVzIGRpZmZlcmVudCB2aWV3cyBvZgp0aGUgc2VjdXJpdHkgeGF0dHJzLgoKTWltaQoK
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVy
cyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRw
czovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

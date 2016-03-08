From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH] devpts: Add ptmx_uid and ptmx_gid options
Date: Tue, 8 Mar 2016 10:17:56 -0800
Message-ID: <CALCETrWq37bfZASiJwYzj1sH5H-7W8EdhA83XPsUKMizjQDfog@mail.gmail.com>
References: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto@amacapital.net>
	<CALCETrVtGE8LdBCFTe1_cqpLf=SxPNX5iCe5wa-hZ0pe8ps_jA@mail.gmail.com>
	<1427447013.2250.9.camel@HansenPartnership.com>
	<1427788642.4411.12.camel@redhat.com>
	<1427807248.2117.117.camel@HansenPartnership.com>
	<CALCETrWKA4ZdHfdLuW0_W5xxJOSCJdt_fiRWs6vDk+8ZQ9n9iA@mail.gmail.com>
	<1427808184.2117.122.camel@HansenPartnership.com>
	<CALCETrW8v1NFa7fcJbyJKXk9Msudht5BJ7Zy1Rg7ZC_TS-2Y-Q@mail.gmail.com>
	<1427810118.2117.126.camel@HansenPartnership.com>
	<CALCETrU1vKf3fXPt8nS-ABDgfp8NxrFjHwTc68rA0rtvg2Lufg@mail.gmail.com>
	<1427810886.2117.129.camel@HansenPartnership.com>
	<1427811444.4411.20.camel@redhat.com>
	<1427969525.3559.120.camel@HansenPartnership.com>
	<CALCETrWyUYgHY53O451AdJUs9Mcjsqmr4fUzoNmYsTP1HLq+VA@mail.gmail.com>
	<1427984969.13651.11.camel@redhat.com>
	<CALCETrWYit+WiAM6DFm0enGeJN==uWNC63zXp_zRSsSJg2YGPg@mail.gmail.com>
	<87zj6qs7v8.fsf@x220.int.ebiederm.org>
	<CALCETrVGcCA2SMiDT8JN=AWiSFCXWSaMeKBQmkbKynKfiPJCwA@mail.gmail.com>
	<87oal4odne.fsf@x220.int.ebiederm.org>
	<1432832511.21304.6.camel@redhat.com>
	<CALCETrUueGomqFG0DSpt5Ern-XW6DE+rAEkd=3Y2ekV+gOwLAA@mail.gmail.com>
	<87siagh4kh.fsf@x220.int.ebiederm.org>
	<CALCETrXNyyG-LZ8ds5ALbWs_Tfonev4+Ci=XZwWFqsSeszes8g@mail.gmail.com>
	<1457428591.27353.55.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1457428591.27353.55.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVHVlLCBNYXIgOCwgMjAxNiBhdCAxOjE2IEFNLCBBbGV4YW5kZXIgTGFyc3NvbiA8YWxleGxA
cmVkaGF0LmNvbT4gd3JvdGU6Cj4gT24gbcOlbiwgMjAxNi0wMy0wNyBhdCAyMDo1OSAtMDgwMCwg
QW5keSBMdXRvbWlyc2tpIHdyb3RlOgo+PiBPbiBUaHUsIE1heSAyOCwgMjAxNSBhdCAxMjo0MiBQ
TSwgRXJpYyBXLiBCaWVkZXJtYW4KPj4gPGViaWVkZXJtQHhtaXNzaW9uLmNvbT4gd3JvdGU6Cj4+
ID4gQW5keSBMdXRvbWlyc2tpIDxsdXRvQGFtYWNhcGl0YWwubmV0PiB3cml0ZXM6Cj4+ID4KPj4g
QXBwYXJlbnRseSBhbGV4bCBpcyBlbmNvdW50ZXJpbmcgc29tZSBhbm5veWFuY2VzIHJlbGF0ZWQg
dG8gdGhlCj4+IGN1cnJlbnQgd29ya2Fyb3VuZCwgYW5kIHRoZSB3b3JrYXJvdW5kIGlzIGNlcnRh
aW5seSB1Z2x5Lgo+Cj4gSXQgd29ya3MsIGJ1dCBpdCBpbnRyb2R1Y2VzIGFuIGV4dHJhIG5hbWVz
cGFjZSB0aGF0IGdldHMgZXhwb3NlZCB0byB0aGUKPiB3b3JsZCwgd2hpY2ggaXMgcHJldHR5IHVn
bHkuIEZvciBpbnN0YW5jZSwgZW50ZXJpbmcgdGhlIG5hbWVzcGFjZQo+IGJlY29tZXMgaGFyZC4g
SSBjYW4gc2V0bnMoKSBpbnRvIHRoZSBpbnRlcm1lZGlhdGUgdXNlcittb3VudCBuYW1lc3BhY2UK
PiB3aXRob3V0IHByb2JsZW1zLCBidXQgaWYgaSB0cnkgdG8gc2V0bnMgaW50byB0aGUgZmluYWwg
dXNlcittb3VudCBucwo+IChpdCBnZXRzIGl0cyBvd24gaW1wbGljaXQgbW91bnQgbnMpIGkgZ2V0
IEVQRVJNLiBJJ20gbm90IHN1cmUgZXhhY3RseQo+IHdoeSB0aG91Z2guLi4KPgo+PiBZb3VyIHBy
b3Bvc2FsIHNlZW1zIGxpa2UgaXQgY291bGQgYnJlYWsgc29tZSB1c2UgY2FzZXMgaW52b2x2aW5n
Cj4+IGZzY2FwcyBvbiBhIG1vdW50IG9yIG1vdW50LWxpa2UgYmluYXJ5Lgo+Pgo+PiBXaGF0IGlm
IHdlIGNoYW5nZSBpdCB0byB1c2UgdGhlIG93bmVyIG9mIHRoZSB1c2VybnMgdGhhdCBvd25zIHRo
ZQo+PiBjdXJyZW50IG1vdW50IG5zPyAgRm9yIGFueXRoaW5nIHRoYXQgZG9lc24ndCBleHBsaWNp
dGx5IHVzZQo+PiBuYW1lc3BhY2VzLCB0aGlzIHdpbGwgYmUgemVyby4gIEZvciBuYW1lc3BhY2Ug
dXNlcnMsIGl0IHNob3VsZCBkbyB0aGUKPj4gcmlnaHQgdGhpbmcuCj4KPiBBbnkgb2YgdGhlc2Ug
aXMgZmluZSB3aXRoIG1lLiBPbmUgbmljZSB0aGluZyB3b3VsZCBpZiBpIGNvdWxkIHNvbWVob3cK
PiBkZXRlY3Qgd2hldGhlciB0aGlzIHdhcyBzdXBwb3J0ZWQgb3Igbm90IHNvIHRoYXQgaSBjYW4g
ZmFsbCBiYWNrIG9uIHRoZQo+IG9sZCB3b3JrYXJvdW5kLgoKSSdsbCBzZW5kIGEgcGF0Y2guCgpJ
IHN1cHBvc2UgdGhlIHN0cmFpZ2h0Zm9yd2FyZCwgaWYgc2xpZ2h0bHkgYXdrd2FyZCwgd2F5IHRv
IGRldGVjdCBpdAppcyBqdXN0IHRvIHRyeSBpdCAtLSBjcmVhdGUgYSBuYW1lc3BhY2UgYW5kIHRy
eSB0byBtb3VudCBkZXZwdHMuCgotLUFuZHkKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0
cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcv
bWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

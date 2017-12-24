From: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 11/11] evm: Don't update hmacs in user ns mounts
Date: Sun, 24 Dec 2017 00:56:01 -0500
Message-ID: <1514094961.5221.132.camel__12040.2036737234$1514094879$gmane$org@linux.vnet.ibm.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<1f2233a1a028f1eb1e9bea7d06efa6d34e69e752.1512041070.git.dongsu@kinvolk.io>
	<20171223040348.GK6837@mail.hallyn.com>
	<1514092328.5221.116.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1514092328.5221.116.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

T24gU3VuLCAyMDE3LTEyLTI0IGF0IDAwOjEyIC0wNTAwLCBNaW1pIFpvaGFyIHdyb3RlOgo+IEhp
IFNlcmdlLAo+IAo+IE9uIEZyaSwgMjAxNy0xMi0yMiBhdCAyMjowMyAtMDYwMCwgU2VyZ2UgRS4g
SGFsbHluIHdyb3RlOgo+ID4gT24gRnJpLCBEZWMgMjIsIDIwMTcgYXQgMDM6MzI6MzVQTSArMDEw
MCwgRG9uZ3N1IFBhcmsgd3JvdGU6Cj4gPiA+IEZyb206IFNldGggRm9yc2hlZSA8c2V0aC5mb3Jz
aGVlQGNhbm9uaWNhbC5jb20+Cj4gPiA+IAo+ID4gPiBUaGUga2VybmVsIHNob3VsZCBub3QgY2Fs
Y3VsYXRlIG5ldyBobWFjcyBmb3IgbW91bnRzIGRvbmUgYnkKPiA+ID4gbm9uLXJvb3QgdXNlcnMu
IFVwZGF0ZSBldm1fY2FsY19obWFjX29yX2hhc2goKSB0byByZWZ1c2UgdG8KPiA+ID4gY2FsY3Vs
YXRlIG5ldyBobWFjcyBmb3IgbW91bnRzIGZvciBub24taW5pdCB1c2VyIG5hbWVzcGFjZXMuCj4g
PiA+IAo+ID4gPiBDYzogbGludXgtaW50ZWdyaXR5QHZnZXIua2VybmVsLm9yZwo+ID4gPiBDYzog
bGludXgtc2VjdXJpdHktbW9kdWxlQHZnZXIua2VybmVsLm9yZwo+ID4gPiBDYzogbGludXgta2Vy
bmVsQHZnZXIua2VybmVsLm9yZwo+ID4gPiBDYzogSmFtZXMgTW9ycmlzIDxqYW1lcy5sLm1vcnJp
c0BvcmFjbGUuY29tPgo+ID4gPiBDYzogTWltaSBab2hhciA8em9oYXJAbGludXgudm5ldC5pYm0u
Y29tPgo+ID4gCj4gPiBIaSBNaW1pLAo+ID4gCj4gPiBkb2VzIHRoaXMgY2hhbmdlIHNlZW0gc3Vm
ZmljaWVudCB0byB5b3U/Cj4gCj4gSSB0aGluayB0aGlzIGlzIHRoZSBjb3JyZWN0IGJlaGF2aW9y
IGluIHRoZSBjb250ZXh0IG9mIGZ1c2UgZmlsZQo+IHN5c3RlbXMuIMKgVGhpcyBwYXRjaCwgdGhl
ICJpbWE6IGRlZmluZSBhIG5ldyBwb2xpY3kgb3B0aW9uIG5hbWVkCj4gZm9yY2UiIHBhdGNoLCBh
bmQgYW4gdXBkYXRlZCBJTUEgcG9saWN5IHNob3VsZCBiZSB1cHN0cmVhbWVkIHRvZ2V0aGVyLgo+
IMKgVGhlIGNvdmVyIGxldHRlciBzaG91bGQgcHJvdmlkZSB0aGUgbW90aXZhdGlvbiBmb3IgdGhl
c2UgcGF0Y2hlcy4KCkFoLCB0aGlzIHBhdGNoIGlzIGJlaW5nIHVwc3RyZWFtZWQgd2l0aCB0aGUg
ZnVzZSBtb3VudHMgcGF0Y2hlcy4gwqBJCmd1ZXNzIFNldGggaXMgcGxhbm5pbmcgb24gcG9zdGlu
ZyB0aGUgSU1BIHBvbGljeSBjaGFuZ2VzIGZvciBmdXNlCnNlcGFyYXRlbHkuCgpNaW1pCgpfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1h
aWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8v
bGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

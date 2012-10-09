From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] ext3: fix return values on parse_options() failure
Date: Mon, 08 Oct 2012 23:50:26 -0700
Message-ID: <87k3v0cf65.fsf@xmission.com>
References: <5073BABF.8090206@gmail.com>
	<alpine.LFD.2.00.1210090814420.11244@dhcp-1-104.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.1210090814420.11244-462rkM2+8ahgDJpvDrVWWBcY2uh10dtjAL8bYrjMMd8@public.gmane.org>
	(=?utf-8?B?Ikx1a8OhxaE=?= Czerner"'s message of "Tue,
	9 Oct 2012 08:19:42 +0200 (CEST)")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?utf-8?B?THVrw6HFoQ==?= Czerner <lczerner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

THVrw6HFoSBDemVybmVyIDxsY3plcm5lckByZWRoYXQuY29tPiB3cml0ZXM6Cgo+IE9uIFR1ZSwg
OSBPY3QgMjAxMiwgWmhhbyBIb25namlhbmcgd3JvdGU6Cj4KPj4gRGF0ZTogVHVlLCAwOSBPY3Qg
MjAxMiAxMzo0ODo0NyArMDgwMAo+PiBGcm9tOiBaaGFvIEhvbmdqaWFuZyA8emhhb2hvbmdqaWFu
ZzM3QGdtYWlsLmNvbT4KPj4gVG86IGphY2tAc3VzZS5jego+PiBDYzogYWtwbUBsaW51eC1mb3Vu
ZGF0aW9uLm9yZywgYWRpbGdlci5rZXJuZWxAZGlsZ2VyLmNhLAo+PiAgICAgbGludXgtZXh0NEB2
Z2VyLmtlcm5lbC5vcmcsIGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcsCj4+ICAgICBFcmlj
IFcuIEJpZWRlcm1hbiA8ZWJpZWRlcm1AeG1pc3Npb24uY29tPiwgc2VyZ2UuaGFsbHluQGNhbm9u
aWNhbC5jb20sCj4+ICAgICBjb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCj4+
IFN1YmplY3Q6IFtQQVRDSF0gZXh0MzogZml4IHJldHVybiB2YWx1ZXMgb24gcGFyc2Vfb3B0aW9u
cygpIGZhaWx1cmUKPj4gCj4+IEZyb206IFpoYW8gSG9uZ2ppYW5nIDx6aGFvaG9uZ2ppYW5nQGh1
YXdlaS5jb20+Cj4+IAo+PiBwYXJzZV9vcHRpb25zKCkgaW4gZXh0MyBzaG91bGQgcmV0dXJuIDAg
d2hlbiBwYXJzZSB0aGUgbW91bnQgb3B0aW9ucyBmYWlscy4KPj4gCj4KPiBBaCwgaXQgcmVhbGx5
IGlzIGEgam95IHRvIHJlYWQgdGhlIHBhcnNlX29wdGlvbnMoKSA6KS4gQnV0IHRoaXMgZml4Cj4g
bWFrZXMgc2Vuc2UsIHRoYW5rcyBmb3IgY2F0Y2hpbmcgaXQuCj4KPiBSZXZpZXdlZC1ieTogTHVr
YXMgQ3plcm5lciA8bGN6ZXJuZXJAcmVkaGF0LmNvbT4KClVnaC4gIEkgZ29vZmVkIHRoYXQgdXAu
ICBIb3cgYW5ub3lpbmcgdGhhdCBleHQ0IGlzIGRpZmZlcmVudCB0aGFuIGV4dDMKYW5kIGV4dDIg
aW4gdGhpcyByZWdhcmQuCgpBY2tlZC1ieTogIkVyaWMgVy4gQmllZGVybWFuIiA8ZWJpZWRlcm1A
eG1pc3Npb24uY29tPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5k
YXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3Rp
bmZvL2NvbnRhaW5lcnM=

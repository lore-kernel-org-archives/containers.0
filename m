From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH v10 0/2] ns, procfs: pid conversion between ns
Date: Thu, 12 Feb 2015 01:35:47 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E737FB132__48933.1431956545$1423704968$gmane$org@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1423219550-4385-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5871495633F38949900D2BF2DC04883E737F9398@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5871495633F38949900D2BF2DC04883E737F9398-ZEd+hNNJ6a5ZYpXjqAkB5jz3u5zwRJJDAzI0kPv9QBlmR6Xm/wNWPw@public.gmane.org>
Content-Language: zh-CN
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, "linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQ2hlbiwgSGFueGlhby+z
wiDqz8/2DQo+IFNlbnQ6IFdlZG5lc2RheSwgRmVicnVhcnkgMTEsIDIwMTUgMTo1MiBQTQ0KPiAN
Cj4gPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiA+IEZyb206IGNvbnRhaW5lcnMtYm91
bmNlc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZw0KPiA+DQo+ID4gQ2hlbiBIYW54aWFvICgx
KToNCj4gPiAgIC9wcm9jL1BJRC9zdGF0dXM6IHNob3cgYWxsIHNldHMgb2YgcGlkIGFjY29yZGlu
ZyB0byBucw0KPiA+DQo+ID4gTmF0aGFuIFNjb3R0ICgxKToNCj4gPiAgIGRvY3M6IGFkZCBtaXNz
aW5nIGFuZCBuZXcgL3Byb2MvUElEL3N0YXR1cyBmaWxlIGVudHJpZXMsIGZpeCB0eXBvcw0KPiA+
DQo+ID4gIERvY3VtZW50YXRpb24vZmlsZXN5c3RlbXMvcHJvYy50eHQgfCAxMSArKysrKysrKy0t
LQ0KPiA+ICBmcy9wcm9jL2FycmF5LmMgICAgICAgICAgICAgICAgICAgIHwgMTYgKysrKysrKysr
KysrKysrKw0KPiA+ICAyIGZpbGVzIGNoYW5nZWQsIDI0IGluc2VydGlvbnMoKyksIDMgZGVsZXRp
b25zKC0pDQo+ID4NCj4gDQo+IEhpIEVyaWMsDQo+IA0KPiBDb3VsZCBwbGVhc2UgcGljayB0aGlz
IHNlcmllcyB1cCBmb3IgMy4yMD8NCj4gDQoNCkhpIEFuZHJldywNCg0KU2luY2UgdGhlIHBhdGNo
IGlzIGFscmVhZHkgQWNrZWQgYnkgRXJpYywgU2VyZ2UgYW5kIFRlc3RlZCBieSBTZXJnZSBhbmQg
TmF0aGFuLg0KV291bGQgeW91IHBsZWFzZSB0YWtlIHRoaXMgc2VyaWVzIGZvciAzLjIwPyANCg0K
SXQncyBhbHJlYWR5IGhhbGYgYSB5ZWFyIHNpbmNlIHdlIHBvc3RlZCB0aGUgcGF0Y2ggZm9yIHRo
ZSBmaXJzdCB0aW1lLA0KYW5kIHJlYmFzZWQgc2V2ZXJhbCB0aW1lcy4gVGhhdCdzIHJlYWxseSBm
cnVzdHJhdGluZy4NCldlIGhvcGUgdGhpcyBwYXRjaCBjYW4gYmUgbWVyZ2VkIGluIHRoaXMgY3lj
bGUuDQoNClRoYW5rcywNCi0gQ2hlbg0KDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3Rz
LmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

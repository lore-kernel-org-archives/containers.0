From: =?gbk?Q?=22Gui=2C_Jianfeng/=B9=E9_=BD=A3=B7=E5=22?=
	<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v10 0/2] ns, procfs: pid conversion between ns
Date: Mon, 16 Feb 2015 09:58:32 +0800
Message-ID: <54E14EC8.7070807__19595.6837539145$1424051958$gmane$org@cn.fujitsu.com>
References: <1423219550-4385-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5871495633F38949900D2BF2DC04883E737F9398@G08CNEXMBPEKD02.g08.fujitsu.local>
	<5871495633F38949900D2BF2DC04883E737FB132@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="gbk"; Format="flowed"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5871495633F38949900D2BF2DC04883E737FB132-ZEd+hNNJ6a5ZYpXjqAkB5jz3u5zwRJJDAzI0kPv9QBlmR6Xm/wNWPw@public.gmane.org>
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

1NogMjAxNS8yLzEyIDk6MzUsIENoZW4sIEhhbnhpYW8vs8Ig6s/P9iDQtLXAOgo+Cj4KPj4gLS0t
LS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0KPj4gRnJvbTogQ2hlbiwgSGFueGlhby+zwiDqz8/2Cj4+
IFNlbnQ6IFdlZG5lc2RheSwgRmVicnVhcnkgMTEsIDIwMTUgMTo1MiBQTQo+Pgo+Pj4gLS0tLS1P
cmlnaW5hbCBNZXNzYWdlLS0tLS0KPj4+IEZyb206IGNvbnRhaW5lcnMtYm91bmNlc0BsaXN0cy5s
aW51eC1mb3VuZGF0aW9uLm9yZwo+Pj4KPj4+IENoZW4gSGFueGlhbyAoMSk6Cj4+PiAgICAvcHJv
Yy9QSUQvc3RhdHVzOiBzaG93IGFsbCBzZXRzIG9mIHBpZCBhY2NvcmRpbmcgdG8gbnMKPj4+Cj4+
PiBOYXRoYW4gU2NvdHQgKDEpOgo+Pj4gICAgZG9jczogYWRkIG1pc3NpbmcgYW5kIG5ldyAvcHJv
Yy9QSUQvc3RhdHVzIGZpbGUgZW50cmllcywgZml4IHR5cG9zCj4+Pgo+Pj4gICBEb2N1bWVudGF0
aW9uL2ZpbGVzeXN0ZW1zL3Byb2MudHh0IHwgMTEgKysrKysrKystLS0KPj4+ICAgZnMvcHJvYy9h
cnJheS5jICAgICAgICAgICAgICAgICAgICB8IDE2ICsrKysrKysrKysrKysrKysKPj4+ICAgMiBm
aWxlcyBjaGFuZ2VkLCAyNCBpbnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQo+Pj4KPj4KPj4g
SGkgRXJpYywKPj4KPj4gQ291bGQgcGxlYXNlIHBpY2sgdGhpcyBzZXJpZXMgdXAgZm9yIDMuMjA/
Cj4+Cj4KPiBIaSBBbmRyZXcsCj4KPiBTaW5jZSB0aGUgcGF0Y2ggaXMgYWxyZWFkeSBBY2tlZCBi
eSBFcmljLCBTZXJnZSBhbmQgVGVzdGVkIGJ5IFNlcmdlIGFuZCBOYXRoYW4uCj4gV291bGQgeW91
IHBsZWFzZSB0YWtlIHRoaXMgc2VyaWVzIGZvciAzLjIwPwo+Cj4gSXQncyBhbHJlYWR5IGhhbGYg
YSB5ZWFyIHNpbmNlIHdlIHBvc3RlZCB0aGUgcGF0Y2ggZm9yIHRoZSBmaXJzdCB0aW1lLAo+IGFu
ZCByZWJhc2VkIHNldmVyYWwgdGltZXMuIFRoYXQncyByZWFsbHkgZnJ1c3RyYXRpbmcuCj4gV2Ug
aG9wZSB0aGlzIHBhdGNoIGNhbiBiZSBtZXJnZWQgaW4gdGhpcyBjeWNsZS4KCkFuZHJldz8gICBF
cmljPwoKVGhhbmtzLApHdWkKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1m
b3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9s
aXN0aW5mby9jb250YWluZXJz

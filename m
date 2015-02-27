From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH v10 2/2] docs: add missing and new /proc/PID/status file
	entries, fix typos
Date: Fri, 27 Feb 2015 10:05:09 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E73819258__48800.4316496246$1425031535$gmane$org@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1423219550-4385-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1423219550-4385-3-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20150223130146.463c3b432ab183580cbc1464@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150223130146.463c3b432ab183580cbc1464-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQW5kcmV3IE1vcnRvbiBb
bWFpbHRvOmFrcG1AbGludXgtZm91bmRhdGlvbi5vcmddDQo+IFNlbnQ6IFR1ZXNkYXksIEZlYnJ1
YXJ5IDI0LCAyMDE1IDU6MDIgQU0NCj4gVG86IENoZW4sIEhhbnhpYW8vs8Ig6s/P9g0KPiBDYzog
RXJpYyBXLiBCaWVkZXJtYW47IGNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmc7
DQo+IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWRvY0B2Z2VyLmtlcm5lbC5v
cmc7IFNlcmdlIEhhbGx5bjsgSm9uYXRoYW4NCj4gQ29yYmV0OyBHdWksIEppYW5mZW5nL7npIL2j
t+U7IE5hdGhhbiBTY290dA0KPiBTdWJqZWN0OiBSZTogW1BBVENIIHYxMCAyLzJdIGRvY3M6IGFk
ZCBtaXNzaW5nIGFuZCBuZXcgL3Byb2MvUElEL3N0YXR1cyBmaWxlIGVudHJpZXMsDQo+IGZpeCB0
eXBvcw0KPiANCj4gT24gRnJpLCA2IEZlYiAyMDE1IDE4OjQ1OjUwICswODAwIENoZW4gSGFueGlh
byA8Y2hlbmhhbnhpYW9AY24uZnVqaXRzdS5jb20+IHdyb3RlOg0KPiANCj4gPiBGcm9tOiBOYXRo
YW4gU2NvdHQgPG5hdGhhbnNAcmVkaGF0LmNvbT4NCj4gPg0KPiA+IEZyb206IE5hdGhhbiBTY290
dCA8bmF0aGFuc0ByZWRoYXQuY29tPg0KPiA+DQo+ID4gZG9jczogYWRkIG1pc3NpbmcgYW5kIG5l
dyAvcHJvYy9QSUQvc3RhdHVzIGZpbGUgZW50cmllcywgZml4IHR5cG9zDQo+ID4NCj4gPiBTaWdu
ZWQtb2ZmLWJ5OiBOYXRoYW4gU2NvdHQgPG5hdGhhbnNAcmVkaGF0LmNvbT4NCj4gDQo+IFRoaXMg
c2hvdWxkIGhhdmUgaGFkIHlvdXIgc2lnbm9mZiwgYmVjYXVzZSB5b3Ugd2VyZSBvbiB0aGUgcGF0
Y2gNCj4gZGVsaXZlcnkgcGF0aCAoRG9jdW1lbnRhdGlvbi9TdWJtaXR0aW5nUGF0Y2hlcyBzZWN0
aW9uIDExIGhhcyBkZXRhaWxzKS4NCj4gDQo+IEkgaGF2ZSBtYWRlIHRoYXQgY2hhbmdlIHRvIG15
IGNvcHkgb2YgdGhpcyBwYXRjaC4NCg0KSGksDQoNClRoYW5rcyBmb3IgeW91ciBoZWxwLg0KSSds
bCBiZSBtb3JlIGNhcmVmdWwgbmV4dCB0aW1lLg0KDQpUaGFuayB5b3UgdmVyeSBtdWNoLg0KDQpS
ZWdhcmRzLA0KLSBDaGVuDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZv
dW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xp
c3RpbmZvL2NvbnRhaW5lcnM=

From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH] sched: updated comments of CLONE_NEWNS
Date: Tue, 7 Oct 2014 08:50:52 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E5DC9BC@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1412587493-10547-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20141006142713.GA26187@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20141006142713.GA26187@ubuntumail>
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
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU2VyZ2UgSGFsbHluIFtt
YWlsdG86c2VyZ2UuaGFsbHluQHVidW50dS5jb21dDQo+IFNlbnQ6IE1vbmRheSwgT2N0b2JlciAw
NiwgMjAxNCAxMDoyNyBQTQ0KPiBUbzogQ2hlbiwgSGFueGlhby+zwiDqz8/2DQo+IENjOiBJbmdv
IE1vbG5hcjsgUGV0ZXIgWmlqbHN0cmE7IERhdmlkIEhvd2VsbHM7DQo+IGNvbnRhaW5lcnNAbGlz
dHMubGludXgtZm91bmRhdGlvbi5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4g
U3ViamVjdDogUmU6IFtQQVRDSF0gc2NoZWQ6IHVwZGF0ZWQgY29tbWVudHMgb2YgQ0xPTkVfTkVX
TlMNCj4gDQo+IFF1b3RpbmcgQ2hlbiBIYW54aWFvIChjaGVuaGFueGlhb0Bjbi5mdWppdHN1LmNv
bSk6DQo+ID4gU2lnbmVkLW9mZi1ieTogQ2hlbiBIYW54aWFvIDxjaGVuaGFueGlhb0Bjbi5mdWpp
dHN1LmNvbT4NCj4gDQo+IFllYWggdGhhdCdsbCBiZSBoZWxwZnVsIHRvIGFueW9uZSBuZXcgdG8g
dGhlc2UgcGFydHMuICBCdXQsIHdoeSB0aGUgcXVlc3Rpb24gbWFyaywNCj4gc2hvdWxkIHlvdSBk
cm9wIHRoYXQgdG9vPyAgRWl0aGVyIHdheQ0KDQpZZXMsIHdlIHNob3VsZCBkcm9wIHRoYXQgcXVl
c3Rpb24gbWFyay4NCkknbGwgc2VuZCBhIHYyIHBhdGNoIHNvb24uDQoNClRoYW5rcywNCi0gQ2hl
bg0KDQo+IA0KPiBBY2tlZC1ieTogU2VyZ2UgRS4gSGFsbHluIDxzZXJnZS5oYWxseW5AdWJ1bnR1
LmNvbT4NCj4gDQoNCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRh
dGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGlu
Zm8vY29udGFpbmVycw==

From: "chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [RFC]Pid conversion between pid namespace
Date: Fri, 29 Aug 2014 09:59:40 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E58AD6E@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <5871495633F38949900D2BF2DC04883E55C374@G08CNEXMBPEKD02.g08.fujitsu.local>
	<5871495633F38949900D2BF2DC04883E560412@G08CNEXMBPEKD02.g08.fujitsu.local>
	<5871495633F38949900D2BF2DC04883E56C7A2@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20140804222044.GJ12438@ubuntumail>
	<5871495633F38949900D2BF2DC04883E57702E@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20140807161141.GG18303@ubuntumail>
	<5871495633F38949900D2BF2DC04883E577E1A@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20140828134957.GA6047@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140828134957.GA6047-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: "Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org)" <richard-/L3Ra7n9ekc@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)" <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org)" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Vasily Kulikov (segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org)" <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU2VyZ2UgRS4gSGFsbHlu
IFttYWlsdG86c2VyZ2VAaGFsbHluLmNvbV0NCj4gU2VudDogVGh1cnNkYXksIEF1Z3VzdCAyOCwg
MjAxNCA5OjUwIFBNDQo+IFRvOiBDaGVuLCBIYW54aWFvL+mZiCDmmZfpnIQNCj4gQ2M6IFNlcmdl
IEhhbGx5bjsgUmljaGFyZCBXZWluYmVyZ2VyIChyaWNoYXJkQG5vZC5hdCk7DQpbc25pcF0NCg0K
PiA+ID4gSSBsaWtlIHlvdXIgcHJvYyBhcHByb2FjaC4gIERvIHlvdSBoYXZlIGFuIGltcGxlbWVu
dGF0aW9uPw0KPiA+DQo+ID4gVGhhbmtzIGZvciB5b3VyIGNvbW1lbnRzLg0KPiA+IEknbSBwcmVw
YXJpbmcgdGhlIHBpZG5zIGhpZXJhcmNoeSBwYXRjaC4NCj4gPiBJdCBzZWVtcyB0aGF0IGl0J3Mg
bm90IGVhc3kgdG8gY2FycnkgaXQgb3V0Lg0KPiANCj4gOikgIE5vdCBlbnRpcmVseSBzdXJwcmlz
ZWQuDQo+IA0KPiBQbGVhc2UgZG8gc2VuZCBwYXRjaGVzIGVhcmxpZXIgcmF0aGVyIHRoYW4gbGF0
ZXIgdG8gYXZvaWQgZ29pbmcNCj4gZG93biBhIHBhdGggdGhhdCBzb21lb25lJ3MgZ29pbmcgdG8g
bmFjayBhbnl3YXkuDQoNCkkndmUgYWxtb3N0IGZpbmlzaGVkIG5zIGhpZXJhcmNoeSBwYXRjaA0K
YW5kIGRvIHNvbWUgdGVzdHMgbm93Lg0KSXQgd2lsbCBiZSBzZW50IGluIHRoZSBuZXh0IHdlZWsu
DQoNClRoYW5rcywNCi0gQ2hlbg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51
eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1h
bi9saXN0aW5mby9jb250YWluZXJz

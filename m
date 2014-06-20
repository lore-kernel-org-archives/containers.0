From: "chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH] ns: introduce getnspid syscall
Date: Fri, 20 Jun 2014 09:14:31 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E54B4DA@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1403000496-10094-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20140618175807.GA21565@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2533660972272405594=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140618175807.GA21565-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============2533660972272405594==
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogT2xlZyBOZXN0ZXJvdiBb
bWFpbHRvOm9sZWdAcmVkaGF0LmNvbV0NCj4gU2VudDogVGh1cnNkYXksIEp1bmUgMTksIDIwMTQg
MTo1OCBBTQ0KPiBUbzogQ2hlbiwgSGFueGlhby+zwiDqz8/2DQo+IENjOiBjb250YWluZXJzQGxp
c3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOw0K
PiBBbmRyZXcgTW9ydG9uOyBFcmljIFcuIEJpZWRlcm1hbjsgU2VyZ2UgSGFsbHluOyBEYW5pZWwg
UC4gQmVycmFuZ2U7IEFsIFZpcm87IERhdmlkDQo+IEhvd2VsbHM7IFJpY2hhcmQgV2VpbmJlcmdl
cjsgUGF2ZWwgRW1lbHlhbm92OyBWYXNpbGl5IEt1bGlrb3Y7IEdvdG91LCBZYXN1bm9yaS8NCj4g
zuWNdSC/tc7EDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0hdIG5zOiBpbnRyb2R1Y2UgZ2V0bnNwaWQg
c3lzY2FsbA0KPiANCj4gT24gMDYvMTcsIENoZW4gSGFueGlhbyB3cm90ZToNCj4gPg0KPiA+ICtT
WVNDQUxMX0RFRklORTQoZ2V0bnNwaWQsIHBpZF90LCBwaWQsIGludCwgZmQxLCBpbnQsIGZkMiwg
aW50LCBwaWR0eXBlKQ0KPiA+ICt7DQo+ID4gKwlzdHJ1Y3QgZmlsZSAqZmlsZTEgPSBOVUxMLCAq
ZmlsZTIgPSBOVUxMOw0KPiA+ICsJc3RydWN0IHRhc2tfc3RydWN0ICp0YXNrOw0KPiA+ICsJc3Ry
dWN0IHBpZF9uYW1lc3BhY2UgKm5zMSwgKm5zMjsNCj4gPiArCXN0cnVjdCBwcm9jX25zICplaTsN
Cj4gPiArCWludCByZXQgPSAtMTsNCj4gPiArDQo+ID4gKwlpZiAocGlkdHlwZSA+PSBQSURUWVBF
X01BWCkNCj4gPiArCQlyZXR1cm4gLUVJTlZBTDsNCj4gPiArDQo+ID4gKwlmaWxlMSA9IHByb2Nf
bnNfZmdldChmZDEpOw0KPiA+ICsJaWYgKElTX0VSUihmaWxlMSkpDQo+ID4gKwkJcmV0dXJuIFBU
Ul9FUlIoZmlsZTEpOw0KPiA+ICsJZWkgPSBnZXRfcHJvY19ucyhmaWxlX2lub2RlKGZpbGUxKSk7
DQo+ID4gKwluczEgPSAoc3RydWN0IHBpZF9uYW1lc3BhY2UgKillaS0+bnM7DQo+IA0KPiBhbmQg
SSBhbSBub3Qgc3VyZSB0aGlzIHBhcnQgaXMgY29ycmVjdC4uLiBzaG91bGRuJ3Qgd2UgYWxzbyB2
ZXJpZnkgdGhhdA0KPiBuc19vcHMgPT0gcGlkbnNfb3BlcmF0aW9ucyA/DQo+IA0KWW91J3JlIHJp
Z2h0LiBXZSBzaG91bGQgY2hlY2sgdGhpcyBwYXJ0Lg0KDQpUaGFua3MsDQotIENoZW4NCg0KPiBQ
ZXJoYXBzIGl0IG1ha2VzIHNlbnNlIHRvIGdlbmVyYWxpemUgZ2V0X25ldF9uc19ieV9mZCgpIGlu
dG8NCj4gInZvaWQgKmdldF9uc19ieV9mZChmZCwgdHlwZSkiLi4uIHRoaXMgcHJvYmFibHkgbmVl
ZHMgYW5vdGhlciAiY2hlY2stYW5kLWdldCINCj4gbWV0aG9kIGluIHByb2NfbnNfb3BlcmF0aW9u
cygpLiBJIGR1bm5vLg0KPiANCj4gT2xlZy4NCg0K

--===============2533660972272405594==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2533660972272405594==--

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: ucount: use-after-free read in inc_ucount & dec_ucount
Date: Sun, 05 Mar 2017 15:00:25 -0600
Message-ID: <87efybfnh2.fsf@xmission.com>
References: <C4CB953C-4712-43F3-9E75-1A12C14B8A4B@gmail.com>
	<180fb7dc-790e-8e82-0cc1-c6e15ddcd20b@gmail.com>
	<87pohy1fx6.fsf@xmission.com>
	<1aafd5e9-d9de-e5d9-a77d-cf245c5a5c6a@gmail.com>
	<CACT4Y+a043_qFN=2uzvYhDFwF4JS9_p3jnOykpMk=RcpqQfKGQ@mail.gmail.com>
	<CACT4Y+Yev63VXYm+kZdii5kheV_ACBn2cehFcFdz6LBVam3Q2g@mail.gmail.com>
	<CACT4Y+b7YXnoOkdYTjp6D6XH-zuYRx063hMayOVMyJVc735dtQ@mail.gmail.com>
	<c69f8f03-4324-f934-eed2-643c91d703c0@gmail.com>
	<CACT4Y+avCy8Susvb09DLHkGym0K_15+EeZ8yBH7tcgjvnb3Yhw@mail.gmail.com>
	<CALRZ7Ut=bAgX+XwS3h8-V-zGqiUFkuSCi_C=j6uN_=OptU-+RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALRZ7Ut=bAgX+XwS3h8-V-zGqiUFkuSCi_C=j6uN_=OptU-+RQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(=?utf-8?B?IuyqvOultCIncw==?= message of "Sat,
	4 Mar 2017 21:35:24 +0900")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?utf-8?B?7Kq866W0?= <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

7Kq866W0IDx6em9ydTAwN0BnbWFpbC5jb20+IHdyaXRlczoKCj4gSGksIFRoaXMgaXMgbXkgbmV3
IG9uZSByZXBvcnQgYWJvdXQgZGVjX3Vjb3VudDoKPiBwcy5Tb3JyeSBmb3IgbXkgdW5jb21mb3J0
YWJsZSByZXBvcnQuIFRoaXMgaXMgbXkgZmlyc3QgdXNhZ2Ugb2YgbGttbC4gCj4gU3l6a2FsbGVy
IGhpdCAnS0FTQU46IHVzZS1hZnRlci1mcmVlIFJlYWQgaW4gZGVjX3Vjb3VudCcgYnVnIG9uIGNv
bW1pdAo+IC4KCllvdSBhcmUgZG9pbmcgd2VsbC4gIFRoYW5rIHlvdSB2ZXJ5IG11Y2ggZm9yIHRo
ZSByZXBvcnQuCgpUaGFuayB5b3UgZm9yIHRoZSByZXByb2R1Y2VyLiAgVW5mb3J0dW5hdGVseSBJ
IGFtIG5vdCBhYmxlIHRvIHJlcHJvZHVjZQp0aGUgYnVnIHdpdGggd2hhdCB0aGUgY29kZSB5b3Ug
aGF2ZSBwb3N0ZWQgaGVyZS4KCkZyb20gdGhlIGluaXRpYWwgbWFpbGluZyB0aGUgY29kZSBzYWlk
OgoKPiBTeXprYWxsZXIgcmVwcm9kdWNlcjoKPiAjIHtUaHJlYWRlZDpmYWxzZSBDb2xsaWRlOmZh
bHNlIFJlcGVhdDp0cnVlIFByb2NzOjQgU2FuZGJveDpzZXR1aWQKPiBSZXBybzpmYWxzZX0KPiBp
bm90aWZ5X2luaXQoKQoKVGhlIGNvZGUgeW91IHBvc3RlZCBzYXlzOgoKPiBTeXprYWxsZXIgcmVw
cm9kdWNlcjoKPiAjIHtUaHJlYWRlZDpmYWxzZSBDb2xsaWRlOmZhbHNlIFJlcGVhdDp0cnVlIFBy
b2NzOjEgU2FuZGJveDpzZXR1aWQgUmVwcm86ZmFsc2V9Cj4gc2VtZ2V0JHByaXZhdGUoMHgwLCAw
eDQwMDAwMTAwMywgMHgxODEpCgpTbyBJIGV4cGVjdCBzeXprYWxsZXIgZGlkIG5vdCBjcmVhdGUg
dGhlIHNhbWUgY29kZSB3aGVuIHlvdSByYW4gaXQKYWdhaW4uICBTb21ldGhpbmcgZWFzeSB0byBt
aXNzIGlmIHlvdSBoYXZlbid0IHJ1biB1c2VkIGEgdG9vbCBsaWtlIHRoYXQKbXVjaC4KCklmIHNv
bWVvbmUga25vd3MgaG93IHRvIGdldCB0aGUgY29kZSB0aGF0IHN5emthbGxlciB3b3VsZCBnZW5l
cmF0ZSB0aGF0Cm1hdGNoZXMgdGhlIG9yaWdpbmFsIHJlcHJvZHVjZXIgSSB3b3VsZCB2ZXJ5IG11
Y2ggYXBwcmVjaWF0ZSBpdCBzbyB0aGF0CndlIGNhbiBjb25maXJtIHRoZSBidWcgd2UgaGF2ZSBz
cG90dGVkIGluIHRoZSBjb2RlIGlzIHRoZSBidWcgc3l6a2FsbGVyCmZvdW5kLgoKVW50aWwgdGhh
dCBwb2ludCBJIGFtIGdvaW5nIHRvIGZpeCB0aGUgb2J2aW91cyBidWcgaW4gdGhlIGNvZGUgYW5k
IGhvcGUKdGhhdCBmaXhlcyB0aGUgcHJvYmxlbS4KCkVyaWMKX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFp
bmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRh
dGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

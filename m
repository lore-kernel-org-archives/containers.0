From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
Date: Tue, 22 Mar 2011 08:39:35 +0530
Message-ID: <AANLkTik7r3naRV6gFfN7+sLAbgAoiMkXwKUwY6nV5FH+__43576.6630260789$1300763471$gmane$org@mail.gmail.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	<1300452855-10194-3-git-send-email-namhyung@gmail.com>
	<20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
	<1300763079.1483.21.camel@leonhard>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1300763079.1483.21.camel@leonhard>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVHVlLCBNYXIgMjIsIDIwMTEgYXQgODozNCBBTSwgTmFtaHl1bmcgS2ltIDxuYW1oeXVuZ0Bn
bWFpbC5jb20+IHdyb3RlOgo+Cj4gMjAxMS0wMy0yMiAo7ZmUKSwgMDg6NTkgKzA5MDAsIEtBTUVa
QVdBIEhpcm95dWtpOgo+ID4gT24gRnJpLCAxOCBNYXIgMjAxMSAyMTo1NDoxNSArMDkwMAo+ID4g
TmFtaHl1bmcgS2ltIDxuYW1oeXVuZ0BnbWFpbC5jb20+IHdyb3RlOgo+ID4KPiA+ID4gU2lnbmVk
LW9mZi1ieTogTmFtaHl1bmcgS2ltIDxuYW1oeXVuZ0BnbWFpbC5jb20+Cj4gPiA+IENjOiBLQU1F
WkFXQSBIaXJveXVraSA8a2FtZXphd2EuaGlyb3l1QGpwLmZ1aml0c3UuY29tPgo+ID4KPiA+IFdo
YXQgaXMgdGhlIGJlbmVmaXQgb2YgdGhpcyBwYXRjaCA/Cj4gPgo+ID4gLUthbWUKPiA+Cj4KPiBP
aCwgSSBqdXN0IHRob3VnaHQgZ2VuZXJhbGx5IGl0J2QgYmV0dGVyIGNhbGwgc3VjaCBhIChwb3Rl
bnRpYWxseSkKPiBjb3N0bHkgZnVuY3Rpb24gb3V0c2lkZSBvZiBsb2NrcyBhbmQgaXQgY291bGQg
cmVkdWNlIGZldyBvZiB0aGVvcmV0aWNhbAo+IGNvbnRlbnRpb25zIGJldHdlZW4gc3dhcG9ucyBh
bmQvb3Igb2Zmcy4gSWYgaXQgZG9lc24ndCBoZWxwIGFueQo+IHJlYWxpc3RpYyBjYXNlcyBJIGRv
bid0IG1pbmQgZGlzY2FyZGluZyBpdC4KCnN3YXBvZmYgaXMgYSByYXJlIHBhdGgsIEkgd291bGQg
bm90IHdvcnJ5IGFib3V0IGl0IHRvbyBtdWNoIGF0IGFsbC4KCkJhbGJpcgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlz
dApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGlu
dXgtZm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

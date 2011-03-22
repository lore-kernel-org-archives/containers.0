From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
Date: Tue, 22 Mar 2011 13:56:19 +0900
Message-ID: <20110322135619.90593f5d.kamezawa.hiroyu__20518.9165928916$1300770224$gmane$org@jp.fujitsu.com>
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
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

T24gVHVlLCAyMiBNYXIgMjAxMSAxMjowNDozOSArMDkwMApOYW1oeXVuZyBLaW0gPG5hbWh5dW5n
QGdtYWlsLmNvbT4gd3JvdGU6Cgo+IDIwMTEtMDMtMjIgKO2ZlCksIDA4OjU5ICswOTAwLCBLQU1F
WkFXQSBIaXJveXVraToKPiA+IE9uIEZyaSwgMTggTWFyIDIwMTEgMjE6NTQ6MTUgKzA5MDAKPiA+
IE5hbWh5dW5nIEtpbSA8bmFtaHl1bmdAZ21haWwuY29tPiB3cm90ZToKPiA+IAo+ID4gPiBTaWdu
ZWQtb2ZmLWJ5OiBOYW1oeXVuZyBLaW0gPG5hbWh5dW5nQGdtYWlsLmNvbT4KPiA+ID4gQ2M6IEtB
TUVaQVdBIEhpcm95dWtpIDxrYW1lemF3YS5oaXJveXVAanAuZnVqaXRzdS5jb20+Cj4gPiAKPiA+
IFdoYXQgaXMgdGhlIGJlbmVmaXQgb2YgdGhpcyBwYXRjaCA/Cj4gPiAKPiA+IC1LYW1lCj4gPiAK
PiAKPiBPaCwgSSBqdXN0IHRob3VnaHQgZ2VuZXJhbGx5IGl0J2QgYmV0dGVyIGNhbGwgc3VjaCBh
IChwb3RlbnRpYWxseSkKPiBjb3N0bHkgZnVuY3Rpb24gb3V0c2lkZSBvZiBsb2NrcyBhbmQgaXQg
Y291bGQgcmVkdWNlIGZldyBvZiB0aGVvcmV0aWNhbAo+IGNvbnRlbnRpb25zIGJldHdlZW4gc3dh
cG9ucyBhbmQvb3Igb2Zmcy4gSWYgaXQgZG9lc24ndCBoZWxwIGFueQo+IHJlYWxpc3RpYyBjYXNl
cyBJIGRvbid0IG1pbmQgZGlzY2FyZGluZyBpdC4KPiAKCk15IHBvaW50IGlzLCBwbGVhc2Ugd3Jp
dGUgcGF0Y2ggZGVzY3JpcHRpb24gd2hpY2ggc2hvd3MgZm9yIHdoYXQgdGhpcyBwYXRjIGlzLgpB
bGwgY2xlYW51cCBhcmUgb2theSB0byBtZSBpZiBpdCByZWFzb25hYmxlLiBCdXQgd2l0aG91dCBw
YXRjaCBkZXNjcmlwdGlvbiBhcwoidGhpcyBpcyBqdXN0IGEgY2xlYW51cCwgbm8gZnVuY3Rpb25h
bCBjaGFuZ2UsIGFuZCB0aGUgcmVhc29uIGlzLi4uLiIKd2UgY2Fubm90IG1haW50YWluIHBhdGNo
ZXMuCgpUaGFua3MsCi1LYW1lCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4
LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcvbWFpbG1h
bi9saXN0aW5mby9jb250YWluZXJz

From: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
Date: Tue, 22 Mar 2011 12:04:39 +0900
Message-ID: <1300763079.1483.21.camel__32009.7671625719$1300763149$gmane$org@leonhard>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	<1300452855-10194-3-git-send-email-namhyung@gmail.com>
	<20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110322085938.0691f7f4.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

MjAxMS0wMy0yMiAo7ZmUKSwgMDg6NTkgKzA5MDAsIEtBTUVaQVdBIEhpcm95dWtpOgo+IE9uIEZy
aSwgMTggTWFyIDIwMTEgMjE6NTQ6MTUgKzA5MDAKPiBOYW1oeXVuZyBLaW0gPG5hbWh5dW5nQGdt
YWlsLmNvbT4gd3JvdGU6Cj4gCj4gPiBTaWduZWQtb2ZmLWJ5OiBOYW1oeXVuZyBLaW0gPG5hbWh5
dW5nQGdtYWlsLmNvbT4KPiA+IENjOiBLQU1FWkFXQSBIaXJveXVraSA8a2FtZXphd2EuaGlyb3l1
QGpwLmZ1aml0c3UuY29tPgo+IAo+IFdoYXQgaXMgdGhlIGJlbmVmaXQgb2YgdGhpcyBwYXRjaCA/
Cj4gCj4gLUthbWUKPiAKCk9oLCBJIGp1c3QgdGhvdWdodCBnZW5lcmFsbHkgaXQnZCBiZXR0ZXIg
Y2FsbCBzdWNoIGEgKHBvdGVudGlhbGx5KQpjb3N0bHkgZnVuY3Rpb24gb3V0c2lkZSBvZiBsb2Nr
cyBhbmQgaXQgY291bGQgcmVkdWNlIGZldyBvZiB0aGVvcmV0aWNhbApjb250ZW50aW9ucyBiZXR3
ZWVuIHN3YXBvbnMgYW5kL29yIG9mZnMuIElmIGl0IGRvZXNuJ3QgaGVscCBhbnkKcmVhbGlzdGlj
IGNhc2VzIEkgZG9uJ3QgbWluZCBkaXNjYXJkaW5nIGl0LgoKVGhhbmtzLgoKCi0tIApSZWdhcmRz
LApOYW1oeXVuZyBLaW0KCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZv
dW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcvbWFpbG1hbi9s
aXN0aW5mby9jb250YWluZXJz

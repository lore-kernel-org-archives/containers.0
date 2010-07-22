From: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Fri, 23 Jul 2010 01:08:12 +0200
Message-ID: <AANLkTinFQtwrCC82T9KlKskDV8fn-zYgimyH2wguHkqY__17499.1032378331$1279840140$gmane$org@mail.gmail.com>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de> <20100722193741.GA2688@redhat.com>
	<20100722211856.GA1297@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100722211856.GA1297-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVGh1LCBKdWwgMjIsIDIwMTAgYXQgMjM6MTgsIEdyZWcgS0ggPGdyZWdraEBzdXNlLmRlPiB3
cm90ZToKPj4gRm9yIG15IHRlc3RpbmcgSSBub3cgYWx3YXlzIHVzZSAvY2dyb3VwLyBhbmQgY3Jl
YXRlIGRpcmVjdG9yaWVzIHVuZGVyIGl0Cj4+IC9jZ3JvdXAvYmxraW8gL2Nncm91cC9jcHUgZXRj
IGFuZCBtb3VudCBjb250cm9sbGVycyBvbiByZXNwZWN0aXZlCj4+IGRpcmVjdG9yaWVzLgo+Cj4g
TGVubmFydCBhbmQgS2F5LCBpcyB0aGlzIHdoYXQgc3lzdGVtZCBpcyBkb2luZz8gwqBJIHJlYWxs
eSBkb24ndCB0aGluayB3ZQo+IHNob3VsZCBiZSBhZGRpbmcgYSByb290IC9jZ3JvdXAvIG1vdW50
IHBvaW50IHRvIHRoZSBzeXN0ZW0gZm9yIHNvbWV0aGluZwo+IGxpa2UgdGhpcy4KCkFscmVhZHkg
c29sdmVkLiBTeXN0ZW1kIGFsd2F5cyBtb3VudHMgYW4gZW1wdHkgdG1wZnMgYXQgdGhlICdjZ3Jv
dXAnCm1vdW50cG9pbnQsIGFuZCBzdHVmZiBpcyBmcmVlIHRvIGNyZWF0ZSBzdWJkaXJzIHRoZXJl
LiBTeXN0ZW1kIGl0c2VsZgptb3VudCAnc3lzdGVtZCcgdGhlcmUuCgpJIGd1ZXNzIHRoYXQgY292
ZXJzIGFsbCBuZWVkcyBleHByZXNzZWQgaGVyZSwgYW5kIHdlIGFyZSBoYXBweSB0bwpzd2l0Y2gg
c3lzdGVtZCBvdmVyIGZyb20gL2Nncm91cCB0byAvc3lzL2ZzL2Nncm91cCBhcyBzb29uIGFzIHRo
ZQprZXJuZWwgY2FycmllcyB0aGUgcGF0Y2guCgpUaGFua3MsCktheQpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApD
b250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgt
Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

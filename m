From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH RFC v0 3/3] memcg: implement memory thresholds
Date: Thu, 26 Nov 2009 19:11:46 +0200
Message-ID: <cc557aab0911260911y577e203aha1c74a7f0f361226__7842.72778914801$1259255876$gmane$org@mail.gmail.com>
References: <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259248846.git.kirill@shutemov.name>
	<cover.1259248846.git.kirill@shutemov.name>
	<8524ba285f6dd59cda939c28da523f344cdab3da.1259248846.git.kirill@shutemov.name>
	<d977350fcc9bc3e1fe484440c1fc3a7470a4e26b.1259248846.git.kirill@shutemov.name>
	<661de9470911260903h4996070emec678f09a7ba2c9e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <661de9470911260903h4996070emec678f09a7ba2c9e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVGh1LCBOb3YgMjYsIDIwMDkgYXQgNzowMyBQTSwgQmFsYmlyIFNpbmdoIDxiYWxiaXJAbGlu
dXgudm5ldC5pYm0uY29tPiB3cm90ZToKPiBPbiBUaHUsIE5vdiAyNiwgMjAwOSBhdCA5OjU3IFBN
LCBLaXJpbGwgQS4gU2h1dGVtb3YKPiA8a2lyaWxsQHNodXRlbW92Lm5hbWU+IHdyb3RlOgo+PiBJ
dCBhbGxvd3MgdG8gcmVnaXN0ZXIgbXVsdGlwbGUgbWVtb3J5IHRocmVzaG9sZHMgYW5kIGdldHMg
bm90aWZpY2F0aW9ucwo+PiB3aGVuIGl0IGNyb3NzZXMuCj4+Cj4+IFRvIHJlZ2lzdGVyIGEgdGhy
ZXNob2xkIGFwcGxpY2F0aW9uIG5lZWQ6Cj4+IC0gY3JlYXRlIGFuIGV2ZW50ZmQ7Cj4+IC0gb3Bl
biBmaWxlIG1lbW9yeS51c2FnZV9pbl9ieXRlcyBvZiBhIGNncm91cAo+PiAtIHdyaXRlIHN0cmlu
ZyAiPGV2ZW50X2ZkPiA8bWVtb3J5LnVzYWdlX2luX2J5dGVzPiA8dGhyZXNob2xkPiIgdG8KPj4g
wqBjZ3JvdXAuZXZlbnRfY29udHJvbC4KPj4KPj4gQXBwbGljYXRpb24gd2lsbCBiZSBub3RpZmll
ZCB0aHJvdWdoIGV2ZW50ZmQgd2hlbiBtZW1vcnkgdXNhZ2UgY3Jvc3Nlcwo+PiB0aHJlc2hvbGQg
aW4gYW55IGRpcmVjdGlvbi4KPj4KPj4gU2lnbmVkLW9mZi1ieTogS2lyaWxsIEEuIFNodXRlbW92
IDxraXJpbGxAc2h1dGVtb3YubmFtZT4KPj4KPgo+IEkgZG9uJ3Qgc2VlIHRoZSBwYXRjaGVzIGF0
dGFjaGVkIG9yIGlubGluZWQgaW4gdGhlIGVtYWlscyB0aGF0IGZvbGxvdwoKU29ycnkuIFJlc2Vu
dC4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFp
bmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpo
dHRwczovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFp
bmVycw==

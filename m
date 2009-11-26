From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH RFC v0 0/3] cgroup notifications API and memory thresholds
Date: Thu, 26 Nov 2009 20:38:27 +0200
Message-ID: <cc557aab0911261038y63ee617oad5198d04cc38aca__19991.632019128$1259260756$gmane$org@mail.gmail.com>
References: <cover.1259248846.git.kirill@shutemov.name>
	<4B0EB4B6.5000702@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B0EB4B6.5000702-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVGh1LCBOb3YgMjYsIDIwMDkgYXQgNzowMiBQTSwgRGFuaWVsIExlemNhbm8gPGRhbmllbC5s
ZXpjYW5vQGZyZWUuZnI+IHdyb3RlOgo+IEtpcmlsbCBBLiBTaHV0ZW1vdiB3cm90ZToKPj4KPj4g
SXQncyBteSBmaXJzdCBhdHRlbXB0IHRvIGltcGxlbWVudCBjZ3JvdXAgbm90aWZpY2F0aW9ucyBB
UEkgYW5kIG1lbW9yeQo+PiB0aHJlc2hvbGRzIG9uIHRvcCBvZiBpdC4gVGhlIGlkZWEgb2YgQVBJ
IHdhcyBwcm9wb3NlZCBieSBQYXVsIE1lbmFnZS4KPj4KPj4gSXQgbGFja3Mgc29tZSBpbXBvcnRh
bnQgZmVhdHVyZXMgYW5kIG5lZWQgbW9yZSB0ZXN0aW5nLCBidXQgSSB3YW50IHB1Ymxpc2gKPj4g
aXQgYXMgc29vbiBhcyBwb3NzaWJsZSB0byBnZXQgZmVlZGJhY2sgZnJvbSBjb21tdW5pdHkuCj4+
Cj4+IFRPRE86Cj4+IMKgLSBtZW1vcnkgdGhyZXNob2xkcyBvbiByb290IGNncm91cDsKPj4gwqAt
IG1lbXN3IHN1cHBvcnQ7Cj4+IMKgLSBkb2N1bWVudGF0aW9uLgo+Pgo+Cj4gTWF5YmUgaXQgd291
bGQgYmUgaW50ZXJlc3RpbmcgdG8gZG8gdGhhdCBmb3IgdGhlIC9jZ3JvdXAvPG5hbWU+L3Rhc2tz
IGJ5Cj4gc2VuZGluZyBpbiB0aGUgZXZlbnQgdGhlIG51bWJlciBvZiB0YXNrcyBpbiB0aGUgY2dy
b3VwIHdoZW4gaXQgY2hhbmdlcywgc28KPiBpdCBtb3JlIGVhc3kgdG8gZGV0ZWN0IDAgcHJvY2Vz
cyBldmVudCBhbmQgdGhlbiByZW1vdmUgdGhlIGNncm91cCBkaXJlY3RvcnksCj4gbm8gPwoKSSds
bCBkbyBpdCBsYXRlci4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3Vu
ZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlz
dGluZm8vY29udGFpbmVycw==

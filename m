From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC] mnt: umount mounts one by one in umount_tree()
Date: Wed, 14 Jun 2017 04:37:19 -0500
Message-ID: <87wp8ec3lc.fsf@xmission.com>
References: <20170512070838.5037-1-avagin@openvz.org>
	<1497405190.2595.3.camel@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1497405190.2595.3.camel-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> (Ian Kent's message of "Wed,
	14 Jun 2017 09:53:10 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

SWFuIEtlbnQgPHJhdmVuQHRoZW1hdy5uZXQ+IHdyaXRlczoKCj4gT24gRnJpLCAyMDE3LTA1LTEy
IGF0IDAwOjA4IC0wNzAwLCBBbmRyZWkgVmFnaW4gd3JvdGU6Cj4+IFdpdGggdGhpcyBwYXRjaCwg
d2UgZG9uJ3QgdHJ5IHRvIHVtb3VudCBhbGwgbW91bnRzIG9mIGEgdHJlZSB0b2dldGhlci4KPj4g
SW5zdGVhZCBvZiB0aGlzIHdlIHVtb3VudCB0aGVtIG9uZSBieSBvbmUuIEluIHRoaXMgY2FzZSwg
d2Ugc2VlIGEgc2lnbmlmaWNhbnQKPj4gaW1wcm92ZW1lbnQgaW4gcGVyZm9ybWFuY2UgZm9yIHRo
ZSB3b3Jz0LUgY2FzZS4KPgo+IEluZGVlZCwgdW1vdW50IGhhcyBiZWVuIHZlcnkgc2xvdyBmb3Ig
YSB3aGlsZSBub3cuCj4gRXZlbiBhIG1vZGVyYXRlbHkgbGFyZ2UgbnVtYmVyIG9mIG1vdW50cyAo
fjEwMDAwKSBiZWNvbWUgcGFpbmZ1bGx5IHNsb3cuCj4KPiBSZSB5b3Ugc3RpbGwgcGVydXNpbmcg
dGhpcz8KPiBBbnl0aGluZyBJIGNhbiBkbyB0byBoZWxwPwo+Cj4gRXJpYywgd2hhdCBhcmUgeW91
ciB0aG91Z2h0cyBvbiB0aGlzIGxhdGVzdCBhdHRlbXB0PwoKSSBoYXZlIHNvbWV0aGluZyBzbGln
aHRseSBtb3JlIHJlY2VudC4gIFBsZWFzZSBjaGVja291dCBteSBmb3ItbmV4dApicmFuY2ggb2Yg
bXkgdXNlcm5zIHRyZWU6CgpnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5l
bC9naXQvZWJpZWRlcm0vdXNlci1uYW1lc3BhY2UuZ2l0IGZvci1uZXh0CgpUaGVyZSBpcyBvbmUg
b3BlbiBhcmVhIG9mIHNlbWFudGljcyB0aGF0IEkgbG9va2luZyBhdCB3aXRoIFJhbSBQYWkgaW4K
dGhlIGhvcGVzIHdlIGNhbiBkcml2ZSBjb25zZW5zdXMgYmVmb3JlIHdlIHRha2UgYW55IHBhdGNo
ZXMgZm9yCmJldHRlciBjaGVja3BvaW50LXJlc3RhcnQgc3VwcG9ydC4KCkVyaWMKCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGlu
ZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0
cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

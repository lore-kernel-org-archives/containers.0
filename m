From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Fri, 20 Oct 2017 10:15:25 +1100
Message-ID: <b0a59b79-64a5-feeb-7f85-ec0f482f0b96__39611.1118644059$1508454971$gmane$org@suse.de>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<2307769.VGpzlLa4Dp@x2>
	<20171019195747.4ssujtaj3f5ipsoh@madcap2.tricolour.ca>
	<8f495870-dd6c-23b9-b82b-4228a441c729@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f495870-dd6c-23b9-b82b-4228a441c729-l3A5Bk7waGM@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
List-Id: containers.vger.kernel.org

Pj4+PiBUaGUgcmVnaXN0cmF0aW9uIGlzIGEgcHNldWRvIGZpbGVzeXN0ZW0gKHByb2MsIHNpbmNl
IFBJRCB0cmVlIGFscmVhZHkKPj4+PiBleGlzdHMpIHdyaXRlIG9mIGEgdThbMTZdIFVVSUQgcmVw
cmVzZW50aW5nIHRoZSBjb250YWluZXIgSUQgdG8gYSBmaWxlCj4+Pj4gcmVwcmVzZW50aW5nIGEg
cHJvY2VzcyB0aGF0IHdpbGwgYmVjb21lIHRoZSBmaXJzdCBwcm9jZXNzIGluIGEgbmV3Cj4+Pj4g
Y29udGFpbmVyLsKgIFRoaXMgd3JpdGUgbWlnaHQgcGxhY2UgcmVzdHJpY3Rpb25zIG9uIG1vdW50
IG5hbWVzcGFjZXMKPj4+PiByZXF1aXJlZCB0byBkZWZpbmUgYSBjb250YWluZXIsIG9yIGF0IGxl
YXN0IGNhcmVmdWwgY2hlY2tpbmcgb2YKPj4+PiBuYW1lc3BhY2VzIGluIHRoZSBrZXJuZWwgdG8g
dmVyaWZ5IHBlcm1pc3Npb25zIG9mIHRoZSBvcmNoZXN0cmF0b3IgCj4+Pj4gc28gaXQKPj4+PiBj
YW4ndCBjaGFuZ2UgaXRzIG93biBjb250YWluZXIgSUQuwqAgQSBiaW5kIG1vdW50IG9mIG5zZnMg
bWF5IGJlCj4+Pj4gbmVjZXNzYXJ5IGluIHRoZSBjb250YWluZXIgb3JjaGVzdHJhdG9yJ3MgbW50
TlMuCj4+Pj4gTm90ZTogVXNlIGEgMTI4LWJpdCBzY2FsYXIgcmF0aGVyIHRoYW4gYSBzdHJpbmcg
dG8gbWFrZSBjb21wYXJlcyBmYXN0ZXIKPj4+PiBhbmQgc2ltcGxlci4KPj4+Pgo+Pj4+IFJlcXVp
cmUgYSBuZXcgQ0FQX0NPTlRBSU5FUl9BRE1JTiB0byBiZSBhYmxlIHRvIGNhcnJ5IG91dCB0aGUK
Pj4+PiByZWdpc3RyYXRpb24uCj4+Pgo+Pj4gV291bGRuJ3QgQ0FQX0FVRElUX1dSSVRFIGJlIHN1
ZmZpY2llbnQ/IEFmdGVyIGFsbCwgdGhpcyBpcyBmb3IgYXVkaXRpbmcuCj4+Cj4+IE5vLCBiZWNh
dXNlIHRoZW4gYW55IHByb2Nlc3Mgd2l0aCB0aGF0IGNhcGFiaWxpdHkgKHZzZnRwZCkgY291bGQg
Y2hhbmdlCj4+IGl0cyBvd24gY29udGFpbmVyIElELsKgIFRoaXMgaXMgZGlzY3Vzc2VkIG1vcmUg
aW4gb3RoZXIgcGFydHMgb2YgdGhlCj4+IHRocmVhZC4uLgo+IAo+IE5vdCBpZiB3ZSBtYWtlIHRo
ZSBjb250YWluZXIgSUQgYXBwZW5kLW9ubHkgKHRvIHN1cHBvcnQgbmVzdGluZyksIG9yIAo+IHdy
aXRlLW9uY2UgKHRoZSBvdGhlciBpZGVhIHRocm93biBhcm91bmQpLiBJbiB0aGF0IGNhc2UsIHlv
dSBjYW4ndCBtb3ZlIAo+ICJvdXQiIGZyb20gYSBwYXJ0aWN1bGFyIGNvbnRhaW5lciBJRCwgeW91
IGNhbiBvbmx5IGdvICJkZWVwZXIiLiBUaGVzZSAKPiBzZW1hbnRpY3MgZG9uJ3QgbWFrZSBzZW5z
ZSBmb3IgZ2VuZXJpYyBjb250YWluZXJzLCBidXQgc2luY2UgdGhlIHBvaW50IAo+IG9mIHRoaXMg
ZmFjaWxpdHkgaXMgKnNwZWNpZmljYWxseSogZm9yIGF1ZGl0IEkgaW1hZ2luZSB0aGF0IG5vdCBi
ZWluZyAKPiBhYmxlIHRvIG1vdmUgYSBwcm9jZXNzIGZyb20gYSBzdWItY29udGFpbmVyJ3MgSUQg
aXMgYSBiZW5lZml0LgoKW1RoaXMgYXNzdW1lcyBpdCdzIENBUF9BVURJVF9DT05UUk9MIHdoaWNo
IGlzIHdoYXQgd2UgYXJlIGRpc2N1c3NpbmcgaW4gCmEgc2lzdGVyIHRocmVhZC5dCgotLSAKQWxl
a3NhIFNhcmFpClNlbmlvciBTb2Z0d2FyZSBFbmdpbmVlciAoQ29udGFpbmVycykKU1VTRSBMaW51
eCBHbWJICmh0dHBzOi8vd3d3LmN5cGhhci5jb20vCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNA
bGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24u
b3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

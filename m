From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Kernel panic with user namespaces
Date: Wed, 27 May 2015 10:16:14 -0500
Message-ID: <87pp5mqce9.fsf__6737.24768353185$1432740114$gmane$org@x220.int.ebiederm.org>
References: <1431959951.5030.2.camel@redhat.com>
	<1432642765.19400.2.camel@redhat.com>
	<87vbff1es3.fsf@x220.int.ebiederm.org>
	<CA+5PVA7wpFwMSHkAQoVzthYSrxJXfpZo5vLGKYAHggN+ujJyow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+5PVA7wpFwMSHkAQoVzthYSrxJXfpZo5vLGKYAHggN+ujJyow-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Josh Boyer's message of "Wed, 27 May 2015 10:06:53 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Linux-Kernel@Vger. Kernel. Org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Sm9zaCBCb3llciA8andib3llckBmZWRvcmFwcm9qZWN0Lm9yZz4gd3JpdGVzOgoKPiBPbiBUdWUs
IE1heSAyNiwgMjAxNSBhdCAxMjozMSBQTSwgRXJpYyBXLiBCaWVkZXJtYW4KPiA8ZWJpZWRlcm1A
eG1pc3Npb24uY29tPiB3cm90ZToKPj4gQWxleGFuZGVyIExhcnNzb24gPGFsZXhsQHJlZGhhdC5j
b20+IHdyaXRlczoKPj4KPj4+IE9uIG3DpW4sIDIwMTUtMDUtMTggYXQgMTY6MzkgKzAyMDAsIEFs
ZXhhbmRlciBMYXJzc29uIHdyb3RlOgo+Pj4KPj4+IERpZG4ndCBnZXQgYW55IHJlcGxpZXMgdG8g
dGhlIGJlbG93IGtlcm5lbCBwYW5pYyAodGVzdGNhc2UgYXR0YWNoZWQpLAo+Pj4gd2hpY2ggc2Vl
bXMgcmF0aGVyIGltcG9ydGFudCB0byBmaXguIFJlcG9zdGluZyB0byBhIHdpZGVyIGF1ZGllbmNl
Lgo+Pgo+PiBCdWdnZXJlZCBiYWNrcG9ydCBncmVnIGFscmVhZHkgaGFzIHRoZSBmaXggc29tZXdo
ZXJlIGluIGhpcyBxdWV1ZS4KPgo+IElzIGl0IGZzX3Bpbi1hbGxvdy1mb3ItdGhlLXBvc3NpYmls
aXR5LXRoYXQtbV9saXN0LW9yLXNfbGlzdC1nby11bnVzZWQucGF0Y2gKPiBvciBtbnQtZmFpbC1j
b2xsZWN0X21vdW50cy13aGVuLWFwcGxpZWQtdG8tdW5tb3VudGVkLW1vdW50cy5wYXRjaCA/Cj4g
KE9yIGJvdGggSSBndWVzcy4pICBUaG9zZSBhcmUgdGhlIG9ubHkgMiBwYXRjaGVzIHF1ZXVlZCBm
b3IgNC4wIHN0YWJsZQo+IHJpZ2h0IG5vdy4KCkJvdGggZml4IHRoZSBidWdnZXJlZCBiYWNrcG9y
dC4KCmZzX3Bpbi1hbGxvdy1mb3ItdGhlLXBvc3NpYmlsaXR5LXRoYXQtbV9saXN0LW9yLXNfbGlz
dC1nby11bnVzZWQucGF0Y2gKZml4ZXMgdGhlIGNyYXNoLgoKRXJpYwpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApD
b250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhm
b3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

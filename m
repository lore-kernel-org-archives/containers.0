From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH net-next v3 1/4] netns: add genl cmd to add and get
	peer netns ids
Date: Fri, 03 Oct 2014 14:22:26 +0200
Message-ID: <542E9502.1040104__11611.7789796137$1412338967$gmane$org@6wind.com>
References: <542D5726.8070308@6wind.com>	<1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>	<1412257690-31253-2-git-send-email-nicolas.dichtel@6wind.com>
	<87tx3mmflp.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tx3mmflp.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

TGUgMDIvMTAvMjAxNCAyMTozMywgRXJpYyBXLiBCaWVkZXJtYW4gYSDDqWNyaXQgOgo+IE5pY29s
YXMgRGljaHRlbCA8bmljb2xhcy5kaWNodGVsQDZ3aW5kLmNvbT4gd3JpdGVzOgo+Cj4+IFdpdGgg
dGhpcyBwYXRjaCwgYSB1c2VyIGNhbiBkZWZpbmUgYW4gaWQgZm9yIGEgcGVlciBuZXRucyBieSBw
cm92aWRpbmcgYSBGRCBvciBhCj4+IFBJRC4gVGhlc2UgaWRzIGFyZSBsb2NhbCB0byBuZXRucyAo
aWUgdmFsaWQgb25seSBpbnRvIG9uZSBuZXRucykuCj4+Cj4+IFRoaXMgd2lsbCBiZSB1c2VmdWwg
Zm9yIG5ldGxpbmsgbWVzc2FnZXMgd2hlbiBhIHgtbmV0bnMgaW50ZXJmYWNlIGlzCj4+IGR1bXBl
ZC4KPgo+IFlvdSBoYXZlIGEgImlkIC0+IHN0cnVjdCBuZXQgKiIgdGFibGUgYnV0IHlvdSBkb24n
dCBoYXZlIGEKPiAic3RydWN0IG5ldCAqIC0+IGlkIiB0YWJsZSB3aGljaCBsb29rcyBsaWtlIGl0
IHdpbGwgaW1wYWN0IHRoZQo+IHBlcmZvcm1hbmNlIG9mIHBlZXJuZXQyaWQgYXQgc2NhbGUuCkl0
IGlzIGluZGlyZWN0bHkgc3RvcmVzIGluICdzdHJ1Y3QgaWRyJy4gSXQgY2FuIGJlIG9wdGltaXpl
ZCBsYXRlciwgd2l0aCBhCnByb3BlciBhbGdvcml0aG0gdG8gZmluZCBxdWlja2x5IHRoaXMgJ3N0
cnVjdCBuZXQgKicgKGhhc2ggdGFibGU/IHNvbWV0aGluZwplbHNlPykuIEEgYmFzaWMgYWxnb3Jp
dGhtIHdpbGwgbm90IGJlIG1vcmUgc2NhbGFibGUgdGhhbiB0aGUgY3VycmVudAppZHJfZm9yX2Vh
Y2goKS4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29u
dGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9y
ZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250
YWluZXJz

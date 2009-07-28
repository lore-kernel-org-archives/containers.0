From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V6
Date: Tue, 28 Jul 2009 19:36:31 +0800
Message-ID: <4A6EE2BF.9040803__20078.6889916801$1248781220$gmane$org@cn.fujitsu.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<4A6D0C9A.3080600@cn.fujitsu.com>
	<20090727125503.GA24449@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090727125503.GA24449-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Vml2ZWsgR295YWwgd3JvdGU6Cj4gT24gTW9uLCBKdWwgMjcsIDIwMDkgYXQgMTA6MTA6MzRBTSAr
MDgwMCwgR3VpIEppYW5mZW5nIHdyb3RlOgo+PiBIae+8jAo+Pgo+PiBIZXJlIGFyZSBzb21lIGZp
byB0ZXN0IHJlc3VsdHMgZm9yIElPIENvbnRyb2xsZXIgVjYgYnVpbHQgYW5kIG5vdCBidWlsdC4K
Pj4gSW96b25lIHRlc3QgcmVzdWx0cyBhcmUgYWxzbyBhdHRhY2hlZC4KPj4KPiAKPiBIaSBHdWks
Cj4gCj4gVGhhbmtzIGEgbG90IGZvciBzb21lIHBlcmZvcm1hbmNlIG51bWJlcnMuIEl0IHNlZW1z
IHRvIGJlIGEgbWl4ZWQgY2hhcnQuCj4gUGVyZm9ybWFuY2UgZ2FpbnMgYXQgc29tZSBwbGFjZXMg
YW5kIGxvc3MgYXQgb3RoZXJzLiBJIGFtIGN1cmlvdXMgYWJvdXQKPiB0aGF0IC03LjAlIGZvciBu
b3JtYWwgd3JpdGVzLiBOb3Qgc3VyZSB3aGF0IGNhbiBjb250cmlidXRlIHRvIHRoYXQuCj4gCj4g
V2hhdCB3YXMgdGhlIHZhbHVlIG9mICJmYWlybmVzcyIgcGFyYW1ldGVyIHdoZW4geW91IHJhbiB0
aG9zZSB0ZXN0cz8gQ2FuIHlvdQo+IHBsZWFzZSBzZXQgZmFpcm5lc3MgPSAwIGFuZCByZS1ydW4g
dGhlIHRlc3RzIChpZiB5b3UgaGF2ZSBhbHJlYWR5IG5vdCBkb25lIHNvKS4KPiAKPiBCeSBkZWZh
dWx0IGZhaXJuZXNzIGlzIHNldCB0byAxIGluIFY2LiBXaXRoIGZhaXJuZXNzID0gMCwgd2Ugc2hv
dWxkIGJlIHZlcnkKPiBjbG9zZSB0byBleGlzdGluZyBDRlEgYmVoYXZpb3IuIElmIG5vdCwgdGhl
biB3ZSBuZWVkIHRvIGRpdmUgZGVlcGVyIGFuZAo+IHNlZSB3aHkgdmFyaWF0aW9ucyBhcmUgaGFw
cGVuaW5nLgoKICBIaSBWaXZlaywKCiAgSSB0ZXN0ZWQgd2l0aCBkZWZhdWx0IGZhaXJuZXNzIHZh
bHVlLCBpJ2xsIHJlLXRlc3QgaXQgd2hlbiBmYWlybmVzcyBpcyBzZXQgdG8gMC4KCj4gCj4gSXMg
aXQgYWxzbyBwb3NzaWJsZSB0byBydW4gdGhlIHNhbWUgdGVzdHMgd2l0aCBWNy4gCgogIFN1cmUu
CgotLSAKUmVnYXJkcwpHdWkgSmlhbmZlbmcKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlz
dHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eC1mb3VuZGF0aW9uLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

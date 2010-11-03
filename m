From: jovi zhang <bookjovi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
Date: Wed, 3 Nov 2010 23:20:32 +0800
Message-ID: <AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-__45723.4256472022$1288798208$gmane$org@mail.gmail.com>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
	<AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com>
	<20101031173336.GA28141@balbir.in.ibm.com>
	<alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
	<alpine.DEB.2.00.1011030937580.10599@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1011030937580.10599-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gV2VkLCBOb3YgMywgMjAxMCBhdCAxMDozOCBQTSwgQ2hyaXN0b3BoIExhbWV0ZXIgPGNsQGxp
bnV4LmNvbT4gd3JvdGU6Cj4gT24gTW9uLCAxIE5vdiAyMDEwLCBKZXNwZXIgSnVobCB3cm90ZToK
Pgo+PiBPbiBTdW4sIDMxIE9jdCAyMDEwLCBCYWxiaXIgU2luZ2ggd3JvdGU6Cj4KPj4gPiA+IFRo
ZXJlIGFyZSBzbyBtYW55IHBsYWNlZCBuZWVkIHZ6YWxsb2MuCj4+ID4gPiBUaGFua3MsIEplc3Bl
ci4KPgo+Cj4gQ291bGQgd2UgYXZvaWQgdGhpcyBwYWluZnVsIGV4ZXJjaXNlIHdpdGggYSAic2Vt
YW50aWMgcGF0Y2giPwo+IC0tCj4gVG8gdW5zdWJzY3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQg
dGhlIGxpbmUgInVuc3Vic2NyaWJlIGxpbnV4LWtlcm5lbCIgaW4KPiB0aGUgYm9keSBvZiBhIG1l
c3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2VybmVsLm9yZwo+IE1vcmUgbWFqb3Jkb21vIGluZm8g
YXQgwqBodHRwOi8vdmdlci5rZXJuZWwub3JnL21ham9yZG9tby1pbmZvLmh0bWwKPiBQbGVhc2Ug
cmVhZCB0aGUgRkFRIGF0IMKgaHR0cDovL3d3dy50dXgub3JnL2xrbWwvCj4KQ2FuIHdlIG1ha2Ug
YSBncmVwIHNjcmlwdCB0byB3YWxrIGFsbCBmaWxlcyB0byBmaW5kIHZ6YWxsb2MgdXNhZ2UgbGlr
ZSB0aGlzPwpObyBuZWVkIHRvIHNlbmQgcGF0Y2ggbWFpbCBvbmUgYnkgb25lIGxpa2UgdGhpcy4K
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVy
cyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRw
czovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVy
cw==

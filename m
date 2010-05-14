From: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Date: Fri, 14 May 2010 16:12:41 +0800
Message-ID: <AANLkTimAfd5vWURp75galRdoHxszFS7GYsOfGHZLD3h7__20019.2476310351$1273824908$gmane$org@mail.gmail.com>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	<1273756816.5605.3547.camel@twins>
	<AANLkTinLT5g5SKjqmQlS2kxvvMq1gsi1jPDgOKTnrT-q@mail.gmail.com>
	<1273824214.5605.3625.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1273824214.5605.3625.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "James E.J. Bottomley" <James.Bottomley-l3A5Bk7waGM@public.gmane.org>, Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gRnJpLCBNYXkgMTQsIDIwMTAgYXQgNDowMyBQTSwgUGV0ZXIgWmlqbHN0cmEgPHBldGVyekBp
bmZyYWRlYWQub3JnPiB3cm90ZToKPiBPbiBUaHUsIDIwMTAtMDUtMTMgYXQgMjI6MDggKzA4MDAs
IENoYW5nbGkgR2FvIHdyb3RlOgo+PiA+IE5BSywgSSByZWFsbHkgdXR0ZXJseSBkaXNsaWtlIHRo
YXQgaW5hdG9taWMgYXJndW1lbnQuIFRoZSBhbGxvYyBzaWRlCj4+ID4gZG9lc24ndCBmdW5jdGlv
biBpbiBhdG9taWMgY29udGV4dCBlaXRoZXIuIFBsZWFzZSBrZWVwIHRoZSB0aGluZwo+PiA+IHN5
bW1ldHJpYyBpbiB0aGF0IHJlZ2FyZHMuCj4+ID4KPj4KPj4gVGhlcmUgYXJlIHNvbWUgdXNlcnMs
IHdobyByZWxlYXNlIG1lbW9yeSBpbiBhdG9taWMgY29udGV4dC4gZm9yCj4+IGV4YW1wbGU6IGZz
L2ZpbGUuYzogZmRtZW0uCj4KPiB1cmdoLCBidXQgeWVhaCwgYXNpZGUgZnJvbSBub3QgdXNpbmcg
dm1hbGxvYyB0byBhbGxvY2F0ZSBmZCB0YWJsZXMgb25lCj4gbmVlZHMgdG8gZGVhbCB3aXRoIHRo
aXMuCj4KPiBCdXQgaWYgdGhhdCBpcyB0aGUgb25seSBvbmUsIEknZCBsZXQgdGhlbSBkbyB0aGUg
d29ya3F1ZXVlIHRoaW5nIHRoYXQncwo+IGFscmVhZHkgdGhlcmUuIElmIHRoZXJlIHJlYWxseSBh
cmUgbW9yZSBwZW9wbGUgd2FudGluZyB0byBkbyB0aGlzLCB0aGVuCj4gbWF5YmUgYWRkOiBrdmZy
ZWVfYXRvbWljKCkuCj4KClRldHN1byBoYXMgcG9pbnRlZCBhbm90aGVyIG9uZSBpbiBhcHBhcm1v
ci4KaHR0cDovL2tlcm5lbC51YnVudHUuY29tL2dpdD9wPWpqL3VidW50dS1sdWNpZC5naXQ7YT1i
bG9iZGlmZjtmPXNlY3VyaXR5L2FwcGFybW9yL21hdGNoLmM7aD1kMmNkNTU0MTlhY2ZjYWU4NWNi
NzQ4YzhmODM3YTQzODRhM2EwZDI5O2hwPWFmYzJkZDIyNjBlZGZmY2Y4ODUyMWFlODY0NThhZDAz
YWE4ZWExMmM7aGI9ZjVlYmE0YjBhMDFjYzY3MWFmZmE0MjliYTE1MTJiNmRlN2NhZWI1YjtocGI9
YWJkZmY5ZGRhZjI2NDRkMGY5OTYyNDkwZjczZTAzMDgwNmJhOTBkMwosIHRob3VnaCBhcHBhcm1v
ciBoYXNuJ3QgYmVlbiBtZXJnZWQgaW50byBtYWlubGluZS4KCi0tIApSZWdhcmRz77yMCkNoYW5n
bGkgR2FvKHhpYW9zdW9AZ21haWwuY29tKQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3Rz
LmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcv
bWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

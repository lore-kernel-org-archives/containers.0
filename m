From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] BUG in tty_open when using containers and ptrace
Date: Thu, 23 Jul 2009 10:04:14 +0200
Message-ID: <4A68197E.4070707@free.fr>
References: <20090714064905.GA25278@us.ibm.com>	<20090714103129.GB12958@megiteam.pl>	<20090715044744.GA25745@us.ibm.com>	<20090715131923.GB21417@megiteam.pl>	<20090718205244.GA23625@us.ibm.com>	<20090719071531.GA20818@megiteam.pl>	<20090722064120.GA24373@us.ibm.com>	<20090722222550.GA633@megiteam.pl>	<20090723012733.GB27764@us.ibm.com>
	<4A67C187.5000201@zytor.com> <20090723074736.GA20236@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723074736.GA20236-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

R3J6ZWdvcnogTm9zZWsgd3JvdGU6Cj4gT24gxZtybywgbGlwIDIyLCAyMDA5IGF0IDA2OjQ4OjU1
IC0wNzAwLCBILiBQZXRlciBBbnZpbiB3cm90ZToKPiAgIAo+Pj4gfCBCaXNlY3RpbmcuLi4KPj4+
ICAgICAgIAo+Cj4gMi42LjI3IGlzIGdvb2QsIDIuNi4yOCBpcyBiYWQuIFNvbWUgNjAwLW9kZCBy
ZXZpc2lvbnMgc3RpbGwgdG8gZ28gKHdpbGwKPiBjb250aW51ZSBpbiB0aGUgZXZlbmluZykuCj4K
PiAgIAo+PiBJbnRlcmVzdGluZy4uLiBJIGhhdmUgdG8gc2F5IEknbSBtb3JlIHRoYW4gYSBiaXQg
c3VycHJpc2VkIHRoYXQgeW91IGNhbgo+PiBtb3VudCBhIGZpbGVzeXN0ZW0gb24gdG9wIG9mIGEg
Y2hhcmFjdGVyIGRldmljZSBub2RlIGF0IGFsbCwgYnV0IHRoZXJlCj4+IGlzbid0IHJlYWxseSBh
IGZ1bmRhbWVudGFsIHJlYXNvbiB3aHkgeW91IGNvdWxkbid0IGRvIGl0LCBzby4uLgo+PiAgICAg
Cj4KPiBBY3R1YWxseSBpdCdzIG1vdW50aW5nIGEgZGV2aWNlIG5vZGUgb3ZlciBhIGRldmljZSBu
b2RlLiBJIHdhcyByZWFsbHkKPiBzdXJwcmlzZWQgd2hlbiBJIGxlYXJudCB0aGF0IHlvdSBjYW4g
bW91bnQgLS1iaW5kIG90aGVyIHRoaW5ncyB0aGFuCj4gZGlyZWN0b3JpZXMgYnV0IHRob3VnaHQg
aXQgY291bGQgYmUgdGhlIGNsb3Nlc3QgYSBjb250YWluZXIgY2FuIGdldCB0byBhCj4gcmVhbCBj
b25zb2xlLiBTbyBtb3VudGluZyAvZGV2L3B0cy8wIG92ZXIgL2Rldi9jb25zb2xlIHNlZW1lZCBx
dWl0ZQo+IG5hdHVyYWwgdG8gbWUuCj4gICAKQWJzb2x1dGVseSBhbmQgdGhpcyBpcyBob3cgaXMg
ZG9uZSB0aGUgY29uc29sZSAvIHR0eSBtYW5hZ2VtZW50IGluIGxpYmx4Yy4KQmluZCBtb3VudGlu
ZyBpcyB2ZXJ5IHBvd2VyZnVsIHdoZW4gaXQgaXMgdXNlZCB3aXRoIHRoZSBtb3VudCBuYW1lc3Bh
Y2UgCmJlY2F1c2UgeW91IGNhbiBoYXZlIG11bHRpcGxlIHByb2Nlc3NlcyBpbiBkaWZmZXJlbnQg
bW91bnQgbmFtZXNwYWNlcyAKYWNjZXNzaW5nIHRoZSBzYW1lIHBhdGggYnV0IHdpdGggZGlmZmVy
ZW50IHJlYWwgbG9jYXRpb25zIDogYSBwZXJmZWN0IApmZWF0dXJlIGZvciB0aGUgY29udGFpbmVy
cyA6KQoKICAtLSBEYW5pZWwKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1m
b3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4v
bGlzdGluZm8vY29udGFpbmVycw==

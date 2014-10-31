From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4 1/4] netns: add genl cmd to add and get peer
	netns ids
Date: Fri, 31 Oct 2014 10:41:24 +0100
Message-ID: <54535944.6050405__22512.5737990767$1414748502$gmane$org@6wind.com>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>	<1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>	<1414682728-4532-2-git-send-email-nicolas.dichtel@6wind.com>
	<874mulh0cs.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874mulh0cs.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

TGUgMzAvMTAvMjAxNCAxOTozNSwgRXJpYyBXLiBCaWVkZXJtYW4gYSDDqWNyaXQgOgo+IE5pY29s
YXMgRGljaHRlbCA8bmljb2xhcy5kaWNodGVsQDZ3aW5kLmNvbT4gd3JpdGVzOgo+Cj4+IFdpdGgg
dGhpcyBwYXRjaCwgYSB1c2VyIGNhbiBkZWZpbmUgYW4gaWQgZm9yIGEgcGVlciBuZXRucyBieSBw
cm92aWRpbmcgYSBGRCBvciBhCj4+IFBJRC4gVGhlc2UgaWRzIGFyZSBsb2NhbCB0byBuZXRucyAo
aWUgdmFsaWQgb25seSBpbnRvIG9uZSBuZXRucykuCj4KPiBTY3JhdGNoZXMgaGVhZC4gIERvIHlv
dSBhY3R1YWxseSBmaW5kIHZhbHVlIGluIHVzaW5nIHRoZSBwaWQgaW5zdGVhZCBvZgo+IGEgZmls
ZSBkZXNjcmlwdG9yPwpJIGNvcGllZCB0aGUgbWVjaGFuaXNtIGZyb20gcnRubF9saW5rX2dldF9u
ZXQoKToKRmlyc3QgY2hlY2sgaWYgdGhlIHVzZXIgcHJvdmlkZXMgYSBQSUQsIGlmIG5vdCwgY2hl
Y2sgZm9yIGEgRkQuCgo+Cj4gRG9pbmcgdGhpbmdzIGJ5IHBpZCB3YXMgYW4gZWFybHkgYXR0ZW1w
dCB0byBtYWtlIHRoaW5ncyB3b3JrLCBhbmQgaGFzCj4gYmVlbiBhIGJpdCBjbHV0c3kuICBJZiB5
b3UgZG9uJ3QgZmluZCB2YWx1ZSBpbiBpdCBJIHdvdWxkIHJlY29tbWVuZCBqdXN0Cj4gc3VwcG9y
dGluZyBnZXR0aW5nL3NldHRpbmcgdGhlIG5ldHdvcmsgbmFtZXNwYWNlIGJ5IGZpbGUgZGVzY3Jp
cHRvci4KSG1tLCBpZiBJIHVuZGVyc3RhbmQgd2VsbCwgaXQncyB3aGF0IGlzIGRvbmUgaW4gdGhl
IHBhdGNoOgoKW3NuaXBdCj4+ICtzdGF0aWMgaW50IG5ldG5zX25sX2NtZF9uZXdpZChzdHJ1Y3Qg
c2tfYnVmZiAqc2tiLCBzdHJ1Y3QgZ2VubF9pbmZvICppbmZvKQo+PiArewpbc25pcF0KPj4gKwlp
ZiAoaW5mby0+YXR0cnNbTkVUTlNBX1BJRF0pCj4+ICsJCXBlZXIgPSBnZXRfbmV0X25zX2J5X3Bp
ZChubGFfZ2V0X3UzMihpbmZvLT5hdHRyc1tORVROU0FfUElEXSkpOwo+PiArCWVsc2UgaWYgKGlu
Zm8tPmF0dHJzW05FVE5TQV9GRF0pCj4+ICsJCXBlZXIgPSBnZXRfbmV0X25zX2J5X2ZkKG5sYV9n
ZXRfdTMyKGluZm8tPmF0dHJzW05FVE5TQV9GRF0pKTsKPj4gKwllbHNlCj4+ICsJCXJldHVybiAt
RUlOVkFMOwo+PiArCWlmIChJU19FUlIocGVlcikpCj4+ICsJCXJldHVybiBQVFJfRVJSKHBlZXIp
OwoKQW0gSSByaWdodD8KCgpSZWdhcmRzLApOaWNvbGFzCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5l
cnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRp
b24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

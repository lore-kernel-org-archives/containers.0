From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] userns: enable tmpfs support for user namespace.
Date: Wed, 24 Oct 2012 15:49:23 +0800
Message-ID: <50879D83.2050905@cn.fujitsu.com>
References: <1348042588-9031-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87wqzq8fe3.fsf@xmission.com> <505A65AB.4000703@cn.fujitsu.com>
	<874nmt5x1r.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874nmt5x1r.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

5LqOIDIwMTLlubQwOeaciDIw5pelIDA4OjU5LCBFcmljIFcuIEJpZWRlcm1hbiDlhpnpgZM6Cj4g
R2FvIGZlbmcgPGdhb2ZlbmdAY24uZnVqaXRzdS5jb20+IHdyaXRlczoKPiAKPj4g5LqOIDIwMTLl
ubQwOeaciDE55pelIDE4OjQwLCBFcmljIFcuIEJpZWRlcm1hbiDlhpnpgZM6Cj4+PiBHYW8gZmVu
ZyA8Z2FvZmVuZ0Bjbi5mdWppdHN1LmNvbT4gd3JpdGVzOgo+Pj4KPj4+PiBtb3VudGluZyB0bXBm
cyBpbiB1c2VyIG5hbWVzcGFjZSBkb2VzIG5vIGhhcm0gdG8gdGhlIGhvc3QuCj4+Pj4gc28gZW5h
YmxlIHRtcGZzIHN1cHBvcnQgZm9yIHRoZSB1c2VyIG5hbWVzcGFjZS4KPj4+Cj4+PiBJIHRoaW5r
IHRoaXMgYWxsb3dzIGVzY2FwaW5nIGZyb20gbWVtb3J5IHJlc291cmNlIGxpbWl0cy4KPj4+Cj4+
Cj4+IEdvdCBpdCxpdCBtYWtlcyBzZW5zZSxzb3JyeSBmb3IgdGhlIG5vaXNlLgo+IAo+IE5vIG5v
aXNlIHByb2JsZW0uCj4gCj4gVGhpcyBpcyBhIHByb2JsZW0gdGhhdCB1bHRpbWF0ZWx5IG5lZWRz
IHNvbHZpbmcuCj4gCj4gSSBwdXR0ZXIgYXQgdGhhdCBlbmQgb2YgbXkgdHJlZSBmcm9tIHRpbWUg
dG8gdGltZSwgYmVjYXVzZSB0aG9zZSBhcmUgdGhlCj4gbW9yZSBpbnRlcmVzdGluZyBwcm9ibGVt
cy4KPiAKCkhpIEVyaWMKCkkgdGVzdCB0aGUgdG1wZnMgd2l0aCBtZW0gY2dyb3VwLGFuZCBmb3Vu
ZCB0aGUgbWVtb3J5IGNncm91cCBjYW4gbGltaXQKaG93IG1hbnkgbWVtb3J5IHRoZSB0YXNrcyB1
c2VkIHRocm91Z2ggdG1wZnMuCgpTbyBJIHRoaW5rIHRoaXMgcHJvYmxlbSBoYXMgYWxyZWFkeSBi
ZWVuIHNvbHZlZC4KCk9yIG1heWJlIEkgbWlzdW5kZXJzdGFuZCB3aGF0IHlvdSBzYWlkPwoKVGhh
bmtzIGhlbHAgZnJvbSBHbGF1YmVyLgoKR2FvCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlz
dHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3Jn
L21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

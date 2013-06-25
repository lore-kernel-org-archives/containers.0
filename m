From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 6/6] cgroup: implement for_each_[builtin_]subsys()
Date: Tue, 25 Jun 2013 11:42:37 -0700
Message-ID: <20130625184237.GA20051@mtj.dyndns.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-7-git-send-email-tj@kernel.org>
	<20130625002236.GU1918@mtj.dyndns.org>
	<51C8F3EB.4090106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51C8F3EB.4090106-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

T24gVHVlLCBKdW4gMjUsIDIwMTMgYXQgMDk6MzU6MzlBTSArMDgwMCwgTGkgWmVmYW4gd3JvdGU6
Cj4g5LqOIDIwMTMvNi8yNSA4OjIyLCBUZWp1biBIZW8g5YaZ6YGTOgo+ID4gVGhlcmUgYXJlIHF1
aXRlIGEgZmV3IHBsYWNlcyB3aGVyZSBhbGwgbG9hZGVkIFtidWlsdGluXSBzdWJzeXMgYXJlCj4g
PiBpdGVyYXRlZC4gIEltcGxlbWVudCBmb3JfZWFjaF9bYnVpbHRpbl9dc3Vic3lzKCkgYW5kIHJl
cGxhY2UgbWFudWFsCj4gPiBpdGVyYXRpb25zIHdpdGggdGhvc2UgdG8gc2ltcGxpZnkgdGhvc2Ug
cGxhY2VzIGEgYml0LiAgVGhlIG5ldwo+ID4gaXRlcmF0b3JzIGF1dG9tYXRpY2FsbHkgc2tpcCBO
VUxMIHN1YnN5c3RlbXMuICBUaGlzIHNob3VsZG4ndCBjYXVzZQo+ID4gYW55IGZ1bmN0aW9uYWwg
ZGlmZmVyZW5jZS4KPiA+IAo+ID4gSXRlcmF0aW9uIGxvb3BzIHdoaWNoIHNjYW4gYWxsIHN1YnN5
c3RlbXMgYW5kIHRoZW4gc2tpcHBpbmcgbW9kdWxhcgo+ID4gb25lcyBleHBsaWNpdGx5IGFyZSBj
b252ZXJ0ZWQgdG8gdXNlIGZvcl9lYWNoX2J1aWx0aW5fc3Vic3lzKCkuCj4gPiAKPiA+IFdoaWxl
IGF0IGl0LCByZW9yZGVyIHZhcmlhYmxlIGRlY2xhcmF0aW9ucyBhbmQgYWRqdXN0IHdoaXRlc3Bh
Y2VzIGEKPiA+IGJpdCBpbiB0aGUgYWZmZWN0ZWQgZnVuY3Rpb25zLgo+ID4gCj4gPiB2MjogQWRk
IGxvY2tkZXBfYXNzZXJ0X2hlbGQoKSBpbiBmb3JfZWFjaF9zdWJzeXMoKSBhbmQgYWRkIGNvbW1l
bnRzCj4gPiAgICAgYWJvdXQgc3luY2hyb25pemF0aW9uIGFzIHN1Z2dlc3RlZCBieSBMaS4KPiA+
IAo+ID4gU2lnbmVkLW9mZi1ieTogVGVqdW4gSGVvIDx0akBrZXJuZWwub3JnPgo+IAo+IEFja2Vk
LWJ5OiBMaSBaZWZhbiA8bGl6ZWZhbkBodWF3ZWkuY29tPgoKQXBwbGllZCA1LjUgYW5kIDYgdG8g
Y2dyb3VwL2Zvci0zLjExLgoKVGhhbmtzLgoKLS0gCnRlanVuCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRh
aW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5k
YXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==

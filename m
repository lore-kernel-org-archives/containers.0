From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] cgroup: s/for_each_subsys()/for_each_root_subsys()/
Date: Mon, 24 Jun 2013 18:52:15 +0800
Message-ID: <51C824DF.5080903@huawei.com>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371864854-28364-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

09ogMjAxMy82LzIyIDk6MzQsIFRlanVuIEhlbyDQtLXAOgo+IGZvcl9lYWNoX3N1YnN5cygpIHdh
bGtzIG92ZXIgc3Vic3lzdGVtcyBhdHRhY2hlZCB0byBhIGhpZXJhcmNoeSBhbmQKPiB3ZSdyZSBn
b25uYSBhZGQgaXRlcmF0b3JzIHdoaWNoIHdhbGsgb3ZlciBhbGwgYXZhaWxhYmxlIHN1YnN5c3Rl
bXMuCj4gUmVuYW1lIGZvcl9lYWNoX3N1YnN5cygpIHRvIGZvcl9lYWNoX3Jvb3Rfc3Vic3lzKCkg
c28gdGhhdCBpdCdzIG1vcmUKPiBhcHByb3ByaWF0ZWx5IG5hbWVkIGFuZCBmb3JfZWFjaF9zdWJz
eXMoKSBjYW4gYmUgdXNlZCB0byBpdGVyYXRlIGFsbAo+IHN1YnN5c3RlbXMuCj4gCj4gV2hpbGUg
YXQgaXQsIHJlbW92ZSB1bm5lY2Vzc2FyeSB1bmRlcmJhciBwcmVmaXggZnJvbSBtYWNybyBhcmd1
bWVudHMsCj4gcHV0IHRoZW0gaW5zaWRlIHBhcmVudGhlc2VzLCBhbmQgYWRqdXN0IGluZGVudGF0
aW9uIGZvciB0aGUgdHdvCj4gZm9yX2VhY2hfKigpIG1hY3Jvcy4KPiAKPiBUaGlzIHBhdGNoIGlz
IHB1cmVseSBjb3NtZXRpYy4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBUZWp1biBIZW8gPHRqQGtlcm5l
bC5vcmc+Cj4gLS0tCj4gIGtlcm5lbC9jZ3JvdXAuYyB8IDQ3ICsrKysrKysrKysrKysrKysrKysr
KystLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCj4gIDEgZmlsZSBjaGFuZ2VkLCAyMiBpbnNlcnRp
b25zKCspLCAyNSBkZWxldGlvbnMoLSkKCkFja2VkLWJ5OiBMaSBaZWZhbiA8bGl6ZWZhbkBodWF3
ZWkuY29tPgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
Q29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9u
Lm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9j
b250YWluZXJz

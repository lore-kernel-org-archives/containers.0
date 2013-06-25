From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 6/6] cgroup: implement for_each_[builtin_]subsys()
Date: Tue, 25 Jun 2013 09:35:39 +0800
Message-ID: <51C8F3EB.4090106@huawei.com>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-7-git-send-email-tj@kernel.org>
	<20130625002236.GU1918@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130625002236.GU1918-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

5LqOIDIwMTMvNi8yNSA4OjIyLCBUZWp1biBIZW8g5YaZ6YGTOgo+IFRoZXJlIGFyZSBxdWl0ZSBh
IGZldyBwbGFjZXMgd2hlcmUgYWxsIGxvYWRlZCBbYnVpbHRpbl0gc3Vic3lzIGFyZQo+IGl0ZXJh
dGVkLiAgSW1wbGVtZW50IGZvcl9lYWNoX1tidWlsdGluX11zdWJzeXMoKSBhbmQgcmVwbGFjZSBt
YW51YWwKPiBpdGVyYXRpb25zIHdpdGggdGhvc2UgdG8gc2ltcGxpZnkgdGhvc2UgcGxhY2VzIGEg
Yml0LiAgVGhlIG5ldwo+IGl0ZXJhdG9ycyBhdXRvbWF0aWNhbGx5IHNraXAgTlVMTCBzdWJzeXN0
ZW1zLiAgVGhpcyBzaG91bGRuJ3QgY2F1c2UKPiBhbnkgZnVuY3Rpb25hbCBkaWZmZXJlbmNlLgo+
IAo+IEl0ZXJhdGlvbiBsb29wcyB3aGljaCBzY2FuIGFsbCBzdWJzeXN0ZW1zIGFuZCB0aGVuIHNr
aXBwaW5nIG1vZHVsYXIKPiBvbmVzIGV4cGxpY2l0bHkgYXJlIGNvbnZlcnRlZCB0byB1c2UgZm9y
X2VhY2hfYnVpbHRpbl9zdWJzeXMoKS4KPiAKPiBXaGlsZSBhdCBpdCwgcmVvcmRlciB2YXJpYWJs
ZSBkZWNsYXJhdGlvbnMgYW5kIGFkanVzdCB3aGl0ZXNwYWNlcyBhCj4gYml0IGluIHRoZSBhZmZl
Y3RlZCBmdW5jdGlvbnMuCj4gCj4gdjI6IEFkZCBsb2NrZGVwX2Fzc2VydF9oZWxkKCkgaW4gZm9y
X2VhY2hfc3Vic3lzKCkgYW5kIGFkZCBjb21tZW50cwo+ICAgICBhYm91dCBzeW5jaHJvbml6YXRp
b24gYXMgc3VnZ2VzdGVkIGJ5IExpLgo+IAo+IFNpZ25lZC1vZmYtYnk6IFRlanVuIEhlbyA8dGpA
a2VybmVsLm9yZz4KCkFja2VkLWJ5OiBMaSBaZWZhbiA8bGl6ZWZhbkBodWF3ZWkuY29tPgoKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBt
YWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczov
L2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

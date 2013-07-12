From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.12] cgroup: replace
	task_cgroup_path_from_hierarchy() with task_cgroup_path()
Date: Fri, 12 Jul 2013 15:49:53 +0800
Message-ID: <51DFB521.6080800@huawei.com>
References: <20130711233448.GA2359@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130711233448.GA2359-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, =?UTF-8?B?SmFuIEthbHXFvmE=?= <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gMjAxMy83LzEyIDc6MzQsIFRlanVuIEhlbyB3cm90ZToKPiAKPiB0YXNrX2Nncm91cF9wYXRo
X2Zyb21faGllcmFyY2h5KCkgd2FzIGFkZGVkIGZvciB0aGUgcGxhbm5lZCBuZXcgdXNlcnMKPiBh
bmQgbm9uZSBvZiB0aGUgY3VycmVudGx5IHBsYW5uZWQgdXNlcnMgd2FudHMgdG8ga25vdyBhYm91
dCBtdWx0aXBsZQo+IGhpZXJhcmNoaWVzLiAgVGhpcyBwYXRjaCBkcm9wcyB0aGUgbXVsdGlwbGUg
aGllcmFyY2h5IHBhcnQgYW5kIG1ha2VzCj4gaXQgYWx3YXlzIHJldHVybiB0aGUgcGF0aCBpbiB0
aGUgZmlyc3Qgbm9uLWR1bW15IGhpZXJhcmNoeS4KPiAKPiBBcyB1bmlmaWVkIGhpZXJhcmNoeSB3
aWxsIGFsd2F5cyBoYXZlIGlkIDEsIHRoaXMgaXMgZ3VhcmFudGVlZCB0bwo+IHJldHVybiB0aGUg
cGF0aCBmb3IgdGhlIHVuaWZpZWQgaGllcmFyY2h5IGlmIG1vdW50ZWQ7IG90aGVyd2lzZSwgaXQK
PiB3aWxsIHJldHVybiB0aGUgcGF0aCBmcm9tIHRoZSBoaWVyYXJjaHkgd2hpY2ggaGFwcGVucyB0
byBvY2N1cHkgdGhlCj4gbG93ZXN0IGhpZXJhcmNoeSBpZCwgd2hpY2ggd2lsbCB1c3VhbGx5IGJl
IHRoZSBmaXJzdCBoaWVyYXJjaHkgbW91bnRlZAo+IGFmdGVyIGJvb3QuCj4gCj4gU2lnbmVkLW9m
Zi1ieTogVGVqdW4gSGVvIDx0akBrZXJuZWwub3JnPgo+IENjOiBMZW5uYXJ0IFBvZXR0ZXJpbmcg
PGxlbm5hcnRAcG9ldHRlcmluZy5uZXQ+Cj4gQ2M6IEtheSBTaWV2ZXJzIDxrYXkuc2lldmVyc0B2
cmZ5Lm9yZz4KPiBDYzogSmFuIEthbHXFvmEgPGprYWx1emFAcmVkaGF0LmNvbT4KCkFja2VkLWJ5
OiBMaSBaZWZhbiA8bGl6ZWZhbkBodWF3ZWkuY29tPgoKX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVy
c0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlv
bi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

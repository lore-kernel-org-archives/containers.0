From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] cgroup:cgroup_mount: Fix uninitialized warning
Date: Sat, 19 Apr 2014 08:57:06 -0400
Message-ID: <20140419125706.GA3277@htj.dyndns.org>
References: <CABYERD89BtTTJh8j0d0kvCU-xNEy8YJhFaPFr+hjuy5gWQoVNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CABYERD89BtTTJh8j0d0kvCU-xNEy8YJhFaPFr+hjuy5gWQoVNg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Takeshi Misawa <jeantsuru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

T24gU2F0LCBBcHIgMTksIDIwMTQgYXQgMDk6NTI6MTRQTSArMDkwMCwgVGFrZXNoaSBNaXNhd2Eg
d3JvdGU6Cj4gVGhpcyBwYXRjaCBmaXhlcyB0aGUgZm9sbG93aW5nIHdhcm5pbmcuCj4gCj4ga2Vy
bmVsL2Nncm91cC5jOiBJbiBmdW5jdGlvbiDigJhjZ3JvdXBfbW91bnTigJk6Cj4ga2VybmVsL2Nn
cm91cC5jOjE2MDk6MTM6IHdhcm5pbmc6IOKAmHJvb3TigJkgbWF5IGJlIHVzZWQgdW5pbml0aWFs
aXplZCBpbiB0aGlzCj4gZnVuY3Rpb24KCldoaWNoIGNvbXBpbGVyIGFyZSB5b3UgdXNpbmc/ICBU
aGlzIGlzIGEgc3B1cmlvdXMgd2FybmluZyB3aGljaCB0aGUKY29tcGlsZXIgc2hvdWxkIGJlIGFi
bGUgdG8gYXZvaWQgcHJldHR5IGVhc2lseS4KClRoYW5rcy4KCi0tIAp0ZWp1bgpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcg
bGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMu
bGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

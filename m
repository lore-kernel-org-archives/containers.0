From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] userns related vfs enhancements for v4.8
Date: Tue, 26 Jul 2016 19:02:24 -0500
Message-ID: <8737mwne27.fsf__10995.6485256136$1469578552$gmane$org@x220.int.ebiederm.org>
References: <87bn1kwjad.fsf@x220.int.ebiederm.org>
	<6ec55309-209d-7b90-9289-19e6fd180af9@poczta.onet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6ec55309-209d-7b90-9289-19e6fd180af9-wo4oW1Pw1HF3vZ0LZ0W7Rg@public.gmane.org>
	(=?utf-8?Q?=22Micha=C5=82?=
	Zegan"'s message of "Wed, 27 Jul 2016 01:18:01 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?utf-8?Q?Micha=C5=82?= Zegan <webczat_200-wo4oW1Pw1HF3vZ0LZ0W7Rg@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

TWljaGHFgiBaZWdhbiA8d2ViY3phdF8yMDBAcG9jenRhLm9uZXQucGw+IHdyaXRlczoKCj4gSSBo
YXZlIG9uZSBxdWVzdGlvbjogd2hhdCB1aWRzIGFyZSB3cml0dGVuIGluIHRoZSBmaWxlc3lzdGVt
IGlub2Rlcz8KPiB0aG9zZSB0aGF0IHRoZSBrZXJuZWwgc2Vlcywgb3IgdGhvc2UgbWFwcGVkIGJ5
IHVzZXIgbmFtZXNwYWNlcz8gYW5kIHNvLAo+IGlzIGl0IHRydWUgdGhhdCB0aGUgZmlsZXN5c3Rl
bSB3aWxsIHN0aWxsIHJlcXVpcmUgc2hpZnRpbmcgdWlkcywKPiBkaXJlY3RseSBvciBpbmRpcmVj
dGx5LCB0byBiZSB1c2FibGUgZnJvbSBpbnNpZGUgdXNlciBuYW1lc3BhY2U/IGNhbid0Cj4gdWlk
cyBiZSBtYXBwZWQgZHluYW1pY2FsbHkgZnJvbSB3aGF0IGlzIGluIHRoZSBpbm9kZSB0byBrZXJu
ZWwgdWlkcwo+IGJhc2VkIG9uIHRoZSB1c2VyIG5hbWVzcGFjZSB0aGV5IGFyZSB1c2VkIGZyb20/
IE1heWJlIGJlY2F1c2UgdGhlIGZzIGNhbgo+IGJlIG1vdW50ZWQgZnJvbSBvdXRzaWRlIGJlZm9y
ZSBzdGFydGluZyB0aGUgY29udGFpbmVyPwoKRmVlbCBmcmVlIHRvIHJlYWQgdGhlIGNvZGUuICBB
cyBiZXN0IEkgY2FuIHVuZGVyc3RhbmQgeW91ciBxdWVzdGlvbiB0aGUKYmVzdCBhbnN3ZXIgaXMg
aW4gcmVhZGluZyBhbmQgdW5kZXJzdGFuZGluZyB0aGUgY29kZSB5b3Vyc2VsZi4KCkVyaWMKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBt
YWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczov
L2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz

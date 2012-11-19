From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 09/11] pidns: Add setns support
Date: Mon, 19 Nov 2012 01:27:41 -0800
Message-ID: <87wqxij62a.fsf@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
	<1353083750-3621-9-git-send-email-ebiederm@xmission.com>
	<50A9F7DE.60807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50A9F7DE.60807-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Mon, 19
	Nov 2012 17:11:58 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

R2FvIGZlbmcgPGdhb2ZlbmdAY24uZnVqaXRzdS5jb20+IHdyaXRlczoKCj4g5LqOIDIwMTLlubQx
MeaciDE35pelIDAwOjM1LCBFcmljIFcuIEJpZWRlcm1hbiDlhpnpgZM6Cj4+IEZyb206ICJFcmlj
IFcuIEJpZWRlcm1hbiIgPGViaWVkZXJtQHhtaXNzaW9uLmNvbT4KPj4gCj4+IC0gUGlkIG5hbWVz
cGFjZXMgYXJlIGRlc2lnbmVkIHRvIGJlIGluZXNjYXBhYmxlIHNvIHZlcmlmeSB0aGF0IHRoZQo+
PiAgIHBhc3NlZCBpbiBwaWQgbmFtZXNwYWNlIGlzIGEgY2hpbGQgb2YgdGhlIGN1cnJlbnRseSBh
Y3RpdmUKPj4gICBwaWQgbmFtZXNwYWNlIG9yIHRoZSBjdXJyZW50bHkgYWN0aXZlIHBpZCBuYW1l
c3BhY2UgaXRzZWxmLgo+PiAKPj4gICBBbGxvd2luZyB0aGUgY3VycmVudGx5IGFjdGl2ZSBwaWQg
bmFtZXNwYWNlIGlzIGltcG9ydGFudCBzbwo+PiAgIHRoZSBlZmZlY3RzIG9mIGFuIGVhcmxpZXIg
c2V0bnMgY2FuIGJlIGNhbmNlbGxlZC4KPj4gCj4+IFNpZ25lZC1vZmYtYnk6IEVyaWMgVy4gQmll
ZGVybWFuIDxlYmllZGVybUB4bWlzc2lvbi5jb20+Cj4+IC0tLQo+Cj4gSGkgRXJpYwo+Cj4gSSBu
b3RpY2VkIHRoYXQsYWZ0ZXIgd2UgY2FsbCBzZXRucyB0byBjaGFuZ2UgdGFzaydzIHBpZG5zIHRv
IGNvbnRhaW5lciBBJ3MgcGlkbnMuCj4gd2UgY2FuJ3Qgc2VlIHRoaXMgdGFzayBpbiBjb250YWlu
ZXIgQSdzIHByb2MgZmlsZXN5c3RlbS4KPgo+IElzIHRoaXMgd2hhdCB3ZSBleHBlY3RlZD8KCk9u
bHkgY2hpbGRyZW4gbW92ZSB0byB0aGUgbmV3IHBpZCBuYW1lc3BhY2Ugc28geWVzLgoKQW55IG90
aGVyIHNlbWFudGljIHJlcXVpcmVzIHVnbHkgcmFjZXMgd2l0aCBjaGFuZ2luZyB0aGUgcGlkIG9m
IGFuCmV4aXN0aW5nIHByb2Nlc3MuCgpFcmljCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxp
c3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=

From: Renato Westphal <renatowestphal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: netns: Issues with deleting virtual interfaces during namespace
	cleanup
Date: Sun, 27 Feb 2011 02:16:23 -0300
Message-ID: <AANLkTinQQHKiujHNet07kbK5eqYvp6-2iBnn27v2-85+@mail.gmail.com>
References: <4D69316F.4000606@ll.mit.edu>
	<4D697F6A.9000907@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf307abd0111177c049d3caa34
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D697F6A.9000907-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "Ward,
	David - 0663 - MITLL" <david.ward-OVIABD91gjs3uPMLIKxrzw@public.gmane.org>, Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

--20cf307abd0111177c049d3caa34
Content-Type: text/plain; charset=ISO-8859-1

Hello David,

You may try the patch below (kernel v2.6.35) and see if that helps. It
basically does what you asked for: during namespace cleanup, move back the
virtual interfaces to their original namespaces. I did some tests with veth
pairs and nested netns's and everything worked fine.

I think this should be the default behaviour, I would like if someone could
review/fix this patch and push it upstream.

Have a good day,
Renato.

2011/2/26 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

> On 02/26/2011 05:59 PM, Ward, David - 0663 - MITLL wrote:
> > (Apologies for the cross-post, but Thunderbird messed up the formatting
> > when I sent this originally, and then I realized I sent it to the wrong
> > list.)
> >
> > A patch was applied to the kernel in November 2008 that deletes virtual
> > network interfaces when network namespaces are cleaned up
> > (d0c082cea6dfb9b674b4f6e1e84025662dbd24e8). A discussion about this
> > patch took place on this list
> > (
> https://lists.linux-foundation.org/pipermail/containers/2008-October/013460.html
> ),
> > where Daniel Lezcano wrote:
> >
> >  > After discussing with Benjamin, this patch means an user can no longer
> >  > manage a pool of virtual devices because they will be automatically
> >  > destroyed when the namespace exits. I don't think it is a big concern,
> >  > but just in case I am asking :)
> >
> > I currently have two use cases where this behavior is not desirable:
> >
> > 1. I use a veth pair device to connect two containers together (as
> > opposed to connecting a container to the host). To do this, I
> > create the veth pair device manually in the host with iproute2
> > ("ip link add type veth"). Then when I start each container, it
> > pulls in one of the interfaces of the veth pair device with
> > "lxc.network.type = phys". When I stop one of the containers, its
> > interface to the veth pair device is deleted instead of moved back
> > to the host, so I can not just start the stopped container again
> > and re-establish the same link.
>
> Maybe you can rely on the lxc configuration to do that.
>
> Assuming you create the two container always in the same order.
>
> The first one:
>
> lxc.network.type=veth
> lxc.network.veth.pair=vethX
>
> The second one
>
> lxc.network.type=phys
> lxc.network.link=vethX
>
> The drawback is you have to stop / start both of them.
>
>
> Otherwise, why don't you use the macvlan configuration ?
>
> For both containers:
>
> lxc.network.type=macvlan
> lxc.network.macvlan.mode=bridge
> lxc.network.link=dummy0
>
>
> > 2. I start a process in the host that creates a TUN/TAP interface,
> > such as a VPN client. I pull the TUN/TAP interface into the
> > container with "lxc.network.type = phys". When the container
> > exits, the TUN/TAP interface is deleted because it is a virtual
> > interface, while the VPN client process continues to run in the
> > host. Again I can not just start the container again with the
> > same connection; I have to restart the VPN client.
> >
> > It makes sense that virtual network interfaces that get created inside a
> > container should be deleted when the container exits. However, I feel
> > that network interfaces from the host that get assigned to the container
> > should be returned to the host when the container exits, whether they
> > are physical or virtual.
>
> Wouldn't make sense to add a configuration option for lxc to create such
> device and handle the vpn client ?
>
> There is the lxc.network.script.up option where you can launch your vpn
> client. So adding the tun/tap interface as a network option, lxc will
> create it for you and when it is up, the up script is invoked where the
> vpn client is launched.
>
> The lxc.network.script.down does not exist yet, but it is quite easy to
> add the option.
>
> What do you think ?
>
> > Can the kernel distinguish between network interfaces that were created
> > inside the namespace, and network interfaces that were moved there?
>
> IMHO that will add more complexity to the network namespace, especially
> to handle the nested namespaces. Furthermore that will impact the
> current design. I am not really in favor of that as that was initial
> behavior and there were limitations.
>  <javascript:void(0);>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>



-- 
Renato Westphal

--20cf307abd0111177c049d3caa34
Content-Type: text/x-patch; charset=US-ASCII; name="commit-4b938c0.patch"
Content-Disposition: attachment; filename="commit-4b938c0.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gkni6wt60

Y29tbWl0IDRiOTM4YzAwN2Q5YTIwZDdlZTY3NTMwODNkN2E5YzZiMWYwOTg2NzEKQXV0aG9yOiBS
ZW5hdG8gV2VzdHBoYWwgPHJ3ZXN0cGhhbEBpbmYudWZyZ3MuYnI+CkRhdGU6ICAgU3VuIEZlYiAy
NyAwMjowNzo1NiAyMDExIC0wMzAwCgogICAgbmV0bnM6IFByZXNlcnZlIGltcG9ydGVkIHZpcnR1
YWwgaW50ZXJmYWNlcyBkdXJpbmcgbmFtZXNwYWNlIGNsZWFudXAKCmRpZmYgLS1naXQgYS9pbmNs
dWRlL2xpbnV4L25ldGRldmljZS5oIGIvaW5jbHVkZS9saW51eC9uZXRkZXZpY2UuaAppbmRleCBi
MjFlNDA1Li43Y2NlNzk5IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L25ldGRldmljZS5oCisr
KyBiL2luY2x1ZGUvbGludXgvbmV0ZGV2aWNlLmgKQEAgLTEwMTksNiArMTAxOSw4IEBAIHN0cnVj
dCBuZXRfZGV2aWNlIHsKICNpZmRlZiBDT05GSUdfTkVUX05TCiAJLyogTmV0d29yayBuYW1lc3Bh
Y2UgdGhpcyBuZXR3b3JrIGRldmljZSBpcyBpbnNpZGUgKi8KIAlzdHJ1Y3QgbmV0CQkqbmRfbmV0
OworCS8qIEluaXRpYWwgbmV0d29yayBuYW1lc3BhY2Ugb2YgdGhpcyBuZXR3b3JrIGRldmljZSAq
LworCXN0cnVjdCBuZXQJCSpuZF9pbml0X25ldDsKICNlbmRpZgogCiAJLyogbWlkLWxheWVyIHBy
aXZhdGUgKi8KZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMKaW5k
ZXggZjNhMjRjNC4uMTZkOWJjNCAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvZGV2LmMKKysrIGIvbmV0
L2NvcmUvZGV2LmMKQEAgLTU4MzAsNiArNTgzMCw3IEBAIHN0YXRpYyBzdHJ1Y3QgcGVybmV0X29w
ZXJhdGlvbnMgX19uZXRfaW5pdGRhdGEgbmV0ZGV2X25ldF9vcHMgPSB7CiBzdGF0aWMgdm9pZCBf
X25ldF9leGl0IGRlZmF1bHRfZGV2aWNlX2V4aXQoc3RydWN0IG5ldCAqbmV0KQogewogCXN0cnVj
dCBuZXRfZGV2aWNlICpkZXYsICphdXg7CisJc3RydWN0IG5ldCAqZGVzdF9uZXQ7CiAJLyoKIAkg
KiBQdXNoIGFsbCBtaWdyYXRhYmxlIG5ldHdvcmsgZGV2aWNlcyBiYWNrIHRvIHRoZQogCSAqIGlu
aXRpYWwgbmV0d29yayBuYW1lc3BhY2UKQEAgLTU4NDQsMTIgKzU4NDUsMTMgQEAgc3RhdGljIHZv
aWQgX19uZXRfZXhpdCBkZWZhdWx0X2RldmljZV9leGl0KHN0cnVjdCBuZXQgKm5ldCkKIAkJCWNv
bnRpbnVlOwogCiAJCS8qIExlYXZlIHZpcnR1YWwgZGV2aWNlcyBmb3IgdGhlIGdlbmVyaWMgY2xl
YW51cCAqLwotCQlpZiAoZGV2LT5ydG5sX2xpbmtfb3BzKQorCQlpZiAoZGV2LT5ydG5sX2xpbmtf
b3BzICYmIGRldi0+bmRfbmV0ID09IGRldi0+bmRfaW5pdF9uZXQpCiAJCQljb250aW51ZTsKIAog
CQkvKiBQdXNoIHJlbWFpbmcgbmV0d29yayBkZXZpY2VzIHRvIGluaXRfbmV0ICovCisJCWRlc3Rf
bmV0ID0gZGV2LT5ydG5sX2xpbmtfb3BzID8gZGV2LT5uZF9pbml0X25ldCA6ICZpbml0X25ldDsK
IAkJc25wcmludGYoZmJfbmFtZSwgSUZOQU1TSVosICJkZXYlZCIsIGRldi0+aWZpbmRleCk7Ci0J
CWVyciA9IGRldl9jaGFuZ2VfbmV0X25hbWVzcGFjZShkZXYsICZpbml0X25ldCwgZmJfbmFtZSk7
CisJCWVyciA9IGRldl9jaGFuZ2VfbmV0X25hbWVzcGFjZShkZXYsIGRlc3RfbmV0LCBmYl9uYW1l
KTsKIAkJaWYgKGVycikgewogCQkJcHJpbnRrKEtFUk5fRU1FUkcgIiVzOiBmYWlsZWQgdG8gbW92
ZSAlcyB0byBpbml0X25ldDogJWRcbiIsCiAJCQkJX19mdW5jX18sIGRldi0+bmFtZSwgZXJyKTsK
ZGlmZiAtLWdpdCBhL25ldC9jb3JlL3J0bmV0bGluay5jIGIvbmV0L2NvcmUvcnRuZXRsaW5rLmMK
aW5kZXggMTliZWRkNS4uYjJlMzE1NSAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvcnRuZXRsaW5rLmMK
KysrIGIvbmV0L2NvcmUvcnRuZXRsaW5rLmMKQEAgLTEzOTQsNiArMTM5NCw3IEBAIHN0cnVjdCBu
ZXRfZGV2aWNlICpydG5sX2NyZWF0ZV9saW5rKHN0cnVjdCBuZXQgKnNyY19uZXQsIHN0cnVjdCBu
ZXQgKm5ldCwKIAkJZ290byBlcnI7CiAKIAlkZXZfbmV0X3NldChkZXYsIG5ldCk7CisJZGV2LT5u
ZF9pbml0X25ldCA9IGRldl9uZXQoZGV2KTsKIAlkZXYtPnJ0bmxfbGlua19vcHMgPSBvcHM7CiAJ
ZGV2LT5ydG5sX2xpbmtfc3RhdGUgPSBSVE5MX0xJTktfSU5JVElBTElaSU5HOwogCWRldi0+cmVh
bF9udW1fdHhfcXVldWVzID0gcmVhbF9udW1fcXVldWVzOwo=
--20cf307abd0111177c049d3caa34
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--20cf307abd0111177c049d3caa34--

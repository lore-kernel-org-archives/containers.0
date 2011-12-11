From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: How to draw values for /proc/stat
Date: Sun, 11 Dec 2011 15:50:56 +0100
Message-ID: <4EE4C350.90509@parallels.com>
References: <4EDC8FB1.60407@parallels.com> <1323439411.17673.65.camel@twins> <4EE22179.5090106@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------080407020109030009040703"
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EE22179.5090106-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

--------------080407020109030009040703
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit

On 12/09/2011 03:55 PM, Glauber Costa wrote:
> On 12/09/2011 12:03 PM, Peter Zijlstra wrote:
>> On Mon, 2011-12-05 at 07:32 -0200, Glauber Costa wrote:
>>> Hi,
>>>
>>> Specially Peter and Paul, but all the others:
>>>
>>> As you can see in https://lkml.org/lkml/2011/12/4/178, and in my answer
>>> to that, there is a question - one I've asked before but without that
>>> much of an audience - of whether /proc files read from process living on
>>> cgroups should display global or per-cgroup resources.
>>>
>>> In the past, I was arguing for a knob to control that, but I recently
>>> started to believe that a knob here will only overcomplicate matters:
>>> if you live in a cgroup, you should display only the resources you can
>>> possibly use. Global is for whoever is in the main cgroup.
>>>
>>> Now, it comes two questions:
>>> 1) Do you agree with that, for files like /proc/stat ? I think the most
>>> important part is to be consistent inside the system, regardless of what
>>> is done
>>
>> Personally I don't give a rats arse about (/proc vs) cgroups :-)
>> Currently /proc is unaffected by whatever cgroup you happen to be in and
>> that seems to make some sort of sense.
>>
>> Namespaces seem to be about limiting visibility, cgroups about
>> controlling resources.
>>
>> The two things are hopelessly disjoint atm, but I believe someone was
>> looking at this mess.
>
> I did take a look at this (if anyone else was, I'd like to know so we
> can share some ideas), but I am not convinced we should do anything to
> join them anymore. We virtualization people are to the best of my
> knowledge the only ones doing namespaces. Cgroups, OTOH, got a lot bigger.
>
> What I am mostly concerned about now, is how consistent they will be.
> /proc always being always global indeed does make sense, but my question
> still stands: if you live in a resource-controlled world, why should you
> even see resources you will never own ?
>
>
>> IOW a /proc namespace coupled to cgroup scope would do what you want.
>> Now my head hurts..
>
> Mine too. The idea is good, but too broad. Boils down to: How do you
> couple them? And none of the methods I thought about seemed to make any
> sense.
>
> If we really want to have the values in /proc being opted-in, I think
> Kamezawa's idea of a mount option is the winner so far.
>

Ok:

How about the following patch to achieve this ?

--------------080407020109030009040703
Content-Type: text/plain;
	name="0001-Add-proc_overlay-option-for-cgroup.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="0001-Add-proc_overlay-option-for-cgroup.patch"

RnJvbSAxZTU4N2JmM2Q5N2Q4NTBjNWJhOGI5YmYzNzVjMmU3NGIzOGE5ODkxIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBHbGF1YmVyIENvc3RhIDxnbG9tbWVyQHBhcmFsbGVs
cy5jb20+CkRhdGU6IEZyaSwgOSBEZWMgMjAxMSAxNjowMzoyNiArMDMwMApTdWJqZWN0OiBb
UEFUQ0hdIEFkZCAicHJvY19vdmVybGF5IiBvcHRpb24gZm9yIGNncm91cAoKVGhpcyBwYXRj
aCBhZGRzIHRoZSAicHJvY19vdmVybGF5IiBmaWxlIHRvIGNncm91cC4gSXQgaXMgYWxzbwph
dmFpbGFibGUgYXMgYSBtb3VudCBvcHRpb24sIHdoaWNoIGNhbiBiZSBvdmVycmlkZW4gbGF0
ZXIgYnkKYW55IG9mIHRoZSBpbmRpdmlkdWFsIGNncm91cHMgaW4gdGhlIGhpZXJhcmNoeS4K
CldpdGggdGhpcyBvcHRpb24gc2V0LCB3ZSB0ZWxsIHRoZSBrZXJuZWwgdGhhdCBmb3IgdGhl
IHByb2Nlc3NlcwppbnNpZGUgY2dyb3VwcyBmb3Igd2hpY2ggcHJvY19vdmVybGF5ID0gdHJ1
ZSwgd2Ugd2FudCAvcHJvYyBmaWxlcwpyZWxhdGVkIHRvIHRoaXMgY2dyb3VwIHRvIHNob3cg
cGVyLWNncm91cCB2YWx1ZXMsIG5vdCBnbG9iYWwgb25lcy4KClRoaXMgaXMgYSBtdXN0LWhh
dmUgaW4gdmlydHVhbGl6ZWQgZW52aXJvbm1lbnRzLCB3aGVyZSB0aGUgaXNvbGF0aW9uCmd1
YXJhbnRlZXMgc2hvdWxkIG5vdCBsZXQgcHJvY2Vzc2VzIGluIGEgY2dyb3VwIHNlZSByZXNv
dXJjZXMgb2YKb3RoZXIgZ3JvdXBzLiBBZGRpbmcgYW4gb3B0aW9uIGFsbG93IHVzIHRvIGFj
aGlldmUgdGhpcyB3aXRob3V0CmludGVyZmVycmluZyB3aXRoIG90aGVyIGNncm91cC11c2Vy
cyB0aGF0IGFyZSBub3QgY29uY2VybmVkIHdpdGgKaXNvbGF0aW9uLgoKU2lnbmVkLW9mZi1i
eTogR2xhdWJlciBDb3N0YSA8Z2xvbW1lckBwYXJhbGxlbHMuY29tPgotLS0KIGluY2x1ZGUv
bGludXgvY2dyb3VwLmggfCAgICA2ICsrKysrKwoga2VybmVsL2Nncm91cC5jICAgICAgICB8
ICAgMzcgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwogMiBmaWxlcyBj
aGFuZ2VkLCA0MyBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBh
L2luY2x1ZGUvbGludXgvY2dyb3VwLmggYi9pbmNsdWRlL2xpbnV4L2Nncm91cC5oCmluZGV4
IDFiN2Y5ZDUuLmYwYmMyZTkgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvY2dyb3VwLmgK
KysrIGIvaW5jbHVkZS9saW51eC9jZ3JvdXAuaApAQCAtMTU4LDYgKzE1OCw3IEBAIGVudW0g
ewogCSAqIENsb25lIGNncm91cCB2YWx1ZXMgd2hlbiBjcmVhdGluZyBhIG5ldyBjaGlsZCBj
Z3JvdXAKIAkgKi8KIAlDR1JQX0NMT05FX0NISUxEUkVOLAorCUNHUlBfUFJPQ19PVkVSTEFZ
LAogfTsKIAogLyogd2hpY2ggcGlkbGlzdCBmaWxlIGFyZSB3ZSB0YWxraW5nIGFib3V0PyAq
LwpAQCAtMjQ1LDYgKzI0NiwxMSBAQCBzdHJ1Y3QgY2dyb3VwIHsKIAlzcGlubG9ja190IGV2
ZW50X2xpc3RfbG9jazsKIH07CiAKK3N0YXRpYyBpbmxpbmUgYm9vbCBjZ3JvdXBfcHJvY19v
dmVybGF5KHN0cnVjdCBjZ3JvdXAgKmNncnApCit7CisJcmV0dXJuIHRlc3RfYml0KENHUlBf
UFJPQ19PVkVSTEFZLCAmY2dycC0+ZmxhZ3MpOworfQorCiAvKgogICogQSBjc3Nfc2V0IGlz
IGEgc3RydWN0dXJlIGhvbGRpbmcgcG9pbnRlcnMgdG8gYSBzZXQgb2YKICAqIGNncm91cF9z
dWJzeXNfc3RhdGUgb2JqZWN0cy4gVGhpcyBzYXZlcyBzcGFjZSBpbiB0aGUgdGFzayBzdHJ1
Y3QKZGlmZiAtLWdpdCBhL2tlcm5lbC9jZ3JvdXAuYyBiL2tlcm5lbC9jZ3JvdXAuYwppbmRl
eCBlNzAwYWJlLi4zMTNjMDZjIDEwMDY0NAotLS0gYS9rZXJuZWwvY2dyb3VwLmMKKysrIGIv
a2VybmVsL2Nncm91cC5jCkBAIC0yMzMsNiArMjMzLDcgQEAgZW51bSB7CiAJUk9PVF9OT1BS
RUZJWCwgLyogbW91bnRlZCBzdWJzeXN0ZW1zIGhhdmUgbm8gbmFtZWQgcHJlZml4ICovCiAJ
Uk9PVF9DTE9ORV9DSElMRFJFTiwgLyogbW91bnRlZCBzdWJzeXN0ZW1zIHN0YXJ0cyB3aXRo
IGNsb25lX2NoaWxkcmVuICovCiAJUk9PVF9OT1NVQlNZUywgLyogZXhwbGljaXRseSBhc2tl
ZCBmb3IgJ25vbmUnIHN1YnN5c3RlbXMgKi8KKwlST09UX1BST0NfT1ZFUkxBWSwgLyogbW91
bnRlZCBzdWJzeXN0ZW1zIHN0YXJ0cyB3aXRoIHByb2Nfb3ZlcmxheSAqLwogfTsKIAogc3Rh
dGljIGludCBjZ3JvdXBfaXNfcmVsZWFzYWJsZShjb25zdCBzdHJ1Y3QgY2dyb3VwICpjZ3Jw
KQpAQCAtMjUzLDYgKzI1NCwxMCBAQCBzdGF0aWMgaW5saW5lIGludCBjbG9uZV9jaGlsZHJl
bihjb25zdCBzdHJ1Y3QgY2dyb3VwICpjZ3JwKQogCXJldHVybiB0ZXN0X2JpdChDR1JQX0NM
T05FX0NISUxEUkVOLCAmY2dycC0+ZmxhZ3MpOwogfQogCitzdGF0aWMgaW5saW5lIGludCBw
cm9jX292ZXJsYXkoY29uc3Qgc3RydWN0IGNncm91cCAqY2dycCkKK3sKKwlyZXR1cm4gdGVz
dF9iaXQoQ0dSUF9QUk9DX09WRVJMQVksICZjZ3JwLT5mbGFncyk7Cit9CiAvKgogICogZm9y
X2VhY2hfc3Vic3lzKCkgYWxsb3dzIHlvdSB0byBpdGVyYXRlIG9uIGVhY2ggc3Vic3lzdGVt
IGF0dGFjaGVkIHRvCiAgKiBhbiBhY3RpdmUgaGllcmFyY2h5CkBAIC0xMDU0LDYgKzEwNTks
OCBAQCBzdGF0aWMgaW50IGNncm91cF9zaG93X29wdGlvbnMoc3RydWN0IHNlcV9maWxlICpz
ZXEsIHN0cnVjdCB2ZnNtb3VudCAqdmZzKQogCQlzZXFfcHJpbnRmKHNlcSwgIixyZWxlYXNl
X2FnZW50PSVzIiwgcm9vdC0+cmVsZWFzZV9hZ2VudF9wYXRoKTsKIAlpZiAoY2xvbmVfY2hp
bGRyZW4oJnJvb3QtPnRvcF9jZ3JvdXApKQogCQlzZXFfcHV0cyhzZXEsICIsY2xvbmVfY2hp
bGRyZW4iKTsKKwlpZiAodGVzdF9iaXQoUk9PVF9QUk9DX09WRVJMQVksICZyb290LT5mbGFn
cykpCisJCXNlcV9wdXRzKHNlcSwgIixwcm9jX292ZXJsYXkiKTsKIAlpZiAoc3RybGVuKHJv
b3QtPm5hbWUpKQogCQlzZXFfcHJpbnRmKHNlcSwgIixuYW1lPSVzIiwgcm9vdC0+bmFtZSk7
CiAJbXV0ZXhfdW5sb2NrKCZjZ3JvdXBfbXV0ZXgpOwpAQCAtMTExNiw2ICsxMTIzLDEwIEBA
IHN0YXRpYyBpbnQgcGFyc2VfY2dyb3VwZnNfb3B0aW9ucyhjaGFyICpkYXRhLCBzdHJ1Y3Qg
Y2dyb3VwX3NiX29wdHMgKm9wdHMpCiAJCQlzZXRfYml0KFJPT1RfTk9QUkVGSVgsICZvcHRz
LT5mbGFncyk7CiAJCQljb250aW51ZTsKIAkJfQorCQlpZiAoIXN0cmNtcCh0b2tlbiwgInBy
b2Nfb3ZlcmxheSIpKSB7CisJCQlzZXRfYml0KFJPT1RfUFJPQ19PVkVSTEFZLCAmb3B0cy0+
ZmxhZ3MpOworCQkJY29udGludWU7CisJCX0KIAkJaWYgKCFzdHJjbXAodG9rZW4sICJjbG9u
ZV9jaGlsZHJlbiIpKSB7CiAJCQlzZXRfYml0KFJPT1RfQ0xPTkVfQ0hJTERSRU4sICZvcHRz
LT5mbGFncyk7CiAJCQljb250aW51ZTsKQEAgLTE0MDYsNiArMTQxNyw4IEBAIHN0YXRpYyBz
dHJ1Y3QgY2dyb3VwZnNfcm9vdCAqY2dyb3VwX3Jvb3RfZnJvbV9vcHRzKHN0cnVjdCBjZ3Jv
dXBfc2Jfb3B0cyAqb3B0cykKIAkJc3RyY3B5KHJvb3QtPm5hbWUsIG9wdHMtPm5hbWUpOwog
CWlmICh0ZXN0X2JpdChST09UX0NMT05FX0NISUxEUkVOLCAmb3B0cy0+ZmxhZ3MpKQogCQlz
ZXRfYml0KENHUlBfQ0xPTkVfQ0hJTERSRU4sICZyb290LT50b3BfY2dyb3VwLmZsYWdzKTsK
KwlpZiAodGVzdF9iaXQoUk9PVF9QUk9DX09WRVJMQVksICZvcHRzLT5mbGFncykpCisJCXNl
dF9iaXQoQ0dSUF9QUk9DX09WRVJMQVksICZyb290LT50b3BfY2dyb3VwLmZsYWdzKTsKIAly
ZXR1cm4gcm9vdDsKIH0KIApAQCAtMzQ0Miw2ICszNDU1LDIyIEBAIHN0YXRpYyBpbnQgY2dy
b3VwX3dyaXRlX25vdGlmeV9vbl9yZWxlYXNlKHN0cnVjdCBjZ3JvdXAgKmNncnAsCiAJcmV0
dXJuIDA7CiB9CiAKK3N0YXRpYyB1NjQgY2dyb3VwX3Byb2Nfb3ZlcmxheV9yZWFkKHN0cnVj
dCBjZ3JvdXAgKmNncnAsCisJCQkJICAgIHN0cnVjdCBjZnR5cGUgKmNmdCkKK3sKKwlyZXR1
cm4gcHJvY19vdmVybGF5KGNncnApOworfQorCitzdGF0aWMgaW50IGNncm91cF9wcm9jX292
ZXJsYXlfd3JpdGUoc3RydWN0IGNncm91cCAqY2dycCwKKwkJCQkgICAgIHN0cnVjdCBjZnR5
cGUgKmNmdCwgdTY0IHZhbCkKK3sKKwlpZiAodmFsKQorCQlzZXRfYml0KENHUlBfUFJPQ19P
VkVSTEFZLCAmY2dycC0+ZmxhZ3MpOworCWVsc2UKKwkJY2xlYXJfYml0KENHUlBfUFJPQ19P
VkVSTEFZLCAmY2dycC0+ZmxhZ3MpOworCXJldHVybiAwOworfQorCiAvKgogICogVW5yZWdp
c3RlciBldmVudCBhbmQgZnJlZSByZXNvdXJjZXMuCiAgKgpAQCAtMzY2Miw2ICszNjkxLDEx
IEBAIHN0YXRpYyBzdHJ1Y3QgY2Z0eXBlIGZpbGVzW10gPSB7CiAJCS5yZWFkX3U2NCA9IGNn
cm91cF9jbG9uZV9jaGlsZHJlbl9yZWFkLAogCQkud3JpdGVfdTY0ID0gY2dyb3VwX2Nsb25l
X2NoaWxkcmVuX3dyaXRlLAogCX0sCisJeworCQkubmFtZSA9ICJjZ3JvdXAucHJvY19vdmVy
bGF5IiwKKwkJLnJlYWRfdTY0ID0gY2dyb3VwX3Byb2Nfb3ZlcmxheV9yZWFkLAorCQkud3Jp
dGVfdTY0ID0gY2dyb3VwX3Byb2Nfb3ZlcmxheV93cml0ZSwKKwl9LAogfTsKIAogc3RhdGlj
IHN0cnVjdCBjZnR5cGUgY2Z0X3JlbGVhc2VfYWdlbnQgPSB7CkBAIC0zNzk0LDYgKzM4Mjgs
OSBAQCBzdGF0aWMgbG9uZyBjZ3JvdXBfY3JlYXRlKHN0cnVjdCBjZ3JvdXAgKnBhcmVudCwg
c3RydWN0IGRlbnRyeSAqZGVudHJ5LAogCWlmIChjbG9uZV9jaGlsZHJlbihwYXJlbnQpKQog
CQlzZXRfYml0KENHUlBfQ0xPTkVfQ0hJTERSRU4sICZjZ3JwLT5mbGFncyk7CiAKKwlpZiAo
cGFyZW50LT5yb290LT5mbGFncyAmIFJPT1RfUFJPQ19PVkVSTEFZKQorCQlzZXRfYml0KENH
UlBfUFJPQ19PVkVSTEFZLCAmY2dycC0+ZmxhZ3MpOworCiAJZm9yX2VhY2hfc3Vic3lzKHJv
b3QsIHNzKSB7CiAJCXN0cnVjdCBjZ3JvdXBfc3Vic3lzX3N0YXRlICpjc3MgPSBzcy0+Y3Jl
YXRlKHNzLCBjZ3JwKTsKIAotLSAKMS43LjYuNAoK
--------------080407020109030009040703--
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

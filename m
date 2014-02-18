From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Tue, 18 Feb 2014 19:54:34 +0000
Message-ID: <1392753259.607.9.camel@ppwaskie-mobl.amr.corp.intel.com>
References: <20140106221251.GJ30183@twins.programming.kicks-ass.net>
	<1389048315.32504.57.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107083440.GL30183@twins.programming.kicks-ass.net>
	<1389107743.32504.69.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107211229.GF2480@laptop.programming.kicks-ass.net>
	<1389380100.32504.172.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140113075528.GR7572@laptop.programming.kicks-ass.net>
	<52D57AC2.3090109@zytor.com>
	<20140127173420.GA9636@twins.programming.kicks-ass.net>
	<1392744567.3069.42.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140218193528.GQ14089@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2003142017882872676=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140218193528.GQ14089-RM5+C6weyIYnLiPH7yDmwOa11wxjtiyuLtmvbW2Dspo@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============2003142017882872676==
Content-Language: en-US
Content-Type: multipart/signed; micalg=sha-1;
	protocol="application/x-pkcs7-signature"; boundary="=-0niHBq5WxlLXsjMfHug1"

--=-0niHBq5WxlLXsjMfHug1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-18 at 20:35 +0100, Peter Zijlstra wrote:
> On Tue, Feb 18, 2014 at 05:29:42PM +0000, Waskiewicz Jr, Peter P wrote:
> > > Its not a problem that changing the task:RMID map is expensive, what =
is
> > > a problem is that there's no deterministic fashion of doing it.
> >=20
> > We are going to add to the SDM that changing RMID's often/frequently is
> > not the intended use case for this feature, and can cause bogus data.
> > The real intent is to land threads into an RMID, and run that until the
> > threads are effectively done.
> >=20
> > That being said, reassigning a thread to a new RMID is certainly
> > supported, just "frequent" updates is not encouraged at all.
>=20
> You don't even need really high frequency, just unsynchronized wrt
> reading the counter. Suppose A flips the RMIDs about and just when its
> done programming B reads them.
>=20
> At that point you've got 0 guarantee the data makes any kind of sense.

Agreed, there is no guarantee with how the hardware is designed.  We
don't have an instruction that can nuke RMID-tagged cachelines from the
cache, and the CPU guys (along with hpa) have been very explicit that
wbinv is not an option.

> > I do see that, however the userspace interface for this isn't ideal for
> > how the feature is intended to be used.  I'm still planning to have thi=
s
> > be managed per process in /proc/<pid>, I just had other priorities push
> > this back a bit on my stovetop.
>=20
> So I really don't like anything /proc/$pid/ nor do I really see a point i=
n
> doing that. What are you going to do in the /proc/$pid/ thing anyway?
> Exposing raw RMIDs is an absolute no-no, and anything else is going to
> end up being yet-another-grouping thing and thus not much different from
> cgroups.

Exactly.  The cgroup grouping mechanisms fit really well with this
feature.  I was exploring another way to do it given the pushback on
using cgroups initially.  The RMID's won't be exposed, rather a group
identifier (in cgroups it's the new subdirectory in the subsystem), and
RMIDs are assigned by the kernel, completely hidden to userspace.

>=20
> > Also, now that the new SDM is available
>=20
> Can you guys please set up a mailing list already so we know when
> there's new versions out? Ideally mailing out the actual PDF too so I
> get the automagic download and archive for all versions.

I assume this has been requested before.  As I'm typing this, I just
received the notification internally that the new SDM is now published.
I'll forward your request along and see what I hear back.

> > , there is a new feature added to
> > the same family as CQM, called Memory Bandwidth Monitoring (MBM).  The
> > original cgroup approach would have allowed another subsystem be added
> > next to cacheqos; the perf-cgroup here is not easily expandable.
> > The /proc/<pid> approach can add MBM pretty easily alongside CQM.
>=20
> I'll have to go read up what you've done now, but if its also RMID based
> I don't see why the proposed scheme won't work.

Yes please do look at the cgroup patches.  For the RMID allocation, we
could use your proposal to manage allocation/reclamation, and the
management interface to userspace will match the use cases I'm trying to
enable.

> > > The below is a rough draft, most if not all XXXs should be
> > > fixed/finished. But given I don't actually have hardware that support=
s
> > > this stuff (afaik) I couldn't be arsed.
> >=20
> > The hardware is not publicly available yet, but I know that Red Hat and
> > others have some of these platforms for testing.
>=20
> Yeah, not in my house therefore it doesn't exist :-)
>=20
> > I really appreciate the patch.  There was a good amount of thought put
> > into this, and gave a good set of different viewpoints.  I'll keep the
> > comments all here in one place, it'll be easier to discuss than
> > disjointed in the code.
> >=20
> > The rotation idea to reclaim RMID's no longer in use is interesting.
> > This differs from the original patch where the original patch would
> > reclaim the RMID when monitoring was disabled for that group of
> > processes.
> >=20
> > I can see a merged sort of approach, where if monitoring for a group of
> > processes is disabled, we can place that RMID onto a reclaim list.  The
> > next time an RMID is requested (monitoring is enabled for a
> > process/group of processes), the reclaim list is searched for an RMID
> > that has 0 occupancy (i.e. not in use), or worst-case, find and assign
> > one with the lowest occupancy.  I did discuss this with hpa offline and
> > this seemed reasonable.
> >=20
> > Thoughts?
>=20
> So you have to wait for one 'freed' RMID to become empty before
> 'allowing' reads of the other RMIDs, otherwise the visible value can be
> complete rubbish. Even for low frequency rotation, see the above
> scenario about asynchronous operations.
>=20
> This means you have to always have at least one free RMID.

Understood now, I was missing the asynchronous point you were trying to
make.  I thought you wanted the free RMID to use that to always assign
so you know it's "empty," not to get around the twiddling that can
occur.

Let me know what you think about the cacheqos cgroup implementation I
sent, and if things don't look horrible, I can respin with your RMID
management scheme.

Thanks,
-PJ

--=20
PJ Waskiewicz				Open Source Technology Center
peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org		Intel Corp.

--=-0niHBq5WxlLXsjMfHug1
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIILOTCCBOsw
ggPToAMCAQICEFLpAsoR6ESdlGU4L6MaMLswDQYJKoZIhvcNAQEFBQAwbzELMAkGA1UEBhMCU0Ux
FDASBgNVBAoTC0FkZFRydXN0IEFCMSYwJAYDVQQLEx1BZGRUcnVzdCBFeHRlcm5hbCBUVFAgTmV0
d29yazEiMCAGA1UEAxMZQWRkVHJ1c3QgRXh0ZXJuYWwgQ0EgUm9vdDAeFw0xMzAzMTkwMDAwMDBa
Fw0yMDA1MzAxMDQ4MzhaMHkxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEUMBIGA1UEBxMLU2Fu
dGEgQ2xhcmExGjAYBgNVBAoTEUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRl
cm5hbCBCYXNpYyBJc3N1aW5nIENBIDRBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
4LDMgJ3YSVX6A9sE+jjH3b+F3Xa86z3LLKu/6WvjIdvUbxnoz2qnvl9UKQI3sE1zURQxrfgvtP0b
Pgt1uDwAfLc6H5eqnyi+7FrPsTGCR4gwDmq1WkTQgNDNXUgb71e9/6sfq+WfCDpi8ScaglyLCRp7
ph/V60cbitBvnZFelKCDBh332S6KG3bAdnNGB/vk86bwDlY6omDs6/RsfNwzQVwo/M3oPrux6y6z
yIoRulfkVENbM0/9RrzQOlyK4W5Vk4EEsfW2jlCV4W83QKqRccAKIUxw2q/HoHVPbbETrrLmE6RR
Z/+eWlkGWl+mtx42HOgOmX0BRdTRo9vH7yeBowIDAQABo4IBdzCCAXMwHwYDVR0jBBgwFoAUrb2Y
ejS0Jvf6xCZU7wO94CTLVBowHQYDVR0OBBYEFB5pKrTcKP5HGE4hCz+8rBEv8Jj1MA4GA1UdDwEB
/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMDYGA1UdJQQvMC0GCCsGAQUFBwMEBgorBgEEAYI3
CgMEBgorBgEEAYI3CgMMBgkrBgEEAYI3FQUwFwYDVR0gBBAwDjAMBgoqhkiG+E0BBQFpMEkGA1Ud
HwRCMEAwPqA8oDqGOGh0dHA6Ly9jcmwudHJ1c3QtcHJvdmlkZXIuY29tL0FkZFRydXN0RXh0ZXJu
YWxDQVJvb3QuY3JsMDoGCCsGAQUFBwEBBC4wLDAqBggrBgEFBQcwAYYeaHR0cDovL29jc3AudHJ1
c3QtcHJvdmlkZXIuY29tMDUGA1UdHgQuMCygKjALgQlpbnRlbC5jb20wG6AZBgorBgEEAYI3FAID
oAsMCWludGVsLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAKcLNo/2So1Jnoi8G7W5Q6FSPq1fmyKW3
sSDf1amvyHkjEgd25n7MKRHGEmRxxoziPKpcmbfXYU+J0g560nCo5gPF78Wd7ZmzcmCcm1UFFfIx
fw6QA19bRpTC8bMMaSSEl8y39Pgwa+HENmoPZsM63DdZ6ziDnPqcSbcfYs8qd/m5d22rpXq5IGVU
tX6LX7R/hSSw/3sfATnBLgiJtilVyY7OGGmYKCAS2I04itvSS1WtecXTt9OZDyNbl7LtObBrgMLh
ZkpJW+pOR9f3h5VG2S5uKkA7Th9NC9EoScdwQCAIw+UWKbSQ0Isj2UFL7fHKvmqWKVTL98sRzvI3
seNC4DCCBkYwggUuoAMCAQICCnfQGsYAAAAARQwwDQYJKoZIhvcNAQEFBQAweTELMAkGA1UEBhMC
VVMxCzAJBgNVBAgTAkNBMRQwEgYDVQQHEwtTYW50YSBDbGFyYTEaMBgGA1UEChMRSW50ZWwgQ29y
cG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgNEEwHhcN
MTQwMjEwMTk0MDU5WhcNMTcwMTI1MTk0MDU5WjBRMR8wHQYDVQQDExZXYXNraWV3aWN6IEpyLCBQ
ZXRlciBQMS4wLAYJKoZIhvcNAQkBFh9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzCvEJuHRAVYYAmbLrl+TRcuS66zyZPg7SKaf
7yVbkU2GvtQ74iqjQ9GJQFuFdDq3ZYUP42movw8k4UZ6ghjGvbwAYAiCphtSeJZVqSKQRIN7cRtf
ItEXvbKCjRAy5U+bxbAr9FkyEqTd5V7Y1yy5bO7ddSKa6939nRqX6kZlmh0VgKcG8QORbs7pfUQB
UHbInD3+LDQroSlSbYJoxXNkXQxGbZLWP2UtyM2oLGlegtz1gx7S4rMtDkBEKG/3/FG/lfXrDNUo
jgvUt1CKjAP30MBN66Optp0GgWSrDwS6pW0Nld3iMX+/IdoG23bUW9BWXMtYXkr6oN7zB+ekvUjg
vwIDAQABo4IC9jCCAvIwCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbD
jHWEmeVRg/2BKIWOn1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFEawoXzp+DrBd+34bKsE
yj4wjKHXMB8GA1UdIwQYMBaAFB5pKrTcKP5HGE4hCz+8rBEv8Jj1MIHJBgNVHR8EgcEwgb4wgbug
gbiggbWGVGh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJu
YWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUyMDRBLmNybIZdaHR0cDovL2NlcnRpZmljYXRlcy5p
bnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWlu
ZyUyMENBJTIwNEEuY3JsMIHvBggrBgEFBQcBAQSB4jCB3zBpBggrBgEFBQcwAoZdaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJh
c2ljJTIwSXNzdWluZyUyMENBJTIwNEEuY3J0MHIGCCsGAQUFBzAChmZodHRwOi8vY2VydGlmaWNh
dGVzLmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIw
QmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjA0QS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQB
gjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsGA1UdEQRU
MFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tgR9wZXRl
ci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQDP4L0gv03sv1PN
XSIPEHQCFZIKC/1T5wPd1EUaFejmnduTD7WcCO61zsMsOPvYTjyrU5f1DYCiV5CUoN0kNdsrOy++
hWplJlk4TOjQFwzgkuouexNWINAICF7WlH3eMMbM+Fo9GC4K+O4w+KRpSVzR815N8B+YBv4SByIY
N+Pnkwnxiq5KaD20gJ6EPsgGCos4Ccu4yWVgXrl6jpcjS8ViOU1jPF0PguQ8BftdfUUrprELUiVo
4RC8q1B/7Yp17tYjIeO7Tb2abzTKp98dXU6agYSK/JNUq2iBhKb5aE+LrlGRTcqC+ioRe1N1D/wX
1Z2L0MEmNIg/Xf5DVdTUCOzBMYICDjCCAgoCAQEwgYcweTELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
AkNBMRQwEgYDVQQHEwtTYW50YSBDbGFyYTEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgNEECCnfQGsYAAAAARQwwCQYF
Kw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE0MDIx
ODE5NTQxOVowIwYJKoZIhvcNAQkEMRYEFOH+JvmCutq5nvtgq0XojdvUK+8uMA0GCSqGSIb3DQEB
AQUABIIBAKSBcaorSXJEQTUGB1aUF4lRJfzElTu6/tlRWnRkzh24IybrpY+hakzOzzRHV0lRbJYe
GsjMGfc4ns61KYCxgLJkCB8lYYGvHNFPf7mqd8mZ4KAdRFxA34g4pemOt9FvrJj4iQjRasDEC30A
oWT1WHYP1JBllBYZ5snMhm6HcAlUNUC/hDJi5uUqsRzETJZMlHH427kyPreUBctinxqwDs/Qg/KO
sG+BP89wex/W5lSerI3X/P2ka2IiYcNnuTzXg73ycvCrfnyLlPjdiCpwCLq27kd99pL+KS7QaZrr
ohvnn8+HI12Pz8nCoMQFbhv15+j9RSnHoaw/xaA221fqyU4AAAAAAAA=


--=-0niHBq5WxlLXsjMfHug1--

--===============2003142017882872676==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2003142017882872676==--
